---
title: "Lab 01 - Detección básica de dispositivos OT-ICS"
description: "Descubrimiento de dispositivos OT-ICS mediante escaneo de red, enumeración de servicios y análisis de protocolos industriales."
categories: ["Laboratorios"]
difficulty: "Intermedio"
tags: ["OT", "ICS", "PLC", "Network Discovery", "Nmap", "Masscan", "Netdiscover", "SNMP", "Conpot", "Shodan", "FOFA", "Google Dorking"]
estimated_time: "60 min"
level: 0
area: "discovery"
---
![](https://raw.githubusercontent.com/substationworm/OTLab/main/OTLab-SecondHeader.png "OTLab01")

[![Curriculum Lattes](https://img.shields.io/badge/Lattes-white)](http://lattes.cnpq.br/8846358506427099)
[![ORCID](https://img.shields.io/badge/ORCID-grey)](https://orcid.org/0000-0002-6254-7306)
[![SciProfiles](https://img.shields.io/badge/SciProfiles-black)](https://sciprofiles.com/profile/lffreitas-gutierres)
[![Scopus](https://img.shields.io/badge/Scopus-white)](https://www.scopus.com/authid/detail.uri?authorId=57195542368)
[![Web of Science](https://img.shields.io/badge/ResearcherID-grey)](https://www.webofscience.com/wos/author/record/Q-8444-2016)
[![substationworm](https://img.shields.io/badge/substationworm-black)](https://github.com/substationworm)
[![LFFreitasGutierres](https://img.shields.io/badge/LFFreitasGutierres-white)](https://github.com/LFFreitas-Gutierres)

## 📝 Tareas

> [!WARNING]
> Cuando utilices motores de búsqueda especializados o Google dorks para identificar dispositivos OT expuestos en Internet, **no interactúes ni intentes acceder a sistemas reales**. Las tareas de este documento son estrictamente educativas, de observación y no intrusivas, y deben cumplir plenamente con los estándares éticos y legales.

- 1️⃣ Verifica la dirección IP del equipo `otlab-student`.
- 2️⃣ Determina el rango de subred de la red donde está desplegado el equipo `otlab-student`.
- 3️⃣ Descubre la dirección IP, la dirección MAC y la información del fabricante de otros hosts activos dentro de la red.
  - *Pista: es un PLC*.
- 4️⃣ Identifica los puertos abiertos y los servicios disponibles en el host OT-ICS tanto por TCP como por UDP.
- 5️⃣ Determina el protocolo industrial propietario utilizado por el PLC.
- 6️⃣ Obtén información adicional del sistema mediante el protocolo SNMP.
- 7️⃣ Identifica el número total de dispositivos OT-ICS de acceso público que usan el mismo protocolo industrial propietario que `conpot-plc` mediante un motor de búsqueda especializado como [Shodan](https://www.shodan.io/) o [FOFA](https://en.fofa.info/).
- 8️⃣ Localiza un dispositivo OT expuesto públicamente que use el mismo protocolo industrial que `conpot-plc` mediante Google dorking.

#### Nota: `conpot-plc` se basa en [Conpot](http://conpot.org/), que reasigna puertos estándar de protocolos y servicios a puertos no privilegiados. Consulta el [enlace](https://github.com/substationworm/OTLab/blob/main/OTLab01/ConpotDefaultPorts.md) para ver algunos puertos estándar y reasignados.

## 🛠️ Herramientas

- Las siguientes herramientas están disponibles en la estación de trabajo `otlab-student` para completar OTLab 1: `ifconfig`, `masscan`, `netdiscover`, `nmap` y `snmpwalk`.

## 🔖 Nomenclatura

- ICS: sistema de control industrial.
- IP: protocolo de Internet.
- MAC: control de acceso al medio.
- OT: tecnología operativa.
- PLC: controlador lógico programable.
- SNMP: protocolo simple de gestión de red.
- TCP: protocolo de control de transmisión.
- UDP: protocolo de datagramas de usuario.
