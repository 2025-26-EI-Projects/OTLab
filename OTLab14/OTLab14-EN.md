---
title: "Lab 14 - DNP3 Protocol Emulation and Traffic Analysis Using Wireshark"
description: "Emulate DNP3 traffic between a master and an outstation and analyse it with Wireshark on an OT network."
categories: ["Laboratories"]
difficulty: "Advanced"
tags: ["OT", "ICS", "DNP3", "Wireshark", "tshark", "Traffic Analysis", "Packet Capture", "SCADA", "Network Reconnaissance", "Protocol Analysis"]
estimated_time: "90 min"
level: 4
area: "detection"
---

![](https://raw.githubusercontent.com/substationworm/OTLab/main/OTLab-SecondHeader.png "OTLab14 — DNP3 + Wireshark Lab")

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

A small electric utility runs a remote substation that publishes telemetry over **DNP3** to a control center located in the corporate network. You — the student — sit at the **engineering workstation (EWS/otlab-student)**, which is dual-homed between the (`OT segment`) and the (`corporate`) segment and forwards traffic between them.

Your job in this lab is to **understand how DNP3 carries the conversation** between the master and the outstation: where each host sits, what the protocol exchanges look like on the wire, which data points are being polled, and what the protocol does *not* do (spoiler: confidentiality and authentication).

This is the first lab in a three-part story. OTLab15 will introduce anomalous traffic on the same topology, which you will detect with Zeek. OTLab16 will walk through the incident-response steps triggered by what OTLab15 surfaces.

> [!NOTE]
> While analysing the captured traffic, refer to `DNP3WiresharkReference-EN.md` for the Wireshark dissector field names, the DNP3 frame layout, the function code table, and useful display filters. It is meant as a lookup card — keep it open in another tab.

## 📝 Tasks

> [!WARNING]
> All tasks are conducted inside the lab containers. **Do not point any DNP3 client, scanner, or capture at hosts outside this lab** — DNP3 devices in production are fragile and unauthenticated probes can disrupt real industrial processes.

- 1️⃣ Verify the IP addresses and interfaces of the `otlab-student` workstation, and confirm that it has one foot in each subnet.
Hint: {xxx.xxx.x0.xxx} and {xxx.xxx.x1.xxx}

- 2️⃣ Using nmap identify the relevant hosts by scaning the subnets that you have access. Try to figure out what is the OT segment and IT segment. Hint: {xxx.xxx.x0.x/xx} and {xxx.xxx.x1.x/xx}

- 3️⃣ Confirm that IP forwarding is enabled on the (`EWS/otlab-student`) by pinging the `outstation` and the `master` to verify both segments are reachable.

- 4️⃣ From the `EWS/otlab-student`, scan the outstation host using nmap and identify the number of the open TCP port serving DNP3. Hint: {xxxxx/tcp}

- 5️⃣ Access the otlab-student desktop using the browser at http://localhost:3000/, capture live traffic in its OT-side interface using Wireshark and isolate the DNP3 conversation between `master` and `outstation`. To open Wireshark you'll need to issue the command `wireshark` in the terminal emulator inside the otlab-student workstation.

- 6️⃣ Identify the **two DNP3 layers** visible in each frame and explain, in your own words, the role of each.
    - *Hint: {xxxx xxxx layer} (with start bytes `0x05 0x64`) and {xxxxxxxxxxx layer}.*

- 7️⃣ In the captured exchange, locate and document:
    - The **master address** and **outstation address** on the data link layer. 
    - The **application function code** used by the master to poll the outstation.
    - The **application function code** used by the outstation to respond. 

- 8️⃣ Decode at least one response message and **infer** which DNP3 object/index corresponds to each simulated process variable (`Voltage`, `Current`, `BreakerOpen`). DNP3 carries no labels on the wire — justify your mapping using the object type (Analog vs Binary), the magnitude of the values, and the temporal dynamics described in the note below.


- 9️⃣ Measure the **polling interval** observed on the wire (from the timestamps of consecutive master→outstation requests) and confirm it matches the configured cadence stated in the note below.
    - *Hint: in Wireshark, build a display filter that keeps only the master's poll requests (frames sourced from the master with the application function code you identified in the previous task), then go to* **View → Time Display Format → Seconds Since Previous Displayed Packet** *— the* **Time** *column will then show the inter-poll delta directly. As a visual cross-check,* **Statistics → I/O Graph** *with the same filter shows the periodic peaks.*


- 🔟 Inspect the bytes of any single DNP3 application message and answer: *Is any field encrypted? Is the master authenticated? What would an attacker learn — or change — by intercepting this traffic?*

- 1️⃣1️⃣ Briefly document your findings (one paragraph) describing the protocol behavior and the security properties (or lack thereof) you observed. **This document is the input for OTLab15.** 


> [!NOTE]
> The outstation simulates a feeder breaker: it publishes a voltage reading in the 110–130 V range and a current reading in the 0.5–15 A range every 5 seconds, and toggles a `BreakerOpen` flag every 20 updates (≈100 s). The master polls every 10 seconds. Knowing the *expected* baseline of this lab — including the value ranges — is what will let you map the DNP3 indices to the right variables and spot anomalies in OTLab15.

## 🎯 Skills

**Hands-on:** Network Reconnaissance · Packet Capture (Wireshark) · DNP3 Protocol Dissection · OT/ICS Security Analysis

**Mapped to [MITRE ATT&CK for ICS](https://attack.mitre.org/matrices/ics/):**

[![T0846 Remote System Discovery](https://img.shields.io/badge/ATT%26CK_ICS-T0846_Remote_System_Discovery-red)](https://attack.mitre.org/techniques/T0846/)
[![T0840 Network Connection Enumeration](https://img.shields.io/badge/ATT%26CK_ICS-T0840_Network_Connection_Enumeration-red)](https://attack.mitre.org/techniques/T0840/)
[![T0842 Network Sniffing](https://img.shields.io/badge/ATT%26CK_ICS-T0842_Network_Sniffing-red)](https://attack.mitre.org/techniques/T0842/)
[![T0861 Point & Tag Identification](https://img.shields.io/badge/ATT%26CK_ICS-T0861_Point_%26_Tag_Identification-red)](https://attack.mitre.org/techniques/T0861/)

## 🔖 Nomenclature

- DNP3: Distributed Network Protocol version 3 — SCADA protocol widely used in electric, water, and oil & gas utilities.
- EWS: Engineering workstation — the host operated by control engineers to configure, program, and monitor field devices.
- ICS: Industrial control system.
- IP: Internet protocol.
- MAC: Media access control.
- OT: Operational technology.
- PLC: Programmable logic controller.
- RTU: Remote terminal unit — the field device role typically played by a DNP3 outstation.
- SCADA: Supervisory control and data acquisition.
- TCP: Transmission control protocol.

## 🛠️ Usage

```
Usage: ./OTLab14.sh -start [kali|ubuntu] | -stop | -clean | -run | -web | -restart | -status

  -start     Start the DNP3Lab environment using the specified distro (default: ubuntu)
             Valid options: kali (rolling) or ubuntu (22.04)
  -run       Open a terminal inside the otlab-student container
  -web       Print the noVNC URL to access the student desktop
  -clean     Remove containers, volumes, and network
  -stop      Stop all containers
  -restart   Restart previously stopped containers
  -status    Show current containers status
```

> [!NOTE]
> When run on **WSL2**, the script auto-detects the environment and applies the kernel-level rules (`bridge-nf-call-iptables=0` and two `DOCKER-USER` ACCEPT rules) needed for traffic to be routed across the two Docker bridges. These rules require `sudo` and are reverted on `-clean`. On native Linux and macOS Docker Desktop the rules are skipped — Docker's defaults already allow the cross-bridge forwarding.
