---
title: "Lab 08 - Máscaras de subred y segmentación"
description: "Exploración de máscaras de subred, direccionamiento IP, segmentación de red y comportamiento de enrutamiento en múltiples estaciones de trabajo."
categories: ["Laboratorios"]
difficulty: "Intermedio"
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

## 📝 Tareas

- 1️⃣ Verifica las direcciones IP y MAC del equipo `pc1`.
- 2️⃣ Identifica la máscara de subred asociada al equipo `pc1`.
- 3️⃣ Repite los pasos anteriores para los equipos `pc2`, `pc3`, `pc4`, `pc5` y `pc6`. Compara los esquemas de direccionamiento y determina la lógica de segmentación subyacente.
- 4️⃣ Desde `pc1`, usa el comando `ping` para probar conectividad con `pc2` y `pc3`. Proporciona una interpretación de los resultados.
- 5️⃣ Desde `pc1`, intenta hacer ping a `pc4`. Evalúa el resultado.
- 6️⃣ Desde `pc5`, intenta hacer ping a `pc6`. Analiza los resultados.
- 7️⃣ Ejecuta el comando `ipcalc` desde cualquier contenedor para calcular la información de red relevante para este estudio.
  - *Identifica la dirección de red, la dirección de broadcast y el número de hosts disponibles*.
- 8️⃣ En `pc2`, ejecuta `traceroute <IP address of pc4>` y explica la ruta observada.
- 9️⃣ En `pc2`, ejecuta `traceroute <IP address of pc3>` e interpreta la ruta resultante.
- 🔟 Desde `pc3`, realiza un escaneo de descubrimiento de red con `nmap -sn <network_address/24>` para cada red analizada en este estudio. Identifica los hosts activos detectados.

## 🛠️ Herramientas

- Las siguientes herramientas están disponibles en las estaciones de trabajo `pc1`, `pc2`, `pc3`, `pc4`, `pc5` y `pc6` para completar OTLab 08: `ifconfig`, `ipcalc`, `masscan`, `nmap`, `ping` y `traceroute`.

## 🔖 Nomenclatura

- IP: protocolo de Internet.
- MAC: control de acceso al medio.
