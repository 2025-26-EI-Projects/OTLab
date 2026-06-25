# DNP3 — Referência Wireshark

Cartão de consulta para analisar tráfego DNP3 com o Wireshark. Usa-o em conjunto com o `OTLab14.md` quando precisares de procurar um campo do dissecador, um código de função ou a estrutura de uma trama DNP3. Este documento **descreve o protocolo de forma genérica** — não indica que endereços, códigos de função ou grupos de objetos aparecem na tua captura específica; isso é para tu observares.

## 🧩 Visão geral da estrutura da trama

Uma PDU DNP3 viaja dentro de um único segmento TCP (porta predefinida `20000/tcp`). O dissecador divide-a em três camadas:

```
+---------------------------------+
| Application Layer (function +   |
|   objects = the actual data)    |
+---------------------------------+
| Transport Layer (1-byte control |
|   for fragmentation/sequencing) |
+---------------------------------+
| Data Link Layer (start bytes,   |
|   addresses, length, CRC)       |
+---------------------------------+
```

Lê de cima para baixo quando quiseres perceber a *intenção* (começa na Application). Lê de baixo para cima quando quiseres perceber a *entrega* (começa na Data Link).

## 🔌 Fazer o Wireshark dissecar DNP3

Se um pacote aparecer apenas como **TCP** com os bytes de payload a começar em `05 64`, o dissecador não atuou. Força-o:

> **Clica com o botão direito no pacote → Decode As… → define "TCP port" para `20000` e "Current" para `DNP 3.0`**

Depois disto, a coluna *Protocol* mostra **DNP 3.0** e o painel Packet Details ganha as três camadas acima.

## 🛰️ Camada de ligação de dados (Data Link) — cabeçalho fixo de 10 bytes

| Offset | Campo          | Tam. | Notas                                                                 |
|-------:|----------------|-----:|-----------------------------------------------------------------------|
| 0–1    | Start bytes    | 2 B  | Sempre `0x05 0x64`. Marca o início de cada trama DNP3 no fio.          |
| 2      | Length         | 1 B  | Octetos no resto da trama, **excluindo** os CRC. Máx. 255.            |
| 3      | Control        | 1 B  | Bits DIR / PRM / FCB / FCV + um código de função de ligação de 4 bits. |
| 4–5    | Destination    | 2 B  | Endereço lógico do recetor (little-endian).                           |
| 6–7    | Source         | 2 B  | Endereço lógico do emissor (little-endian).                           |
| 8–9    | CRC            | 2 B  | CRC de 16 bits calculado sobre os 8 bytes anteriores (apenas ao nível da ligação). |

Após este cabeçalho, o payload é dividido em blocos de 16 bytes, cada um seguido do seu próprio CRC de 2 bytes.

> [!NOTE]
> Os **endereços da camada de ligação não são endereços IP** — são IDs numéricos curtos que identificam o master e a outstation ao nível da aplicação DNP3. Dois dispositivos podem partilhar o mesmo IP e ainda assim distinguir-se por estes endereços, e o mesmo endereço pode mudar para um IP diferente sem alterar a identidade. Os CRC aqui protegem apenas contra erros de transmissão; **não** são criptográficos.

## 📨 Camada de aplicação (Application) — função + objetos

Cada PDU de aplicação contém:

1. Um byte de **Application Control** (bits FIR/FIN/CON/UNS + um número de sequência de 4 bits).
2. Um **Function Code** (1 byte) — o que o emissor quer fazer.
3. Para respostas, um campo **IIN** (Internal Indications) — 2 bytes de flags de estado sobre a outstation.
4. Zero ou mais **Object headers**, cada um seguido dos seus dados.

Cada Object header transporta:

| Campo           | Significado                                                                  |
|-----------------|-----------------------------------------------------------------------------|
| Group           | A classe do ponto (binary input, analog input, counter, etc.).              |
| Variation       | Como esse ponto é codificado (com/sem flags, 16-bit vs 32-bit, float, …).   |
| Qualifier       | Como os índices seguintes são expressos (range, count, prefixed, …).        |
| Range / Count   | Que índices o bloco de dados abrange.                                        |
| Data            | Os valores reais dos pontos (a interpretação depende de Group + Variation). |

## 📋 Tabela de códigos de função (mais comuns)

**Pedidos** master → outstation:

| Código (dec / hex) | Nome              | Efeito                                                        |
|-------------------:|-------------------|---------------------------------------------------------------|
| 0  / `0x00`        | CONFIRM           | Confirma um fragmento. Não transporta objetos.               |
| 1  / `0x01`        | READ              | Pede à outstation que devolva valores de pontos.             |
| 2  / `0x02`        | WRITE             | Escreve um valor (ex.: no objeto de tempo, bits IIN).        |
| 3  / `0x03`        | SELECT            | Seleciona um ponto de controlo para um OPERATE subsequente.  |
| 4  / `0x04`        | OPERATE           | Opera um ponto previamente selecionado (Select-Before-Operate). |
| 5  / `0x05`        | DIRECT_OPERATE    | Opera um ponto de controlo numa só etapa (sem Select).       |
| 6  / `0x06`        | DIRECT_OPERATE_NR | Igual a `0x05` mas sem resposta esperada.                    |
| 13 / `0x0D`        | COLD_RESTART      | Força um reinício total da outstation.                       |
| 14 / `0x0E`        | WARM_RESTART      | Força um reinício parcial da outstation.                     |
| 23 / `0x17`        | DELAY_MEASURE     | Usado na sincronização de tempo.                             |

