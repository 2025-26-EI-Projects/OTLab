---
title: "Lab 01 - Deteção básica de dispositivos OT-ICS"
description: "Descoberta de dispositivos OT-ICS através de escaneamento de rede, enumeração de serviços e análise de protocolos industriais."
categories: ["Laboratórios"]
difficulty: "Intermédio"
tags: ["OT", "ICS", "PLC", "Network Discovery", "Nmap", "Masscan", "Netdiscover", "SNMP", "Conpot", "Shodan", "FOFA", "Google Dorking"]
estimated_time: "60 min"
level: 0
area: "discovery"
---
![](https://raw.githubusercontent.com/substationworm/OTLab/main/OTLab-SecondHeader.png "OTLab01")

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
  - *Dica: é um PLC*.
- 4️⃣ Identifica as portas abertas e os serviços disponíveis no host OT-ICS tanto em TCP como em UDP.
- 5️⃣ Determina o protocolo de comunicação industrial proprietário utilizado pelo PLC.
- 6️⃣ Obtém informação adicional do sistema através do protocolo SNMP.
- 7️⃣ Identifica o número total de dispositivos OT-ICS de acesso público que usam o mesmo protocolo industrial proprietário que `conpot-plc` através de um motor de busca especializado como [Shodan](https://www.shodan.io/) ou [FOFA](https://en.fofa.info/).
- 8️⃣ Localiza um dispositivo OT exposto publicamente que use o mesmo protocolo industrial que `conpot-plc` através de Google dorking.

#### Nota: O `conpot-plc` baseia-se em [Conpot](http://conpot.org/), que remapeia portas padrão de protocolos e serviços para portas não privilegiadas. Consulta o [link](https://github.com/substationworm/OTLab/blob/main/OTLab01/ConpotDefaultPorts.md) para uma lista de algumas portas padrão e remapeadas.

## 🛠️ Ferramentas

- As seguintes ferramentas estão disponíveis na estação de trabalho `otlab-student` para completar o OTLab 1: `ifconfig`, `masscan`, `netdiscover`, `nmap` e `snmpwalk`.

## 🔖 Nomenclatura

- ICS: sistema de controlo industrial.
- IP: protocolo de Internet.
- MAC: controlo de acesso ao meio.
- OT: tecnologia operacional.
- PLC: controlador lógico programável.
- SNMP: protocolo simples de gestão de rede.
- TCP: protocolo de controlo de transmissão.
- UDP: protocolo de datagramas de utilizador.