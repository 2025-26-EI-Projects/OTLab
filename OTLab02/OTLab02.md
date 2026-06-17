---
title: "Lab 02 - Emulação de PLC Siemens S7"
description: "Descoberta e análise de um PLC Siemens S7 através de escaneamento de rede, enumeração de serviços e identificação de protocolos específicos do fabricante."
categories: ["Laboratórios"]
difficulty: "Intermédio"
tags: ["OT", "ICS", "PLC", "Siemens S7", "S7 Protocol", "Network Discovery", "Nmap", "Masscan", "Netdiscover", "Plcscan"]
estimated_time: "60 min"
level: 0
area: "discovery"
---
![](https://raw.githubusercontent.com/substationworm/OTLab/main/OTLab-SecondHeader.png "OTLab02")

[![Curriculum Lattes](https://img.shields.io/badge/Lattes-white)](http://lattes.cnpq.br/8846358506427099)
[![ORCID](https://img.shields.io/badge/ORCID-grey)](https://orcid.org/0000-0002-6254-7306)
[![SciProfiles](https://img.shields.io/badge/SciProfiles-black)](https://sciprofiles.com/profile/lffreitas-gutierres)
[![Scopus](https://img.shields.io/badge/Scopus-white)](https://www.scopus.com/authid/detail.uri?authorId=57195542368)
[![Web of Science](https://img.shields.io/badge/ResearcherID-grey)](https://www.webofscience.com/wos/author/record/Q-8444-2016)
[![substationworm](https://img.shields.io/badge/substationworm-black)](https://github.com/substationworm)
[![LFFreitasGutierres](https://img.shields.io/badge/LFFreitasGutierres-white)](https://github.com/LFFreitas-Gutierres)

## 📝 Tarefas

> [!WARNING]
> As tarefas deste documento são estritamente educativas, observacionais e não intrusivas, e devem cumprir integralmente os padrões éticos e legais.

- 1️⃣ Verifica o endereço IP da estação de trabalho `otlab-student`.
- 2️⃣ Determina o intervalo da subrede da rede onde a estação `otlab-student` está implementada.
- 3️⃣ Descobre o endereço IP, o endereço MAC e a informação do fabricante de outros hosts ativos dentro da rede.  
  - *Dica: é um PLC*.
- 4️⃣ Identifica as portas abertas e os serviços disponíveis no host OT-ICS tanto em TCP como em UDP.
- 5️⃣ Determina o protocolo de comunicação industrial proprietário utilizado pelo PLC.
- 6️⃣ Obtém informação adicional do sistema através de scripts específicos do fabricante no `nmap`.
- 7️⃣ Executa um `plcscan` sobre o dispositivo OT-ICS detetado na rede e recolhe mais dados.

#### Nota: Na estação de trabalho `otlab-student`, a ferramenta `plcscan` ([meeas/plcscan](https://github.com/meeas/plcscan)) deve ser executada utilizando `python2`.

## 🛠️ Ferramentas

- As seguintes ferramentas estão disponíveis na estação de trabalho `otlab-student` para completar o OTLab 2: `ifconfig`, `masscan`, `netdiscover`, `nmap` e `plcscan`.

## 🔖 Nomenclatura

- ICS: sistema de controlo industrial.
- IP: protocolo de Internet.
- MAC: controlo de acesso ao meio.
- OT: tecnologia operacional.
- PLC: controlador lógico programável.
- TCP: protocolo de controlo de transmissão.
- UDP: protocolo de datagramas de utilizador.