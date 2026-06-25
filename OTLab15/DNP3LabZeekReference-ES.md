# DNP3 Lab — Referencia Zeek

## 1. Qué es este documento

Tres cosas, por orden de la frecuencia con que recurrirás a cada una:

1. **Esenciales de Zeek** (§2) — el vocabulario mínimo que necesitas para leer los eventos que disparan en el `dnp3.log` y escribir los detectores que el `local.zeek` está preparado para cargar.
2. **Un detector totalmente resuelto** (§3) — el `unknown-endpoint.zeek` de principio a fin, con cada línea no obvia anotada. Úsalo como plantilla para los tuyos.
3. **Bocetos de patrón** (§4) — para los detectores centrales restantes (`unexpected-function-code.zeek`, `link-vs-ip-mismatch.zeek`), la superficie de eventos Zeek a enganchar más el idioma clave, dejando el cuerpo del handler para que lo rellenes.

## 2. Esenciales de Zeek para el OTLab15

### 2.1 El modelo de ejecución orientado a eventos

Los scripts Zeek son **event handlers**. No escribes un `main`; escribes funciones que disparan cuando los analizadores de protocolo de Zeek extraen algo del flujo de paquetes. Los eventos DNP3 que encontrarás en este laboratorio son:

| Evento                                                                          | Dispara cuando                                            |
| ------------------------------------------------------------------------------ | --------------------------------------------------------- |
| `new_connection(c)`                                                            | Zeek ve el primer paquete de cualquier nuevo flujo TCP/UDP |
| `dnp3_application_request_header(c, is_orig, application, fc)`                 | El analizador DNP3 procesa una cabecera de petición       |
| `dnp3_application_response_header(c, is_orig, application, fc, iin)`           | El analizador DNP3 procesa una cabecera de respuesta      |
| `dnp3_header_block(c, is_orig, len, ctrl, dest_addr, src_addr)`                | Cada cabecera de capa de enlace DNP3 — expone las direcciones de enlace |

Cada uno de ellos transporta un `c: connection` como primer parámetro — ver §2.2. Varios handlers pueden suscribirse al mismo evento; Zeek los ejecuta todos por orden de registro. El orden rara vez es algo de lo que tengas que preocuparte.

### 2.2 El registro `connection`

La mayoría de los campos que tocarás viven bajo `c$id`:

```zeek
c$id$orig_h     # addr — IP que abrió la conexión TCP
c$id$resp_h     # addr — IP que respondió
c$id$orig_p     # port — puerto de origen (p. ej., 54321/tcp)
c$id$resp_p     # port — puerto de destino (p. ej., 20000/tcp)
c$uid           # string — id único de la conexión, usado en todos los logs
```

Fíjate en el accesor con signo de dólar: los registros Zeek son `c$field`, no `c.field`.

`c$id$resp_p == 20000/tcp` es como compruebas que el puerto de destino es DNP3. El literal `20000/tcp` es un valor `port`, no un entero — el sistema de tipos de Zeek marca los puertos con su transporte, por lo que `20000/tcp != 20000/udp`.

### 2.3 Conjuntos, tablas y los operadores `in` / `!in`

Toda la maquinaria de allowlist de la baseline se apoya en dos tipos de colección:

```zeek
# Un conjunto de direcciones (sin duplicados, sin ordenación).
const expected_endpoints: set[addr] = { 192.168.20.10, 192.168.21.20 } &redef;

# Una tabla que mapea dirección de enlace → IP esperada.
const link_addr_to_ip: table[count] of addr = {
    [1] = 192.168.20.10,
    [2] = 192.168.21.20,
} &redef;
```

Las pruebas de pertenencia son infijas:

```zeek
if ( my_ip !in expected_endpoints )    { ... }   # IP fuera de la allowlist
if ( link_addr in link_addr_to_ip )    { ... }   # dirección de enlace conocida
```

La consulta de tabla es `t[k]`, idéntica a la de la mayoría de los lenguajes. `&redef` hace la constante sustituible desde otro script (útil cuando el `local.zeek` decide ampliar la allowlist para una ejecución específica sin editar el `baseline.zeek`).

### 2.4 Módulos y namespacing

Cada detector en este laboratorio pertenece a `DNP3Baseline` (las allowlists en `baseline.zeek`) o a `DNP3Anomaly` (los notices que los detectores levantan). Para colocar una declaración en un módulo, empieza el fichero con `module X;`:

```zeek
module DNP3Anomaly;

export {
    # declaraciones exportadas — visibles como DNP3Anomaly::Foo desde el exterior
}
```

Las referencias entre módulos usan `Module::name`:

```zeek
if ( c$id$orig_h !in DNP3Baseline::expected_endpoints ) { ... }
```

¿Por qué un único módulo `DNP3Anomaly` compartido entre tres detectores, en lugar de tres módulos separados? Porque todos los notices pertenecen a una familia lógica — el namespace `DNP3Anomaly::Unknown_Endpoint`, `DNP3Anomaly::Unexpected_Function_Code`, ... se lee mejor en el `notice.log` que `UnknownEndpoint::Note`, `UnexpectedFC::Note`, ...

### 2.5 El framework Notice

Levantar una alerta es una sola llamada de función:

```zeek
NOTICE([$note = DNP3Anomaly::Unknown_Endpoint,
        $msg  = "DNP3 endpoint outside expected set",
        $conn = c]);
```

Convenciones clave:

