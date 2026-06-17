---
title: "Lab 05 - Modbus/TCP Routing Between Subnets"
description: "Discovery of subnet ranges, active OT-ICS hosts, TCP/UDP services, and intercepted Modbus/TCP communications."
categories: ["Laboratories"]
difficulty: "Intermediate"
tags: ["OT", "ICS", "Modbus/TCP", "Network Discovery", "Subnet Routing", "Packet Analysis", "Nmap", "Masscan", "Netdiscover", "Tcpdump"]
estimated_time: "60 min"
level: 1
area: "protection"
---

![](https://raw.githubusercontent.com/substationworm/OTLab/main/OTLab-SecondHeader.png "OTLab05")

[![Curriculum Lattes](https://img.shields.io/badge/Lattes-white)](http://lattes.cnpq.br/8846358506427099)
[![ORCID](https://img.shields.io/badge/ORCID-grey)](https://orcid.org/0000-0002-6254-7306)
[![SciProfiles](https://img.shields.io/badge/SciProfiles-black)](https://sciprofiles.com/profile/lffreitas-gutierres)
[![Scopus](https://img.shields.io/badge/Scopus-white)](https://www.scopus.com/authid/detail.uri?authorId=57195542368)
[![Web of Science](https://img.shields.io/badge/ResearcherID-grey)](https://www.webofscience.com/wos/author/record/Q-8444-2016)
[![substationworm](https://img.shields.io/badge/substationworm-black)](https://github.com/substationworm)
[![LFFreitasGutierres](https://img.shields.io/badge/LFFreitasGutierres-white)](https://github.com/LFFreitas-Gutierres)

## 📝 Tasks

- 1️⃣ Verify the IP addresses assigned to the otlab-student workstation.
- 2️⃣ Determine the subnet ranges of the networks in which the otlab-student workstation is deployed.
- 3️⃣ Discover the IP address, MAC address, and vendor information of other active hosts within the subnets. Hint: Two industrial devices belong to the same vendor.
- 4️⃣ Identify open ports and available services on both OT-ICS hosts over TCP and UDP protocols.
- 5️⃣ Intercept the communication between the OT-ICS hosts and determine the secret message being transmitted. Hint: The message must be decoded.

## 🛠️ Tools

- These are the tools available on the otlab-student workstation for completing OTLab 05: ifconfig, masscan, netdiscover, nmap, and tcpdump.

## 🔖 Nomenclature

- ICS: Industrial control system.
- IP: Internet protocol.
- MAC: Media access control.
- OT: Operational technology.
- TCP: Transmission control protocol.
- UDP: User datagram protocol.
