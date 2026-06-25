# DNP3 Lab — Referência Zeek

## 1. O que é este documento

Três coisas, por ordem da frequência com que recorrerás a cada uma:

1. **Essenciais de Zeek** (§2) — o vocabulário mínimo de que precisas para ler os eventos que disparam no `dnp3.log` e escrever os detetores que o `local.zeek` está preparado para carregar.
2. **Um detetor totalmente resolvido** (§3) — o `unknown-endpoint.zeek` de ponta a ponta, com cada linha não-óbvia anotada. Usa-o como modelo para os teus.
3. **Esboços de padrão** (§4) — para os restantes detetores centrais (`unexpected-function-code.zeek`, `link-vs-ip-mismatch.zeek`), a superfície de eventos Zeek a ligar mais o idioma-chave, deixando o corpo do handler para tu preencheres.

## 2. Essenciais de Zeek para o OTLab15

### 2.1 O modelo de execução orientado a eventos

Os scripts Zeek são **event handlers**. Não escreves um `main`; escreves funções que disparam quando os analisadores de protocolo do Zeek extraem algo do fluxo de pacotes. Os eventos DNP3 que vais encontrar neste laboratório são:

| Evento                                                                          | Dispara quando                                            |
| ------------------------------------------------------------------------------ | --------------------------------------------------------- |
| `new_connection(c)`                                                            | O Zeek vê o primeiro pacote de qualquer novo fluxo TCP/UDP |
| `dnp3_application_request_header(c, is_orig, application, fc)`                 | O analisador DNP3 processa um cabeçalho de pedido         |
| `dnp3_application_response_header(c, is_orig, application, fc, iin)`           | O analisador DNP3 processa um cabeçalho de resposta       |
| `dnp3_header_block(c, is_orig, len, ctrl, dest_addr, src_addr)`                | Cada cabeçalho de camada de ligação DNP3 — expõe os endereços de ligação |

Cada um deles transporta um `c: connection` como primeiro parâmetro — ver §2.2. Vários handlers podem subscrever o mesmo evento; o Zeek executa-os todos por ordem de registo. A ordem raramente é algo com que tenhas de te preocupar.

### 2.2 O registo `connection`

A maioria dos campos que vais tocar vivem sob `c$id`:

```zeek
c$id$orig_h     # addr — IP que abriu a conexão TCP
c$id$resp_h     # addr — IP que respondeu
c$id$orig_p     # port — porta de origem (ex.: 54321/tcp)
c$id$resp_p     # port — porta de destino (ex.: 20000/tcp)
c$uid           # string — id único da conexão, usado em todos os logs
```

Repara no acessor com cifrão: os registos Zeek são `c$field`, não `c.field`.

`c$id$resp_p == 20000/tcp` é como verificas que a porta de destino é DNP3. O literal `20000/tcp` é um valor `port`, não um inteiro — o sistema de tipos do Zeek marca as portas com o respetivo transporte, por isso `20000/tcp != 20000/udp`.

### 2.3 Conjuntos, tabelas e os operadores `in` / `!in`

Toda a maquinaria de allowlist da baseline assenta em dois tipos de coleção:

```zeek
# Um conjunto de endereços (sem duplicados, sem ordenação).
const expected_endpoints: set[addr] = { 192.168.20.10, 192.168.21.20 } &redef;

# Uma tabela que mapeia endereço de ligação → IP esperado.
const link_addr_to_ip: table[count] of addr = {
    [1] = 192.168.20.10,
    [2] = 192.168.21.20,
} &redef;
```

Os testes de pertença são infixos:

```zeek
if ( my_ip !in expected_endpoints )    { ... }   # IP fora da allowlist
if ( link_addr in link_addr_to_ip )    { ... }   # endereço de ligação conhecido
```

A consulta de tabela é `t[k]`, idêntica à da maioria das linguagens. `&redef` torna a constante substituível a partir de outro script (útil quando o `local.zeek` decide alargar a allowlist para uma execução específica sem editar o `baseline.zeek`).

### 2.4 Módulos e namespacing

Cada detetor neste laboratório pertence a `DNP3Baseline` (as allowlists no `baseline.zeek`) ou a `DNP3Anomaly` (os notices que os detetores levantam). Para colocar uma declaração num módulo, começa o ficheiro com `module X;`:

```zeek
module DNP3Anomaly;

export {
    # declarações exportadas — visíveis como DNP3Anomaly::Foo a partir do exterior
}
```

As referências entre módulos usam `Module::name`:

