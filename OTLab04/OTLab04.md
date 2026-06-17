---
title: "Lab 04 - Emulação Modbus/TCP e acesso a registos"
description: "Configuração de um simulador Modbus/TCP e interação com registos holding através de descoberta de rede e acesso a registos Modbus."
categories: ["Laboratórios"]
difficulty: "Intermédio"
tags: ["OT", "ICS", "Modbus/TCP", "ModbusPal", "Holding Registers", "Modbus CLI", "Network Discovery", "Nmap", "Masscan", "Netdiscover"]
estimated_time: "45 min"
level: 0
area: "detection"
---

![](https://raw.githubusercontent.com/substationworm/OTLab/main/OTLab-SecondHeader.png "OTLab04")

[![Curriculum Lattes](https://img.shields.io/badge/Lattes-white)](http://lattes.cnpq.br/8846358506427099)
[![ORCID](https://img.shields.io/badge/ORCID-grey)](https://orcid.org/0000-0002-6254-7306)
[![SciProfiles](https://img.shields.io/badge/SciProfiles-black)](https://sciprofiles.com/profile/lffreitas-gutierres)
[![Scopus](https://img.shields.io/badge/Scopus-white)](https://www.scopus.com/authid/detail.uri?authorId=57195542368)
[![Web of Science](https://img.shields.io/badge/ResearcherID-grey)](https://www.webofscience.com/wos/author/record/Q-8444-2016)
[![substationworm](https://img.shields.io/badge/substationworm-black)](https://github.com/substationworm)
[![LFFreitasGutierres](https://img.shields.io/badge/LFFreitasGutierres-white)](https://github.com/LFFreitas-Gutierres)

## 📝 Tarefas

- 1️⃣ Depois de iniciar o OTLab 04, acede à estação `otlab-student` via VNC em `10.1.0.40:5901` usando a palavra-passe `123456`. Dica: se estiveres a executar o OTLab 04 num sistema Linux, recomenda-se o uso do Remmina para aceder à interface gráfica da estação `otlab-student`. Se estiveres no Windows e a usar WSL, a interface gráfica pode ser acedida através de `localhost:5901`, desde que o WSL esteja em modo WSL2 e não existam restrições de firewall.
- 2️⃣ Dentro da interface gráfica da estação `otlab-student` acedida via VNC, adiciona um escravo Modbus no ModbusPal, um simulador Modbus baseado em Java: adiciona escravo: 1, nome do escravo: Slave.
- 3️⃣ Edita o escravo Modbus recém-criado adicionando cinco registos holding com os endereços 1 a 5, atribuindo os valores correspondentes 10, 20, 30, 40 e 50.
- 4️⃣ Depois de concluídas estas configurações, clica em Run no ModbusPal e abre um terminal na estação `otlab-student` (`./OOTab04.sh -run`).
- 5️⃣ Verifica o endereço IP da estação `otlab-student`.
- 6️⃣ Determina o intervalo de subrede da rede onde a estação `otlab-student` está implementada.
- 7️⃣ Descobre o endereço IP, o endereço MAC e a informação do fabricante da estação `otlab-student`.
- 8️⃣ Usa `favalex/modbus-cli` para ler os registos holding do escravo configurado no ModbusPal. Dica: `modbus -s <Slave_ID> <IPPAddress> 0 1 2 3 4` (onde os endereços 0 a 4 correspondem aos primeiros cinco registos).

## 🛠️ Ferramentas

Estas são as ferramentas disponíveis na estação `otlab-student` para completar o OTLab 04:
`ifconfig`, `masscan`, `netdiscover`, `nmap` e `modbus`.

## 🔖 Nomenclatura

- ID: identificador.
- IP: protocolo de Internet.
- MAC: controlo de acesso ao meio.
- TCP: protocolo de controlo de transmissão.
- UDP: protocolo de datagramas de utilizador.
- VNC: virtual network computing.
- WSL: subsistema Windows para Linux.
