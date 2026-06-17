---
title: "Lab 04 - Modbus/TCP Emulation and Register Access"
description: "Configuration of a Modbus/TCP simulator and interaction with holding registers through network discovery and Modbus register access."
categories: ["Laboratories"]
difficulty: "Intermediate"
tags: ["OT", "ICS", "Modbus/TCP", "ModbusPal", "Holding Registers", "Modbus CLI", "Network Discovery", "Nmap", "Masscan", "Netdiscover"]
estimated_time: "45 min"
level: 0
area: "detection"
---

![](https://raw.githubusercontent.com/substationworm/OTLab/main/OTLab-SecondHeader.png "OTLab04")

[![Curriculum Lattes](https://img.shields.io/badge/Lattes-white)](http://lattes.cnpq.br/8846358506427099)
[![ORCID](https://img.shields.io/badge/ORCID-grey)](https://orcid.org/0000-0002-6254-7306)
[![SciProfiles](https://img.shields.io/badge/SciProfiles-black)](https://sciprofiles.com/profile/lffreitas-gutierres)
[![Scopus](https://img.shields.io/badge/Scopus-white)](https://www.scopus.com/authid/detail.uri?authorId=57195542368)
[![Web of Science](https://img.shields.io/badge/ResearcherID-grey)](https://www.webofscience.com/wos/author/record/Q-8444-2016)
[![substationworm](https://img.shields.io/badge/substationworm-black)](https://github.com/substationworm)
[![LFFreitasGutierres](https://img.shields.io/badge/LFFreitasGutierres-white)](https://github.com/LFFreitas-Gutierres)

## 📝 Tasks

- 1️⃣ After starting OTLab 04, access the `otlab-student` workstation via VNC at `10.1.0.40:5901` using the password `123456`. Hint: if you are running OTLab 04 on a Linux system, it is recommended to use Remmina to access the graphical interface of the `otlab-student` workstation. If you are using Windows with WSL, the graphical interface may be accessed through `localhost:5901`, provided that WSL is running in WSL2 mode and no firewall restrictions are present.
- 2️⃣ Within the graphical interface of the `otlab-student` workstation accessed through VNC, add a Modbus slave in ModbusPal, a Java-based Modbus simulator: slave ID: 1, slave name: Slave.
- 3️⃣ Edit the newly created Modbus slave by adding five holding registers with addresses 1 to 5 and assigning the corresponding values 10, 20, 30, 40, and 50.
- 4️⃣ After completing these configurations, click **Run** in ModbusPal and open a terminal on the `otlab-student` workstation (`./OTLab04.sh -run`).
- 5️⃣ Verify the IP address of the `otlab-student` workstation.
- 6️⃣ Determine the subnet range of the network where the `otlab-student` workstation is deployed.
- 7️⃣ Discover the IP address, MAC address, and vendor information of the `otlab-student` workstation.
- 8️⃣ Use `favalex/modbus-cli` to read the holding registers of the slave configured in ModbusPal. Hint: `modbus -s <Slave_ID> <IPAddress> 0 1 2 3 4` (where addresses 0 to 4 correspond to the first five holding registers).

## 🛠️ Tools

The following tools are available on the `otlab-student` workstation to complete OTLab 04:
`ifconfig`, `masscan`, `netdiscover`, `nmap`, and `modbus`.

## 🔖 Nomenclature

* ID: identifier.
* IP: Internet Protocol.
* MAC: Media Access Control.
* TCP: Transmission Control Protocol.
* UDP: User Datagram Protocol.
* VNC: Virtual Network Computing.
* WSL: Windows Subsystem for Linux.
