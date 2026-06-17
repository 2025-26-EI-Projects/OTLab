---
title: "Lab 02 - Emulación de PLC Siemens S7"
description: "Descubrimiento y análisis de un PLC Siemens S7 mediante escaneo de red, enumeración de servicios e identificación de protocolos específicos del fabricante."
categories: ["Laboratorios"]
difficulty: "Intermedio"
tags: ["OT", "ICS", "PLC", "Siemens S7", "S7 Protocol", "Network Discovery", "Nmap", "Masscan", "Netdiscover", "Plcscan"]
estimated_time: "60 min"
level: 0
area: "discovery"
---
![](https://raw.githubusercontent.com/substationworm/OTLab/main/OTLab-SecondHeader.png "OTLab02")

[![Curriculum Lattes](https://img.shields.io/badge/Lattes-white)](http://lattes.cnpq.br/8846358506427099)
[![ORCID](https://img.shields.io/badge/ORCID-grey)](https://orcid.org/0000-0002-6254-7306)
[![SciProfiles](https://img.shields.io/badge/SciProfiles-black)](https://sciprofiles.com/profile/lffreitas-gutierres)
[![Scopus](https://img.shields.io/badge/Scopus-white)](https://www.scopus.com/authid/detail.uri?authorId=57195542368)
[![Web of Science](https://img.shields.io/badge/ResearcherID-grey)](https://www.webofscience.com/wos/author/record/Q-8444-2016)
[![substationworm](https://img.shields.io/badge/substationworm-black)](https://github.com/substationworm)
[![LFFreitasGutierres](https://img.shields.io/badge/LFFreitasGutierres-white)](https://github.com/LFFreitas-Gutierres)

## 📝 Tareas

> [!WARNING]
> Las tareas de este documento son estrictamente educativas, de observación y no intrusivas, y deben cumplir plenamente con los estándares éticos y legales.

- 1️⃣ Verifica la dirección IP del equipo `otlab-student`.
- 2️⃣ Determina el rango de subred de la red donde está desplegado el equipo `otlab-student`.
- 3️⃣ Descubre la dirección IP, la dirección MAC y la información del fabricante de otros hosts activos dentro de la red.
  - *Pista: es un PLC*.
- 4️⃣ Identifica los puertos abiertos y los servicios disponibles en el host OT-ICS tanto por TCP como por UDP.
- 5️⃣ Determina el protocolo industrial propietario utilizado por el PLC.
- 6️⃣ Obtén información adicional del sistema mediante scripts específicos del fabricante en `nmap`.
- 7️⃣ Ejecuta `plcscan` sobre el dispositivo OT-ICS detectado en la red y recopila más datos.

#### Nota: En la estación de trabajo `otlab-student`, la herramienta `plcscan` ([meeas/plcscan](https://github.com/meeas/plcscan)) debe ejecutarse utilizando `python2`.

## 🛠️ Herramientas

- Las siguientes herramientas están disponibles en la estación de trabajo `otlab-student` para completar OTLab 2: `ifconfig`, `masscan`, `netdiscover`, `nmap` y `plcscan`.

## 🔖 Nomenclatura

- ICS: sistema de control industrial.
- IP: protocolo de Internet.
- MAC: control de acceso al medio.
- OT: tecnología operativa.
- PLC: controlador lógico programable.
- TCP: protocolo de control de transmisión.
- UDP: protocolo de datagramas de usuario.
