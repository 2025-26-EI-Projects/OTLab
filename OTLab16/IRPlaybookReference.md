# IR Playbook Reference — Resposta a Incidentes alinhada com o NIST para OT

> Cartão de consulta para o OTLab16. Mantém-no aberto noutro separador enquanto
> trabalhas o incidente. Condensa o ciclo de vida de resposta a incidentes do NIST,
> as regras de empenhamento específicas de OT, uma matriz de severidade e as receitas
> de contenção/verificação usadas nas tarefas. Ficheiro companheiro:
> `PurdueModelReference.md` (arquitetura).

---

## 1. O ciclo de vida — NIST SP 800-61r3 / CSF 2.0

O OTLab16 usa o enquadramento da **Rev 3** do *Computer Security Incident Handling*,
que mapeia o ciclo de vida nas **funções do CSF 2.0** em vez do antigo ciclo de
quatro fases.

| Função CSF 2.0  | Papel neste laboratório                                | Quando               |
|------------------|-------------------------------------------------------|----------------------|
| **Govern**       | Papéis, autoridade para agir, quem assina o "tudo limpo" | Preparação (antes)  |
| **Identify**     | Inventário de ativos mapeado a níveis Purdue (Labs 14/15) | Preparação (antes) |
| **Protect**      | Os detetores/allowlists do OTLab15 já implementados   | Preparação (antes)   |
| **Detect**       | Triagem do `notice.log`; declarar o incidente         | Durante              |
| **Respond**      | Cronologia, contenção, erradicação                    | Durante              |
| **Recover**      | Restaurar o processo monitorizado; verificação de baseline | Durante / depois |
| **Improve**      | Lições aprendidas; realimentar correções na baseline  | Depois               |

> [!NOTE]
> **Relação com o SP 800-61r2.** O ciclo clássico r2 — *Preparation → Detection &
> Analysis → Containment, Eradication & Recovery → Post-Incident Activity* — ainda
> mapeia bem: Preparation = *Govern/Identify/Protect*; Detection & Analysis =
> *Detect*; Containment/Eradication/Recovery = *Respond/Recover*; Post-Incident =
> *Improve*. Usa o vocabulário que o modelo do teu relatório exigir.

## 2. O que é diferente na IR em OT (NIST SP 800-82)

O SP 800-82 (*Guide to OT Security*) inverte alguns reflexos de IT. A ordem de
prioridade em OT é **Safety → Disponibilidade → Integridade → Confidencialidade** —
o espelho do padrão C-I-A de IT.

- **Não "desligar a ficha".** Desconectar ou reiniciar um controlador pode disparar
  um processo físico. A disponibilidade do ciclo de controlo é, ela própria, um
  controlo de segurança física.
- **Conter cirurgicamente.** Preserva o tráfego legítimo do processo (o poll
  master↔outstation) enquanto cortas o adversário. Isolamento total é uma paragem
  de serviço, não uma resposta.
- **Dispositivos de campo não podem ser corrigidos a pedido.** A erradicação em
  L0–L1 muitas vezes significa *cortar o alcance agora* e agendar a correção para
  uma janela de manutenção.
- **Coordenar com operações/engenharia.** Nenhuma ação de contenção ou recuperação
  avança sem o autorizador de operações nomeado durante a Preparação.
- **Recuperação = o processo está verificado como normal**, não apenas que o malware
  desapareceu. A telemetria tem de estar de volta à sua gama conhecida-boa.

## 3. Matriz de severidade / escalonamento (ponderada para OT)

Classifica pelo impacto no **processo**, não nos dados. Escolhe a linha mais alta que
se aplique.

| Severidade   | Impacto em Safety / Disponibilidade                  | Exemplo neste laboratório                     |
|--------------|------------------------------------------------------|-----------------------------------------------|
| **Crítica**  | Manipulação de um dispositivo de campo / disjuntor plausível | Controlo falsificado em direção à outstation L1 |
| **Alta**     | O adversário tem um caminho alcançável para OT (L0–L2) | Tráfego do atacante a atravessar o conduit corp→OT |
| **Média**    | Recon/fingerprinting dentro de OT, ainda sem controlo | Códigos de função inesperados no `dnp3.log`   |
| **Baixa**    | Atividade confinada a IT/L3.5, sem alcance a OT      | Scan que nunca sai do segmento corporativo    |

