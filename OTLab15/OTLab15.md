---
title: "Lab 15 - Emulação do protocolo DNP3 e deteção com Zeek"
description: "Traduzir a baseline do OTLab14 em allowlists Zeek e construir detetores comportamentais para tráfego DNP3 malicioso numa rede OT."
categories: ["Laboratórios"]
difficulty: "Avançado"
tags: ["OT", "ICS", "DNP3", "Zeek", "NSM", "Deteção de Ameaças", "Engenharia de Deteção", "SCADA", "Deteção Comportamental", "Allowlisting"]
estimated_time: "90 min"
level: 4
area: "detection"
---

![](https://raw.githubusercontent.com/substationworm/OTLab/main/OTLab-SecondHeader.png "OTLab15 — DNP3 + Zeek Detection Lab")

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

A mesma pequena empresa de eletricidade do OTLab14 está agora preocupada. Depois de o teu relatório no Wireshark ter mostrado que o DNP3 não transporta autenticação, nem cifra, e que tem um padrão de conversa estável e previsível, a empresa coloca a pergunta óbvia: **se algo de invulgar acontecesse neste fio, dar-nos-íamos sequer conta?**

A pergunta não é académica. Na terça-feira passada, a **Maria, do departamento Financeiro**, apanhou uma pen USB que encontrou no parque de estacionamento de visitantes e — sem qualquer má intenção — ligou-a à sua estação de trabalho para ver de quem era. O malware nela existente comunicou para o exterior e instalou-se no PC dela. A partir daí tem linha de vista limpa para o segmento corporativo, e este segmento partilha um host com a estação de trabalho de engenharia OT. Ninguém reparou.

Tu — ainda na **(`otlab-student`)**, com uma interface em OT e outra em corporativo — vais introduzir o **Zeek**, uma ferramenta de monitorização de segurança de rede, na mesma topologia. A tua tarefa *não* é escrever regras de assinatura para ataques conhecidos. É traduzir a **baseline que documentaste no OTLab14** num pequeno conjunto de allowlists, deixar o Zeek avisar-te sempre que o fio se desvie dessa baseline e aprender — experimentando-os — que tipos de comportamento de adversário OT esses desvios realmente representam.

A partir do host comprometido vais disparar cenários de ataque controlados (no papel do agente de ameaça); e de dentro da otlab-student vais apanhá-los com scripts Zeek que escreves tu próprio.

> [!NOTE]
> **O entregável do OTLab14 é a entrada aqui.** Mantém as tuas conclusões do OTLab14 abertas: os endpoints esperados, os códigos de função e os endereços da camada de ligação que aí documentaste são exatamente o que vais codificar como allowlists Zeek.

> [!NOTE]
> Consulta o `DNP3WiresharkReference.md` para a estrutura da trama DNP3 e as tabelas de códigos de função, como antes. Para eventos específicos do Zeek, campos de log e receitas `zeek-cut`, vê o `DNP3LabZeekReference.md` que acompanha este laboratório, na sua diretoria.

## 📝 Tarefas

> [!WARNING]
> Todas as tarefas são realizadas dentro dos contentores do laboratório. **Não executes nenhum cenário de ataque, scanner ou captura contra hosts fora deste laboratório.** Os scripts de ataque em `scripts/attacks/` emitem PDUs DNP3 reais e válidas; apontados a equipamento de produção, podem perturbar processos industriais reais.

### Fase 0 — Orientação

- 1️⃣ Levanta o laboratório com `./OTLab15.sh -start` e confirma que os **quatro** contentores estão a correr com `./OTLab15.sh -status`. Identifica que papel desempenha cada contentor.
    - *Pista: outstation, master, otlab-student e o novo papel exclusivo do OTLab15 — {xxxxxxxx}.*

- 2️⃣ Abre uma shell na otlab-student com `./OTLab15.sh -run`. Verifica as tuas duas interfaces e confirma uma em cada sub-rede (traz a resposta do OTLab14).
    - *Pista: `{xxxx}` está virada para o segmento corporativo e `{xxxx}` para o segmento OT.*

- 3️⃣ Confirma que o Zeek está instalado dentro da otlab-student. Anota a versão apresentada — escreve-a; importa para os nomes dos eventos que usarás mais tarde.
    - *Pista: `zeek -v` deve reportar a versão `{x.x.x}` ou superior.*

### Fase 1 — Zeek sobre a baseline limpa

- 1️⃣ Dentro da otlab-student, cria uma diretoria de trabalho para as tuas capturas (ex.: `/root/otlab15/` ou sob `/opt/zeek-lab/`). Inicia uma captura Zeek ao vivo na interface do **lado OT**, deixa a baseline correr pelo menos 60 segundos (ainda sem ataques) e depois para com Ctrl-C.
    - *Pista: `zeek -C -i {xxxx} local` corre o Zeek com a política local predefinida.*

- 2️⃣ Lista os ficheiros de log que o Zeek produziu. Para cada um dos três logs abaixo, segue a ligação para a documentação oficial do Zeek e escreve uma frase a descrever o que regista.
    - [`conn.log`](https://docs.zeek.org/en/master/logs/conn.html) — *que nível de detalhe?*
    - [`dnp3.log`](https://docs.zeek.org/en/master/scripts/base/protocols/dnp3/main.zeek.html) — *que campos transporta que o `conn.log` não tem?*
    - [`notice.log`](https://docs.zeek.org/en/master/frameworks/notice.html) — *presente? Porquê ou porque não numa baseline limpa?*
    - *Pista: o Zeek usa TSV por omissão. Para uma vista amigável a JSON que encadeie bem com o `jq`, reinicia com `zeek -C LogAscii::use_json=T -i {xxxx} local` (ex.: `jq -c '{ts, id, service}' < conn.log`).*

- 3️⃣ Usa o `zeek-cut` no `conn.log` da baseline para listar cada par único de `id.orig_h` / `id.resp_h` que viste a comunicar na porta `20000/tcp`. Compara com os endpoints que documentaste no OTLab14 — têm de corresponder.
    - *Pista: `cat conn.log | zeek-cut id.orig_h id.resp_h service | sort -u`. Filtra pelo serviço `{xxxx_xxx}`.*

- 4️⃣ Usa o `zeek-cut` no `dnp3.log` da baseline para listar cada valor único de `fc_request` e `fc_reply`. **Vais ver mais códigos de função do que o teu relatório do OTLab14 mencionava** — investiga porquê antes de continuar.
    - *Pista: no estado estacionário, o teu OTLab14 documentou `{0xXX RxxD}` e `{0xXX RxxxxxxE}`. Os dois extra na baseline são `{0xXX CxxxxxM}` e `{0xXX UNSOLICITED_xxxxxxxE}` — a outstation publica eventos que o master não consultou, e o master confirma-os.*

- 5️⃣ Regista as tuas **allowlists de baseline** numa nota curta e depois abre `scripts/zeek/baseline.zeek` e transfere a nota para as constantes `&redef`. Allowlists vazias fazem com que todos os detetores da Fase 2 disparem em todos os pacotes (`!in {}` é sempre verdadeiro) — preenchê-las é o que dá à Fase 2 um sinal limpo para comparar. (`link_addr_to_ip` é codificada mais tarde, no ciclo 2.3.)
    - `expected_endpoints` — *os dois IPs do OTLab14*
    - `expected_func_codes` — *os quatro códigos que acabaste de observar.*

### Fase 2 — O ciclo disparar-detetar

> [!NOTE]
> Cada ciclo abaixo segue a mesma forma: **(a)** dispara um cenário de ataque a partir do host com `./OTLab15.sh -attack <nome>`, **(b)** observa o desvio nos logs Zeek em bruto sem o teu próprio script de deteção, **(c)** escreve um detetor Zeek que transforma esse desvio num `Notice`, **(d)** repete o ataque e confirma que o teu detetor acendeu o `notice.log`. Para a captura Zeek entre iterações para que cada ronda produza um conjunto de logs limpo.
>


#### 2.1 Ciclo: `scan` → `unknown-endpoint.zeek`

- 1️⃣ A partir de um **segundo terminal no host** (não dentro da otlab-student), dispara `./OTLab15.sh -attack scan` enquanto uma nova captura Zeek ao vivo corre na interface do lado corporativo da ews.

- 2️⃣ Inspeciona o `conn.log` após o ataque. Encontra as linhas que não existiam na baseline. Documenta o `id.orig_h` divergente, a porta de destino, os estados de conexão (`conn_state`) e, aproximadamente, quantos fluxos viste.
    - *Pista: haverá muitos fluxos em estados que significam SYNs que nunca transportaram dados de aplicação.*

- 3️⃣ Escreve `scripts/zeek/detectors/unknown-endpoint.zeek` que emite um `Notice` sempre que um `dnp3_application_request_header` ou `dnp3_application_response_header` dispara numa conexão em que `orig_h` ou `resp_h` está fora do teu conjunto `expected_endpoints`. Repete `-attack scan` com o teu script carregado (`zeek -i <iface> /opt/zeek-lab/local.zeek` depois de fazer `@load` ao teu detetor). Confirma que o `notice.log` mostra o teu alerta.
    - *Pista: o detetor mais simples usa os eventos de conexão, não o `conn.log`. Uma boa extensão: alertar também sobre conexões TCP simples para `{xxxxx}/tcp` a partir de uma origem desconhecida (apanha o `scan` mesmo antes de qualquer PDU DNP3 ser enviada).*

#### 2.2 Ciclo: `fingerprint` → `unexpected-function-code.zeek`

- 1️⃣ Dispara `./OTLab15.sh -attack fingerprint`. Inspeciona os novos valores de `fc_request` no `dnp3.log` face à tua allowlist `expected_func_codes`.
    - *Pista: pelo menos um dos novos códigos de função será `{0xXX DELAY_MEASURE}`. Porque é invulgar um master medir o atraso de ida-e-volta depois de o polling em estado estacionário já ter estabilizado?*

- 2️⃣ Escreve `scripts/zeek/detectors/unexpected-function-code.zeek`. Liga (*hook*) `dnp3_application_request_header(c, is_orig, application, fc)` para a direção de pedido e `dnp3_application_response_header(c, is_orig, application, fc, iin)` para respostas. Emite um `Notice` quando `fc` está fora da allowlist.

- 3️⃣ Repete `-attack fingerprint`. Anota no teu relatório que sondagens dispararam o detetor — e quais **não** dispararam, e porquê.

#### 2.3 Ciclo: `spoof` → `link-vs-ip-mismatch.zeek`

- 1️⃣ Dispara `./OTLab15.sh -attack spoof`. Isto envia um **único** READ à outstation — quase nada visível na contagem de linhas do `dnp3.log`, mas o indício na camada de ligação está lá.

- 2️⃣ Liga (*hook*) `dnp3_header_block(c, is_orig, len, ctrl, dest_addr, src_addr)`. Este evento expõe os endereços de origem/destino da camada de ligação, que o `dnp3.log` não regista. A partir de `c$id$orig_h`/`c$id$resp_h` sabes também o **IP** que emitiu a trama.
    - *Pista: o mapeamento do OTLab14 é `link addr {1} ↔ IP da outstation` e `link addr {2} ↔ IP do master`. Codifica isso como uma `table[count] of addr` em `baseline.zeek`.*

- 3️⃣ Escreve `scripts/zeek/detectors/link-vs-ip-mismatch.zeek` que cruza o endereço de origem da ligação contra o IP esperado para esse endereço de ligação, escolhendo o lado certo via `is_orig`. Emite um `Notice` em caso de incompatibilidade.

- 4️⃣ Repete `-attack spoof` e confirma que o detetor dispara. Como verificação de sanidade, volta a disparar `fingerprint` com este detetor carregado — ele **também** dispara, porque usa a origem de ligação do master legítimo a partir do IP do atacante. Discute numa frase porque esta sobreposição é desejável, e não um defeito.

### Fase 3 — Composição e reflexão

- 1️⃣ Inspeciona `scripts/zeek/local.zeek` — vem pré-ligado para fazer `@load` ao `baseline.zeek` mais os três esqueletos de detetor. Confirma que `zeek -C -i <iface> /opt/zeek-lab/local.zeek` arranca sem erros de script face aos detetores que implementaste.
    - *Pista: os detetores em que não tocaste permanecem esqueletos vazios — o Zeek carrega-os sem problema, só não emitem nada.*

- 2️⃣ Com a stack completa carregada, corre os três cenários em sequência a partir do host: `scan`, `fingerprint`, `spoof` (com uma pausa curta entre cada). Produz um único `notice.log` e extrai uma cronologia de que detetor disparou quando, para que cenário, contra que IP de origem.
    - *Pista: `zeek-cut ts note src | sort` chega para esboçar a cronologia.*

- 3️⃣ Escreve um **resumo de incidente de uma página** estruturado como: (a) os cenários de ataque que correste, em linguagem corrente, (b) os IOCs que colocarias numa regra de SIEM para cada um, (c) que facto da baseline do OTLab14 cada detetor consumiu, (d) o que um atacante teria de fazer para evadir a tua stack e ficar sob cada allowlist. **Este documento é a entrada para o OTLab16.**

- 4️⃣ Parágrafo de reflexão: no teu relatório, argumenta brevemente porque a deteção comportamental baseada em allowlists é adequada a ambientes OT — e onde falharia em ambientes IT. Refere o tamanho real do vocabulário, a estabilidade da baseline e a previsibilidade que observaste.

## 🎯 Competências

**Práticas:** Monitorização de Segurança de Rede (Zeek) · Deteção Comportamental / por Allowlist · Análise de Logs DNP3 · Engenharia de Deteção

**A detetar técnicas do [MITRE ATT&CK for ICS](https://attack.mitre.org/matrices/ics/):**

[![T0846 Remote System Discovery](https://img.shields.io/badge/ATT%26CK_ICS-T0846_Remote_System_Discovery-red)](https://attack.mitre.org/techniques/T0846/)
[![T0888 Remote System Information Discovery](https://img.shields.io/badge/ATT%26CK_ICS-T0888_Remote_System_Information_Discovery-red)](https://attack.mitre.org/techniques/T0888/)
[![T0855 Unauthorized Command Message](https://img.shields.io/badge/ATT%26CK_ICS-T0855_Unauthorized_Command_Message-red)](https://attack.mitre.org/techniques/T0855/)

## 🔖 Nomenclatura

- DNP3: Distributed Network Protocol version 3 — protocolo SCADA amplamente usado em serviços de eletricidade, água e óleo & gás.
- EWS: Estação de trabalho de engenharia (*engineering workstation*) — o host operado por engenheiros de controlo para configurar, programar e monitorizar dispositivos de campo.
- ICS: Sistema de controlo industrial (*industrial control system*).
- IOC: Indicador de compromisso (*indicator of compromise*) — um artefacto observável de rede ou host que sugere uma intrusão.
- IP: Protocolo de Internet (*internet protocol*).
- NSM: Monitorização de segurança de rede (*network security monitoring*) — observação passiva do tráfego para fins forenses e de deteção; o Zeek é uma ferramenta NSM.
- OT: Tecnologia operacional (*operational technology*).
- PDU: Protocol data unit — uma "mensagem" numa dada camada do protocolo (ex.: um fragmento de aplicação DNP3).
- PLC: Controlador lógico programável (*programmable logic controller*).
- RTU: Unidade terminal remota (*remote terminal unit*) — o papel de dispositivo de campo tipicamente desempenhado por uma outstation DNP3.
- SCADA: Supervisão, controlo e aquisição de dados (*supervisory control and data acquisition*).
- TCP: Protocolo de controlo de transmissão (*transmission control protocol*).
- Zeek: Plataforma NSM de código aberto (anteriormente Bro). Analisa protocolos em logs estruturados e expõe uma linguagem de scripting para deteção.

## 🛠️ Utilização

```
Usage: ./OTLab15.sh -start [kali|ubuntu] | -stop | -clean | -run | -restart | -status | -attack <scenario>

  -start     Inicia o ambiente DNP3_Zeek usando a distro indicada (predefinição: ubuntu)
             Opções válidas: kali (rolling) ou ubuntu (22.04)
  -run       Abre um terminal dentro do contentor otlab-student
  -clean     Remove contentores, volumes e a rede (mantém ./scripts/attacks e ./scripts/zeek do lado do host)
  -stop      Para todos os contentores
  -restart   Reinicia contentores previamente parados
  -status    Mostra o estado atual dos contentores
  -attack    Dispara um cenário de ataque controlado a partir do dnp3-attacker
             Cenários válidos: scan fingerprint spoof
```

> [!NOTE]
> Quando executado em **WSL2**, o script deteta automaticamente o ambiente e aplica as regras ao nível do kernel (`bridge-nf-call-iptables=0` e duas regras `DOCKER-USER` ACCEPT) necessárias para que o tráfego seja encaminhado entre as duas *bridges* Docker. Estas regras requerem `sudo` e são revertidas no `-clean`. Em Linux nativo e no Docker Desktop do macOS as regras são ignoradas — as predefinições do Docker já permitem o encaminhamento entre *bridges*.

## Soluções

`scripts/zeek/` traz aquilo em que o estudante trabalha: `baseline.zeek` com allowlists vazias para preencher a partir do OTLab14, e três esqueletos de detetor (comentário de cabeçalho + assinatura de evento comentada, corpo vazio). `local.zeek` vem pré-ligado para fazer `@load` a todos eles, por isso um esqueleto intacto carrega sem problema e simplesmente não emite nada.

As respostas de referência resolvidas para todas as tarefas vivem em `scripts/solutions/` — um `baseline.zeek` preenchido e os três detetores implementados. É a chave do instrutor e **não** é montada na EWS (aí, `/opt/zeek-lab` é `scripts/zeek/`); vê `scripts/solutions/README.md` para a copiar para lá e verificar.
