---
title: "Lab 12 - Topologías de red fundamentales"
description: "Exploración de topologías de red fundamentales mediante análisis ARP, pruebas ICMP y mapeo de rutas de Capa 3."
categories: ["Laboratorios"]
difficulty: "Intermedio"
tags: ["OT", "ICS", "Network Topology", "ARP", "ARP Scan", "ARPing", "ICMP", "Traceroute", "Nmap", "Tcpdump", "Broadcast Domains", "Layer 2", "Layer 3", "Static Routing"]
estimated_time: "60 min"
level: 1
area: "protection"
---

![](https://raw.githubusercontent.com/substationworm/OTLab/main/OTLab-SecondHeader.png "OTLab12")

[![Curriculum Lattes](https://img.shields.io/badge/Lattes-white)](http://lattes.cnpq.br/8846358506427099)
[![ORCID](https://img.shields.io/badge/ORCID-grey)](https://orcid.org/0000-0002-6254-7306)
[![SciProfiles](https://img.shields.io/badge/SciProfiles-black)](https://sciprofiles.com/profile/lffreitas-gutierres)
[![Scopus](https://img.shields.io/badge/Scopus-white)](https://www.scopus.com/authid/detail.uri?authorId=57195542368)
[![Web of Science](https://img.shields.io/badge/ResearcherID-grey)](https://www.webofscience.com/wos/author/record/Q-8444-2016)
[![substationworm](https://img.shields.io/badge/substationworm-black)](https://github.com/substationworm)
[![LFFreitasGutierres](https://img.shields.io/badge/LFFreitasGutierres-white)](https://github.com/LFFreitas-Gutierres)

## 📝 Resumen del problema

### Hosts en contenedores

- single-pc1: 172.30.20.10, 02:12:20:00:00:01.
- single-pc2: 172.30.20.11, 02:12:20:00:00:02.
- single-pc3: 172.30.20.12, 02:12:20:00:00:03.
- ring-node1: 172.30.40.2, 172.30.40.34, 02:14:40:00:00:01.
- ring-node2: 172.30.40.3, 172.30.40.10, 02:14:40:00:00:02.
- ring-node3: 172.30.40.11, 172.30.40.18, 02:14:40:00:00:03.
- ring-node4: 172.30.40.19, 172.30.40.26, 02:14:40:00:00:04.
- ring-node5: 172.30.40.27, 172.30.40.35, 02:14:40:00:00:05.
- star-core: 172.30.30.2, 172.30.30.10, 172.30.30.18, 02:13:30:00:00:00.
- star-leaf1: 172.30.30.3, 02:13:30:00:00:01.
- star-leaf2: 172.30.30.11, 02:13:30:00:00:02.
- star-leaf3: 172.30.30.19, 02:13:30:00:00:03.

### Redes

- single-net: 172.30.20.0/24.
- ring-ab: 172.30.40.0/29.
- ring-bc: 172.30.40.8/29.
- ring-cd: 172.30.40.16/29.
- ring-de: 172.30.40.24/29.
- ring-ea: 172.30.40.32/29.
- star-net-a: 172.30.30.0/29.
- star-net-b: 172.30.30.8/29.
- star-net-c: 172.30.30.16/29.

#### Nota: `single-net` es una red sencilla de Capa 2 con un único segmento Ethernet. La topología en anillo, compuesta por los segmentos `ring-ab`, `ring-bc`, `ring-cd`, `ring-de` y `ring-ea`, es conceptual e implementada solo con rutas estáticas; por tanto, no existe reconvergencia ante la caída de un enlace. La topología en estrella utiliza un nodo central (`star-core`) que actúa como router y tres subredes conectadas (`star-net-a`, `star-net-b` y `star-net-c`).

## 📝 Tareas

- 1️⃣ Accede a `single-pc1` usando `./OOTab12 -run single1` y muestra la caché ARP con `arp -a`. Después, accede a `single-pc2` y `single-pc3` en dos terminales adicionales. En ambos hosts, inicia la monitorización de tráfico ICMP con `tcpdump -i any icmp`. Desde `single-pc1`, realiza un ping sweep sobre `single-net` con `fping -a -g <single-net_IPIrange>`. Al terminar, vuelve a ejecutar `arp -a`. Analiza y comenta los cambios observados en la caché ARP.
- 2️⃣ En `single-pc1`, ejecuta un escaneo de ping con `nmap -sn <single-net_IPIrange>`. Durante este escaneo, captura tráfico ARP en `single-pc2` y `single-pc3` con `tcpdump -i any arp`. Identifica y reporta qué hosts aparecen como activos.
- 3️⃣ Accede a `ring-node1` con `./OOTab12 -run ring1`. Evalúa los caminos lógicos hacia `ring-node2`, `ring-node3`, `ring-node4` y `ring-node5` usando `traceroute <destination_IP>`. Mapea las rutas, evalúa la secuencia de saltos y dibuja un diagrama de topología de red.
- 4️⃣ Deshabilita una interfaz lógica en `ring-node1` con `ip link set eth1 down`. Repite `traceroute` hacia `ring-node2`, `ring-node3`, `ring-node4` y `ring-node5`. Analiza el impacto de la caída de la interfaz en la continuidad de la ruta. Ten en cuenta que OTLab12 usa enrutamiento estático y no implementa failover automático.
- 5️⃣ Accede a `star-leaf1` con `./OOTab12 -run star1`. Comprueba la conectividad enviando peticiones ICMP echo a `star-leaf2` y `star-leaf3`. Mapea las rutas, evalúa la secuencia de saltos y dibuja un diagrama de topología de red.
- 6️⃣ Reinicia OTLab12 para restaurar la configuración predeterminada de todos los hosts. En terminales separadas para `single-pc2` y `single-pc3`, monitoriza tráfico ARP con `tcpdump -i any arp`. En `single-pc1`, genera broadcasts ARP con `arping -c 3 172.30.20.11`. Documenta los resultados e identifica los dominios de broadcast.
- 7️⃣ En terminales separadas para `ring-node2` y `ring-node3`, monitoriza tráfico ARP con `tcpdump -i any arp`. Desde `ring-node1`, ejecuta `arping -c 3 172.30.40.3`. Documenta los resultados e identifica los dominios de broadcast.
- 8️⃣ En terminales separadas para `star-leaf2` y `star-leaf3`, monitoriza tráfico ARP con `tcpdump -i any arp`. Desde `star-leaf1`, ejecuta `arping -c 3 172.30.30.2`. Documenta los resultados e identifica los dominios de broadcast.
- 9️⃣ Usa la utilidad `arp-scan` para validar y confirmar los dominios de broadcast en cada uno de los tres escenarios de red implementados en OTLab12.
- 🔟 Para cada uno de los tres escenarios de red de OTLab12, mapea la topología de Capa 3 usando: `nmap -sn --traceroute <sequential_list_of_all_IPIaddresses>`. Analiza las rutas resultantes y compáralas con la topología lógica esperada. Según las respuestas observadas durante el descubrimiento de hosts y la reconstrucción de topología, también puede ser útil el comando alternativo: `nmap -sn -PE -vv --packet-trace <sequential_list_of_all_IPIaddresses>`.

## 🛠️ Herramientas

- Las siguientes herramientas están disponibles para completar OTLab 12: `arp`, `arp-scan`, `arping`, `fping`, `nmap`, `ping`, `tcpdump` y `traceroute`.

## 🔖 Nomenclatura

- ARP: protocolo de resolución de direcciones.
- ICMP: protocolo de mensajes de control de Internet.
- IP: protocolo de Internet.
