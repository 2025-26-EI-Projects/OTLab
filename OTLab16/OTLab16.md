# OTLab16 — DNP3 + Incident Response Lab

![](https://raw.githubusercontent.com/substationworm/OTLab/main/OTLab-SecondHeader.png "OTLab16 — DNP3 + Incident Response Lab")

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

This is the **third and final lab** in the substation story. In OTLab14 you read DNP3 off the wire with Wireshark and wrote down the baseline. In OTLab15 you turned that baseline into Zeek allowlists and built behavioural detectors — and the last thing you produced was a `notice.log` and a one-page incident summary.

**This time the alarm is real.** The `notice.log` is no longer a classroom artefact: it is the **detection that opens a live incident**. The intrusion that started when **Maria from Finance** plugged in the parking-lot USB has worked its way through the corporate segment and is now probing — and spoofing — into OT, where a real feeder breaker can be flipped. You stop being the detection engineer and become the **incident responder**.

You will work the incident through the **[NIST SP 800-61r3](https://csrc.nist.gov/pubs/sp/800/61/r3/final)** lifecycle, expressed as the **[CSF 2.0](https://csrc.nist.gov/pubs/cswp/29/the-nist-cybersecurity-framework-csf-20/final) functions**: *Govern · Identify · Protect* as **Preparation**, then *Detect · Respond · Recover* as the live **Incident Response**, closing with *Improve*. For the OT angle you will lean on **[NIST SP 800-82](https://csrc.nist.gov/pubs/sp/800/82/r3/final)** (Guide to OT Security).

The single most important lesson of this lab: **in OT, incident response is not "pull the plug".** There are *safety* and *availability* to protect — the legitimate master↔outstation polling **must keep running** while you eject the attacker. That trade-off is what makes OT IR different from IT IR, and it is the thread that runs through every task below.

> [!NOTE]
> **The OTLab15 deliverable is the input here.** Keep your OTLab15 `notice.log` and one-page incident summary open — they are what *triggers* this incident. Keep the OTLab14 baseline open too (endpoints, function codes, value ranges); you will use it again to declare the all-clear.

> [!NOTE]
> Two companions live in this lab's directory. `IRPlaybookReference.md` summarises the [NIST SP 800-61r3](https://csrc.nist.gov/pubs/sp/800/61/r3/final) / [800-82](https://csrc.nist.gov/pubs/sp/800/82/r3/final) lifecycle, the OT severity matrix, and the containment/verification recipes. `PurdueModelReference.md` is the visual heart of the lab — the *current (insecure)* vs *target (hardened)* architecture. Record your work in `IR_Template.md` (three artefacts: running log, containment decision record, incident report).

## 📝 Tasks

> [!WARNING]
> All tasks are conducted inside the lab containers. **Do not run any attack scenario, scanner, or containment rule against hosts outside this lab.** `-incident` emits real, valid DNP3 PDUs and `-contain` edits host firewall rules; pointed at production gear they can disrupt real industrial processes.

The seven actions below are each tagged with its CSF 2.0 function and the Purdue overlay it exercises.

### Preparation — `Govern` · `Identify`  *(optional, do once)*

- [ ] **Action 1 — Map the estate to Purdue, before the incident.** Bring the lab up with `./OTLab16.sh -start` and `-status` (the four OTLab15 containers return). Using `PurdueModelReference.md`, place every host from Labs 14/15 on a Purdue level and write it into the header of **Artifact 1** (running log). Name the **operations contact / authoriser** now — the person you must call before you cut anything.
    - *Hint: the outstation/RTU is L`{x}`, the master is L`{x}`, the EWS is the L`{x.x}` boundary host, and the breaker is L`{x}`. The IR plan must name an ops contact `{before|after}` the incident, not during it.*

### Detect

> [!NOTE]
> **Open the incident live — start the sensor first.** The EWS only records the attack if Zeek is already capturing when it lands. Enter the EWS with `./OTLab16.sh -run`, find its interfaces with `ip -br a`, then start the ready policy in a working directory and leave it running:
> ```
> mkdir -p ~/ir && cd ~/ir
> zeek -i <iface> /opt/zeek-lab/local.zeek
> ```
> The OT-facing link (`192.168.20.100`) is the one that carries the spoof down to L1. With Zeek capturing, open a **second terminal on the host** and fire the kill-chain:
> ```
> ./OTLab16.sh -incident
> ```
> When it finishes, stop Zeek with `Ctrl+C`; `conn.log`, `dnp3.log` and `notice.log` are waiting in `~/ir` — that is the detection that opens this incident. *(Rather reuse the `notice.log` you produced in OTLab15? Skip `-incident` and point the triage below at that file instead.)*

- [ ] **Action 2 — Triage and declare.** Open the `notice.log` you just generated with `-incident` (or reuse your OTLab15 one). Decide: real incident or false positive? Justify with `conn.log`/`dnp3.log` evidence. Then **declare the incident** — state the scope and **which Purdue level(s) are affected**. In OT the question is not "what data leaked" but **what process is at risk**.
    - *Hint: a single spoofed READ that reaches the L`{x}` outstation is more serious than a noisy scan that never leaves L`{x.x}`. Focus on process impact vs data breached.*

### Respond

- [ ] **Action 3 — Rebuild the timeline and name the conduit.** From the Zeek logs reconstruct an ordered incident timeline (`ts`, source, technique, CSF function) into **Artifact 1**. Identify the **conduit** the attacker is abusing — describe it in Purdue terms.
    - *Hint: `cat notice.log | zeek-cut -u ts note src id.resp_h | sort` drafts the timeline — the `-u` flag renders `ts` as a human-readable UTC timestamp instead of the raw epoch (use `-d` for local time). The abused conduit is the path L`{x.x}`→L`{x}` that the dual-homed EWS bridges — the same one the legitimate master poll uses, which is exactly why you cannot simply block all of it.*

- [ ] **Action 4 — Cut the conduit (isolate, do not shut down).** Run `./OTLab16.sh -contain`. It applies the reference segmentation: a **surgical DROP** of the attacker host into OT, while the sanctioned master→outstation poll keeps flowing. **Verify with Zeek**: the attacker's flows stop *and* `dnp3.log` shows polling continuing within the OTLab14 ranges. Record the decision, the reversibility, and the post-action checks in **Artifact 2** (Containment Decision Record).
    - *Hint: containment inserts `DROP -s {xxx.xxx.xx.xx} -d 192.168.20.0/24` at the top of the EWS `FORWARD` chain — the dual-homed EWS routes all corp↔OT traffic, so its `FORWARD` chain is the real chokepoint. Isolate vs shutdown: the feeder must keep being polled. Confirm with `cat conn.log | zeek-cut id.orig_h id.resp_h service | sort -u` — the `{attacker IP}` row is gone, the `{master IP}` row remains.*

- [ ] **Action 5 — Eradicate the foothold.** Remove the attacker's foothold on the compromised corporate PC and close the initial vector (the USB / the EWS IP-forwarding that let corp reach OT). Note in your log **what you could not patch on demand** and why.
    - *Hint: field devices (the L`{x}` outstation/RTU) can't be patched or rebooted on demand mid-incident — eradication in OT often means cutting reach and scheduling the fix for a maintenance window, not a live reboot.*

### Recover

- [ ] **Action 6 — Run the baseline check (process verified, not just threat gone).** Run `./OTLab16.sh -restore` to return to the clean monitored state, then re-run your Zeek baseline. Recovery is signed off **only** when: `notice.log` shows no new alerts, the endpoints/function codes match the OTLab14 allowlists, and the outstation telemetry is back in range (voltage `{xxx–xxx}` V, current `{x.x–xx}` A).
    - *Hint: "recover" means the **process** is verified normal, not merely that the attacker is gone. Get the ops contact from Action 1 to authorise the all-clear in Artifact 3.*

### Recover · Improve

- [ ] **Action 7 — Write the post-incident report.** Complete **Artifact 3** (Incident Report): executive summary, scope in Purdue terms, timeline summary, **root cause**, attacker actions mapped to **MITRE ATT&CK for ICS**, IOCs you would turn into SIEM rules, response actions tagged by CSF function, what you deliberately did **not** do and why, recovery sign-off, and lessons learned. Your top recommendation should feed back into the architecture: introduce the **IDMZ / segmentation** from `PurdueModelReference.md` so this conduit cannot be abused again. **This document closes the OTLab14/15/16 trilogy.**
    - *Hint: root cause is not "the USB" alone — it is `{USB}` + `{flat IT/OT}` + `{dual-homed EWS with no DMZ}`. The fix that prevents recurrence is the **target** Purdue architecture, which ties Recover back to Improve.*

## 🎯 Skills

**Hands-on:** Incident Triage · Log Forensics (Zeek) · Network Containment · OT Architecture Hardening

**Applying [MITRE ATT&CK for ICS](https://attack.mitre.org/matrices/ics/) — Mitigations:**

[![M0930 Network Segmentation](https://img.shields.io/badge/ATT%26CK_ICS-M0930_Network_Segmentation-blue)](https://attack.mitre.org/mitigations/M0930/)
[![M0937 Filter Network Traffic](https://img.shields.io/badge/ATT%26CK_ICS-M0937_Filter_Network_Traffic-blue)](https://attack.mitre.org/mitigations/M0937/)
[![M0931 Network Intrusion Prevention](https://img.shields.io/badge/ATT%26CK_ICS-M0931_Network_Intrusion_Prevention-blue)](https://attack.mitre.org/mitigations/M0931/)

**Mapped to the [NIST SP 800-61r3](https://csrc.nist.gov/pubs/sp/800/61/r3/final) incident-response lifecycle ([CSF 2.0](https://csrc.nist.gov/pubs/cswp/29/the-nist-cybersecurity-framework-csf-20/final) functions):** the seven actions move through *Govern/Identify* (Preparation) → *Detect* → *Respond* → *Recover/Improve*.

## 🔖 Nomenclature

- ATT&CK for ICS: MITRE's adversary-behaviour knowledge base for industrial control systems; *Mitigations* are the defensive counterparts of *Techniques*.
- conduit: in the Purdue/IEC 62443 sense, the controlled communication path between two security zones.
- CSF: [NIST Cybersecurity Framework](https://csrc.nist.gov/pubs/cswp/29/the-nist-cybersecurity-framework-csf-20/final); version 2.0 organises work into the functions *Govern, Identify, Protect, Detect, Respond, Recover*.
- CSIRT: Computer Security Incident Response Team.
- DNP3: Distributed Network Protocol version 3 — SCADA protocol widely used in electric, water, and oil & gas utilities.
- EWS: Engineering workstation — the host operated by control engineers to configure, program, and monitor field devices.
- ICS: Industrial control system.
- IDMZ: Industrial Demilitarised Zone — the Purdue Level 3.5 buffer that brokers all IT↔OT traffic.
- IOC: Indicator of compromise — an observable network or host artefact that suggests an intrusion.
- IR / IRP: Incident response / incident response plan.
- NSM: Network security monitoring — passive observation of traffic; Zeek is an NSM tool.
- OT: Operational technology.
- PERA / Purdue: Purdue Enterprise Reference Architecture — the layered (L0–L5) reference model for ICS network segmentation.
- RTO / RPO: Recovery time objective / recovery point objective.
- RTU: Remote terminal unit — the field device role typically played by a DNP3 outstation.
- SCADA: Supervisory control and data acquisition.
- [SP 800-61](https://csrc.nist.gov/pubs/sp/800/61/r3/final) / [SP 800-82](https://csrc.nist.gov/pubs/sp/800/82/r3/final): NIST guides for incident handling and for OT security, respectively.

## 🛠️ Usage

```
Usage: ./OTLab16.sh -start [kali|ubuntu] | -stop | -clean | -run | -restart | -status
                    | -attack <scenario> | -incident | -contain | -restore

  -start     Start the DNP3_IR environment using the specified distro (default: ubuntu)
             Valid options: kali (rolling) or ubuntu (22.04)
  -run       Open a terminal inside the otlab-student (EWS) container
  -clean     Remove containers, volumes, and network (reverts all iptables rules)
  -stop      Stop all containers
  -restart   Restart previously stopped containers
  -status    Show current containers status
  -attack    Fire a single controlled attack scenario (scan | fingerprint | spoof)
  -incident  Replay the full kill-chain (scan → fingerprint → spoof) to open the incident
  -contain   Apply the reference containment: surgical DROP of the attacker into OT,
             preserving the legitimate master→outstation poll
  -restore   Lift containment and return to the clean monitored state
```

> [!NOTE]
> When run on **WSL2**, the script auto-detects the environment and applies the kernel-level rules (`bridge-nf-call-iptables=0` and two `DOCKER-USER` ACCEPT rules) needed for traffic to be routed across the two Docker bridges. `-contain` then applies its surgical `DROP` in the **EWS's own `FORWARD` chain** (via `docker exec`, no host `sudo`), and `-restore` removes it — a host `DOCKER-USER` rule would be silently inert under WSL2, since cross-bridge traffic is L2-switched. The cross-bridge `ACCEPT` rules require `sudo` and are reverted on `-clean`. On native Linux and macOS Docker Desktop the cross-bridge rules are skipped — see `IRPlaybookReference.md` for the containment details.

---

## Solutions

This lab is **operational, not code-to-fill**: the student drives the incident through the `OTLab16.sh` verbs and records reasoning in `IR_Template.md`. The instructor key is the expected content of the three artefacts plus the reference containment:

- **Containment (reference):** a single surgical drop in the EWS `FORWARD` chain — `docker exec otlab-student iptables -I FORWARD 1 -s 192.168.21.30 -d 192.168.20.0/24 -j DROP` — inserted at the top so it wins over the forwarding rules. The master (192.168.21.20) keeps polling the outstation (192.168.20.10); only the attacker (192.168.21.30) loses its path into OT. This is what `-contain` applies and `-restore` removes.
- **Baseline check (all-clear criteria):** clean `notice.log`, endpoints and function codes back inside the OTLab14 allowlists, and telemetry in range (110–130 V, 0.5–15 A) with the breaker toggling on its ~100 s cadence.
- **Root cause:** USB-borne malware **+** flat IT/OT with no segmentation **+** dual-homed EWS bridging the two segments with no IDMZ. The recommended fix is the *target* architecture in `PurdueModelReference.md`.
