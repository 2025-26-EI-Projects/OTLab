---
title: "Lab 15 - Emulación del protocolo DNP3 y detección con Zeek"
description: "Traducir la baseline del OTLab14 en allowlists de Zeek y construir detectores conductuales para tráfico DNP3 malicioso en una red OT."
categories: ["Laboratorios"]
difficulty: "Avanzado"
tags: ["OT", "ICS", "DNP3", "Zeek", "NSM", "Detección de Amenazas", "Ingeniería de Detección", "SCADA", "Detección Conductual", "Allowlisting"]
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

## Escenario

La misma pequeña empresa eléctrica del OTLab14 está ahora preocupada. Después de que tu informe en Wireshark mostrara que el DNP3 no transporta autenticación, ni cifrado, y que tiene un patrón de conversación estable y predecible, la empresa plantea la pregunta obvia: **si algo inusual ocurriera en este cable, ¿nos daríamos siquiera cuenta?**

La pregunta no es académica. El martes pasado, **María, del departamento de Finanzas**, recogió un USB que encontró en el aparcamiento de visitantes y — sin mala intención — lo conectó a su estación de trabajo para ver de quién era. El malware que contenía se comunicó hacia el exterior y se instaló en su PC. Desde ahí tiene línea de visión limpia hacia el segmento corporativo, y este segmento comparte un host con la estación de trabajo de ingeniería OT. Nadie se dio cuenta.

Tú — todavía en la **(`otlab-student`)**, con una interfaz en OT y otra en corporativo — vas a introducir **Zeek**, una herramienta de monitorización de seguridad de red, en la misma topología. Tu tarea *no* es escribir reglas de firma para ataques conocidos. Es traducir la **baseline que documentaste en el OTLab14** en un pequeño conjunto de allowlists, dejar que Zeek te avise cada vez que el cable se desvíe de esa baseline y aprender — probándolos — qué tipos de comportamiento de adversario OT representan realmente esos desvíos.

Desde el host comprometido vas a lanzar escenarios de ataque controlados (en el papel del actor de amenaza); y desde dentro de la otlab-student vas a atraparlos con scripts de Zeek que escribes tú mismo.

> [!NOTE]
> **El entregable del OTLab14 es la entrada aquí.** Mantén tus conclusiones del OTLab14 abiertas: los endpoints esperados, los códigos de función y las direcciones de la capa de enlace que documentaste allí son exactamente lo que codificarás como allowlists de Zeek.

> [!NOTE]
> Consulta `DNP3WiresharkReference-ES.md` para la estructura de la trama DNP3 y las tablas de códigos de función, como antes. Para eventos específicos de Zeek, campos de log y recetas `zeek-cut`, consulta el `DNP3LabZeekReference-ES.md` que acompaña este laboratorio, en su directorio.

## 📝 Tareas

> [!WARNING]
> Todas las tareas se realizan dentro de los contenedores del laboratorio. **No ejecutes ningún escenario de ataque, escáner o captura contra hosts fuera de este laboratorio.** Los scripts de ataque en `scripts/attacks/` emiten PDUs DNP3 reales y válidas; apuntados a equipos de producción, pueden interrumpir procesos industriales reales.

### Fase 0 — Orientación

- 1️⃣ Levanta el laboratorio con `./OTLab15.sh -start` y confirma que los **cuatro** contenedores están corriendo con `./OTLab15.sh -status`. Identifica qué papel desempeña cada contenedor.
    - *Pista: outstation, master, otlab-student y el nuevo papel exclusivo del OTLab15 — {xxxxxxxx}.*

- 2️⃣ Abre una shell en la otlab-student con `./OTLab15.sh -run`. Verifica tus dos interfaces y confirma una en cada subred (trae la respuesta del OTLab14).
    - *Pista: `{xxxx}` mira al segmento corporativo y `{xxxx}` al segmento OT.*

- 3️⃣ Confirma que Zeek está instalado dentro de la otlab-student. Anota la versión mostrada — escríbela; importa para los nombres de los eventos que usarás más tarde.
    - *Pista: `zeek -v` debe reportar la versión `{x.x.x}` o superior.*

### Fase 1 — Zeek sobre la baseline limpia

- 1️⃣ Dentro de la otlab-student, crea un directorio de trabajo para tus capturas (p. ej. `/root/otlab15/` o bajo `/opt/zeek-lab/`). Inicia una captura Zeek en vivo en la interfaz del **lado OT**, deja correr la baseline al menos 60 segundos (todavía sin ataques) y luego detén con Ctrl-C.
    - *Pista: `zeek -C -i {xxxx} local` corre Zeek con la política local por defecto.*

