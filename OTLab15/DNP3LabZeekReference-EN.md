# DNP3 Lab — Zeek Reference

## 1. What this document is

Three things, in order of how often you'll reach for each:

1. **Zeek essentials** (§2) — the minimum vocabulary you need to read the events firing in `dnp3.log` and write the detectors `local.zeek` is wired to load.
2. **One fully worked detector** (§3) — `unknown-endpoint.zeek` from end to end, with every non-obvious line annotated. Use as the template for your own.
3. **Pattern sketches** (§4) — for the remaining core detectors (`unexpected-function-code.zeek`, `link-vs-ip-mismatch.zeek`), the Zeek event surface to hook plus the key idiom, with the actual handler body left for you to fill.

## 2. Zeek essentials for OTLab15

### 2.1 The event-driven execution model

Zeek scripts are **event handlers**. You don't write a `main`; you write functions that fire when Zeek's protocol analysers parse something out of the packet stream. The DNP3 events you will meet in this lab are:

| Event                                                                          | Fires when                                                |
| ------------------------------------------------------------------------------ | --------------------------------------------------------- |
| `new_connection(c)`                                                            | Zeek sees the first packet of any new TCP/UDP flow        |
| `dnp3_application_request_header(c, is_orig, application, fc)`                 | DNP3 analyser parses a request header                     |
| `dnp3_application_response_header(c, is_orig, application, fc, iin)`           | DNP3 analyser parses a response header                    |
| `dnp3_header_block(c, is_orig, len, ctrl, dest_addr, src_addr)`                | Every DNP3 link-layer header — exposes the link addresses |

Every one of them carries a `c: connection` as the first parameter — see §2.2. Multiple handlers may subscribe to the same event; Zeek runs them all in registration order. Order is rarely something you need to care about.

### 2.2 The `connection` record

Most fields you'll touch live under `c$id`:

```zeek
c$id$orig_h     # addr — IP that opened the TCP connection
c$id$resp_h     # addr — IP that answered
c$id$orig_p     # port — source port (e.g., 54321/tcp)
c$id$resp_p     # port — destination port (e.g., 20000/tcp)
c$uid           # string — unique connection id, used across all logs
```

Note the dollar-sign accessor: Zeek records are `c$field`, not `c.field`.

`c$id$resp_p == 20000/tcp` is how you check the destination port is DNP3. The literal `20000/tcp` is a `port` value, not an integer — Zeek's type system tags ports with their transport so `20000/tcp != 20000/udp`.

### 2.3 Sets, tables, and the `in` / `!in` operators

The whole baseline-allowlist machinery rests on two collection types:

```zeek
# A set of addresses (no duplicates, no ordering).
const expected_endpoints: set[addr] = { 192.168.20.10, 192.168.21.20 } &redef;

# A table mapping link address → expected IP.
const link_addr_to_ip: table[count] of addr = {
    [1] = 192.168.20.10,
    [2] = 192.168.21.20,
} &redef;
```

Membership tests are infix:

```zeek
if ( my_ip !in expected_endpoints )    { ... }   # IP not in the allowlist
if ( link_addr in link_addr_to_ip )    { ... }   # link addr is known
```

Table lookup is `t[k]`, identical to most languages. `&redef` makes the constant overridable from another script (handy when `local.zeek` decides to widen the allowlist for a specific run without editing `baseline.zeek`).

### 2.4 Modules and namespacing

Every detector in this lab belongs to either `DNP3Baseline` (the allowlists in `baseline.zeek`) or `DNP3Anomaly` (the notices the detectors raise). To put a declaration in a module, start the file with `module X;`:

```zeek
module DNP3Anomaly;

export {
    # exported declarations — visible as DNP3Anomaly::Foo from outside
}
```

References across modules use `Module::name`:

```zeek
if ( c$id$orig_h !in DNP3Baseline::expected_endpoints ) { ... }
```

