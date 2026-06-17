---
title: "Lab 09 - Nmap Scanning Techniques"
description: "Nmap scanning techniques in corporate subnets using ICMP, ARP, TCP and UDP analysis."
categories: ["Laboratories"]
difficulty: "Intermediate"
tags: ["OT", "ICS", "Nmap", "Network Scanning", "Host Discovery", "ICMP", "ARP", "TCP", "UDP", "Tcpdump", "Service Enumeration", "Port Scanning"]
estimated_time: "75 min"
level: 1
area: "discovery"
---

![](https://raw.githubusercontent.com/substationworm/OTLab/main/OTLab-SecondHeader.png "OTLab09")

[![Curriculum Lattes](https://img.shields.io/badge/Lattes-white)](http://lattes.cnpq.br/8846358506427099)
[![ORCID](https://img.shields.io/badge/ORCID-grey)](https://orcid.org/0000-0002-6254-7306)
[![SciProfiles](https://img.shields.io/badge/SciProfiles-black)](https://sciprofiles.com/profile/lffreitas-gutierres)
[![Scopus](https://img.shields.io/badge/Scopus-white)](https://www.scopus.com/authid/detail.uri?authorId=57195542368)
[![Web of Science](https://img.shields.io/badge/ResearcherID-grey)](https://www.webofscience.com/wos/author/record/Q-8444-2016)
[![substationworm](https://img.shields.io/badge/substationworm-black)](https://github.com/substationworm)
[![LFFreitasGutierres](https://img.shields.io/badge/LFFreitasGutierres-white)](https://github.com/LFFreitas-Gutierres)

## 📝 Problem Overview

### Containerized Hosts (Generic Corporate Systems)

- server1: 172.30.0.11, 02:aa:bb:cc:dd:11.
- server2: 172.30.0.12, 02:aa:bb:cc:dd:12.
- server3: 172.30.10.10, 02:aa:bb:cc:dd:13.
- attacker: 172.30.0.5 (eth0) and 172.30.10.5 (eth1), 02:aa:bb:cc:dd:01.

### Networks

- corp-net: 172.30.0.0/24 (single /24 broadcast domain).
- corp-subnet: 172.30.10.0/26 (subnet).

## 📝 Tasks

- 1️⃣ Issue three ICMP echo requests (ping) from the attacker workstation to server1 while capturing ICMP traffic on server1 using tcpdump. Analyze and describe the communication pattern.
- 2️⃣ Conduct a host discovery scan (no port scan, using -sn) on the corp-net from the attacker workstation while monitoring ARP traffic on server1 using tcpdump. Analyze and describe the ARP-based communication.
- 3️⃣ Perform a TCP connect scan (-sT) from the attacker workstation against port 22 on server1, and monitor the resulting TCP traffic on server1 using tcpdump.
- 4️⃣ Repeat Task 3, but use a SYN stealth scan (-sS) instead of a TCP connect scan.
- 5️⃣ Repeat Task 3 using the following TCP flag–based scans: Null scan (-sN), FIN scan (-sF), and Xmas scan (-sX).
- 6️⃣ Execute a UDP scan (-sU) from the attacker workstation targeting server2 on ports 53 and 161 while monitoring UDP and ICMP traffic on server2 using tcpdump.
- 7️⃣ Use nmap to perform service and version detection (-sV) against ports 22 and 80 on server1.
- 8️⃣ Use nmap to conduct a cross-subnet scan (-sS) targeting port 9999 on server3.

## 🛠️ Tools

- These are the tools available on the server1, server2, server3, and attacker hosts for completing OTLab 09: ifconfig, nmap, ping, and tcpdump.

## 🔖 Nomenclature

- ARP: Address resolution protocol.
- ICMP: Internet control message protocol.
- IP: Internet protocol.
- MAC: Media access control.
- TCP: Transmission control protocol.
- UDP: User datagram protocol.
