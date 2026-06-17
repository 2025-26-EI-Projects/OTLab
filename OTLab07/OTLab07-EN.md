---
title: "Lab 07 - Default Password Exposure"
description: "Discovery of an OT-ICS host, identification of exposed services, and access to a management interface protected by default credentials."
categories: ["Laboratories"]
difficulty: "Intermediate"
tags: ["OT", "ICS", "Default Credentials", "Weak Authentication", "HMI", "Conpot", "Network Discovery", "Nmap", "Masscan", "Netdiscover"]
estimated_time: "60 min"
level: 3
area: "protection"
---

![](https://raw.githubusercontent.com/substationworm/OTLab/main/OTLab-SecondHeader.png "OTLab07")


[![Curriculum Lattes](https://img.shields.io/badge/Lattes-white)](http://lattes.cnpq.br/8846358506427099)
[![ORCID](https://img.shields.io/badge/ORCID-grey)](https://orcid.org/0000-0002-6254-7306)
[![SciProfiles](https://img.shields.io/badge/SciProfiles-black)](https://sciprofiles.com/profile/lffreitas-gutierres)
[![Scopus](https://img.shields.io/badge/Scopus-white)](https://www.scopus.com/authid/detail.uri?authorId=57195542368)
[![Web of Science](https://img.shields.io/badge/ResearcherID-grey)](https://www.webofscience.com/wos/author/record/Q-8444-2016)
[![substationworm](https://img.shields.io/badge/substationworm-black)](https://github.com/substationworm)
[![LFFreitasGutierres](https://img.shields.io/badge/LFFreitasGutierres-white)](https://github.com/LFFreitas-Gutierres)

## 📝 Tasks

- 1️⃣ Verify the IP address of the otlab-student workstation.
- 2️⃣ Determine the subnet range of the network where the otlab-student workstation is deployed.
- 3️⃣ Discover the IP address, MAC address, and vendor information of other active hosts within the network.
- 4️⃣ Identify open ports and available services on the OT-ICS host over both TCP and UDP protocols.
- 5️⃣ Obtain the authentication credentials and log in to the user management and access control interface of the OT-ICS host. Hint: Weak authentication mechanism.
#### Note: The plc-hmi is based on Conpot, which remaps standard protocol and service ports to non-privileged ports. Refer to the link for a list of some default and remapped ports.

## 🛠️ Tools

- These are the tools available on the otlab-student workstation for completing OTLab 07:
ifconfig, masscan, netdiscover, and nmap..

## 🔖 Nomenclature

- ICS: Industrial control system.
- IP: Internet protocol.
- MAC: Media access control.
- OT: Operational technology.
- TCP: Transmission control protocol.
- UDP: User datagram protocol.

