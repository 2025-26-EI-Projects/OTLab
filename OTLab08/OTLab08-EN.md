---
title: "Lab 08 - Subnet Masks and Segmentation"
description: "Exploration of subnet masks, IP addressing, network segmentation, and routing behavior across multiple workstations."
categories: ["Laboratories"]
difficulty: "Intermediate"
tags: ["OT", "ICS", "Subnetting", "Network Segmentation", "IP Addressing", "Routing", "Traceroute", "Ping", "IPCalc", "Nmap", "Masscan"]
estimated_time: "45 min"
level: 1
area: "protection"
---
![](https://raw.githubusercontent.com/substationworm/OTLab/main/OTLab-SecondHeader.png "OTLab08")

[![Curriculum Lattes](https://img.shields.io/badge/Lattes-white)](http://lattes.cnpq.br/8846358506427099)
[![ORCID](https://img.shields.io/badge/ORCID-grey)](https://orcid.org/0000-0002-6254-7306)
[![SciProfiles](https://img.shields.io/badge/SciProfiles-black)](https://sciprofiles.com/profile/lffreitas-gutierres)
[![Scopus](https://img.shields.io/badge/Scopus-white)](https://www.scopus.com/authid/detail.uri?authorId=57195542368)
[![Web of Science](https://img.shields.io/badge/ResearcherID-grey)](https://www.webofscience.com/wos/author/record/Q-8444-2016)
[![substationworm](https://img.shields.io/badge/substationworm-black)](https://github.com/substationworm)
[![LFFreitasGutierres](https://img.shields.io/badge/LFFreitasGutierres-white)](https://github.com/LFFreitas-Gutierres)

## 📝 Tasks

- 1️⃣ Verify the IP and MAC addresses of the `pc1` workstation.
- 2️⃣ Identify the subnet mask associated with the `pc1` workstation.
- 3️⃣ Repeat the previous steps for the workstations `pc2`, `pc3`, `pc4`, `pc5`, and `pc6`. Compare the addressing schemes and determine the underlying segmentation logic.
- 4️⃣ From `pc1`, use the `ping` command to test connectivity with `pc2` and `pc3`. Provide an interpretation of the results.
- 5️⃣ From `pc1`, attempt to `ping` `pc4`. Evaluate the outcome.
- 6️⃣ From `pc5`, attempt to `ping` `pc6`. Analyze the results.
- 7️⃣ Execute the `ipcalc` command from any container to calculate the network information relevant to this study.
    - *Identify the network address, broadcast address, and number of available hosts*.
- 8️⃣ On `pc2`, run `traceroute <IP address of pc4>` and explain the observed routing path.
- 9️⃣ On `pc2`, execute `traceroute <IP address of pc3>` and interpret the resulting path.
- 🔟 From `pc3`, perform a network discovery scan using `nmap -sn <network_address/24>` for each network analyzed in this study. Identify the active hosts detected.

## 🛠️ Tools

- The following tools are available on the `pc1`, `pc2`, `pc3`, `pc4`, `pc5`, and `pc6` workstations for completing OTLab 08: `ifconfig`, `ipcalc`, `masscan`, `nmap`, `ping`, and `traceroute`.

## 🔖 Nomenclature

- IP: Internet protocol.
- MAC: Media access control.