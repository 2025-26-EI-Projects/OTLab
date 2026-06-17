---
title: "Lab 08 - Máscaras de subrede e segmentação"
description: "Exploração de máscaras de subrede, endereçamento IP, segmentação de rede e comportamento de encaminhamento em várias estações de trabalho."
categories: ["Laboratórios"]
difficulty: "Intermédio"
tags: ["OT", "ICS", "Subnetting", "Network Segmentation", "IP Addressing", "Routing", "Traceroute", "Ping", "IPCalc", "Nmap", "Masscan"]
estimated_time: "45 min"
level: 1
area: "protection"
---
![](https://raw.githubusercontent.com/substationworm/OTLab/main/OTLab-SecondHeader.png "OTLab08")

[![Curriculum Lattes](https://img.shields.io/badge/Lattes-white)](http://lattes.cnpq.br/8846358506427099)
[![ORCID](https://img.shields.io/badge/ORCID-grey)](https://orcid.org/0000-0002-6254-7306)
[![SciProfiles](https://img.shields.io/badge/SciProfiles-black)](https://sciprofiles.com/profile/lffreitas-gutierres)
[![Scopus](https://img.shields.io/badge/Scopus-white)](https://www.scopus.com/authid/detail.uri?authorId=57195542368)
[![Web of Science](https://img.shields.io/badge/ResearcherID-grey)](https://www.webofscience.com/wos/author/record/Q-8444-2016)
[![substationworm](https://img.shields.io/badge/substationworm-black)](https://github.com/substationworm)
[![LFFreitasGutierres](https://img.shields.io/badge/LFFreitasGutierres-white)](https://github.com/LFFreitas-Gutierres)

## 📝 Tarefas

- 1️⃣ Verifica os endereços IP e MAC da estação `pc1`.
- 2️⃣ Identifica a máscara de subrede associada à estação `pc1`.
- 3️⃣ Repete os passos anteriores para as estações `pc2`, `pc3`, `pc4`, `pc5` e `pc6`. Compara os esquemas de endereçamento e determina a lógica de segmentação subjacente.
- 4️⃣ A partir de `pc1`, usa o comando `ping` para testar conectividade com `pc2` e `pc3`. Fornece uma interpretação dos resultados.
- 5️⃣ A partir de `pc1`, tenta fazer `ping` a `pc4`. Avalia o resultado.
- 6️⃣ A partir de `pc5`, tenta fazer `ping` a `pc6`. Analisa os resultados.
- 7️⃣ Executa o comando `ipcalc` a partir de qualquer contentor para calcular a informação de rede relevante para este estudo.
    - *Identifica o endereço de rede, o endereço de broadcast e o número de hosts disponíveis*.
- 8️⃣ Em `pc2`, executa `traceroute <IP address of pc4>` e explica o caminho observado.
- 9️⃣ Em `pc2`, executa `traceroute <IP address of pc3>` e interpreta o caminho resultante.
- 🔟 A partir de `pc3`, realiza um scan de descoberta de rede com `nmap -sn <network_address/24>` para cada rede analisada neste estudo. Identifica os hosts ativos detetados.

## 🛠️ Ferramentas

- As seguintes ferramentas estão disponíveis nas estações de trabalho `pc1`, `pc2`, `pc3`, `pc4`, `pc5` e `pc6` para completar o OTLab 08: `ifconfig`, `ipcalc`, `masscan`, `nmap`, `ping` e `traceroute`.

## 🔖 Nomenclatura

- IP: protocolo de Internet.
- MAC: controlo de acesso ao meio.