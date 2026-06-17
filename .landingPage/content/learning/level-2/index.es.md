---
title: "Nivel 2 — Análisis de protocolos y tráfico"
description: "Inspeccionar y analizar tráfico de red para comprender el comportamiento de los protocolos." 
level: 2
---

## Objetivo
Interpretar capturas de paquetes, entender el comportamiento de protocolos y extraer información relevante.

## Conceptos
- Handshake TCP de tres vías, retransmisiones, flags
- Análisis de payloads y extracción de datos
- Filtrado y uso de expresiones BPF

## Herramientas
- `tcpdump`, `tshark`, `Wireshark`
- `ngrep`, `scapy` (manipulación/generación de paquetes)

## Laboratorios sugeridos
{{< labs-by-level level="2" >}}

## Ejercicios prácticos
- Capturar el handshake TCP entre cliente y servidor e identificar los campos SYN/ACK
- Filtrar tráfico por IP/puerto y exportar pcap para análisis en Wireshark
