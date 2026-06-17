---
title: "Lab 13 - Host de salto"
description: "Evaluación de seguridad de una red industrial con pivoting de IT a OT, descubrimiento y enumeración de servicios."
categories: ["Laboratorios"]
difficulty: "Avanzado"
tags: ["OT", "ICS", "Pivoting", "Jump Host", "Network Discovery", "Nmap", "Netdiscover", "SSH", "Tcpdump", "Conpot", "Industrial Protocols", "Web Enumeration", "DMZ", "Lateral Movement", "Security Assessment"]
estimated_time: "120 min"
level: 4
area: "response"
---

![](https://raw.githubusercontent.com/substationworm/OTLab/main/OTLab-SecondHeader.png "OTLab13")

[![Curriculum Lattes](https://img.shields.io/badge/Lattes-white)](http://lattes.cnpq.br/8846358506427099)
[![ORCID](https://img.shields.io/badge/ORCID-grey)](https://orcid.org/0000-0002-6254-7306)
[![SciProfiles](https://img.shields.io/badge/SciProfiles-black)](https://sciprofiles.com/profile/lffreitas-gutierres)
[![Scopus](https://img.shields.io/badge/Scopus-white)](https://www.scopus.com/authid/detail.uri?authorId=57195542368)
[![Web of Science](https://img.shields.io/badge/ResearcherID-grey)](https://www.webofscience.com/wos/author/record/Q-8444-2016)
[![substationworm](https://img.shields.io/badge/substationworm-black)](https://github.com/substationworm)
[![LFFreitasGutierres](https://img.shields.io/badge/LFFreitasGutierres-white)](https://github.com/LFFreitas-Gutierres)

## 📝 Resumen del problema

- Realiza una evaluación interna de seguridad de red para una organización industrial de fabricación. El punto de acceso inicial es una estación de trabajo (`corp-pc1`) dentro de la red corporativa IT. El objetivo principal es identificar vulnerabilidades o errores de configuración que permitan a un atacante pivotar desde la red IT hacia los sistemas OT-ICS de la organización. No se han proporcionado diagramas de red, inventarios de activos ni credenciales administrativas.

## 📝 Tareas

- 1️⃣ Verifica la dirección IP asignada a la estación `corp-pc1`. `OTLab13{XXX.XX.X.XX}`
- 2️⃣ Determina la subred a la que pertenece `corp-pc1`. `OTLab13{XXX.XX.X.X/XX}`
- 3️⃣ Desde `corp-pc1`, identifica las direcciones IP y la información del fabricante (MAC OUI) de otros hosts activos dentro de la red corporativa. `OTLab13{XXX.XX.X.XX:<Vendor>, XXX.XX.X.XX:<Vendor>, XXX.XX.X.XXX:<Vendor>}`
- 4️⃣ Identifica al menos otra red alcanzable desde `corp-pc1` inspeccionando la tabla de rutas del sistema. `OTLab13{XXX.XX.XX.X/XX via XXX.XX.X.XXX dev ethX}`
- 5️⃣ Para la red descubierta en la tarea anterior, realiza un escaneo TCP y identifica puertos abiertos y servicios expuestos. Pista: usa `--top-ports 50`. Pista: las reglas del firewall pueden restringir el escaneo en algunos hosts. `OTLab13{XXX.XX.XX.XX:<Port>:<Service>}`
- 6️⃣ Usando los resultados de la tarea anterior, obtén acceso al host de salto y localiza la bandera oculta dentro de sus directorios. `OTLab13{Xxxx_Xx_Xxx_Xxxxx}`
- 7️⃣ Realiza un ping sweep con `nmap` para identificar hosts OT-ICS disponibles en la red industrial. Reporta sus direcciones IP y la información del fabricante. `OTLab13{XXX.XX.XX.XX:<Vendor>, XXX.XX.XX.XX:<Vendor>, XXX.XX.XX.X:<Vendor>}`
- 8️⃣ Para el dispositivo OT-ICS cuya dirección IP tiene dos dígitos iguales en el último octeto, identifica el protocolo industrial en uso y extrae el número de serie del dispositivo. `OTLab13{XXXxxx, <Serial>}`
- 9️⃣ Otro host en la red industrial expone una interfaz de administración web. Explora la interfaz y recupera la bandera protegida. `OTLab13{Xxxxxxx_Xxxxxxxxxxx}`
- 🔟 Un mensaje sospechoso se transmite en la red industrial indicando un problema operativo. Intercepta el mensaje e identifica remitente, destinatario y contenido. `OTLab13{<Sender_IP>:<Recipient_IP>:Xxxxxxxxxxxxx_Xxxxx_Xxx}`
- 1️⃣1️⃣ En la DMZ, se transmitió un mensaje de estado operativo y quedó almacenado como registro. Localiza el registro e identifica el remitente y el contenido del mensaje. `OTLab13{<Sender_IP>:Xxx_Xxx_Xxxxxx_X_Xx_Xxxxxxx}`

#### Nota: Algunos dispositivos OT-ICS se basan en Conpot, que reasigna puertos estándar de protocolos y servicios a puertos no privilegiados. Consulta el enlace para ver una lista de algunos puertos estándar y reasignados.

## 🛠️ Herramientas

- Las siguientes herramientas se recomiendan para completar OTLab 13: `curl`, `ifconfig`, `ip`, `netdiscover`, `nmap`, `ssh` y `tcpdump`.

## 🔖 Nomenclatura

- DMZ: zona desmilitarizada.
- ICS: sistema de control industrial.
- IP: protocolo de Internet.
- IT: tecnología de la información.
- MAC: control de acceso al medio.
- OT: tecnología operativa.
- OUI: identificador único organizacional.
- SSH: shell segura.
