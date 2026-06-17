---
title: "Lab 12 - Topologias de rede fundamentais"
description: "Exploração de topologias de rede fundamentais através de análise ARP, testes ICMP e mapeamento de caminhos de Camada 3."
categories: ["Laboratórios"]
difficulty: "Intermédio"
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

## 📝 Resumo do problema

### Hosts em contentores

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

#### Nota: `single-net` é definida como uma rede simples de Camada 2, composta por um único segmento Ethernet. A topologia em anel, constituída pelos segmentos `ring-ab`, `ring-bc`, `ring-cd`, `ring-de` e `ring-ea`, é conceptual e implementada apenas com rotas estáticas; por isso, não ocorre reconvergência em caso de falha de ligação. A topologia em estrela é composta por um nó central (`star-core`) que funciona como router e três subredes ligadas (`star-net-a`, `star-net-b` e `star-net-c`).

## 📝 Tarefas

- 1️⃣ Acede a `single-pc1` usando o comando `./OOTab12 -run single1` e lista a cache ARP executando `arp -a`. Depois, acede a `single-pc2` e `single-pc3` em duas sessões de terminal adicionais. Em ambos os hosts `single-pc2` e `single-pc3`, inicia a monitorização de tráfego ICMP com `tcpdump -i any icmp`. A partir de `single-pc1`, faz um ping sweep na rede `single-net`: `fping -a -g <single-net_IPIrange>`. Depois de concluído o sweep, executa novamente `arp -a`. Analisa e discute as alterações observadas na cache ARP.
- 2️⃣ Em `single-pc1`, executa um ping scan com `nmap -sn <single-net_IPIrange>`. Durante este scan, captura tráfego ARP em `single-pc2` e `single-pc3` usando `tcpdump -i any arp`. Identifica e reporta quais os hosts detetados como ativos.
- 3️⃣ Acede a `ring-node1` usando `./OOTab12 -run ring1`. Avalia os caminhos lógicos para `ring-node2`, `ring-node3`, `ring-node4` e `ring-node5` usando `traceroute <destination_IP>`. Mapeia as rotas, avalia a sequência de saltos e desenha um diagrama de topologia de rede.
- 4️⃣ Desativa uma interface lógica em `ring-node1` com `ip link set eth1 down`. Repete o procedimento de `traceroute` para `ring-node2`, `ring-node3`, `ring-node4` e `ring-node5`. Analisa o impacto da interrupção da interface na continuidade do caminho. Nota: o OTLab12 usa roteamento estático e não implementa failover automático.
- 5️⃣ Acede a `star-leaf1` usando `./OOTab12 -run star1`. Testa a conectividade enviando pedidos ICMP echo a `star-leaf2` e `star-leaf3`. Mapeia as rotas, avalia a sequência de saltos e desenha um diagrama de topologia de rede.
- 6️⃣ Reinicia o OTLab12 para restaurar todos os hosts para a configuração predefinida. Em terminais separados para `single-pc2` e `single-pc3`, monitoriza tráfego ARP: `tcpdump -i any arp`. Em `single-pc1`, gera broadcasts ARP: `arping -c 3 172.30.20.11`. Documenta os resultados e identifica os domínios de broadcast.
- 7️⃣ Em terminais separados para `ring-node2` e `ring-node3`, monitoriza tráfego ARP: `tcpdump -i any arp`. A partir de `ring-node1`, executa: `arping -c 3 172.30.40.3`. Documenta os resultados e identifica os domínios de broadcast.
- 8️⃣ Em terminais separados para `star-leaf2` e `star-leaf3`, monitoriza tráfego ARP: `tcpdump -i any arp`. A partir de `star-leaf1`, executa: `arping -c 3 172.30.30.2`. Documenta os resultados e identifica os domínios de broadcast.
- 9️⃣ Usa a utilidade `arp-scan` para validar e confirmar os domínios de broadcast em cada um dos três cenários de rede implementados no OTLab12.
- 🔟 Para cada um dos três cenários de rede do OTLab12, mapeia a topologia de Camada 3 usando: `nmap -sn --traceroute <sequential_list_of_all_IPIaddresses>`. Analisa os caminhos resultantes e compara-os com a topologia lógica esperada. Dependendo das respostas observadas durante a descoberta de hosts e a reconstrução da topologia, o comando alternativo seguinte também pode ser útil: `nmap -sn -PE -vv --packet-trace <sequential_list_of_all_IPIaddresses>`.

## 🛠️ Ferramentas

- As seguintes ferramentas estão disponíveis para completar o OTLab 12: `arp`, `arp-scan`, `arping`, `fping`, `nmap`, `ping`, `tcpdump` e `traceroute`.

## 🔖 Nomenclatura

- ARP: protocolo de resolução de endereços.
- ICMP: protocolo de mensagens de controlo da Internet.
- IP: protocolo de Internet.
