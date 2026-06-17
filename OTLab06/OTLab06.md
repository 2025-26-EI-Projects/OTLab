---
title: "Lab 06 - Protocolos industriais e exposição de interface web"
description: "Descoberta de dispositivos industriais através de enumeração de subredes, análise de serviços, inspeção de interfaces web e recolha de informação SNMP."
categories: ["Laboratórios"]
difficulty: "Intermédio"
tags: ["OT", "ICS", "Industrial Protocols", "Web Interface", "SNMP", "OID", "Conpot", "Plcscan", "Tcpdump", "Network Discovery", "Nmap", "Masscan", "Netdiscover"]
estimated_time: "75 min"
level: 3
area: "detection"
---

![](https://raw.githubusercontent.com/substationworm/OTLab/main/OTLab-SecondHeader.png "OTLab06")

[![Curriculum Lattes](https://img.shields.io/badge/Lattes-white)](http://lattes.cnpq.br/8846358506427099)
[![ORCID](https://img.shields.io/badge/ORCID-grey)](https://orcid.org/0000-0002-6254-7306)
[![SciProfiles](https://img.shields.io/badge/SciProfiles-black)](https://sciprofiles.com/profile/lffreitas-gutierres)
[![Scopus](https://img.shields.io/badge/Scopus-white)](https://www.scopus.com/authid/detail.uri?authorId=57195542368)
[![Web of Science](https://img.shields.io/badge/ResearcherID-grey)](https://www.webofscience.com/wos/author/record/Q-8444-2016)
[![substationworm](https://img.shields.io/badge/substationworm-black)](https://github.com/substationworm)
[![LFFreitasGutierres](https://img.shields.io/badge/LFFreitasGutierres-white)](https://github.com/LFFreitas-Gutierres)

## 📝 Tarefas

- 1️⃣ Verifica o endereço IP da estação `otlab-student`. `OTLab06{XXX.XXX.X2.XXX}`
- 2️⃣ Descobre os endereços IP dos hosts ativos dentro da mesma subrede da resposta anterior. `OTLab06{XXX.XXX.XX.2X, XXX.XXX.XX.XX, XXX.XXX.XX.XXX}`
- 3️⃣ Determina quais as portas abertas no endereço IP no formato `XXX.XXX.XX.2X`, identificado na pergunta anterior. `OTLab06{XXXX, XXXX, XXXX, XXXXX, XXXXX}`
- 4️⃣ Identifica o endereço MAC do host ativo correspondente ao endereço IP no formato `XXX.XXX.XX.2X` da pergunta 2. `OTLab06{XX:XX:XX:XX:XX:XX}`
- 5️⃣ Localiza a flag escondida numa interface web exposta no host ativo mencionado na pergunta 3.
  - _Usa `curl`. Não são fornecidas mais pistas._
- 6️⃣ Que porta está aberta no endereço IP no formato `XXX.XXX.XX.XX` da pergunta 2? `OTLab06{XXX}`
- 7️⃣ Determina a versão do firmware base emulado no host ativo referenciado na pergunta anterior. `OTLab06{X.X.X.X}`
- 8️⃣ Dois dispositivos em redes distintas configuradas em modo bridge estão a comunicar. Qual é o endereço MAC do único host ativo no outro segmento em bridge? `OTLab06{XX:XX:XX:XX:XX:XX}`
- 9️⃣ Dois dispositivos em redes distintas configuradas em modo bridge estão a comunicar. Qual é a mensagem transmitida? `OTLab06{Xxxx xxx Xxxxxxxxxxx xx Xxxxxxxx xxx Xxxxxxxxxx xxx XX-XXX!}`
- 🔟 Qual OID pode ser extraído através do serviço SNMP a partir de um host ativo que opera com um protocolo de comunicação industrial? `OTLab06{(XXXX) X:XX:XX.XX}`

#### Nota: O `plc03-scada` baseia-se em [Conpot](http://conpot.org/), que remapeia portas padrão de protocolos e serviços para portas não privilegiadas. Consulta o [link](https://github.com/substationworm/OTLab/blob/main/OTLab01/ConpotDefaultPorts.md) para uma lista de algumas portas padrão e remapeadas. A ferramenta `opt/plcscan/plcscan.py` ([meeas/plcscan](https://github.com/meeas/plcscan)) deve ser executada utilizando `python2`.

## 🛠️ Ferramentas

- As seguintes ferramentas estão disponíveis na estação de trabalho `otlab-student` para completar o OTLab 06: `ifconfig`, `masscan`, `netdiscover`, `nmap`, `snmpwalk`, `plcscan` e `tcpdump`.

## 🔖 Nomenclatura

- IP: protocolo de Internet.
- MAC: controlo de acesso ao meio.
- OID: identificador de objeto.
- SNMP: protocolo simples de gestão de rede.