```zeek
if ( c$id$orig_h !in DNP3Baseline::expected_endpoints ) { ... }
```

Porquê um único módulo `DNP3Anomaly` partilhado entre três detetores, em vez de três módulos separados? Porque todos os notices pertencem a uma família lógica — o namespace `DNP3Anomaly::Unknown_Endpoint`, `DNP3Anomaly::Unexpected_Function_Code`, ... lê-se melhor no `notice.log` do que `UnknownEndpoint::Note`, `UnexpectedFC::Note`, ...

### 2.5 A framework Notice

Levantar um alerta é uma só chamada de função:

```zeek
NOTICE([$note = DNP3Anomaly::Unknown_Endpoint,
        $msg  = "DNP3 endpoint outside expected set",
        $conn = c]);
```

Convenções-chave:

- `$note` — um valor enum que declaraste com `redef enum Notice::Type += { Foo };` dentro de um bloco `export {}`.
- `$msg` — string livre legível por humanos. Usa `fmt(...)` para formatação (como o `printf`); `%s` funciona para `addr` e `string`, `%d` para `count`.
- `$conn = c` — passa a conexão inteira. A framework Notice preenche então automaticamente `id.orig_h`, `id.resp_h`, `uid` e o timestamp no `notice.log`. Sem `$conn`, terias de definir `$src` e `$dst` à mão.

A supressão é automática: o Zeek, por omissão, silencia notices duplicados (mesmo `note`, mesmo `src`, mesmo `dst`) durante uma hora. Um ataque `scan` com 1024 SYNs de um IP produz exatamente um notice `Unknown_Endpoint`, não 1024. Quase nunca precisas de o substituir.

## 3. Exemplo resolvido — `unknown-endpoint.zeek`

O ficheiro completo:

```zeek
##! Notice when a DNP3 conversation involves an endpoint outside
##! DNP3Baseline::expected_endpoints.
##!
##! References:
##!   - DNP3 events:      https://docs.zeek.org/en/master/scripts/base/bif/plugins/Zeek_DNP3.events.bif.zeek.html
##!   - Notice framework: https://docs.zeek.org/en/master/frameworks/notice.html

@load ../baseline.zeek

module DNP3Anomaly;

export {
    redef enum Notice::Type += {
        ## A DNP3 request or response was seen with an endpoint not in
        ## DNP3Baseline::expected_endpoints.
        Unknown_Endpoint,
    };
}

# Shared check. c$id$orig_h is the IP that opened the TCP connection;
# c$id$resp_h is the side that answered. Either being outside the allowlist
# is enough to flag the whole flow. `kind` is just the word ("request" /
# "response") that ends up in the notice, so request and response can share
# one body instead of two near-identical copies.
function check_endpoints(c: connection, kind: string, fc: count)
    {
    local o = c$id$orig_h;
    local r = c$id$resp_h;

    if ( o !in DNP3Baseline::expected_endpoints ||
         r !in DNP3Baseline::expected_endpoints )
        NOTICE([$note = Unknown_Endpoint,
                $msg  = fmt("DNP3 %s on flow %s -> %s (fc=%d): endpoint outside expected set",
                            kind, o, r, fc),
                $conn = c]);
    }

# Request side.
event dnp3_application_request_header(c: connection, is_orig: bool,
                                       application: count, fc: count)
    {
    check_endpoints(c, "request", fc);
    }

# Response side — same check, different event. We must cover both because the
# DNP3 spec lets the outstation publish unsolicited responses; a spoofed one
# would otherwise slip through.
event dnp3_application_response_header(c: connection, is_orig: bool,
                                        application: count, fc: count, iin: count)
    {
    check_endpoints(c, "response", fc);
    }
```

### Análise — as quatro linhas que importam

1. **`@load ../baseline.zeek`** — traz as constantes de allowlist. Sem isto, `DNP3Baseline::expected_endpoints` fica por resolver e o Zeek recusa-se a arrancar.
2. **`module DNP3Anomaly; export { redef enum Notice::Type += { ... } }`** — adiciona um novo valor ao enum global `Notice::Type`. O bloco `export` é necessário para que o valor do enum seja visível fora do módulo (para o `notice.log` poder etiquetar linhas com ele).
3. **`o !in DNP3Baseline::expected_endpoints || r !in ...`** — teste de pertença a conjunto. Qualquer um dos lados fora chega para sinalizar a conversa. Usar ligações `local` (`o`, `r`) evita repetir `c$id$orig_h` e encurta os argumentos do `fmt`.
4. **`function check_endpoints(c, kind, fc)`** — os eventos de pedido e de resposta carregam a *mesma* verificação, por isso o corpo vive num único auxiliar e cada handler é uma só chamada. `kind` é a única coisa que difere (a palavra no notice), passada como `string`. Um único sítio a corrigir se a regra mudar — sem cópia a dessincronizar-se.
5. **`NOTICE([$note=..., $msg=..., $conn=c])`** — construção de literal-registo passada a uma função. `$conn=c` é o truque de preenchimento automático da §2.5.

