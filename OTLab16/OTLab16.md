---
title: "Lab 16 - Emulação do protocolo DNP3 e resposta a incidentes"
description: "Trabalhar uma intrusão OT em direto pelo ciclo de vida NIST SP 800-61r3 / CSF 2.0: triagem, contenção cirúrgica que preserva o processo DNP3, recuperação e relatório pós-incidente."
categories: ["Laboratórios"]
difficulty: "Avançado"
tags: ["OT", "ICS", "DNP3", "Resposta a Incidentes", "NIST SP 800-61", "NIST SP 800-82", "CSF 2.0", "Modelo Purdue", "Contenção", "SCADA"]
estimated_time: "90 min"
level: 4
area: "response"
---

![](https://raw.githubusercontent.com/substationworm/OTLab/main/OTLab-SecondHeader.png "OTLab16 — DNP3 + Incident Response Lab")

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

Este é o **terceiro e último laboratório** da história da subestação. No OTLab14 leste DNP3 do fio com o Wireshark e anotaste a baseline. No OTLab15 transformaste essa baseline em allowlists Zeek e construíste detetores comportamentais — e a última coisa que produziste foi um `notice.log` e um resumo de incidente de uma página.

**Desta vez o alarme é real.** O `notice.log` já não é um artefacto de sala de aula: é a **deteção que abre um incidente em direto**. A intrusão que começou quando a **Maria, do Financeiro**, ligou a pen USB do parque de estacionamento abriu caminho pelo segmento corporativo e está agora a sondar — e a falsificar (*spoof*) — para dentro da OT, onde um disjuntor de alimentador real pode ser acionado. Deixas de ser o engenheiro de deteção e passas a ser o **responsável pela resposta a incidentes**.

Vais trabalhar o incidente pelo ciclo de vida do **[NIST SP 800-61r3](https://csrc.nist.gov/pubs/sp/800/61/r3/final)**, expresso como as **funções do [CSF 2.0](https://csrc.nist.gov/pubs/cswp/29/the-nist-cybersecurity-framework-csf-20/final)**: *Govern · Identify · Protect* como **Preparação**, depois *Detect · Respond · Recover* como a **Resposta a Incidentes** em direto, fechando com *Improve*. Para a vertente OT vais apoiar-te no **[NIST SP 800-82](https://csrc.nist.gov/pubs/sp/800/82/r3/final)** (Guide to OT Security).

A lição mais importante deste laboratório: **em OT, resposta a incidentes não é "desligar a ficha".** Há *segurança física (safety)* e *disponibilidade* a proteger — o polling legítimo master↔outstation **tem de continuar a correr** enquanto ejetas o atacante. Esse compromisso é o que torna a IR em OT diferente da IR em IT, e é o fio condutor de todas as tarefas abaixo.

> [!NOTE]
> **O entregável do OTLab15 é a entrada aqui.** Mantém o teu `notice.log` e o resumo de incidente de uma página do OTLab15 abertos — são eles que *desencadeiam* este incidente. Mantém também a baseline do OTLab14 aberta (endpoints, códigos de função, gamas de valores); vais usá-la de novo para declarar o "tudo limpo".

> [!NOTE]
> Dois companheiros vivem na diretoria deste laboratório. `IRPlaybookReference.md` resume o ciclo de vida [NIST SP 800-61r3](https://csrc.nist.gov/pubs/sp/800/61/r3/final) / [800-82](https://csrc.nist.gov/pubs/sp/800/82/r3/final), a matriz de severidade OT e as receitas de contenção/verificação. `PurdueModelReference.md` é o coração visual do laboratório — a arquitetura *atual (insegura)* vs *alvo (endurecida)*. Regista o teu trabalho em `IR_Template.md` (três artefactos: registo corrente, registo de decisão de contenção, relatório de incidente).

## 📝 Tarefas

> [!WARNING]
> Todas as tarefas são realizadas dentro dos contentores do laboratório. **Não executes nenhum cenário de ataque, scanner ou regra de contenção contra hosts fora deste laboratório.** O `-incident` emite PDUs DNP3 reais e válidas e o `-contain` edita regras de firewall do host; apontados a equipamento de produção, podem perturbar processos industriais reais.

As sete ações abaixo estão etiquetadas, cada uma, com a sua função CSF 2.0 e a sobreposição Purdue que exercita.

### Preparação — `Govern` · `Identify`  *(opcional, fazer uma vez)*

- 1️⃣ **Ação 1 — Mapear o parque para Purdue, antes do incidente.** Levanta o laboratório com `./OTLab16.sh -start` e `-status` (os quatro contentores do OTLab15 regressam). Usando `PurdueModelReference.md`, coloca cada host dos Labs 14/15 num nível Purdue e escreve-o no cabeçalho do **Artefacto 1** (registo corrente). Nomeia já o **contacto de operações / autorizador** — a pessoa a quem tens de ligar antes de cortares o que quer que seja.
    - *Pista: a outstation/RTU é L`{x}`, o master é L`{x}`, a EWS é o host de fronteira L`{x.x}` e o disjuntor é L`{x}`. O plano de IR tem de nomear um contacto de operações `{antes|depois}` do incidente, não durante.*

### Deteção (Detect)

> [!NOTE]
> **Abre o incidente em direto — arranca primeiro o sensor.** A EWS só regista o ataque se o Zeek já estiver a capturar quando ele acontecer. Entra na EWS com `./OTLab16.sh -run`, encontra as suas interfaces com `ip -br a` e depois inicia a política pronta numa diretoria de trabalho, deixando-a a correr:
> ```
> mkdir -p ~/ir && cd ~/ir
> zeek -i <iface> /opt/zeek-lab/local.zeek
> ```
> A ligação virada para OT (`192.168.20.100`) é a que transporta o spoof até L1. Com o Zeek a capturar, abre um **segundo terminal no host** e dispara a kill-chain:
> ```
> ./OTLab16.sh -incident
> ```
> Quando terminar, para o Zeek com `Ctrl+C`; `conn.log`, `dnp3.log` e `notice.log` ficam à espera em `~/ir` — essa é a deteção que abre este incidente. *(Preferes reutilizar o `notice.log` que produziste no OTLab15? Salta o `-incident` e aponta a triagem abaixo a esse ficheiro.)*

- 2️⃣ **Ação 2 — Triagem e declaração.** Abre o `notice.log` que acabaste de gerar com o `-incident` (ou reutiliza o do OTLab15). Decide: incidente real ou falso positivo? Justifica com evidência de `conn.log`/`dnp3.log`. Depois **declara o incidente** — indica o âmbito e **que nível(eis) Purdue estão afetados**. Em OT a pergunta não é "que dados vazaram" mas **que processo está em risco**.
    - *Pista: um único READ falsificado que chega à outstation L`{x}` é mais grave do que um scan ruidoso que nunca sai de L`{x.x}`. Foca o impacto no processo vs dados violados.*

### Resposta (Respond)

- 3️⃣ **Ação 3 — Reconstruir a cronologia e nomear o conduit.** A partir dos logs Zeek reconstrói uma cronologia ordenada do incidente (`ts`, origem, técnica, função CSF) no **Artefacto 1**. Identifica o **conduit** que o atacante está a abusar — descreve-o em termos Purdue.
    - *Pista: `cat notice.log | zeek-cut -u ts note src id.resp_h | sort` esboça a cronologia — a flag `-u` apresenta `ts` como um timestamp UTC legível em vez do epoch bruto (usa `-d` para hora local). O conduit abusado é o caminho L`{x.x}`→L`{x}` que a EWS dual-homed faz de ponte — o mesmo que o poll legítimo do master usa, e é exatamente por isso que não podes simplesmente bloqueá-lo todo.*

- 4️⃣ **Ação 4 — Cortar o conduit (isolar, não desligar).** Corre `./OTLab16.sh -contain`. Aplica a segmentação de referência: um **DROP cirúrgico** do host atacante para OT, enquanto o poll sancionado master→outstation continua a fluir. **Verifica com Zeek**: os fluxos do atacante param *e* o `dnp3.log` mostra o polling a continuar dentro das gamas do OTLab14. Regista a decisão, a reversibilidade e as verificações pós-ação no **Artefacto 2** (Registo de Decisão de Contenção).
    - *Pista: a contenção insere `DROP -s {xxx.xxx.xx.xx} -d 192.168.20.0/24` no topo da chain `FORWARD` da EWS — a EWS dual-homed encaminha todo o tráfego corp↔OT, por isso a sua chain `FORWARD` é o verdadeiro ponto de estrangulamento. Isolar vs desligar: o alimentador tem de continuar a ser consultado. Confirma com `cat conn.log | zeek-cut id.orig_h id.resp_h service | sort -u` — a linha do `{IP do atacante}` desapareceu, a linha do `{IP do master}` permanece.*

- 5️⃣ **Ação 5 — Erradicar o ponto de apoio.** Remove o ponto de apoio do atacante no PC corporativo comprometido e fecha o vetor inicial (a USB / o IP-forwarding da EWS que deixou o corporativo chegar à OT). Anota no teu registo **o que não conseguiste corrigir a pedido** e porquê.
    - *Pista: os dispositivos de campo (a outstation/RTU L`{x}`) não podem ser corrigidos nem reiniciados a pedido a meio do incidente — a erradicação em OT muitas vezes significa cortar o alcance e agendar a correção para uma janela de manutenção, não um reinício em direto.*

### Recuperação (Recover)

- 6️⃣ **Ação 6 — Correr a verificação de baseline (processo verificado, não apenas ameaça eliminada).** Corre `./OTLab16.sh -restore` para regressar ao estado limpo e monitorizado, depois volta a correr a tua baseline Zeek. A recuperação só é aprovada **quando**: o `notice.log` não mostra novos alertas, os endpoints/códigos de função correspondem às allowlists do OTLab14, e a telemetria da outstation volta às gamas (tensão `{xxx–xxx}` V, corrente `{x.x–xx}` A).
    - *Pista: "recuperar" significa que o **processo** está verificado como normal, não apenas que o atacante desapareceu. Pede ao contacto de operações da Ação 1 para autorizar o "tudo limpo" no Artefacto 3.*

### Recuperação · Melhoria (Recover · Improve)

- 7️⃣ **Ação 7 — Escrever o relatório pós-incidente.** Completa o **Artefacto 3** (Relatório de Incidente): resumo executivo, âmbito em termos Purdue, resumo da cronologia, **causa-raiz**, ações do atacante mapeadas ao **MITRE ATT&CK for ICS**, IOCs que transformarias em regras de SIEM, ações de resposta etiquetadas por função CSF, o que deliberadamente **não** fizeste e porquê, aprovação da recuperação e lições aprendidas. A tua principal recomendação deve realimentar a arquitetura: introduzir a **IDMZ / segmentação** do `PurdueModelReference.md` para que este conduit não possa ser abusado de novo. **Este documento fecha a trilogia OTLab14/15/16.**
    - *Pista: a causa-raiz não é "a USB" sozinha — é `{USB}` + `{IT/OT plana}` + `{EWS dual-homed sem DMZ}`. A correção que previne a recorrência é a arquitetura Purdue **alvo**, que liga Recover de volta a Improve.*

## 🎯 Competências

**Práticas:** Triagem de Incidentes · Análise Forense de Logs (Zeek) · Contenção de Rede · Endurecimento de Arquitetura OT

**A aplicar [MITRE ATT&CK for ICS](https://attack.mitre.org/matrices/ics/) — Mitigações:**

[![M0930 Network Segmentation](https://img.shields.io/badge/ATT%26CK_ICS-M0930_Network_Segmentation-blue)](https://attack.mitre.org/mitigations/M0930/)
[![M0937 Filter Network Traffic](https://img.shields.io/badge/ATT%26CK_ICS-M0937_Filter_Network_Traffic-blue)](https://attack.mitre.org/mitigations/M0937/)
[![M0931 Network Intrusion Prevention](https://img.shields.io/badge/ATT%26CK_ICS-M0931_Network_Intrusion_Prevention-blue)](https://attack.mitre.org/mitigations/M0931/)

**Mapeado ao ciclo de vida de resposta a incidentes [NIST SP 800-61r3](https://csrc.nist.gov/pubs/sp/800/61/r3/final) (funções [CSF 2.0](https://csrc.nist.gov/pubs/cswp/29/the-nist-cybersecurity-framework-csf-20/final)):** as sete ações percorrem *Govern/Identify* (Preparação) → *Detect* → *Respond* → *Recover/Improve*.

## 🔖 Nomenclatura

- ATT&CK for ICS: base de conhecimento da MITRE sobre comportamento de adversários em sistemas de controlo industrial; as *Mitigações* são as contrapartes defensivas das *Técnicas*.
- conduit: no sentido Purdue/IEC 62443, o caminho de comunicação controlado entre duas zonas de segurança.
- CSF: [NIST Cybersecurity Framework](https://csrc.nist.gov/pubs/cswp/29/the-nist-cybersecurity-framework-csf-20/final); a versão 2.0 organiza o trabalho nas funções *Govern, Identify, Protect, Detect, Respond, Recover*.
- CSIRT: Equipa de resposta a incidentes de segurança informática (*Computer Security Incident Response Team*).
- DNP3: Distributed Network Protocol version 3 — protocolo SCADA amplamente usado em serviços de eletricidade, água e óleo & gás.
- EWS: Estação de trabalho de engenharia (*engineering workstation*) — o host operado por engenheiros de controlo para configurar, programar e monitorizar dispositivos de campo.
- ICS: Sistema de controlo industrial (*industrial control system*).
- IDMZ: Zona desmilitarizada industrial (*Industrial Demilitarised Zone*) — o buffer de nível Purdue 3.5 que intermedeia todo o tráfego IT↔OT.
- IOC: Indicador de compromisso (*indicator of compromise*) — um artefacto observável de rede ou host que sugere uma intrusão.
- IR / IRP: Resposta a incidentes / plano de resposta a incidentes.
- NSM: Monitorização de segurança de rede (*network security monitoring*) — observação passiva do tráfego; o Zeek é uma ferramenta NSM.
- OT: Tecnologia operacional (*operational technology*).
- PERA / Purdue: Purdue Enterprise Reference Architecture — o modelo de referência em camadas (L0–L5) para segmentação de redes ICS.
- RTO / RPO: Objetivo de tempo de recuperação / objetivo de ponto de recuperação (*recovery time/point objective*).
- RTU: Unidade terminal remota (*remote terminal unit*) — o papel de dispositivo de campo tipicamente desempenhado por uma outstation DNP3.
- SCADA: Supervisão, controlo e aquisição de dados (*supervisory control and data acquisition*).
- [SP 800-61](https://csrc.nist.gov/pubs/sp/800/61/r3/final) / [SP 800-82](https://csrc.nist.gov/pubs/sp/800/82/r3/final): guias NIST para tratamento de incidentes e para segurança OT, respetivamente.

## 🛠️ Utilização

```
Usage: ./OTLab16.sh -start [kali|ubuntu] | -stop | -clean | -run | -restart | -status
                    | -attack <scenario> | -incident | -contain | -restore

  -start     Inicia o ambiente DNP3_IR usando a distro indicada (predefinição: ubuntu)
             Opções válidas: kali (rolling) ou ubuntu (22.04)
  -run       Abre um terminal dentro do contentor otlab-student (EWS)
  -clean     Remove contentores, volumes e a rede (reverte todas as regras iptables)
  -stop      Para todos os contentores
  -restart   Reinicia contentores previamente parados
  -status    Mostra o estado atual dos contentores
  -attack    Dispara um único cenário de ataque controlado (scan | fingerprint | spoof)
  -incident  Repete a kill-chain completa (scan → fingerprint → spoof) para abrir o incidente
  -contain   Aplica a contenção de referência: DROP cirúrgico do atacante para OT,
             preservando o poll legítimo master→outstation
  -restore   Levanta a contenção e regressa ao estado limpo e monitorizado
```

> [!NOTE]
> Quando executado em **WSL2**, o script deteta automaticamente o ambiente e aplica as regras ao nível do kernel (`bridge-nf-call-iptables=0` e duas regras `DOCKER-USER` ACCEPT) necessárias para que o tráfego seja encaminhado entre as duas *bridges* Docker. O `-contain` aplica então o seu `DROP` cirúrgico na **própria chain `FORWARD` da EWS** (via `docker exec`, sem `sudo` no host), e o `-restore` remove-o — uma regra `DOCKER-USER` no host seria silenciosamente inerte em WSL2, já que o tráfego entre bridges é comutado a L2. As regras `ACCEPT` entre bridges requerem `sudo` e são revertidas no `-clean`. Em Linux nativo e no Docker Desktop do macOS as regras entre bridges são ignoradas — vê `IRPlaybookReference.md` para os detalhes da contenção.

## Soluções

Este laboratório é **operacional, não código-para-preencher**: o estudante conduz o incidente pelos verbos do `OTLab16.sh` e regista o raciocínio em `IR_Template.md`. A chave do instrutor é o conteúdo esperado dos três artefactos mais a contenção de referência:

- **Contenção (referência):** um único drop cirúrgico na chain `FORWARD` da EWS — `docker exec otlab-student iptables -I FORWARD 1 -s 192.168.21.30 -d 192.168.20.0/24 -j DROP` — inserido no topo para ganhar às regras de encaminhamento. O master (192.168.21.20) continua a consultar a outstation (192.168.20.10); apenas o atacante (192.168.21.30) perde o seu caminho para OT. É isto que o `-contain` aplica e o `-restore` remove.
- **Verificação de baseline (critérios de "tudo limpo"):** `notice.log` limpo, endpoints e códigos de função de volta dentro das allowlists do OTLab14, e telemetria nas gamas (110–130 V, 0,5–15 A) com o disjuntor a alternar na sua cadência de ~100 s.
- **Causa-raiz:** malware via USB **+** IT/OT plana sem segmentação **+** EWS dual-homed a fazer ponte entre os dois segmentos sem IDMZ. A correção recomendada é a arquitetura *alvo* em `PurdueModelReference.md`.
