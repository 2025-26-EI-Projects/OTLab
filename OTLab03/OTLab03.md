---
title: "Lab 03 - Emulação de um sistema de controlo de estação de serviço"
description: "Descoberta e análise de um sistema simulado de controlo de uma estação de serviço através da identificação de hosts, enumeração de serviços e análise de um dispositivo ATG."
categories: ["Laboratórios"]
difficulty: "Intermédio"
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

## 📝 Tarefas

> [!WARNING]
> Ao utilizar motores de busca especializados ou Google dorks para identificar dispositivos OT expostos na Internet, **não interajas nem tentes aceder a sistemas reais**. As tarefas deste documento são estritamente educativas, observacionais e não intrusivas, e devem cumprir integralmente os padrões éticos e legais.

- 1️⃣ Verifica o endereço IP da estação de trabalho `otlab-student`.
- 2️⃣ Determina o intervalo da subrede da rede onde a estação `otlab-student` está implementada.
- 3️⃣ Descobre o endereço IP, o endereço MAC e a informação do fabricante de outros hosts ativos dentro da rede.  
  - *Dica: um dos dispositivos é um controlador automático de nível de combustível (ATG)*.
- 4️⃣ Identifica as portas abertas e os serviços disponíveis no host OT-ICS tanto em TCP como em UDP.
- 5️⃣ Obtém informação adicional do sistema através de scripts específicos do fabricante no `nmap`.
- 6️⃣ Identifica o número total de dispositivos OT-ICS de acesso público que usam a mesma porta aberta que `gas_station` através de um motor de busca especializado como [Shodan](https://www.shodan.io/) ou [FOFA](https://en.fofa.info/).
- 7️⃣ Determina o número total de dispositivos OT-ICS expostos publicamente que implementam a mesma funcionalidade relacionada com ATG do host `gas_station` consultando um motor de busca especializado como [Shodan](https://www.shodan.io/) ou [FOFA](https://en.fofa.info/).

## 🛠️ Ferramentas

- As seguintes ferramentas estão disponíveis na estação de trabalho `otlab-student` para completar o OTLab 3: `ifconfig`, `masscan`, `netdiscover` e `nmap`.

## 🔖 Nomenclatura

- ATG: medidor automático de tanques.
- ICS: sistema de controlo industrial.
- IP: protocolo de Internet.
- MAC: controlo de acesso ao meio.
- OT: tecnologia operacional.
- TCP: protocolo de controlo de transmissão.
- UDP: protocolo de datagramas de utilizador.