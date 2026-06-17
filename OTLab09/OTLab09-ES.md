---
title: "Lab 09 - Técnicas de escaneo con nmap"
description: "Técnicas de escaneo con nmap en subredes corporativas utilizando análisis de ICMP, ARP, TCP y UDP."
categories: ["Laboratorios"]
difficulty: "Intermedio"
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

## 📝 Resumen del problema

### Hosts en contenedores (sistemas corporativos genéricos)

- server1: 172.30.0.11, 02:aa:bb:cc:dd:11.
- server2: 172.30.0.12, 02:aa:bb:cc:dd:12.
- server3: 172.30.10.10, 02:aa:bb:cc:dd:13.
- attacker: 172.30.0.5 (eth0) y 172.30.10.5 (eth1), 02:aa:bb:cc:dd:01.

### Redes

- corp-net: 172.30.0.0/24 (dominio de broadcast /24 único).
- corp-subnet: 172.30.10.0/26 (subred).

## 📝 Tareas

- 1️⃣ Envía tres solicitudes ICMP echo request (ping) desde la estación atacante hacia server1 mientras capturas tráfico ICMP en server1 usando tcpdump. Analiza y describe el patrón de comunicación.
- 2️⃣ Realiza un escaneo de descubrimiento de hosts (sin escaneo de puertos, usando -sn) en corp-net desde la estación atacante mientras monitorizas tráfico ARP en server1 con tcpdump. Analiza y describe la comunicación basada en ARP.
- 3️⃣ Ejecuta un escaneo TCP connect (-sT) desde la estación atacante contra el puerto 22 de server1 y monitoriza el tráfico TCP resultante en server1 con tcpdump.
- 4️⃣ Repite la tarea 3, pero usando un escaneo SYN stealth (-sS) en lugar de un TCP connect scan.
- 5️⃣ Repite la tarea 3 usando los siguientes escaneos basados en flags TCP: Null (-sN), FIN (-sF) y Xmas (-sX).
- 6️⃣ Ejecuta un escaneo UDP (-sU) desde la estación atacante contra server2 en los puertos 53 y 161 mientras monitorizas tráfico UDP e ICMP en server2 con tcpdump.
- 7️⃣ Usa `nmap` para realizar detección de servicios y versiones (-sV) en los puertos 22 y 80 de server1.
- 8️⃣ Usa `nmap` para realizar un escaneo entre subredes (-sS) dirigido al puerto 9999 de server3.

## 🛠️ Herramientas

- Las siguientes herramientas están disponibles en server1, server2, server3 y attacker para completar OTLab 09: `ifconfig`, `nmap`, `ping` y `tcpdump`.

## 🔖 Nomenclatura

- ARP: protocolo de resolución de direcciones.
- ICMP: protocolo de mensajes de control de Internet.
- IP: protocolo de Internet.
- MAC: control de acceso al medio.
- TCP: protocolo de control de transmisión.
- UDP: protocolo de datagramas de usuario.