- 2️⃣ Lista los ficheros de log que Zeek produjo. Para cada uno de los tres logs siguientes, sigue el enlace a la documentación oficial de Zeek y escribe una frase describiendo lo que registra.
    - [`conn.log`](https://docs.zeek.org/en/master/logs/conn.html) — *¿qué nivel de detalle?*
    - [`dnp3.log`](https://docs.zeek.org/en/master/scripts/base/protocols/dnp3/main.zeek.html) — *¿qué campos transporta que el `conn.log` no tiene?*
    - [`notice.log`](https://docs.zeek.org/en/master/frameworks/notice.html) — *¿presente? ¿Por qué sí o por qué no en una baseline limpia?*
    - *Pista: Zeek usa TSV por defecto. Para una vista amigable a JSON que encadene bien con `jq`, reinicia con `zeek -C LogAscii::use_json=T -i {xxxx} local` (p. ej. `jq -c '{ts, id, service}' < conn.log`).*

- 3️⃣ Usa `zeek-cut` en el `conn.log` de la baseline para listar cada par único de `id.orig_h` / `id.resp_h` que viste comunicándose en el puerto `20000/tcp`. Compara con los endpoints que documentaste en el OTLab14 — deben coincidir.
    - *Pista: `cat conn.log | zeek-cut id.orig_h id.resp_h service | sort -u`. Filtra por el servicio `{xxxx_xxx}`.*

- 4️⃣ Usa `zeek-cut` en el `dnp3.log` de la baseline para listar cada valor único de `fc_request` y `fc_reply`. **Verás más códigos de función de los que mencionaba tu informe del OTLab14** — investiga por qué antes de continuar.
    - *Pista: en el estado estacionario, tu OTLab14 documentó `{0xXX RxxD}` y `{0xXX RxxxxxxE}`. Los dos adicionales en la baseline son `{0xXX CxxxxxM}` y `{0xXX UNSOLICITED_xxxxxxxE}` — la outstation publica eventos que el master no consultó, y el master los confirma.*

- 5️⃣ Registra tus **allowlists de baseline** en una nota corta y luego abre `scripts/zeek/baseline.zeek` y transfiere la nota a las constantes `&redef`. Allowlists vacías hacen que cada detector de la Fase 2 dispare en cada paquete (`!in {}` es siempre verdadero) — rellenarlas es lo que da a la Fase 2 una señal limpia para comparar. (`link_addr_to_ip` se codifica más tarde, en el ciclo 2.3.)
    - `expected_endpoints` — *las dos IPs del OTLab14*
    - `expected_func_codes` — *los cuatro códigos que acabas de observar.*

### Fase 2 — El ciclo disparar-detectar

> [!NOTE]
> Cada ciclo siguiente tiene la misma forma: **(a)** dispara un escenario de ataque desde el host con `./OTLab15.sh -attack <nombre>`, **(b)** observa el desvío en los logs Zeek en bruto sin tu propio script de detección, **(c)** escribe un detector Zeek que convierta ese desvío en un `Notice`, **(d)** repite el ataque y confirma que tu detector encendió el `notice.log`. Detén la captura Zeek entre iteraciones para que cada ronda produzca un conjunto de logs limpio.
>


#### 2.1 Ciclo: `scan` → `unknown-endpoint.zeek`

- 1️⃣ Desde un **segundo terminal en el host** (no dentro de la otlab-student), dispara `./OTLab15.sh -attack scan` mientras una nueva captura Zeek en vivo corre en la interfaz del lado corporativo de la ews.

- 2️⃣ Inspecciona el `conn.log` tras el ataque. Encuentra las filas que no existían en la baseline. Documenta el `id.orig_h` divergente, el puerto de destino, los estados de conexión (`conn_state`) y, aproximadamente, cuántos flujos viste.
    - *Pista: habrá muchos flujos en estados que significan SYNs que nunca transportaron datos de aplicación.*

- 3️⃣ Escribe `scripts/zeek/detectors/unknown-endpoint.zeek` que emita un `Notice` cada vez que un `dnp3_application_request_header` o `dnp3_application_response_header` dispare en una conexión donde `orig_h` o `resp_h` esté fuera de tu conjunto `expected_endpoints`. Repite `-attack scan` con tu script cargado (`zeek -i <iface> /opt/zeek-lab/local.zeek` tras hacer `@load` a tu detector). Confirma que el `notice.log` muestra tu alerta.
    - *Pista: el detector más simple usa los eventos de conexión, no el `conn.log`. Una buena extensión: alertar también sobre conexiones TCP simples a `{xxxxx}/tcp` desde un origen desconocido (atrapa el `scan` incluso antes de que se envíe cualquier PDU DNP3).*

#### 2.2 Ciclo: `fingerprint` → `unexpected-function-code.zeek`

- 1️⃣ Dispara `./OTLab15.sh -attack fingerprint`. Inspecciona los nuevos valores de `fc_request` en el `dnp3.log` frente a tu allowlist `expected_func_codes`.
    - *Pista: al menos uno de los nuevos códigos de función será `{0xXX DELAY_MEASURE}`. ¿Por qué es inusual que un master mida el retardo de ida y vuelta una vez que el polling en estado estacionario ya se ha asentado?*

- 2️⃣ Escribe `scripts/zeek/detectors/unexpected-function-code.zeek`. Engancha (*hook*) `dnp3_application_request_header(c, is_orig, application, fc)` para la dirección de petición y `dnp3_application_response_header(c, is_orig, application, fc, iin)` para respuestas. Emite un `Notice` cuando `fc` esté fuera de la allowlist.

- 3️⃣ Repite `-attack fingerprint`. Anota en tu informe qué sondeos dispararon el detector — y cuáles **no**, y por qué.

#### 2.3 Ciclo: `spoof` → `link-vs-ip-mismatch.zeek`

- 1️⃣ Dispara `./OTLab15.sh -attack spoof`. Esto envía un **único** READ a la outstation — casi nada visible en el recuento de filas del `dnp3.log`, pero la señal en la capa de enlace está ahí.

- 2️⃣ Engancha (*hook*) `dnp3_header_block(c, is_orig, len, ctrl, dest_addr, src_addr)`. Este evento expone las direcciones de origen/destino de la capa de enlace, que el `dnp3.log` no registra. A partir de `c$id$orig_h`/`c$id$resp_h` sabes también la **IP** que emitió la trama.
    - *Pista: el mapeo del OTLab14 es `link addr {1} ↔ IP de la outstation` y `link addr {2} ↔ IP del master`. Codifica eso como una `table[count] of addr` en `baseline.zeek`.*

- 3️⃣ Escribe `scripts/zeek/detectors/link-vs-ip-mismatch.zeek` que contraste la dirección de origen del enlace con la IP esperada para esa dirección de enlace, eligiendo el lado correcto vía `is_orig`. Emite un `Notice` en caso de discrepancia.

- 4️⃣ Repite `-attack spoof` y confirma que el detector dispara. Como verificación de sanidad, vuelve a disparar `fingerprint` con este detector cargado — **también** dispara, porque usa el origen de enlace del master legítimo desde la IP del atacante. Discute en una frase por qué este solapamiento es deseable, y no un defecto.

### Fase 3 — Composición y reflexión

- 1️⃣ Inspecciona `scripts/zeek/local.zeek` — viene precableado para hacer `@load` al `baseline.zeek` más los tres esqueletos de detector. Confirma que `zeek -C -i <iface> /opt/zeek-lab/local.zeek` arranca sin errores de script frente a los detectores que implementaste.
    - *Pista: los detectores que no tocaste permanecen como esqueletos vacíos — Zeek los carga sin problema, solo que no emiten nada.*

- 2️⃣ Con la pila completa cargada, ejecuta los tres escenarios en secuencia desde el host: `scan`, `fingerprint`, `spoof` (con una pausa corta entre cada uno). Produce un único `notice.log` y extrae una cronología de qué detector disparó cuándo, para qué escenario, contra qué IP de origen.
    - *Pista: `zeek-cut ts note src | sort` basta para esbozar la cronología.*

- 3️⃣ Escribe un **resumen de incidente de una página** estructurado como: (a) los escenarios de ataque que ejecutaste, en lenguaje llano, (b) los IOCs que pondrías en una regla de SIEM para cada uno, (c) qué hecho de la baseline del OTLab14 consumió cada detector, (d) qué tendría que hacer un atacante para evadir tu pila y permanecer bajo cada allowlist. **Este documento es la entrada para el OTLab16.**

- 4️⃣ Párrafo de reflexión: en tu informe, argumenta brevemente por qué la detección conductual basada en allowlists es adecuada para entornos OT — y dónde fallaría en entornos IT. Refiere el tamaño real del vocabulario, la estabilidad de la baseline y la previsibilidad que observaste.

## 🎯 Competencias

**Prácticas:** Monitorización de Seguridad de Red (Zeek) · Detección Conductual / por Allowlist · Análisis de Logs DNP3 · Ingeniería de Detección

**Detectando técnicas del [MITRE ATT&CK for ICS](https://attack.mitre.org/matrices/ics/):**

[![T0846 Remote System Discovery](https://img.shields.io/badge/ATT%26CK_ICS-T0846_Remote_System_Discovery-red)](https://attack.mitre.org/techniques/T0846/)
[![T0888 Remote System Information Discovery](https://img.shields.io/badge/ATT%26CK_ICS-T0888_Remote_System_Information_Discovery-red)](https://attack.mitre.org/techniques/T0888/)
[![T0855 Unauthorized Command Message](https://img.shields.io/badge/ATT%26CK_ICS-T0855_Unauthorized_Command_Message-red)](https://attack.mitre.org/techniques/T0855/)

## 🔖 Nomenclatura

- DNP3: Distributed Network Protocol version 3 — protocolo SCADA ampliamente usado en servicios eléctricos, de agua y de petróleo y gas.
- EWS: Estación de trabajo de ingeniería (*engineering workstation*) — el host operado por ingenieros de control para configurar, programar y monitorizar dispositivos de campo.
- ICS: Sistema de control industrial (*industrial control system*).
- IOC: Indicador de compromiso (*indicator of compromise*) — un artefacto observable de red o host que sugiere una intrusión.
- IP: Protocolo de Internet (*internet protocol*).
- NSM: Monitorización de seguridad de red (*network security monitoring*) — observación pasiva del tráfico con fines forenses y de detección; Zeek es una herramienta NSM.
- OT: Tecnología operativa (*operational technology*).
- PDU: Protocol data unit — un "mensaje" en una capa dada del protocolo (p. ej. un fragmento de aplicación DNP3).
- PLC: Controlador lógico programable (*programmable logic controller*).
- RTU: Unidad terminal remota (*remote terminal unit*) — el papel de dispositivo de campo que normalmente desempeña una outstation DNP3.
- SCADA: Supervisión, control y adquisición de datos (*supervisory control and data acquisition*).
- TCP: Protocolo de control de transmisión (*transmission control protocol*).
- Zeek: Plataforma NSM de código abierto (anteriormente Bro). Analiza protocolos en logs estructurados y expone un lenguaje de scripting para detección.

## 🛠️ Uso

```
Usage: ./OTLab15.sh -start [kali|ubuntu] | -stop | -clean | -run | -restart | -status | -attack <scenario>

  -start     Inicia el entorno DNP3_Zeek usando la distro indicada (por defecto: ubuntu)
             Opciones válidas: kali (rolling) o ubuntu (22.04)
  -run       Abre un terminal dentro del contenedor otlab-student
  -clean     Elimina contenedores, volúmenes y la red (mantiene ./scripts/attacks y ./scripts/zeek del lado del host)
  -stop      Detiene todos los contenedores
  -restart   Reinicia contenedores previamente detenidos
  -status    Muestra el estado actual de los contenedores
  -attack    Dispara un escenario de ataque controlado desde el dnp3-attacker
             Escenarios válidos: scan fingerprint spoof
```

> [!NOTE]
> Cuando se ejecuta en **WSL2**, el script detecta automáticamente el entorno y aplica las reglas a nivel de kernel (`bridge-nf-call-iptables=0` y dos reglas `DOCKER-USER` ACCEPT) necesarias para que el tráfico se enrute entre los dos *bridges* de Docker. Estas reglas requieren `sudo` y se revierten con `-clean`. En Linux nativo y en Docker Desktop de macOS las reglas se omiten — los valores por defecto de Docker ya permiten el reenvío entre *bridges*.

## Soluciones

`scripts/zeek/` trae aquello en lo que trabaja el estudiante: `baseline.zeek` con allowlists vacías para rellenar a partir del OTLab14, y tres esqueletos de detector (comentario de cabecera + firma de evento comentada, cuerpo vacío). `local.zeek` viene precableado para hacer `@load` a todos ellos, por lo que un esqueleto intacto carga sin problema y simplemente no emite nada.

Las respuestas de referencia resueltas para todas las tareas viven en `scripts/solutions/` — un `baseline.zeek` relleno y los tres detectores implementados. Es la clave del instructor y **no** se monta en la EWS (allí, `/opt/zeek-lab` es `scripts/zeek/`); consulta `scripts/solutions/README.md` para copiarla allí y verificar.
