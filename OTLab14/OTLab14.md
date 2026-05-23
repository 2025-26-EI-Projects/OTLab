# DNP3 & Wireshark Lab

## Scenario

A small electric utility runs a remote substation that publishes telemetry over **DNP3** to a control center located in the corporate network. You — the student — sit at the **engineering workstation (EWS/otlab-student)**, which is dual-homed between the (`OT segment`) and the (`corporate`) segment and forwards traffic between them.

Your job in this lab is to **understand how DNP3 carries the conversation** between the master and the outstation: where each host sits, what the protocol exchanges look like on the wire, which data points are being polled, and what the protocol does *not* do (spoiler: confidentiality and authentication).

This is the first lab in a three-part story. Lab 2 will introduce anomalous traffic on the same topology, which you will detect with Zeek. Lab 3 will walk through the incident-response steps triggered by what Lab 2 surfaces. Each lab can be taken by itself, but we highly recommend completing them in order to gain a broader, more holistic understanding of how these topics connect.

> [!NOTE]
> While analysing the captured traffic, refer to `DNP3WiresharkReference.md` for the Wireshark dissector field names, the DNP3 frame layout, the function code table, and useful display filters. It is meant as a lookup card — keep it open in another tab.

## 📝 Tasks

> [!WARNING]
> All tasks are conducted inside the lab containers. **Do not point any DNP3 client, scanner, or capture at hosts outside this lab** — DNP3 devices in production are fragile and unauthenticated probes can disrupt real industrial processes.

- [ ] Verify the IP addresses and interfaces of the `otlab-student` workstation, and confirm that it has one foot in each subnet.
Hint: {xxx.xxx.x0.xxx} and {xxx.xxx.x1.xxx}

- [ ] Using nmap identify the relevant hosts by scaning the subnets that you have access. Try to figure out what is the OT segment and IT segment. Hint: {xxx.xxx.x0.x/xx} and {xxx.xxx.x1.x/xx}

- [ ] Confirm that IP forwarding is enabled on the (`EWS/otlab-student`) by pinging the `outstation` and the `master` to verify both segments are reachable.

- [ ] From the `EWS/otlab-student`, scan the outstation host using nmap and identify the number of the open TCP port serving DNP3. Hint: {xxxxx/tcp}

- [ ] Access the otlab-student desktop using the browser at http://localhost:3000/, capture live traffic on the OT-side interface of the using Wireshark and isolate the DNP3 conversation between `master` and `outstation`. To open Wireshark you'll need to issue the command `wireshark` in the terminal emulator inside the otlab-student workstation.

- [ ] Identify the **two DNP3 layers** visible in each frame and explain, in your own words, the role of each.
    - *Hint: {xxxx xxxx layer} (with start bytes `0x05 0x64`) and {xxxxxxxxxxx layer}.*

- [ ] In the captured exchange, locate and document:
    - The **master address** and **outstation address** on the data link layer. 
    - The **application function code** used by the master to poll the outstation.
    - The **application function code** used by the outstation to respond. 

- [ ] Decode at least one response message and **infer** which DNP3 object/index corresponds to each simulated process variable (`Voltage`, `Current`, `BreakerOpen`). DNP3 carries no labels on the wire — justify your mapping using the object type (Analog vs Binary), the magnitude of the values, and the temporal dynamics described in the note below.


- [ ] Measure the **polling interval** observed on the wire (from the timestamps of consecutive master→outstation requests) and confirm it matches the configured cadence stated in the note below.
    - *Hint: in Wireshark, build a display filter that keeps only the master's poll requests (frames sourced from the master with the application function code you identified in the previous task), then go to* **View → Time Display Format → Seconds Since Previous Displayed Packet** *— the* **Time** *column will then show the inter-poll delta directly. As a visual cross-check,* **Statistics → I/O Graph** *with the same filter shows the periodic peaks.*


- [ ] Inspect the bytes of any single DNP3 application message and answer: *Is any field encrypted? Is the master authenticated? What would an attacker learn — or change — by intercepting this traffic?*

- [ ] Briefly document your findings (one paragraph) describing the protocol behavior and the security properties (or lack thereof) you observed. **This document is the input for Lab 2.** 


> [!NOTE]
> The outstation simulates a feeder breaker: it publishes a voltage reading in the 110–130 V range and a current reading in the 0.5–15 A range every 5 seconds, and toggles a `BreakerOpen` flag every 20 updates (≈100 s). The master polls every 10 seconds. Knowing the *expected* baseline of this lab — including the value ranges — is what will let you map the DNP3 indices to the right variables and spot anomalies in Lab 2.

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
Usage: ./DNP3Lab.sh -start [kali|ubuntu] | -stop | -clean | -run | -web | -restart | -status

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
