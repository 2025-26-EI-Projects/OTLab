---
title: "Lab 06 - Protocolos industriales y exposición de interfaz web"
description: "Descubrimiento de dispositivos industriales mediante enumeración de subredes, análisis de servicios, inspección de interfaces web y recopilación de información SNMP."
categories: ["Laboratorios"]
difficulty: "Intermedio"
tags: ["OT", "ICS", "Industrial Protocols", "Web Interface", "SNMP", "OID", "Conpot", "Plcscan", "Tcpdump", "Network Discovery", "Nmap", "Masscan", "Netdiscover"]
estimated_time: "75 min"
level: 3
area: "detection"
---

![](https://raw.githubusercontent.com/substationworm/OTLab/main/OTLab-SecondHeader.png "OTLab06")

[![Curriculum Lattes](https://img.shields.io/badge/Lattes-white)](http://lattes.cnpq.br/8846358506427099)
[![ORCID](https://img.shields.io/badge/ORCID-grey)](https://orcid.org/0000-0002-6254-7306)
[![SciProfiles](https://img.shields.io/badge/SciProfiles-black)](https://sciprofiles.com/profile/lffreitas-gutierres)
[![Scopus](https://img.shields.io/badge/Scopus-white)](https://www.scopus.com/authid/detail.uri?authorId=57195542368)
[![Web of Science](https://img.shields.io/badge/ResearcherID-grey)](https://www.webofscience.com/wos/author/record/Q-8444-2016)
[![substationworm](https://img.shields.io/badge/substationworm-black)](https://github.com/substationworm)
[![LFFreitasGutierres](https://img.shields.io/badge/LFFreitasGutierres-white)](https://github.com/LFFreitas-Gutierres)

## 📝 Tareas

- 1️⃣ Verifica la dirección IP de la estación de trabajo `otlab-student`. `OTLab06{XXX.XXX.X2.XXX}`
- 2️⃣ Descubre las direcciones IP de los hosts activos dentro de la misma subred de la respuesta anterior. `OTLab06{XXX.XXX.XX.2X, XXX.XXX.XX.XX, XXX.XXX.XX.XXX}`
- 3️⃣ Determina qué puertos están abiertos en la dirección IP con formato `XXX.XXX.XX.2X`, identificada en la pregunta anterior. `OTLab06{XXXX, XXXX, XXXX, XXXXX, XXXXX}`
- 4️⃣ Identifica la dirección MAC del host activo correspondiente a la dirección IP con formato `XXX.XXX.XX.2X` de la pregunta 2. `OTLab06{XX:XX:XX:XX:XX:XX}`
- 5️⃣ Localiza la bandera oculta en una interfaz web expuesta en el host activo mencionado en la pregunta 3.
  - _Utiliza `curl`. No se proporcionan más pistas._
- 6️⃣ ¿Qué puerto está abierto en la dirección IP con formato `XXX.XXX.XX.XX` de la pregunta 2? `OTLab06{XXX}`
- 7️⃣ Determina la versión del firmware base emulado en el host activo mencionado en la pregunta anterior. `OTLab06{X.X.X.X}`
- 8️⃣ Dos dispositivos en redes distintas configuradas en modo bridge están comunicándose. ¿Cuál es la dirección MAC del único host activo en el otro segmento bridge? `OTLab06{XX:XX:XX:XX:XX:XX}`
- 9️⃣ Dos dispositivos en redes distintas configuradas en modo bridge están comunicándose. ¿Cuál es el mensaje transmitido? `OTLab06{Xxxx xxx Xxxxxxxxxxx xx Xxxxxxxx xxx Xxxxxxxxxx xxx XX-XXX!}`
- 🔟 ¿Qué OID puede extraerse mediante el servicio SNMP desde un host activo que opera con un protocolo de comunicación industrial? `OTLab06{(XXXX) X:XX:XX.XX}`

#### Nota: `plc03-scada` se basa en [Conpot](http://conpot.org/), que reasigna los puertos estándar de protocolos y servicios a puertos no privilegiados. Consulta el [enlace](https://github.com/substationworm/OTLab/blob/main/OTLab01/ConpotDefaultPorts.md) para ver una lista de algunos puertos predeterminados y reasignados. La herramienta `opt/plcscan/plcscan.py` ([meeas/plcscan](https://github.com/meeas/plcscan)) debe ejecutarse utilizando `python2`.

## 🛠️ Herramientas

- Las siguientes herramientas están disponibles en la estación de trabajo `otlab-student` para completar OTLab 06: `ifconfig`, `masscan`, `netdiscover`, `nmap`, `snmpwalk`, `plcscan` y `tcpdump`.

## 🔖 Nomenclatura

- IP: protocolo de Internet.
- MAC: control de acceso al medio.
- OID: identificador de objeto.
- SNMP: protocolo simple de administración de red.