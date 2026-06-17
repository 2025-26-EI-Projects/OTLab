---
title: "Lab 07 - Exposición de contraseñas por defecto"
description: "Descubrimiento de un host OT-ICS, identificación de servicios expuestos y acceso a una interfaz de gestión protegida por credenciales predeterminadas."
categories: ["Laboratorios"]
difficulty: "Intermedio"
tags: ["OT", "ICS", "Default Credentials", "Weak Authentication", "HMI", "Conpot", "Network Discovery", "Nmap", "Masscan", "Netdiscover"]
estimated_time: "60 min"
level: 3
area: "protection"
---

![](https://raw.githubusercontent.com/substationworm/OTLab/main/OTLab-SecondHeader.png "OTLab07")

[![Curriculum Lattes](https://img.shields.io/badge/Lattes-white)](http://lattes.cnpq.br/8846358506427099)
[![ORCID](https://img.shields.io/badge/ORCID-grey)](https://orcid.org/0000-0002-6254-7306)
[![SciProfiles](https://img.shields.io/badge/SciProfiles-black)](https://sciprofiles.com/profile/lffreitas-gutierres)
[![Scopus](https://img.shields.io/badge/Scopus-white)](https://www.scopus.com/authid/detail.uri?authorId=57195542368)
[![Web of Science](https://img.shields.io/badge/ResearcherID-grey)](https://www.webofscience.com/wos/author/record/Q-8444-2016)
[![substationworm](https://img.shields.io/badge/substationworm-black)](https://github.com/substationworm)
[![LFFreitasGutierres](https://img.shields.io/badge/LFFreitasGutierres-white)](https://github.com/LFFreitas-Gutierres)

## 📝 Tareas

- 1️⃣ Verifica la dirección IP del equipo `otlab-student`.
- 2️⃣ Determina el rango de subred de la red donde está desplegado el equipo `otlab-student`.
- 3️⃣ Descubre la dirección IP, la dirección MAC y la información del fabricante de otros hosts activos dentro de la red.
- 4️⃣ Identifica los puertos abiertos y los servicios disponibles en el host OT-ICS tanto por TCP como por UDP.
- 5️⃣ Obtén las credenciales de autenticación e inicia sesión en la interfaz de gestión y control de acceso del host OT-ICS. Pista: mecanismo de autenticación débil.

#### Nota: `plc-hmi` se basa en Conpot, que reasigna puertos estándar de protocolos y servicios a puertos no privilegiados. Consulta el enlace para ver algunos puertos estándar y reasignados.

## 🛠️ Herramientas

- Estas son las herramientas disponibles en la estación `otlab-student` para completar OTLab 07:
`ifconfig`, `masscan`, `netdiscover` y `nmap`.

## 🔖 Nomenclatura

- ICS: sistema de control industrial.
- IP: protocolo de Internet.
- MAC: control de acceso al medio.
- OT: tecnología operativa.
- TCP: protocolo de control de transmisión.
- UDP: protocolo de datagramas de usuario.
