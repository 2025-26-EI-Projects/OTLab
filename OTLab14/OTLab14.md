---
title: "Lab 14 - Emulação do protocolo DNP3 e análise de tráfego com Wireshark"
description: "Emulação de tráfego DNP3 entre master e outstation e a sua análise com Wireshark numa rede OT."
categories: ["Laboratórios"]
difficulty: "Avançado"
tags: ["OT", "ICS", "DNP3", "Wireshark", "tshark", "Análise de Tráfego", "Captura de Pacotes", "SCADA", "Reconhecimento de Rede", "Análise de Protocolo"]
estimated_time: "90 min"
level: 4
area: "detection"
---

![](https://raw.githubusercontent.com/substationworm/OTLab/main/OTLab-SecondHeader.png "OTLab14 — DNP3 + Wireshark Lab")

[![Curriculum Lattes](https://img.shields.io/badge/Lattes-white)](http://lattes.cnpq.br/8846358506427099)
[![ORCID](https://img.shields.io/badge/ORCID-grey)](https://orcid.org/0000-0002-6254-7306)
[![SciProfiles](https://img.shields.io/badge/SciProfiles-black)](https://sciprofiles.com/profile/lffreitas-gutierres)
[![Scopus](https://img.shields.io/badge/Scopus-white)](https://www.scopus.com/authid/detail.uri?authorId=57195542368)
[![Web of Science](https://img.shields.io/badge/ResearcherID-grey)](https://www.webofscience.com/wos/author/record/Q-8444-2016)
[![substationworm](https://img.shields.io/badge/substationworm-black)](https://github.com/substationworm)
[![LFFreitasGutierres](https://img.shields.io/badge/LFFreitasGutierres-white)](https://github.com/LFFreitas-Gutierres)

[![GitHub fariasrafael10](https://img.shields.io/badge/GitHub-fariasrafael10-black)](https://github.com/fariasrafael10)
[![LinkedIn Farias Rafael](https://img.shields.io/badge/LinkedIn-Farias_Rafael-blue)](https://www.linkedin.com/in/farias-rafael/)
[![IPLeiria ESTG-DEI](https://img.shields.io/badge/IPLeiria-ESTG--DEI-green)](https://www.ipleiria.pt/estg-dei/)

## Cenário

Uma pequena empresa de eletricidade opera uma subestação remota que publica telemetria por **DNP3** para um centro de controlo situado na rede corporativa. Tu — o estudante — estás na **estação de trabalho de engenharia (EWS/otlab-student)**, que tem uma interface em cada segmento (`OT` e `corporativo`) e encaminha tráfego entre ambos.

A tua tarefa neste laboratório é **perceber como o DNP3 transporta a conversa** entre o master e a outstation: onde está cada host, qual o aspeto das trocas do protocolo no fio, que pontos de dados estão a ser consultados (*polled*) e o que o protocolo *não* faz (atenção: confidencialidade e autenticação).

Este é o primeiro laboratório de uma história em três partes. O OTLab15 introduzirá tráfego anómalo na mesma topologia, que irás detetar com Zeek. O OTLab16 percorrerá os passos de resposta a incidentes desencadeados pelo que o OTLab15 revelar.

> [!NOTE]
> Enquanto analisas o tráfego capturado, consulta o `DNP3WiresharkReference.md` para os nomes dos campos do dissecador do Wireshark, a estrutura da trama DNP3, a tabela de códigos de função e filtros de exibição úteis. Serve de cartão de consulta — mantém-no aberto noutro separador.

## 📝 Tarefas

> [!WARNING]
> Todas as tarefas são realizadas dentro dos contentores do laboratório. **Não apontes nenhum cliente DNP3, scanner ou captura a hosts fora deste laboratório** — os dispositivos DNP3 em produção são frágeis e sondagens não autenticadas podem perturbar processos industriais reais.

- 1️⃣ Verifica os endereços IP e as interfaces da estação `otlab-student` e confirma que tem um pé em cada sub-rede.
Pista: {xxx.xxx.x0.xxx} e {xxx.xxx.x1.xxx}

- 2️⃣ Usando o nmap, identifica os hosts relevantes através do varrimento das sub-redes a que tens acesso. Tenta perceber qual é o segmento OT e qual é o segmento IT. Pista: {xxx.xxx.x0.x/xx} e {xxx.xxx.x1.x/xx}

- 3️⃣ Confirma que o encaminhamento de IP (*IP forwarding*) está ativo na (`EWS/otlab-student`), fazendo ping à `outstation` e ao `master` para verificar que ambos os segmentos são alcançáveis.

- 4️⃣ A partir da `EWS/otlab-student`, faz scan ao host da outstation com o nmap e identifica o número da porta TCP aberta que serve o DNP3. Pista: {xxxxx/tcp}

- 5️⃣ Acede ao desktop do otlab-student através do browser em http://localhost:3000/, captura tráfego em direto na sua interface do lado OT usando o Wireshark e isola a conversa DNP3 entre `master` e `outstation`. Para abrir o Wireshark precisas de executar o comando `wireshark` no emulador de terminal dentro da estação otlab-student.

- 6️⃣ Identifica as **duas camadas DNP3** visíveis em cada trama e explica, por palavras tuas, o papel de cada uma.
    - *Pista: a {camada xxxx xxxx} (com os bytes iniciais `0x05 0x64`) e a {camada xxxxxxxxxxx}.*

- 7️⃣ Na troca capturada, localiza e documenta:
    - O **endereço do master** e o **endereço da outstation** na camada de ligação de dados.
    - O **código de função de aplicação** usado pelo master para consultar a outstation.
    - O **código de função de aplicação** usado pela outstation para responder.

- 8️⃣ Descodifica pelo menos uma mensagem de resposta e **infere** que objeto/índice DNP3 corresponde a cada variável de processo simulada (`Voltage`, `Current`, `BreakerOpen`). O DNP3 não transporta etiquetas no fio — justifica o teu mapeamento com base no tipo de objeto (Analógico vs Binário), na magnitude dos valores e na dinâmica temporal descrita na nota abaixo.

- 9️⃣ Mede o **intervalo de polling** observado no fio (a partir dos *timestamps* de pedidos consecutivos master→outstation) e confirma que corresponde à cadência configurada indicada na nota abaixo.
    - *Pista: no Wireshark, constrói um filtro de exibição que mantenha apenas os pedidos de poll do master (tramas com origem no master e com o código de função de aplicação que identificaste na tarefa anterior) e depois vai a* **View → Time Display Format → Seconds Since Previous Displayed Packet** *— a coluna* **Time** *passará a mostrar diretamente o delta entre polls. Como verificação visual,* **Statistics → I/O Graph** *com o mesmo filtro mostra os picos periódicos.*

- 🔟 Inspeciona os bytes de uma única mensagem de aplicação DNP3 e responde: *Algum campo está cifrado? O master está autenticado? O que aprenderia — ou alteraria — um atacante ao intercetar este tráfego?*

- 1️⃣1️⃣ Documenta brevemente as tuas conclusões (um parágrafo) descrevendo o comportamento do protocolo e as propriedades de segurança (ou a sua ausência) que observaste. **Este documento é a entrada para o OTLab15.**

> [!NOTE]
> A outstation simula o disjuntor de um alimentador: publica uma leitura de tensão na gama 110–130 V e uma leitura de corrente na gama 0,5–15 A a cada 5 segundos, e alterna uma *flag* `BreakerOpen` a cada 20 atualizações (≈100 s). O master faz poll a cada 10 segundos. Conhecer a baseline *esperada* deste laboratório — incluindo as gamas de valores — é o que te permitirá mapear os índices DNP3 às variáveis corretas e detetar anomalias no OTLab15.

## 🎯 Competências

**Práticas:** Reconhecimento de Rede · Captura de Pacotes (Wireshark) · Dissecação do Protocolo DNP3 · Análise de Segurança OT/ICS

**Mapeadas para o [MITRE ATT&CK for ICS](https://attack.mitre.org/matrices/ics/):**

[![T0846 Remote System Discovery](https://img.shields.io/badge/ATT%26CK_ICS-T0846_Remote_System_Discovery-red)](https://attack.mitre.org/techniques/T0846/)
[![T0840 Network Connection Enumeration](https://img.shields.io/badge/ATT%26CK_ICS-T0840_Network_Connection_Enumeration-red)](https://attack.mitre.org/techniques/T0840/)
[![T0842 Network Sniffing](https://img.shields.io/badge/ATT%26CK_ICS-T0842_Network_Sniffing-red)](https://attack.mitre.org/techniques/T0842/)
[![T0861 Point & Tag Identification](https://img.shields.io/badge/ATT%26CK_ICS-T0861_Point_%26_Tag_Identification-red)](https://attack.mitre.org/techniques/T0861/)

## 🔖 Nomenclatura

- DNP3: Distributed Network Protocol version 3 — protocolo SCADA amplamente usado em serviços de eletricidade, água e óleo & gás.
- EWS: Estação de trabalho de engenharia (*engineering workstation*) — o host operado por engenheiros de controlo para configurar, programar e monitorizar dispositivos de campo.
- ICS: Sistema de controlo industrial (*industrial control system*).
- IP: Protocolo de Internet (*internet protocol*).
- MAC: Controlo de acesso ao meio (*media access control*).
- OT: Tecnologia operacional (*operational technology*).
- PLC: Controlador lógico programável (*programmable logic controller*).
- RTU: Unidade terminal remota (*remote terminal unit*) — o papel de dispositivo de campo tipicamente desempenhado por uma outstation DNP3.
- SCADA: Supervisão, controlo e aquisição de dados (*supervisory control and data acquisition*).
- TCP: Protocolo de controlo de transmissão (*transmission control protocol*).

## 🛠️ Utilização

```
Usage: ./OTLab14.sh -start [kali|ubuntu] | -stop | -clean | -run | -web | -restart | -status

  -start     Inicia o ambiente do DNP3Lab usando a distro indicada (predefinição: ubuntu)
             Opções válidas: kali (rolling) ou ubuntu (22.04)
  -run       Abre um terminal dentro do contentor otlab-student
  -web       Mostra o URL noVNC para aceder ao desktop do estudante
  -clean     Remove contentores, volumes e a rede
  -stop      Para todos os contentores
  -restart   Reinicia contentores previamente parados
  -status    Mostra o estado atual dos contentores
```

> [!NOTE]
> Quando executado em **WSL2**, o script deteta automaticamente o ambiente e aplica as regras ao nível do kernel (`bridge-nf-call-iptables=0` e duas regras `DOCKER-USER` ACCEPT) necessárias para que o tráfego seja encaminhado entre as duas *bridges* Docker. Estas regras requerem `sudo` e são revertidas no `-clean`. Em Linux nativo e no Docker Desktop do macOS as regras são ignoradas — as predefinições do Docker já permitem o encaminhamento entre *bridges*.
