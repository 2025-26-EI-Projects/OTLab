---
title: "Lab 13 - Jump Host"
description: "Security assessment of an industrial network involving IT-to-OT pivoting, service discovery and enumeration."
categories: ["Laboratories"]
difficulty: "Advanced"
tags: ["OT", "ICS", "Pivoting", "Jump Host", "Network Discovery", "Nmap", "Netdiscover", "SSH", "Tcpdump", "Conpot", "Industrial Protocols", "Web Enumeration", "DMZ", "Lateral Movement", "Security Assessment"]
estimated_time: "120 min"
level: 4
area: "response"
---

![](https://raw.githubusercontent.com/substationworm/OTLab/main/OTLab-SecondHeader.png "OTLab13")

[![Curriculum Lattes](https://img.shields.io/badge/Lattes-white)](http://lattes.cnpq.br/8846358506427099)
[![ORCID](https://img.shields.io/badge/ORCID-grey)](https://orcid.org/0000-0002-6254-7306)
[![SciProfiles](https://img.shields.io/badge/SciProfiles-black)](https://sciprofiles.com/profile/lffreitas-gutierres)
[![Scopus](https://img.shields.io/badge/Scopus-white)](https://www.scopus.com/authid/detail.uri?authorId=57195542368)
[![Web of Science](https://img.shields.io/badge/ResearcherID-grey)](https://www.webofscience.com/wos/author/record/Q-8444-2016)
[![substationworm](https://img.shields.io/badge/substationworm-black)](https://github.com/substationworm)
[![LFFreitasGutierres](https://img.shields.io/badge/LFFreitasGutierres-white)](https://github.com/LFFreitas-Gutierres)

## 📝 Problem Overview

- Conduct an internal network security assessment for an industrial manufacturing organization. Your initial access point is a workstation (corp-pc1) within the corporate IT network. Your primary objective is to identify security vulnerabilities or misconfigurations that could allow a malicious actor to pivot from the IT network into the organization's OT-ICS systems. No network diagrams, asset inventories, or administrative credentials have been provided.

## 📝 Tasks

- 1️⃣ Verify the IP address assigned to the corp-pc1 workstation. `OTLab13{XXX.XX.X.XX}`
- 2️⃣ Determine the network subnet to which corp-pc1 belongs. `OTLab13{XXX.XX.X.X/XX}`
- 3️⃣ From corp-pc1, identify the IP addresses and vendor (MAC OUI) information of other active hosts within the corporate network. `OTLab13{XXX.XX.X.XX:<Vendor>, XXX.XX.X.XX:<Vendor>, XXX.XX.X.XXX:<Vendor>}`
- 4️⃣ Identify at least one additional reachable network from corp-pc1 by inspecting the system routing table. O OTLab13{XXX.XX.XX.X/XX via XXX.XX.X.XXX dev ethX}
- 5️⃣ For the network discovered in the previous task, perform a TCP port scan and identify open ports and exposed services. Hint: Use --top-ports 50. Hint: Firewall rules may restrict scanning on some hosts. `OTLab13{XXX.XX.XX.XX:<Port>:<Service>} `
- 6️⃣ Using the results from the previous task, gain access to the jump host and locate the hidden flag within its directories. O Oab13{Xxxx_Xx_Xxx_Xxxxx}
- 7️⃣ Perform an nmap ping sweep to identify available OT-ICS hosts in the industrial network. Report their IP addresses and vendor information. `OTLab13{XXX.XX.XX.XX:<Vendor>, XXX.XX.XX.XX:<Vendor>, XXX.XX.XX.X:<Vendor>}`
- 8️⃣ For the OT-ICS device whose IP address has two identical digits in the last octet, identify the industrial protocol in use and extract the device’s serial number. `OTLab13{XXXxxx, <Serial>}`
- 9️⃣ Another host on the industrial network exposes a web-based management interface. Explore the interface and retrieve the protected flag. O OTLab13{Xxxxxxx_Xxxxxxxxxxx}
- 🔟 A suspicious message is being transmitted on the industrial network indicating an operational issue. Intercept the message and identify the sender, recipient, and message content. `OTLab13{<Sender_IP>:<Recipient_IP>:Xxxxxxxxxxxxx_Xxxxx_Xxx}`
- 1️⃣1️⃣ In the DMZ, an operational status message was transmitted and stored as a log record. Locate the record and identify the sender and the message content.  `OTLab13{<Sender_IP>:Xxx_Xxx_Xxxxxx_X_Xx_Xxxxxxx}`

#### Note: Some OT-ICS devices are based on Conpot, which remaps standard protocol and service ports to non-privileged ports. Refer to the link for a list of some default and remapped ports.

## 🛠️ Tools

- The following tools are recommended for completing OTLab 13: curl, ifconfig, ip, netdiscover, nmap, ssh, and tcpdump.

## 🔖 Nomenclature

- DMZ: Demilitarized zone.
- ICS: Industrial control system.
- IP: Internet protocol.
- IT: Information technology.
- MAC: Media access control.
- OT: Operational technology.
- OUI: Organizationally unique identifier.
- SSH: Secure shell.