---
title: "Lab 07 - Exposição de palavras-passe por defeito"
description: "Descoberta de um host OT-ICS, identificação de serviços expostos e acesso a uma interface de gestão protegida por credenciais predefinidas."
categories: ["Laboratórios"]
difficulty: "Intermédio"
tags: ["OT", "ICS", "Default Credentials", "Weak Authentication", "HMI", "Conpot", "Network Discovery", "Nmap", "Masscan", "Netdiscover"]
estimated_time: "60 min"
level: 3
area: "protection"
---

![](https://raw.githubusercontent.com/substationworm/OTLab/main/OTLab-SecondHeader.png "OTLab07")

[![Curriculum Lattes](https://img.shields.io/badge/Lattes-white)](http://lattes.cnpq.br/8846358506427099)
[![ORCID](https://img.shields.io/badge/ORCID-grey)](https://orcid.org/0000-0002-6254-7306)
[![SciProfiles](https://img.shields.io/badge/SciProfiles-black)](https://sciprofiles.com/profile/lffreitas-gutierres)
[![Scopus](https://img.shields.io/badge/Scopus-white)](https://www.scopus.com/authid/detail.uri?authorId=57195542368)
[![Web of Science](https://img.shields.io/badge/ResearcherID-grey)](https://www.webofscience.com/wos/author/record/Q-8444-2016)
[![substationworm](https://img.shields.io/badge/substationworm-black)](https://github.com/substationworm)
[![LFFreitasGutierres](https://img.shields.io/badge/LFFreitasGutierres-white)](https://github.com/LFFreitas-Gutierres)

## 📝 Tarefas

- 1️⃣ Verifica o endereço IP da estação `otlab-student`.
- 2️⃣ Determina o intervalo da subrede da rede onde a estação `otlab-student` está implementada.
- 3️⃣ Descobre o endereço IP, o endereço MAC e a informação do fabricante de outros hosts ativos dentro da rede.
- 4️⃣ Identifica as portas abertas e os serviços disponíveis no host OT-ICS tanto em TCP como em UDP.
- 5️⃣ Obtém as credenciais de autenticação e inicia sessão na interface de gestão e controlo de acesso do host OT-ICS. Dica: mecanismo de autenticação fraco.
#### Nota: O `plc-hmi` baseia-se em Conpot, que remapeia portas padrão de protocolos e serviços para portas não privilegiadas. Consulta o link para ver uma lista de algumas portas padrão e remapeadas.

## 🛠️ Ferramentas

- Estas são as ferramentas disponíveis na estação `otlab-student` para completar o OTLab 07:
ifconfig, masscan, netdiscover e nmap.

## 🔖 Nomenclatura

- ICS: sistema de controlo industrial.
- IP: protocolo de Internet.
- MAC: controlo de acesso ao meio.
- OT: tecnologia operacional.
- TCP: protocolo de controlo de transmissão.
- UDP: protocolo de datagramas de utilizador.

