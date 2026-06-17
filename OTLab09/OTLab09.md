---
title: "Lab 09 - Técnicas de scan com nmap"
description: "Técnicas de scan com nmap em subredes corporativas usando análise de ICMP, ARP, TCP e UDP."
categories: ["Laboratórios"]
difficulty: "Intermédio"
tags: ["OT", "ICS", "Nmap", "Network Scanning", "Host Discovery", "ICMP", "ARP", "TCP", "UDP", "Tcpdump", "Service Enumeration", "Port Scanning"]
estimated_time: "75 min"
level: 1
area: "discovery"
---

![](https://raw.githubusercontent.com/substationworm/OTLab/main/OTLab-SecondHeader.png "OTLab09")

[![Curriculum Lattes](https://img.shields.io/badge/Lattes-white)](http://lattes.cnpq.br/8846358506427099)
[![ORCID](https://img.shields.io/badge/ORCID-grey)](https://orcid.org/0000-0002-6254-7306)
[![SciProfiles](https://img.shields.io/badge/SciProfiles-black)](https://sciprofiles.com/profile/lffreitas-gutierres)
[![Scopus](https://img.shields.io/badge/Scopus-white)](https://www.scopus.com/authid/detail.uri?authorId=57195542368)
[![Web of Science](https://img.shields.io/badge/ResearcherID-grey)](https://www.webofscience.com/wos/author/record/Q-8444-2016)
[![substationworm](https://img.shields.io/badge/substationworm-black)](https://github.com/substationworm)
[![LFFreitasGutierres](https://img.shields.io/badge/LFFreitasGutierres-white)](https://github.com/LFFreitas-Gutierres)

## 📝 Resumo do problema

### Hosts em contentores (sistemas corporativos genéricos)

- server1: 172.30.0.11, 02:aa:bb:cc:dd:11.
- server2: 172.30.0.12, 02:aa:bb:cc:dd:12.
- server3: 172.30.10.10, 02:aa:bb:cc:dd:13.
- attacker: 172.30.0.5 (eth0) and 172.30.10.5 (eth1), 02:aa:bb:cc:dd:01.

### Redes

- corp-net: 172.30.0.0/24 (single /24 broadcast domain).
- corp-subnet: 172.30.10.0/26 (subnet).

## 📝 Tarefas

- 1️⃣ Envia três pedidos ICMP echo request (ping) da estação atacante para `server1` enquanto capturas tráfego ICMP em `server1` com `tcpdump`. Analisa e descreve o padrão de comunicação.
- 2️⃣ Realiza um scan de descoberta de hosts (sem scan de portas, usando `-sn`) na `corp-net` a partir da estação atacante enquanto monitorizas tráfego ARP em `server1` com `tcpdump`. Analisa e descreve a comunicação baseada em ARP.
- 3️⃣ Executa um scan TCP connect (`-sT`) a partir da estação atacante contra a porta 22 de `server1` e monitoriza o tráfego TCP resultante em `server1` com `tcpdump`.
- 4️⃣ Repete a tarefa 3, mas usando um scan SYN stealth (`-sS`) em vez de um TCP connect scan.
- 5️⃣ Repete a tarefa 3 usando os seguintes scans baseados em flags TCP: Null (`-sN`), FIN (`-sF`) e Xmas (`-sX`).
- 6️⃣ Executa um scan UDP (`-sU`) a partir da estação atacante direcionado a `server2` nas portas 53 e 161 enquanto monitorizas tráfego UDP e ICMP em `server2` com `tcpdump`.
- 7️⃣ Usa o `nmap` para fazer deteção de serviços e versões (`-sV`) nas portas 22 e 80 de `server1`.
- 8️⃣ Usa o `nmap` para conduzir um scan entre subredes (`-sS`) direcionado à porta 9999 em `server3`.

## 🛠️ Ferramentas

- Estas são as ferramentas disponíveis nos hosts `server1`, `server2`, `server3` e `attacker` para completar o OTLab 09: `ifconfig`, `nmap`, `ping` e `tcpdump`.

## 🔖 Nomenclatura

- ARP: protocolo de resolução de endereços.
- ICMP: protocolo de mensagens de controlo da Internet.
- IP: protocolo de Internet.
- MAC: controlo de acesso ao meio.
- TCP: protocolo de controlo de transmissão.
- UDP: protocolo de datagramas de utilizador.