### Extensão — apanhar o `scan` antes de qualquer PDU DNP3 ser processada

O ataque `scan` despeja SYNs TCP na porta 20000. O handshake nunca completa, por isso nenhum `dnp3_application_request_header` dispara — e o detetor acima fica em silêncio durante a varredura pura. Para os apanhar, subscreve `new_connection` e sinaliza qualquer fluxo com `c$id$resp_p == 20000/tcp` cujo `orig_h` esteja fora da allowlist. Dois eventos, um detetor, cobertura total. Deixado como exercício.

## 4. Esboços de padrão para os outros ciclos centrais

### 4.1 `unexpected-function-code.zeek` (ciclo fingerprint)

**Superfície de eventos.** Os mesmos dois eventos da §3: `dnp3_application_request_header` expõe `fc: count` diretamente; `dnp3_application_response_header` também.

**Onde o padrão atua.** `fc_request` no `dnp3.log` é o nome textual (`READ`, `RESPONSE`, ...). `fc` no evento é o código numérico. A tua allowlist tem de usar os números (0x01, 0x81, 0x00, 0x82) — vê a pista no `baseline.zeek`.

**Caso-limite.** O parser binpac do Zeek pode saltar o evento de pedido para códigos de função não atribuídos. O lado de resposta ainda dispara com uma resposta de erro `iin` — esse é o teu sinal de recurso. Vê a pista na tarefa 2.2 do OTLab15.md.

### 4.2 `link-vs-ip-mismatch.zeek` (ciclo spoof)

**Superfície de eventos.** `dnp3_header_block` — o Zeek expõe os endereços de origem e destino da camada de ligação DNP3, que nunca aparecem no `dnp3.log`. Esta é a única forma de cruzar a identidade da camada de ligação contra o IP que transporta a trama.

**Porque importa o ramo `is_orig`.** Uma trama DNP3 pode vir de qualquer lado da conexão TCP. `is_orig=T` significa que o originador enviou a trama, por isso a origem de ligação mapeia para `c$id$orig_h`. `is_orig=F` inverte. Saltar este ramo produz falsos positivos em cada resposta legítima.

## 5. Receitas `zeek-cut` e JSON

O `zeek-cut` extrai colunas nomeadas dos logs TSV predefinidos do Zeek. A flag `-d` reescreve `ts` de epoch para ISO 8601. Encadeia para `column -t -s $'\t'` para saída alinhada.

```bash
# notice.log — the detector outputs
zeek-cut -d ts note src dst msg < notice.log | column -t -s $'\t'

# conn.log — every flow Zeek saw, with the DPD service name
zeek-cut -d ts uid id.orig_h id.resp_h id.resp_p proto service conn_state < conn.log

# dnp3.log — DNP3 function codes on the wire
zeek-cut -d ts uid id.orig_h id.resp_h fc_request fc_reply < dnp3.log

# Unique note types fired in a run (sanity check)
zeek-cut note < notice.log | sort -u
```

Se preferires JSON, reinicia o Zeek com a flag JSON do LogAscii e usa `jq`:

```bash
zeek -C LogAscii::use_json=T -i eth1 /opt/zeek-lab/local.zeek
jq -c '{ts, note, src, dst, msg}' < notice.log
```

## 6. Documentação oficial do Zeek

- [conn.log](https://docs.zeek.org/en/master/logs/conn.html) — campos e estados de conexão
- [dnp3.log fields](https://docs.zeek.org/en/master/scripts/base/protocols/dnp3/main.zeek.html) — definição do registo `DNP3::Info`
- [DNP3 events](https://docs.zeek.org/en/master/scripts/base/bif/plugins/Zeek_DNP3.events.bif.zeek.html) — assinatura de cada evento `dnp3_*`
- [Notice framework](https://docs.zeek.org/en/master/frameworks/notice.html) — `Notice::Info`, `Notice::policy`, supressão
- [Scripting language reference](https://docs.zeek.org/en/master/script-reference/index.html) — tipos, operadores, registos, `&redef`
