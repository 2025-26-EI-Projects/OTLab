---
title: "Lab 05 - Roteamento Modbus/TCP entre subredes"
description: "Descoberta de intervalos de subrede, hosts OT-ICS ativos, serviços TCP/UDP e comunicação Modbus/TCP intercetada."
categories: ["Laboratórios"]
difficulty: "Intermédio"
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

## 📝 Tarefas

- 1️⃣ Verifica os endereços IP atribuídos à estação `otlab-student`.
- 2️⃣ Determina os intervalos de subrede das redes em que a estação `otlab-student` está implementada.
- 3️⃣ Descobre o endereço IP, o endereço MAC e a informação do fabricante de outros hosts ativos dentro das subredes. Dica: dois dispositivos industriais pertencem ao mesmo fabricante.
- 4️⃣ Identifica as portas abertas e os serviços disponíveis em ambos os hosts OT-ICS sobre os protocolos TCP e UDP.
- 5️⃣ Interceta a comunicação entre os hosts OT-ICS e determina a mensagem secreta transmitida. Dica: a mensagem deve ser decodificada.

## 🛠️ Ferramentas

- Estas são as ferramentas disponíveis na estação `otlab-student` para completar o OTLab 05: `ifconfig`, `masscan`, `netdiscover`, `nmap` e `tcpdump`.

## 🔖 Nomenclatura

- ICS: sistema de controlo industrial.
- IP: protocolo de Internet.
- MAC: controlo de acesso ao meio.
- OT: tecnologia operacional.
- TCP: protocolo de controlo de transmissão.
- UDP: protocolo de datagramas de utilizador.
