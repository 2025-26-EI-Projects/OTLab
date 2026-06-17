---
title: "Nível 2 — Análise de protocolos e tráfego"
description: "Inspeção e análise de tráfego de rede para compreensão de protocolos." 
level: 2
---

## Objetivo
Interpretar capturas de pacotes, entender o comportamento de protocolos e extrair informação relevante.

## Conceitos
- Três-way handshake TCP, retransmissões, flags
- Análise de payloads e extração de dados
- Filtragem e uso de expressões BPF

## Ferramentas
- `tcpdump`, `tshark`, `Wireshark`
- `ngrep`, `scapy` (para manipulação/geração de pacotes)

## Labs sugeridos
{{< labs-by-level level="2" >}}

## Exercícios práticos
- Capturar o handshake TCP entre cliente e servidor e identificar os campos SYN/ACK
- Filtrar tráfego por IP/porta e exportar pcap para análise no Wireshark