Why one shared `DNP3Anomaly` module across three detectors instead of three separate modules? Because all the notices belong to one logical family — the namespace `DNP3Anomaly::Unknown_Endpoint`, `DNP3Anomaly::Unexpected_Function_Code`, ... reads better in `notice.log` than `UnknownEndpoint::Note`, `UnexpectedFC::Note`, ...

### 2.5 The Notice framework

Raising an alert is one function call:

```zeek
NOTICE([$note = DNP3Anomaly::Unknown_Endpoint,
        $msg  = "DNP3 endpoint outside expected set",
        $conn = c]);
```

Key conventions:

- `$note` — an enum value you declared with `redef enum Notice::Type += { Foo };` inside an `export {}` block.
- `$msg` — free-form human-readable string. Use `fmt(...)` for formatting (like `printf`); `%s` works for both `addr` and `string`, `%d` for `count`.
- `$conn = c` — passes the whole connection in. The Notice framework then auto-fills `id.orig_h`, `id.resp_h`, `uid`, and the timestamp in `notice.log`. Without `$conn`, you would have to set `$src` and `$dst` by hand.

Suppression is automatic: Zeek's default is to silence duplicate notices (same `note`, same `src`, same `dst`) for one hour. A `scan` attack with 1024 SYNs from one IP produces exactly one `Unknown_Endpoint` notice, not 1024. You almost never need to override this.

## 3. Worked example — `unknown-endpoint.zeek`

The full file:

```zeek
##! Notice when a DNP3 conversation involves an endpoint outside
##! DNP3Baseline::expected_endpoints.
##!
##! References:
##!   - DNP3 events:      https://docs.zeek.org/en/master/scripts/base/bif/plugins/Zeek_DNP3.events.bif.zeek.html
##!   - Notice framework: https://docs.zeek.org/en/master/frameworks/notice.html

@load ../baseline.zeek

module DNP3Anomaly;

export {
    redef enum Notice::Type += {
        ## A DNP3 request or response was seen with an endpoint not in
        ## DNP3Baseline::expected_endpoints.
        Unknown_Endpoint,
    };
}

# Shared check. c$id$orig_h is the IP that opened the TCP connection;
# c$id$resp_h is the side that answered. Either being outside the allowlist
# is enough to flag the whole flow. `kind` is just the word ("request" /
# "response") that ends up in the notice, so request and response can share
# one body instead of two near-identical copies.
function check_endpoints(c: connection, kind: string, fc: count)
    {
    local o = c$id$orig_h;
    local r = c$id$resp_h;

    if ( o !in DNP3Baseline::expected_endpoints ||
         r !in DNP3Baseline::expected_endpoints )
        NOTICE([$note = Unknown_Endpoint,
                $msg  = fmt("DNP3 %s on flow %s -> %s (fc=%d): endpoint outside expected set",
                            kind, o, r, fc),
                $conn = c]);
    }

# Request side.
event dnp3_application_request_header(c: connection, is_orig: bool,
                                       application: count, fc: count)
    {
    check_endpoints(c, "request", fc);
    }

# Response side — same check, different event. We must cover both because the
# DNP3 spec lets the outstation publish unsolicited responses; a spoofed one
# would otherwise slip through.
event dnp3_application_response_header(c: connection, is_orig: bool,
                                        application: count, fc: count, iin: count)
    {
    check_endpoints(c, "response", fc);
    }
```

### Walkthrough — the four lines that matter

1. **`@load ../baseline.zeek`** — pulls in the allowlist constants. Without this, `DNP3Baseline::expected_endpoints` is unresolved and Zeek refuses to start.
2. **`module DNP3Anomaly; export { redef enum Notice::Type += { ... } }`** — adds a new value to the global `Notice::Type` enum. The `export` block is necessary for the enum value to be visible outside the module (so `notice.log` can label rows with it).
3. **`o !in DNP3Baseline::expected_endpoints || r !in ...`** — set-membership check. Either side outside is enough to flag the conversation. Using `local` bindings (`o`, `r`) avoids repeating `c$id$orig_h` and makes the `fmt` arguments shorter.
4. **`function check_endpoints(c, kind, fc)`** — the request and response events carry the *same* check, so the body lives in one helper and each handler is a single call. `kind` is the only thing that differs (the word in the notice), passed in as a `string`. One place to fix if the rule changes — no copy to drift out of sync.
5. **`NOTICE([$note=..., $msg=..., $conn=c])`** — record-literal construction passed to a function. `$conn=c` is the auto-fill trick from §2.5.