## 4. Checklist de incidente (mapear às 7 ações do laboratório)

- [ ] **Identify** — ativos colocados em níveis Purdue; contacto de operações nomeado *(Ação 1)*
- [ ] **Detect** — `notice.log` triado; incidente declarado com âmbito + níveis Purdue *(Ação 2)*
- [ ] **Respond** — cronologia reconstruída; conduit abusado nomeado *(Ação 3)*
- [ ] **Respond** — conduit cortado cirurgicamente; verificado que o poll continua a fluir *(Ação 4)*
- [ ] **Respond** — ponto de apoio erradicado; vetor inicial fechado *(Ação 5)*
- [ ] **Recover** — verificação de baseline passa; operações autoriza o "tudo limpo" *(Ação 6)*
- [ ] **Improve** — relatório pós-incidente; recomendação de arquitetura *(Ação 7)*

## 5. Receita de contenção (cirúrgica, não total)

O master legítimo vive no segmento **corporativo** (`192.168.21.20`) e o seu poll
atravessa para OT pela EWS dual-homed. Por isso **não podes** dropar corp→OT em bloco
— isso mata o processo. Dropa **apenas o atacante** e aplica-o onde o tráfego é de
facto encaminhado: a **própria chain `FORWARD` da EWS** (a EWS é o conduit). A regra
vai no topo para ganhar às regras de encaminhamento:

```bash
# Applied automatically by ./OTLab16.sh -contain :
docker exec otlab-student iptables -I FORWARD 1 -s 192.168.21.30 -d 192.168.20.0/24 -j DROP
# Lift it with ./OTLab16.sh -restore :
docker exec otlab-student iptables -D FORWARD     -s 192.168.21.30 -d 192.168.20.0/24 -j DROP
```

> [!NOTE]
> **Porquê a EWS e não o host?** Cada pacote corp↔OT é encaminhado pela EWS
> dual-homed (`ip_forward=1`), por isso a sua chain `FORWARD` é o verdadeiro ponto de
> estrangulamento — e comporta-se da mesma forma em WSL2, Linux nativo e macOS, sem
> `sudo` no host. Um DROP na chain `DOCKER-USER` do host **não** funciona em WSL2: o
> tráfego entre bridges é comutado a L2 e, com `bridge-nf-call-iptables=0` (definido
> para que o encaminhamento entre bridges sequer funcione), nunca atravessa o
> netfilter do host — pelo que essa regra fica silenciosamente inerte.

> Verifica que a regra está aplicada e a apanhar pacotes:
> ```bash
> docker exec otlab-student iptables -L FORWARD -n -v --line-numbers | grep 21.30
> ```

## 6. Receita de verificação (Zeek)

Após a contenção, prova **ambas** as metades do compromisso OT a partir da EWS:

```bash
# (a) Attacker is cut — its IP should no longer appear talking to OT:
cat conn.log | zeek-cut id.orig_h id.resp_h service | sort -u
#   -> the 192.168.21.30 -> 192.168.20.10 row is GONE

# (b) Process still runs — master keeps polling the outstation:
cat dnp3.log | zeek-cut ts id.orig_h id.resp_h fc_request | sort | tail
#   -> 192.168.21.20 -> 192.168.20.10 polls continue (~10 s cadence)

# (c) All-clear — no new notices after restore:
cat notice.log | zeek-cut ts note src 2>/dev/null
#   -> empty / no new rows
```

O "tudo limpo" (Ação 6) só é aprovado quando: `notice.log` limpo, endpoints e
códigos de função de volta dentro das allowlists do OTLab14, e telemetria na gama
(**110–130 V**, **0,5–15 A**, disjuntor a alternar na sua cadência de ~100 s).
