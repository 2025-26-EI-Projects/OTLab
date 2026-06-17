---
title: "Lab 04 - Emulación Modbus/TCP y acceso a registros"
description: "Configuración de un simulador Modbus/TCP e interacción con registros holding mediante descubrimiento de red y acceso a registros Modbus."
categories: ["Laboratorios"]
difficulty: "Intermedio"
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

## 📝 Tareas

- 1️⃣ Después de iniciar OTLab 04, accede a la estación `otlab-student` mediante VNC en `10.1.0.40:5901` con la contraseña `123456`. Pista: si ejecutas OTLab 04 en Linux, se recomienda usar Remmina para acceder a la interfaz gráfica de la estación `otlab-student`. Si estás en Windows y usando WSL, la interfaz puede accederse mediante `localhost:5901`, siempre que WSL esté en modo WSL2 y no existan restricciones de firewall.
- 2️⃣ Dentro de la interfaz gráfica de `otlab-student` accedida por VNC, añade un esclavo Modbus en ModbusPal, un simulador Modbus basado en Java: añadir esclavo: 1, nombre del esclavo: Slave.
- 3️⃣ Edita el esclavo Modbus recién creado añadiendo cinco registros holding con las direcciones 1 a 5, asignando los valores 10, 20, 30, 40 y 50, respectivamente.
- 4️⃣ Tras completar esta configuración, haz clic en Run en ModbusPal y abre un terminal en la estación `otlab-student` (`./OOTab04.sh -run`).
- 5️⃣ Verifica la dirección IP de la estación `otlab-student`.
- 6️⃣ Determina el rango de subred de la red donde está desplegada la estación `otlab-student`.
- 7️⃣ Descubre la dirección IP, la dirección MAC y la información del fabricante de la estación `otlab-student`.
- 8️⃣ Usa `favalex/modbus-cli` para leer los registros holding del esclavo configurado en ModbusPal. Pista: `modbus -s <Slave_ID> <IPPAddress> 0 1 2 3 4` (donde las direcciones 0 a 4 corresponden a los primeros cinco registros).

## 🛠️ Herramientas

Estas son las herramientas disponibles en la estación `otlab-student` para completar OTLab 04:
`ifconfig`, `masscan`, `netdiscover`, `nmap` y `modbus`.

## 🔖 Nomenclatura

- ID: identificador.
- IP: protocolo de Internet.
- MAC: control de acceso al medio.
- TCP: protocolo de control de transmisión.
- UDP: protocolo de datagramas de usuario.
- VNC: computación en red virtual.
- WSL: subsistema de Windows para Linux.
