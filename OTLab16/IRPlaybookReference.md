# IR Playbook Reference — NIST-aligned Incident Response for OT

> Lookup card for OTLab16. Keep it open in another tab while you work the incident.
> It condenses the NIST incident-response lifecycle, the OT-specific rules of
> engagement, a severity matrix, and the containment/verification recipes used in
> the tasks. Companion file: `PurdueModelReference.md` (architecture).

---

## 1. The lifecycle — NIST SP 800-61r3 / CSF 2.0

OTLab16 uses the **Rev 3** framing of *Computer Security Incident Handling*, which
maps the lifecycle onto the **CSF 2.0 functions** instead of the older four-phase
loop.

| CSF 2.0 function | Role in this lab                                     | When                 |
|------------------|------------------------------------------------------|----------------------|
| **Govern**       | Roles, authority to act, who signs the all-clear     | Preparation (before) |
| **Identify**     | Asset inventory mapped to Purdue levels (Labs 14/15) | Preparation (before) |
| **Protect**      | The OTLab15 detectors/allowlists already in place    | Preparation (before) |
| **Detect**       | Triage the `notice.log`; declare the incident        | During               |
| **Respond**      | Timeline, containment, eradication                   | During               |
| **Recover**      | Restore the monitored process; baseline check        | During / after       |
| **Improve**      | Lessons learned; feed fixes back to the baseline     | After                |

> [!NOTE]
> **Relation to SP 800-61r2.** The classic r2 loop — *Preparation → Detection &
> Analysis → Containment, Eradication & Recovery → Post-Incident Activity* — still
> maps cleanly: Preparation = *Govern/Identify/Protect*; Detection & Analysis =
> *Detect*; Containment/Eradication/Recovery = *Respond/Recover*; Post-Incident =
> *Improve*. Use whichever vocabulary your report template expects.

## 2. What is different about IR in OT (NIST SP 800-82)

SP 800-82 (*Guide to OT Security*) inverts some IT reflexes. The priority order in
OT is **Safety → Availability → Integrity → Confidentiality** — the mirror image of
the IT C-I-A default.

- **Do not "pull the plug".** Disconnecting or rebooting a controller can trip a
  physical process. Availability of the control loop is itself a safety control.
- **Contain surgically.** Preserve the legitimate process traffic (the
  master↔outstation poll) while cutting the adversary. Blanket isolation is an
  outage, not a response.
- **Field devices cannot be patched on demand.** Eradication on L0–L1 often means
  *cutting reach now* and scheduling the fix for a maintenance window.
- **Coordinate with operations/engineering.** No containment or recovery action
  goes ahead without the operations authoriser named during Preparation.
- **Recovery = the process is verified normal**, not merely that the malware is
  gone. Telemetry must be back in its known-good range.

## 3. Severity / escalation matrix (OT-weighted)

Rank by impact on the **process**, not on data. Pick the highest row that applies.

| Severity     | Safety / Availability impact                         | Example in this lab                           |
|--------------|------------------------------------------------------|-----------------------------------------------|
| **Critical** | Manipulation of a field device / breaker plausible   | Spoofed control toward the L1 outstation      |
| **High**     | Adversary has a reachable path into OT (L0–L2)       | Attacker traffic crossing the corp→OT conduit |
| **Medium**   | Recon/fingerprinting inside OT, no control yet       | Unexpected function codes in `dnp3.log`       |
| **Low**      | Activity confined to IT/L3.5, no OT reach            | Scan that never leaves the corp segment       |

## 4. Incident checklist (map to the 7 lab actions)

- [ ] **Identify** — assets placed on Purdue levels; ops contact named *(Action 1)*
- [ ] **Detect** — `notice.log` triaged; incident declared with scope + Purdue levels *(Action 2)*
- [ ] **Respond** — timeline rebuilt; abused conduit named *(Action 3)*
- [ ] **Respond** — conduit cut surgically; verified poll still flows *(Action 4)*
- [ ] **Respond** — foothold eradicated; initial vector closed *(Action 5)*
- [ ] **Recover** — baseline check passes; ops authorises all-clear *(Action 6)*
- [ ] **Improve** — post-incident report; architecture recommendation *(Action 7)*

## 5. Containment recipe (surgical, not blanket)

The legitimate master lives on the **corp** segment (`192.168.21.20`) and its poll
crosses into OT through the dual-homed EWS. So you **cannot** drop corp→OT wholesale
— that kills the process. Drop **only the attacker**, and apply it where the traffic
is actually routed: the **EWS's own `FORWARD` chain** (the EWS is the conduit). The
rule goes at the top so it wins over the forwarding rules:

```bash
# Applied automatically by ./OTLab16.sh -contain :
docker exec otlab-student iptables -I FORWARD 1 -s 192.168.21.30 -d 192.168.20.0/24 -j DROP
# Lift it with ./OTLab16.sh -restore :
docker exec otlab-student iptables -D FORWARD     -s 192.168.21.30 -d 192.168.20.0/24 -j DROP
```

> [!NOTE]
> **Why the EWS and not the host?** Every corp↔OT packet is routed by the dual-homed
> EWS (`ip_forward=1`), so its `FORWARD` chain is the real chokepoint — and it behaves
> the same on WSL2, native Linux, and macOS, with no host `sudo`. A DROP in the host
> `DOCKER-USER` chain does **not** work under WSL2: inter-bridge traffic is L2-switched
> and, with `bridge-nf-call-iptables=0` (set so cross-bridge routing works at all),
> never traverses the host netfilter — so such a rule is silently inert.

> Check the rule is in place and catching packets:
> ```bash
> docker exec otlab-student iptables -L FORWARD -n -v --line-numbers | grep 21.30
> ```

## 6. Verification recipe (Zeek)

After containment, prove **both** halves of the OT trade-off from the EWS:

```bash
# (a) Attacker is cut — its IP should no longer appear talking to OT:
cat conn.log | zeek-cut id.orig_h id.resp_h service | sort -u
#   -> the 192.168.21.30 -> 192.168.20.10 row is GONE

# (b) Process still runs — master keeps polling the outstation:
cat dnp3.log | zeek-cut ts id.orig_h id.resp_h fc_request | sort | tail
#   -> 192.168.21.20 -> 192.168.20.10 polls continue (~10 s cadence)

# (c) All-clear — no new notices after restore:
cat notice.log | zeek-cut ts note src 2>/dev/null
#   -> empty / no new rows
```

All-clear (Action 6) is signed off only when: clean `notice.log`, endpoints and
function codes inside the OTLab14 allowlists, and telemetry in range
(**110–130 V**, **0.5–15 A**, breaker toggling on its ~100 s cadence).
