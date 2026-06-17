---
title: "Lab 03 - Emulación de un sistema de control de estación de servicio"
description: "Descubrimiento y análisis de un sistema simulado de control de una estación de servicio mediante la identificación de hosts, enumeración de servicios y análisis de un dispositivo ATG."
categories: ["Laboratorios"]
difficulty: "Intermedio"
tags: ["OT", "ICS", "ATG", "Fuel Station", "Network Discovery", "Nmap", "Masscan", "Netdiscover", "Shodan", "FOFA", "Google Dorking", "Service Enumeration"]
estimated_time: "60 min"
level: 0
area: "discovery"
---

![](https://raw.githubusercontent.com/substationworm/OTLab/main/OTLab-SecondHeader.png "OTLab03")

[![Curriculum Lattes](https://img.shields.io/badge/Lattes-white)](http://lattes.cnpq.br/8846358506427099)
[![ORCID](https://img.shields.io/badge/ORCID-grey)](https://orcid.org/0000-0002-6254-7306)
[![SciProfiles](https://img.shields.io/badge/SciProfiles-black)](https://sciprofiles.com/profile/lffreitas-gutierres)
[![Scopus](https://img.shields.io/badge/Scopus-white)](https://www.scopus.com/authid/detail.uri?authorId=57195542368)
[![Web of Science](https://img.shields.io/badge/ResearcherID-grey)](https://www.webofscience.com/wos/author/record/Q-8444-2016)
[![substationworm](https://img.shields.io/badge/substationworm-black)](https://github.com/substationworm)
[![LFFreitasGutierres](https://img.shields.io/badge/LFFreitasGutierres-white)](https://github.com/LFFreitas-Gutierres)

## 📝 Tareas

> [!WARNING]
> Al utilizar motores de búsqueda especializados o Google dorks para identificar dispositivos OT expuestos en Internet, **no interactúes ni intentes acceder a sistemas reales**. Las tareas de este documento son estrictamente educativas, observacionales y no intrusivas, y deben cumplir plenamente con los estándares éticos y legales.

* 1️⃣ Verifica la dirección IP de la estación de trabajo `otlab-student`.
* 2️⃣ Determina el rango de la subred de la red donde está desplegada la estación `otlab-student`.
* 3️⃣ Descubre la dirección IP, la dirección MAC y la información del fabricante de otros hosts activos dentro de la red.

  * *Pista: uno de los dispositivos es un controlador automático de nivel de combustible (ATG)*.
* 4️⃣ Identifica los puertos abiertos y los servicios disponibles en el host OT-ICS tanto en TCP como en UDP.
* 5️⃣ Obtén información adicional del sistema mediante scripts específicos del fabricante en `nmap`.
* 6️⃣ Identifica el número total de dispositivos OT-ICS de acceso público que utilizan el mismo puerto abierto que `gas_station` mediante un motor de búsqueda especializado como [Shodan](https://www.shodan.io/) o [FOFA](https://en.fofa.info/).
* 7️⃣ Determina el número total de dispositivos OT-ICS expuestos públicamente que implementan la misma funcionalidad relacionada con ATG que el host `gas_station` consultando un motor de búsqueda especializado como [Shodan](https://www.shodan.io/) o [FOFA](https://en.fofa.info/).

## 🛠️ Herramientas

* Las siguientes herramientas están disponibles en la estación de trabajo `otlab-student` para completar OTLab 3: `ifconfig`, `masscan`, `netdiscover` y `nmap`.

## 🔖 Nomenclatura

* ATG: medidor automático de tanques.
* ICS: sistema de control industrial.
* IP: protocolo de Internet.
* MAC: control de acceso al medio.
* OT: tecnología operativa.
* TCP: protocolo de control de transmisión.
* UDP: protocolo de datagramas de usuario.
