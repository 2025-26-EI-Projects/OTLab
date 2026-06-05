# OTLab15 — DNP3 + Zeek Detection Lab

![](https://raw.githubusercontent.com/substationworm/OTLab/main/OTLab-SecondHeader.png "OTLab15 — DNP3 + Zeek Detection Lab")

[![Curriculum Lattes](https://img.shields.io/badge/Lattes-white)](http://lattes.cnpq.br/8846358506427099)
[![ORCID](https://img.shields.io/badge/ORCID-grey)](https://orcid.org/0000-0002-6254-7306)
[![SciProfiles](https://img.shields.io/badge/SciProfiles-black)](https://sciprofiles.com/profile/lffreitas-gutierres)
[![Scopus](https://img.shields.io/badge/Scopus-white)](https://www.scopus.com/authid/detail.uri?authorId=57195542368)
[![Web of Science](https://img.shields.io/badge/ResearcherID-grey)](https://www.webofscience.com/wos/author/record/Q-8444-2016)
[![substationworm](https://img.shields.io/badge/substationworm-black)](https://github.com/substationworm)
[![LFFreitasGutierres](https://img.shields.io/badge/LFFreitasGutierres-white)](https://github.com/LFFreitas-Gutierres)

[![GitHub fariasrafael10](https://img.shields.io/badge/GitHub-fariasrafael10-black)](https://github.com/fariasrafael10)
[![LinkedIn Farias Rafael](https://img.shields.io/badge/LinkedIn-Farias_Rafael-blue)](https://www.linkedin.com/in/farias-rafael/)
[![IPLeiria ESTG-DEI](https://img.shields.io/badge/IPLeiria-ESTG--DEI-green)](https://www.ipleiria.pt/estg-dei/)

## Scenario

The same small utility from OTLab14 is now worried. After your Wireshark write-up showed that DNP3 carries no authentication, no encryption, and a stable, predictable conversation pattern, the company asks the obvious follow-up: **if anything unusual happened on this wire, would we even notice?**

The question is not academic. Last Tuesday, **Maria from the Finance department** picked up a USB stick she found in the visitor parking lot and — meaning no harm — plugged it into her workstation to see who it belonged to. The malware on it phoned home and parked itself on her PC. From there it has a clean line of sight to the corporate segment, and this segment shares a host with the OT engineering workstation. Nobody noticed.

You — still at the **(`otlab-student`)** dual-homed between OT and corporate — will introduce **Zeek**, a network security monitoring tool, into the same topology. Your job is *not* to write signature rules for known attacks. It is to translate the **baseline you documented in OTLab14** into a small set of allowlists, let Zeek tell you whenever the wire deviates from that baseline, and learn — by trying them — what kinds of OT-adversary behaviour those deviations actually look like.

From the compromised host you will fire controlled attack scenarios 'for' actor; and from inside the otlab-student you will catch them with Zeek scripts you write yourself.

> [!NOTE]
> **OTLab14 deliverable is the input here.** Keep your OTLab14 findings open: the expected endpoints, function codes, and link-layer addresses you documented there are exactly what you will encode as Zeek allowlists.

> [!NOTE]
> Refer to `DNP3WiresharkReference.md` for DNP3 frame layout and function-code tables as before. For Zeek-specific events, log fields, and `zeek-cut` recipes, see the companion `DNP3LabZeekReference.md` in this lab's directory.

## 📝 Tasks

> [!WARNING]
> All tasks are conducted inside the lab containers. **Do not run any attack scenario, scanner, or capture against hosts outside this lab.** The attack scripts under `scripts/attacks/` emit real, valid DNP3 PDUs; pointed at production gear they can disrupt real industrial processes.

### Phase 0 — Orientation

- [ ] Bring the lab up with `./OTLab15.sh -start` and confirm all **four** containers are running with `./OTLab15.sh -status`. Identify which container plays each role.
    - *Hint: outstation, master, otlab-student, and the new role unique to OTLab15 — {xxxxxxxx}.*

- [ ] Open a shell in the otlab-student with `./OTLab15.sh -run`. Verify your two interfaces and confirm one foot in each subnet (carry the answer from OTLab14).
    - *Hint: `{xxxx}` faces the corporate segment and `{xxxx}` faces the OT segment.*

- [ ] Confirm Zeek is installed inside the otlab-student. Note the version printed — write it down; it matters for the event names you will use later.
    - *Hint: `zeek -v` should report version `{x.x.x}` or newer.*

### Phase 1 — Zeek on the clean baseline

- [ ] Inside the otlab-student, create a working directory for your captures (e.g. `/root/otlab15/` or under `/opt/zeek-lab/`). Start a Zeek live capture on the **OT-side** interface, let the baseline run for at least 60 seconds (no attacks yet), then stop with Ctrl-C.
    - *Hint: `zeek -C -i {xxxx} local` runs Zeek with the default local policy.*

- [ ] List the log files Zeek produced. For each of the three logs below, follow the link to the official Zeek docs and write one sentence describing what it records.
    - [`conn.log`](https://docs.zeek.org/en/master/logs/conn.html) — *what level of detail?*
    - [`dnp3.log`](https://docs.zeek.org/en/master/scripts/base/protocols/dnp3/main.zeek.html) — *what fields does it carry that `conn.log` does not?*
    - [`notice.log`](https://docs.zeek.org/en/master/frameworks/notice.html) — *present? Why or why not on a clean baseline?*
    - *Hint: Zeek defaults to TSV. For a JSON-friendly view that pipes cleanly into `jq`, restart with `zeek -C LogAscii::use_json=T -i {xxxx} local` (e.g. `jq -c '{ts, id, service}' < conn.log`).*

- [ ] Use `zeek-cut` on the baseline `conn.log` to list every unique pair of `id.orig_h` / `id.resp_h` you saw talking on port `20000/tcp`. Compare against the endpoints you documented in OTLab14 — they must match.
    - *Hint: `cat conn.log | zeek-cut id.orig_h id.resp_h service | sort -u`. Filter for service `{xxxx_xxx}`.*

- [ ] Use `zeek-cut` on the baseline `dnp3.log` to list every unique value of `fc_request` and `fc_reply`. **You will see more function codes than your OTLab14 write-up mentioned** — investigate why before continuing.
    - *Hint: in the steady state your OTLab14 documented `{0xXX RxxD}` and `{0xXX RxxxxxxE}`. The two extra ones in the baseline are `{0xXX CxxxxxM}` and `{0xXX UNSOLICITED_xxxxxxxE}` — the outstation publishes events the master did not poll for, and the master acknowledges them.*

- [ ] Record your **baseline allowlists** as a short note, then open `scripts/zeek/baseline.zeek` and transfer the note into the `&redef` constants. Empty allowlists make every detector in Phase 2 fire on every packet (`!in {}` is always true) — filling them in is what gives Phase 2 a clean signal to compare against. (`link_addr_to_ip` is encoded later, in cycle 2.3.)
    - `expected_endpoints` — *the two IPs from OTLab14*
    - `expected_func_codes` — *the four codes you just observed.*

### Phase 2 — The fire-detect cycle

> [!NOTE]
> Every cycle below shares the same shape: **(a)** fire an attack scenario from the host with `./OTLab15.sh -attack <name>`, **(b)** observe the deviation in raw Zeek logs without your own detection script, **(c)** write a Zeek detector that turns that deviation into a `Notice`, **(d)** replay the attack and verify your detector lit up `notice.log`. Stop the Zeek capture between iterations so each round produces a clean log set.
>


#### 2.1 Cycle: `scan` → `unknown-endpoint.zeek`

- [ ] From a **second terminal on the host** (not inside the otlab-student), fire `./OTLab15.sh -attack scan` while a fresh Zeek live capture is running on the corp-side interface of the ews.

- [ ] Inspect `conn.log` after the attack. Find the rows that did not exist in the baseline. Document the deviating `id.orig_h`, the destination port, the connection states (`conn_state`), and roughly how many flows you saw.
    - *Hint: there will be many flows in states meaning SYNs that never carried application data.*

- [ ] Write `scripts/zeek/detectors/unknown-endpoint.zeek` that emits a `Notice` whenever a `dnp3_application_request_header` or `dnp3_application_response_header` fires on a connection where `orig_h` or `resp_h` is outside your `expected_endpoints` set. Replay `-attack scan` with your script loaded (`zeek -i <iface> /opt/zeek-lab/local.zeek` after `@load`-ing your detector). Confirm `notice.log` shows your alert.
    - *Hint: the simplest detector uses the connection events, not `conn.log`. A nice extension: also alert on plain TCP connections to `{xxxxx}/tcp` from an unknown source (catches `scan` even before any DNP3 PDU is sent).*

#### 2.2 Cycle: `fingerprint` → `unexpected-function-code.zeek`

- [ ] Fire `./OTLab15.sh -attack fingerprint`. Inspect the new `fc_request` values in `dnp3.log` against your `expected_func_codes` allowlist.
    - *Hint: at least one of the new function codes will be `{0xXX DELAY_MEASURE}`. Why is a master measuring round-trip delay unusual once steady-state polling has settled?*

- [ ] Write `scripts/zeek/detectors/unexpected-function-code.zeek`. Hook `dnp3_application_request_header(c, is_orig, application, fc)` for the request direction and `dnp3_application_response_header(c, is_orig, application, fc, iin)` for responses. Emit a `Notice` when `fc` is outside the allowlist.

- [ ] Replay `-attack fingerprint`. Note in your write-up which probes fired the detector — and which did **not**, and why.

#### 2.3 Cycle: `spoof` → `link-vs-ip-mismatch.zeek`

- [ ] Fire `./OTLab15.sh -attack spoof`. This sends a **single** READ to the outstation — almost nothing visible in `dnp3.log` row count, but the link-layer telltale is there.

- [ ] Hook `dnp3_header_block(c, is_orig, len, ctrl, dest_addr, src_addr)`. This event surfaces the link-layer source/destination addresses, which `dnp3.log` does not record. From `c$id$orig_h`/`c$id$resp_h` you also know the **IP** that emitted the frame.
    - *Hint: the OTLab14 mapping is `link addr {1} ↔ outstation IP` and `link addr {2} ↔ master IP`. Encode that as a `table[count] of addr` in `baseline.zeek`.*

- [ ] Write `scripts/zeek/detectors/link-vs-ip-mismatch.zeek` that cross-checks the link source address against the expected IP for that link address, picking the right side via `is_orig`. Emit a `Notice` on mismatch.

- [ ] Replay `-attack spoof` and confirm the detector fires. As a sanity check, re-fire `fingerprint` with this detector loaded — it **also** trips it, because it uses the legitimate master's link source from the attacker's IP. Discuss in one sentence why this overlap is desirable, not a flaw.

### Phase 3 — Composition and reflection

- [ ] Inspect `scripts/zeek/local.zeek` — it ships pre-wired to `@load` `baseline.zeek` plus all three detector skeletons. Confirm `zeek -C -i <iface> /opt/zeek-lab/local.zeek` starts cleanly with no script errors against the detectors you have implemented.
    - *Hint: detectors you did not touch stay as empty skeletons — Zeek loads them fine, they just don't emit anything.*

- [ ] With the full stack loaded, run the three scenarios back-to-back from the host: `scan`, `fingerprint`, `spoof` (with a short pause between each). Produce a single `notice.log` and extract a timeline of which detector fired when, for which scenario, against which source IP.
    - *Hint: `zeek-cut ts note src | sort` is enough to draft the timeline.*

- [ ] Write a **one-page incident summary** structured as: (a) the attack scenarios you ran, in plain language, (b) the IOCs you would put in a SIEM rule for each, (c) which OTLab14 baseline fact each detector consumed, (d) what an attacker would have to do to evade your stack and stay under each allowlist. **This document is the input for OTLab16.**

- [ ] Reflection paragraph (no checkbox required): in your write-up, argue briefly why allowlist-based, behavioural detection is a good fit for OT environments — and where it would break in IT environments. Reference the actual vocabulary size, baseline stability, and predictability you observed.

## 🎯 Skills

**Hands-on:** Network Security Monitoring (Zeek) · Behavioural / Allowlist Detection · DNP3 Log Analysis · Detection Engineering

**Detecting [MITRE ATT&CK for ICS](https://attack.mitre.org/matrices/ics/) techniques:**

[![T0846 Remote System Discovery](https://img.shields.io/badge/ATT%26CK_ICS-T0846_Remote_System_Discovery-red)](https://attack.mitre.org/techniques/T0846/)
[![T0888 Remote System Information Discovery](https://img.shields.io/badge/ATT%26CK_ICS-T0888_Remote_System_Information_Discovery-red)](https://attack.mitre.org/techniques/T0888/)
[![T0855 Unauthorized Command Message](https://img.shields.io/badge/ATT%26CK_ICS-T0855_Unauthorized_Command_Message-red)](https://attack.mitre.org/techniques/T0855/)

## 🔖 Nomenclature

- DNP3: Distributed Network Protocol version 3 — SCADA protocol widely used in electric, water, and oil & gas utilities.
- EWS: Engineering workstation — the host operated by control engineers to configure, program, and monitor field devices.
- ICS: Industrial control system.
- IOC: Indicator of compromise — an observable network or host artefact that suggests an intrusion.
- IP: Internet protocol.
- NSM: Network security monitoring — passive observation of traffic for forensic and detection purposes; Zeek is an NSM tool.
- OT: Operational technology.
- PDU: Protocol data unit — one "message" at a given protocol layer (e.g. a DNP3 application fragment).
- PLC: Programmable logic controller.
- RTU: Remote terminal unit — the field device role typically played by a DNP3 outstation.
- SCADA: Supervisory control and data acquisition.
- TCP: Transmission control protocol.
- Zeek: Open-source NSM platform (formerly Bro). Parses protocols into structured logs and exposes a scripting language for detection.

## 🛠️ Usage

```
Usage: ./OTLab15.sh -start [kali|ubuntu] | -stop | -clean | -run | -restart | -status | -attack <scenario>

  -start     Start the DNP3_Zeek environment using the specified distro (default: ubuntu)
             Valid options: kali (rolling) or ubuntu (22.04)
  -run       Open a terminal inside the otlab-student container
  -clean     Remove containers, volumes, and network (keeps host-side ./scripts/attacks and ./scripts/zeek)
  -stop      Stop all containers
  -restart   Restart previously stopped containers
  -status    Show current containers status
  -attack    Fire a controlled attack scenario from dnp3-attacker
             Valid scenarios: scan fingerprint spoof
```

> [!NOTE]
> When run on **WSL2**, the script auto-detects the environment and applies the kernel-level rules (`bridge-nf-call-iptables=0` and two `DOCKER-USER` ACCEPT rules) needed for traffic to be routed across the two Docker bridges. These rules require `sudo` and are reverted on `-clean`. On native Linux and macOS Docker Desktop the rules are skipped — Docker's defaults already allow the cross-bridge forwarding.

---

## Solutions

`scripts/zeek/` ships what the student works on: `baseline.zeek` with empty
allowlists to fill from OTLab14, and three detector skeletons (header comment +
commented event signature, empty body). `local.zeek` is pre-wired to `@load`
all of them, so an untouched skeleton loads cleanly and simply emits nothing.

Worked reference answers for every task live in `scripts/solutions/` — a filled
`baseline.zeek` and all three detectors implemented. It is the instructor key and
is **not** mounted into the EWS (there, `/opt/zeek-lab` is `scripts/zeek/`); see
`scripts/solutions/README.md` to copy it in for verification.