- `$note` — un valor enum que declaraste con `redef enum Notice::Type += { Foo };` dentro de un bloque `export {}`.
- `$msg` — string libre legible por humanos. Usa `fmt(...)` para formateo (como `printf`); `%s` funciona para `addr` y `string`, `%d` para `count`.
- `$conn = c` — pasa la conexión entera. El framework Notice rellena entonces automáticamente `id.orig_h`, `id.resp_h`, `uid` y el timestamp en el `notice.log`. Sin `$conn`, tendrías que definir `$src` y `$dst` a mano.

La supresión es automática: Zeek, por defecto, silencia notices duplicados (mismo `note`, mismo `src`, mismo `dst`) durante una hora. Un ataque `scan` con 1024 SYNs de una IP produce exactamente un notice `Unknown_Endpoint`, no 1024. Casi nunca necesitas sustituirlo.

## 3. Ejemplo resuelto — `unknown-endpoint.zeek`

El fichero completo:

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

### Análisis — las cuatro líneas que importan

1. **`@load ../baseline.zeek`** — trae las constantes de allowlist. Sin esto, `DNP3Baseline::expected_endpoints` queda sin resolver y Zeek se niega a arrancar.
2. **`module DNP3Anomaly; export { redef enum Notice::Type += { ... } }`** — añade un nuevo valor al enum global `Notice::Type`. El bloque `export` es necesario para que el valor del enum sea visible fuera del módulo (para que el `notice.log` pueda etiquetar filas con él).
3. **`o !in DNP3Baseline::expected_endpoints || r !in ...`** — prueba de pertenencia a conjunto. Cualquiera de los lados fuera basta para señalar la conversación. Usar enlaces `local` (`o`, `r`) evita repetir `c$id$orig_h` y acorta los argumentos del `fmt`.
4. **`function check_endpoints(c, kind, fc)`** — los eventos de petición y de respuesta llevan la *misma* comprobación, por lo que el cuerpo vive en un único auxiliar y cada handler es una sola llamada. `kind` es lo único que difiere (la palabra en el notice), pasada como `string`. Un único sitio que corregir si la regla cambia — sin copia que se desincronice.
5. **`NOTICE([$note=..., $msg=..., $conn=c])`** — construcción de literal-registro pasada a una función. `$conn=c` es el truco de autorrelleno de la §2.5.

### Extensión — atrapar el `scan` antes de que se procese cualquier PDU DNP3

El ataque `scan` arroja SYNs TCP al puerto 20000. El handshake nunca se completa, por lo que ningún `dnp3_application_request_header` dispara — y el detector anterior permanece en silencio durante el barrido puro. Para atraparlos, suscríbete a `new_connection` y señala cualquier flujo con `c$id$resp_p == 20000/tcp` cuyo `orig_h` esté fuera de la allowlist. Dos eventos, un detector, cobertura total. Dejado como ejercicio.

## 4. Bocetos de patrón para los otros ciclos centrales

### 4.1 `unexpected-function-code.zeek` (ciclo fingerprint)

**Superficie de eventos.** Los mismos dos eventos de la §3: `dnp3_application_request_header` expone `fc: count` directamente; `dnp3_application_response_header` también.

**Dónde actúa el patrón.** `fc_request` en el `dnp3.log` es el nombre textual (`READ`, `RESPONSE`, ...). `fc` en el evento es el código numérico. Tu allowlist debe usar los números (0x01, 0x81, 0x00, 0x82) — ve la pista en el `baseline.zeek`.

**Caso límite.** El parser binpac de Zeek puede saltarse el evento de petición para códigos de función no asignados. El lado de respuesta aún dispara con una respuesta de error `iin` — esa es tu señal de respaldo. Ve la pista en la tarea 2.2 del OTLab15.md.

### 4.2 `link-vs-ip-mismatch.zeek` (ciclo spoof)

**Superficie de eventos.** `dnp3_header_block` — Zeek expone las direcciones de origen y destino de la capa de enlace DNP3, que nunca aparecen en el `dnp3.log`. Esta es la única forma de contrastar la identidad de la capa de enlace con la IP que transporta la trama.

**Por qué importa la rama `is_orig`.** Una trama DNP3 puede venir de cualquier lado de la conexión TCP. `is_orig=T` significa que el originador envió la trama, por lo que el origen de enlace mapea a `c$id$orig_h`. `is_orig=F` lo invierte. Saltarse esta rama produce falsos positivos en cada respuesta legítima.

## 5. Recetas `zeek-cut` y JSON

El `zeek-cut` extrae columnas con nombre de los logs TSV por defecto de Zeek. La flag `-d` reescribe `ts` de epoch a ISO 8601. Encadena a `column -t -s $'\t'` para una salida alineada.

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

Si prefieres JSON, reinicia Zeek con la flag JSON del LogAscii y usa `jq`:

```bash
zeek -C LogAscii::use_json=T -i eth1 /opt/zeek-lab/local.zeek
jq -c '{ts, note, src, dst, msg}' < notice.log
```

## 6. Documentación oficial de Zeek

- [conn.log](https://docs.zeek.org/en/master/logs/conn.html) — campos y estados de conexión
- [dnp3.log fields](https://docs.zeek.org/en/master/scripts/base/protocols/dnp3/main.zeek.html) — definición del registro `DNP3::Info`
- [DNP3 events](https://docs.zeek.org/en/master/scripts/base/bif/plugins/Zeek_DNP3.events.bif.zeek.html) — firma de cada evento `dnp3_*`
- [Notice framework](https://docs.zeek.org/en/master/frameworks/notice.html) — `Notice::Info`, `Notice::policy`, supresión
- [Scripting language reference](https://docs.zeek.org/en/master/script-reference/index.html) — tipos, operadores, registros, `&redef`
