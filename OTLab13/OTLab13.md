---
title: "Lab 13 - Host de salto"
description: "Avaliação de segurança de uma rede industrial envolvendo pivoting de IT para OT, descoberta e enumeração de serviços."
categories: ["Laboratórios"]
difficulty: "Avançado"
tags: ["OT", "ICS", "Pivoting", "Jump Host", "Network Discovery", "Nmap", "Netdiscover", "SSH", "Tcpdump", "Conpot", "Industrial Protocols", "Web Enumeration", "DMZ", "Lateral Movement", "Security Assessment"]
estimated_time: "120 min"
level: 4
area: "response"
---

![](https://raw.githubusercontent.com/substationworm/OTLab/main/OTLab-SecondHeader.png "OTLab13")

[![Curriculum Lattes](https://img.shields.io/badge/Lattes-white)](http://lattes.cnpq.br/8846358506427099)
[![ORCID](https://img.shields.io/badge/ORCID-grey)](https://orcid.org/0000-0002-6254-7306)
[![SciProfiles](https://img.shields.io/badge/SciProfiles-black)](https://sciprofiles.com/profile/lffreitas-gutierres)
[![Scopus](https://img.shields.io/badge/Scopus-white)](https://www.scopus.com/authid/detail.uri?authorId=57195542368)
[![Web of Science](https://img.shields.io/badge/ResearcherID-grey)](https://www.webofscience.com/wos/author/record/Q-8444-2016)
[![substationworm](https://img.shields.io/badge/substationworm-black)](https://github.com/substationworm)
[![LFFreitasGutierres](https://img.shields.io/badge/LFFreitasGutierres-white)](https://github.com/LFFreitas-Gutierres)

## 📝 Resumo do problema

- Realiza uma avaliação interna de segurança de rede para uma organização industrial de fabrico. O ponto de acesso inicial é uma estação de trabalho (`corp-pc1`) dentro da rede corporativa IT. O objetivo principal é identificar vulnerabilidades ou más configurações de segurança que permitam a um atacante pivotar da rede IT para os sistemas OT-ICS da organização. Não foram fornecidos diagramas de rede, inventários de ativos nem credenciais administrativas.

## 📝 Tarefas

- 1️⃣ Verifica o endereço IP atribuído à estação `corp-pc1`. `OTLab13{XXX.XX.X.XX}`
- 2️⃣ Determina a subrede de rede à qual `corp-pc1` pertence. `OTLab13{XXX.XX.X.X/XX}`
- 3️⃣ A partir de `corp-pc1`, identifica os endereços IP e a informação do fabricante (MAC OUI) de outros hosts ativos dentro da rede corporativa. `OTLab13{XXX.XX.X.XX:<Vendor>, XXX.XX.X.XX:<Vendor>, XXX.XX.X.XXX:<Vendor>}`
- 4️⃣ Identifica pelo menos outra rede alcançável a partir de `corp-pc1` inspecionando a tabela de rotas do sistema. `OTLab13{XXX.XX.XX.X/XX via XXX.XX.X.XXX dev ethX}`
- 5️⃣ Para a rede descoberta na tarefa anterior, realiza um scan TCP e identifica portas abertas e serviços expostos. Dica: usa `--top-ports 50`. Dica: as regras de firewall podem restringir o scan em alguns hosts. `OTLab13{XXX.XX.XX.XX:<Port>:<Service>}`
- 6️⃣ Usando os resultados da tarefa anterior, ganha acesso ao host de salto e localiza a flag escondida dentro dos seus diretórios. `OTLab13{Xxxx_Xx_Xxx_Xxxxx}`
- 7️⃣ Executa um ping sweep com `nmap` para identificar hosts OT-ICS disponíveis na rede industrial. Reporta os respetivos endereços IP e a informação do fabricante. `OTLab13{XXX.XX.XX.XX:<Vendor>, XXX.XX.XX.XX:<Vendor>, XXX.XX.XX.X:<Vendor>}`
- 8️⃣ Para o dispositivo OT-ICS cujo endereço IP tem dois dígitos idênticos no último octeto, identifica o protocolo industrial em uso e extrai o número de série do dispositivo. `OTLab13{XXXxxx, <Serial>}`
- 9️⃣ Outro host na rede industrial expõe uma interface de gestão web. Explora a interface e recupera a flag protegida. `OTLab13{Xxxxxxx_Xxxxxxxxxxx}`
- 🔟 Uma mensagem suspeita está a ser transmitida na rede industrial indicando um problema operacional. Interceta a mensagem e identifica remetente, destinatário e conteúdo da mensagem. `OTLab13{<Sender_IP>:<Recipient_IP>:Xxxxxxxxxxxxx_Xxxxx_Xxx}`
- 1️⃣1️⃣ Na DMZ, foi transmitida uma mensagem de estado operacional e armazenada como registo de log. Localiza o registo e identifica o remetente e o conteúdo da mensagem. `OTLab13{<Sender_IP>:Xxx_Xxx_Xxxxxx_X_Xx_Xxxxxxx}`

#### Nota: Alguns dispositivos OT-ICS baseiam-se em Conpot, que remapeia portas padrão de protocolos e serviços para portas não privilegiadas. Consulta o link para uma lista de algumas portas padrão e remapeadas.

## 🛠️ Ferramentas

- As seguintes ferramentas são recomendadas para completar o OTLab 13: `curl`, `ifconfig`, `ip`, `netdiscover`, `nmap`, `ssh` e `tcpdump`.

## 🔖 Nomenclatura

- DMZ: zona desmilitarizada.
- ICS: sistema de controlo industrial.
- IP: protocolo de Internet.
- IT: tecnologia da informação.
- MAC: controlo de acesso ao meio.
- OT: tecnologia operacional.
- OUI: identificador único organizacional.
- SSH: shell segura.