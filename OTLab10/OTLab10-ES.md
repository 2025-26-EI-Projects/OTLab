---
title: "Lab 10 - TCP/IP y Three-Way Handshake"
description: "Introducción a la comunicación TCP/IP, descubrimiento ARP y análisis del three-way handshake TCP."
categories: ["Laboratorios"]
difficulty: "Principiante"
tags: ["OT", "ICS", "TCP/IP", "TCP", "ARP", "HTTP", "Nmap", "Tcpdump", "Wireshark Concepts", "Port Scanning", "Network Fundamentals", "Three-Way Handshake"]
estimated_time: "45 min"
level: 2
area: "detection"
---

![](https://raw.githubusercontent.com/substationworm/OTLab/main/OTLab-SecondHeader.png "OTLab10")

[![Curriculum Lattes](https://img.shields.io/badge/Lattes-white)](http://lattes.cnpq.br/8846358506427099)
[![ORCID](https://img.shields.io/badge/ORCID-grey)](https://orcid.org/0000-0002-6254-7306)
[![SciProfiles](https://img.shields.io/badge/SciProfiles-black)](https://sciprofiles.com/profile/lffreitas-gutierres)
[![Scopus](https://img.shields.io/badge/Scopus-white)](https://www.scopus.com/authid/detail.uri?authorId=57195542368)
[![Web of Science](https://img.shields.io/badge/ResearcherID-grey)](https://www.webofscience.com/wos/author/record/Q-8444-2016)
[![substationworm](https://img.shields.io/badge/substationworm-black)](https://github.com/substationworm)
[![LFFreitasGutierres](https://img.shields.io/badge/LFFreitasGutierres-white)](https://github.com/LFFreitas-Gutierres)

## 📝 Resumen del problema

### Hosts en contenedores

- client.
- server.
- sniffer.

## 📝 Tareas

- 1️⃣ Accede al host client y verifica la conectividad con el servidor usando el comando: `ping -c 3 server`.
- 2️⃣ Desde client, limpia la caché ARP con `ip neigh flush all`. Después, fuerza el descubrimiento ARP ejecutando `ping -c 1 server`. Luego verifica la MAC asociada al servidor con `ip neigh show`.
- 3️⃣ Accede al servidor y levanta un servicio HTTP con: `python3 -m http.server 80`. En otra terminal, accede al host client y ejecuta `curl -v http://server`. Registra y analiza la respuesta devuelta por el servicio web.
- 4️⃣ En el host sniffer, usa tcpdump para monitorizar el tráfico TCP entre client y server: `tcpdump -i any 'tcp and host <client_IP> and host <server_IP>' -n -vv`. En otra terminal del servidor, ejecuta `nc -l -p 8080`. Después, desde client, conecta con `nc server 8080` y envía un mensaje de texto. Analiza los paquetes capturados y describe el proceso observado del three-way handshake TCP.
- 5️⃣ Tras el paso anterior, ejecuta en client: `nc -vz server 9090`. Se espera un fallo de conexión. Examina la captura en tcpdump durante este proceso y describe el comportamiento TCP observado.
- 6️⃣ Desde client, realiza un escaneo de puertos contra el servidor con: `nmap -Pn -p 80,8080 server`. Evalúa los puertos abiertos y los servicios asociados según los resultados.

## 🛠️ Herramientas

- Las siguientes herramientas están disponibles para completar OTLab 10: `curl`, `ifconfig`, `ip`, `ipcalc`, `nc`, `nmap`, `ping`, `python3`, `tcpdump` y `traceroute`.

## 🔖 Nomenclatura

- ARP: protocolo de resolución de direcciones.
- HTTP: protocolo de transferencia de hipertexto.
- IP: protocolo de Internet.
- MAC: control de acceso al medio.
- TCP: protocolo de control de transmisión.