**Respostas** outstation → master:

| Código (dec / hex) | Nome                  | Efeito                                                |
|-------------------:|-----------------------|-------------------------------------------------------|
| 129 / `0x81`       | RESPONSE              | Resposta a um pedido READ (ou outro) do master.       |
| 130 / `0x82`       | UNSOLICITED_RESPONSE  | Reporte espontâneo da outstation, não solicitado.     |
| 131 / `0x83`       | AUTHENTICATE_RESPONSE | Resposta dentro das trocas de DNP3 Secure Authentication. |

> [!NOTE]
> O Wireshark mostra o nome simbólico entre parênteses depois do byte hex (ex.: `Function Code: READ (0x01)`). Não precisas de memorizar números — mas conhecer as famílias (pedido 0–127, resposta 128–255) ajuda a ler filtros.

## 🗂️ Grupos de objetos prováveis em telemetria básica

(Para a biblioteca completa de objetos DNP3 consulta a especificação do protocolo — este é um pequeno subconjunto útil.)

| Group | Classe             | O que transporta                                  |
|------:|--------------------|---------------------------------------------------|
| 1     | Binary Input       | Pontos de estado on/off (ex.: disjuntor aberto/fechado). |
| 2     | Binary Input Event | Alterações com marca temporal de pontos Binary Input.    |
| 10    | Binary Output      | Estado das coils de saída.                        |
| 12    | Binary Command     | Comandos de controlo para saídas binárias.        |
| 30    | Analog Input       | Valores analógicos medidos (tensão, corrente, …). |
| 32    | Analog Input Event | Alterações com marca temporal de pontos Analog Input. |
| 41    | Analog Output      | Pontos de comando analógico de saída.             |
| 50    | Time and Date      | Usado para sincronização de tempo.                |

Uma *variation* seleciona a codificação: ex.: Group 30 var 1 = inteiro de 32 bits com flags, var 2 = inteiro de 16 bits com flags, var 5 = float de 32 bits, var 6 = float de 64 bits. O Wireshark mostra a variation como parte do object header.

## 🔍 Filtros de exibição do Wireshark (cheat sheet)

| Objetivo                                        | Filtro                                                |
|-------------------------------------------------|-------------------------------------------------------|
| Apenas tramas DNP3                              | `dnp3`                                                |
| Apenas DNP3 de/para um endpoint TCP específico  | `dnp3 && tcp.port == 20000`                           |
| Apenas tramas com origem num IP                 | `dnp3 && ip.src == <ip>`                              |
| Apenas pedidos com um dado código de função     | `dnp3.al.func == <code>` (ex.: `dnp3.al.func == 1`)   |
| Filtrar pelo endereço de origem da ligação      | `dnp3.src == <id>`                                    |
| Filtrar pelo endereço de destino da ligação     | `dnp3.dst == <id>`                                    |
| Mostrar só tramas com objetos de um grupo       | `dnp3.al.obj == <group_variation_combined>` *         |

\* O Wireshark exprime Group/Variation como um único inteiro (Group × 256 + Variation). Na dúvida, clica no campo em Packet Details — o Wireshark mostra a expressão de filtro exata no fundo da janela.

## 🧭 Navegação útil no Wireshark

| O que queres                                             | Como                                                                              |
|----------------------------------------------------------|----------------------------------------------------------------------------------|
| Inspecionar os bytes em bruto de uma trama               | Painel inferior (**Packet Bytes**). Clica num campo para realçar os bytes.       |
| Ver o nome simbólico de qualquer campo DNP3              | **Packet Details**; a expressão de filtro aparece na barra de estado inferior esquerda. |
| Medir o tempo entre pacotes filtrados                    | **View → Time Display Format → Seconds Since Previous Displayed Packet**.        |
| Visualizar a periodicidade                               | **Statistics → I/O Graph**, com o teu filtro e intervalo de 1 s.                 |
| Seguir uma conversa TCP em bytes                         | Clica com o botão direito num pacote → **Follow → TCP Stream**.                  |
| Exportar uma única PDU em bytes                          | Clica com o botão direito em Packet Bytes → **Copy → … as Hex Stream**.          |

## 🔖 Siglas

- **PDU**: Protocol Data Unit — uma mensagem autónoma numa dada camada do protocolo.
- **APDU / ALPDU**: PDU da camada de aplicação.
- **CRC**: Cyclic Redundancy Check — código de deteção de erros (não criptográfico).
- **IIN**: Internal Indications — flags de estado da outstation transportadas nas respostas.
- **SBO**: Select-Before-Operate — sequência de controlo em dois passos (`SELECT` e depois `OPERATE`).
- **DIR / PRM / FCB / FCV**: Direction, Primary, Frame Count Bit, Frame Count Valid — bits de controlo no cabeçalho da camada de ligação.