### Stretch — catching `scan` before any DNP3 PDU is parsed

The `scan` attack rains TCP SYNs on port 20000. The handshake never completes, so no `dnp3_application_request_header` ever fires — and the detector above stays silent during pure scanning. To catch those, subscribe to `new_connection` and flag any flow with `c$id$resp_p == 20000/tcp` whose `orig_h` is outside the allowlist. Two events, one detector, full coverage. Left as exercise.

## 4. Pattern sketches for the other core cycles

### 4.1 `unexpected-function-code.zeek` (fingerprint cycle)

**Event surface.** Same two events as §3: `dnp3_application_request_header` exposes `fc: count` directly; `dnp3_application_response_header` does too.

**Where the pattern bites.** `fc_request` in `dnp3.log` is the textual name (`READ`, `RESPONSE`, ...). `fc` in the event is the numeric code. Your allowlist must use the numbers (0x01, 0x81, 0x00, 0x82) — see the hint in `baseline.zeek`.

**Edge case.** Zeek's binpac parser may skip the request event for unassigned function codes. The response side still fires with an `iin` error reply — that's your fallback signal. See the hint in OTLab15.md task 2.2.

### 4.2 `link-vs-ip-mismatch.zeek` (spoof cycle)

**Event surface.** `dnp3_header_block` — Zeek surfaces the DNP3 link-layer source and destination addresses, which never appear in `dnp3.log`. This is the only way to cross-check the link-layer identity against the IP carrying the frame.

**Why the `is_orig` branch matters.** A DNP3 frame can come from either side of the TCP connection. `is_orig=T` means the originator sent the frame, so the link source maps to `c$id$orig_h`. `is_orig=F` flips it. Skipping this branch produces false positives on every legitimate response.

## 5. `zeek-cut` and JSON recipes

`zeek-cut` extracts named columns from Zeek's default TSV logs. The `-d` flag rewrites `ts` from epoch to ISO 8601. Pipe to `column -t -s $'\t'` for aligned output.

```bash
# notice.log — the detector outputs
zeek-cut -d ts note src dst msg < notice.log | column -t -s $'\t'

# conn.log — every flow Zeek saw, with the DPD service name
zeek-cut -d ts uid id.orig_h id.resp_h id.resp_p proto service conn_state < conn.log

# dnp3.log — DNP3 function codes on the wire
zeek-cut -d ts uid id.orig_h id.resp_h fc_request fc_reply < dnp3.log

# Unique note types fired in a run (sanity check)
zeek-cut note < notice.log | sort -u
```

If you prefer JSON, restart Zeek with the JSON LogAscii flag and use `jq`:

```bash
zeek -C LogAscii::use_json=T -i eth1 /opt/zeek-lab/local.zeek
jq -c '{ts, note, src, dst, msg}' < notice.log
```

## 6. Official Zeek docs

- [conn.log](https://docs.zeek.org/en/master/logs/conn.html) — fields and connection states
- [dnp3.log fields](https://docs.zeek.org/en/master/scripts/base/protocols/dnp3/main.zeek.html) — `DNP3::Info` record definition
- [DNP3 events](https://docs.zeek.org/en/master/scripts/base/bif/plugins/Zeek_DNP3.events.bif.zeek.html) — every `dnp3_*` event signature
- [Notice framework](https://docs.zeek.org/en/master/frameworks/notice.html) — `Notice::Info`, `Notice::policy`, suppression
- [Scripting language reference](https://docs.zeek.org/en/master/script-reference/index.html) — types, operators, records, `&redef`
