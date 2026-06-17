---
title: "Lab 10 - TCP/IP e three-way handshake"
description: "Introdução à comunicação TCP/IP, descoberta ARP e análise do three-way handshake TCP."
categories: ["Laboratórios"]
difficulty: "Iniciante"
tags: ["OT", "ICS", "TCP/IP", "TCP", "ARP", "HTTP", "Nmap", "Tcpdump", "Wireshark Concepts", "Port Scanning", "Network Fundamentals", "Three-Way Handshake"]
estimated_time: "45 min"
level: 2
area: "detection"
---

![](https://raw.githubusercontent.com/substationworm/OTLab/main/OTLab-SecondHeader.png "OTLab10")

[![Curriculum Lattes](https://img.shields.io/badge/Lattes-white)](http://lattes.cnpq.br/8846358506427099)
[![ORCID](https://img.shields.io/badge/ORCID-grey)](https://orcid.org/0000-0002-6254-7306)
[![SciProfiles](https://img.shields.io/badge/SciProfiles-black)](https://sciprofiles.com/profile/lffreitas-gutierres)
[![Scopus](https://img.shields.io/badge/Scopus-white)](https://www.scopus.com/authid/detail.uri?authorId=57195542368)
[![Web of Science](https://img.shields.io/badge/ResearcherID-grey)](https://www.webofscience.com/wos/author/record/Q-8444-2016)
[![substationworm](https://img.shields.io/badge/substationworm-black)](https://github.com/substationworm)
[![LFFreitasGutierres](https://img.shields.io/badge/LFFreitasGutierres-white)](https://github.com/LFFreitas-Gutierres)

## 📝 Resumo do problema

### Hosts em contentores

- client.
- server.
- sniffer.

## 📝 Tarefas

- 1️⃣ Acede ao host `client` e verifica a conectividade de rede com o servidor usando o comando: `ping -c 3 server`.
- 2️⃣ A partir do cliente, limpa a cache ARP com o comando `ip neigh flush all`. Em seguida, força a descoberta ARP executando `ping -c 1 server`. Depois, verifica o endereço MAC associado ao servidor executando `ip neigh show`.
- 3️⃣ Acede ao servidor e inicia um serviço HTTP com o seguinte comando: `python3 -m http.server 80`. Numa sessão de terminal separada, acede ao host cliente e envia o pedido: `curl -v http://server`. Regista e analisa a resposta devolvida pelo serviço web.
- 4️⃣ No host sniffer, usa `tcpdump` para monitorizar tráfego TCP entre o cliente e o servidor executando: `tcpdump -i any 'tcp and host <client_IP> and host <server_IP>' -n -vv`. Noutra sessão de terminal no servidor, executa: `nc -l -p 8080`. Depois, a partir do cliente, estabelece ligação usando `nc server 8080` e envia uma mensagem de texto. Analisa os pacotes capturados e descreve o processo observado do three-way handshake TCP.
- 5️⃣ Depois de concluíres o passo anterior, executa o seguinte comando no cliente: `nc -vz server 9090`. Espera-se uma falha de ligação. Examina a captura de pacotes em `tcpdump` durante este processo e descreve o comportamento TCP observado.
- 6️⃣ A partir do cliente, executa um scan de portas ao servidor usando o comando: `nmap -Pn -p 80,8080 server`. Avalia as portas abertas e os serviços associados com base nos resultados do scan.

## 🛠️ Ferramentas

- As seguintes ferramentas estão disponíveis para completar o OTLab 10: `curl`, `ifconfig`, `ip`, `ipcalc`, `nc`, `nmap`, `ping`, `python3`, `tcpdump` e `traceroute`.

## 🔖 Nomenclatura

- ARP: protocolo de resolução de endereços.
- HTTP: protocolo de transferência de hipertexto.
- IP: protocolo de Internet.
- MAC: controlo de acesso ao meio.
- TCP: protocolo de controlo de transmissão.
