---
title: "Lab 05 - Enrutamiento Modbus/TCP entre subredes"
description: "Descubrimiento de rangos de subred, hosts OT-ICS activos, servicios TCP/UDP y comunicaciones Modbus/TCP interceptadas."
categories: ["Laboratorios"]
difficulty: "Intermedio"
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

## 📝 Tareas

- 1️⃣ Verifica las direcciones IP asignadas a la estación `otlab-student`.
- 2️⃣ Determina los rangos de subred de las redes en las que se despliega la estación `otlab-student`.
- 3️⃣ Descubre la dirección IP, la dirección MAC y la información del fabricante de otros hosts activos dentro de las subredes. Pista: dos dispositivos industriales pertenecen al mismo fabricante.
- 4️⃣ Identifica los puertos abiertos y los servicios disponibles en ambos hosts OT-ICS sobre protocolos TCP y UDP.
- 5️⃣ Intercepta la comunicación entre los hosts OT-ICS y determina el mensaje secreto transmitido. Pista: el mensaje debe decodificarse.

## 🛠️ Herramientas

- Estas son las herramientas disponibles en la estación `otlab-student` para completar OTLab 05: `ifconfig`, `masscan`, `netdiscover`, `nmap` y `tcpdump`.

## 🔖 Nomenclatura

- ICS: sistema de control industrial.
- IP: protocolo de Internet.
- MAC: control de acceso al medio.
- OT: tecnología operativa.
- TCP: protocolo de control de transmisión.
- UDP: protocolo de datagramas de usuario.
