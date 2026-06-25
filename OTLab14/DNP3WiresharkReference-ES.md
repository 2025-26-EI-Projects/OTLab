# DNP3 — Referencia Wireshark

Tarjeta de consulta para analizar tráfico DNP3 con Wireshark. Úsala junto con `OTLab14.md` cuando necesites buscar un campo del disector, un código de función o la estructura de una trama DNP3. Este documento **describe el protocolo de forma genérica** — no indica qué direcciones, códigos de función o grupos de objetos aparecen en tu captura específica; eso es para que tú lo observes.

## 🧩 Visión general de la estructura de la trama

Una PDU DNP3 viaja dentro de un único segmento TCP (puerto por defecto `20000/tcp`). El disector la divide en tres capas:

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

Lee de arriba hacia abajo cuando quieras entender la *intención* (empieza por Application). Lee de abajo hacia arriba cuando quieras entender la *entrega* (empieza por Data Link).

## 🔌 Hacer que Wireshark diseccione DNP3

Si un paquete aparece solo como **TCP** con los bytes de payload empezando en `05 64`, el disector no actuó. Fuérzalo:

> **Clic derecho en el paquete → Decode As… → define "TCP port" a `20000` y "Current" a `DNP 3.0`**

Tras esto, la columna *Protocol* muestra **DNP 3.0** y el panel Packet Details gana las tres capas anteriores.

## 🛰️ Capa de enlace de datos (Data Link) — cabecera fija de 10 bytes

| Offset | Campo          | Tam. | Notas                                                                 |
|-------:|----------------|-----:|-----------------------------------------------------------------------|
| 0–1    | Start bytes    | 2 B  | Siempre `0x05 0x64`. Marca el inicio de cada trama DNP3 en el cable.   |
| 2      | Length         | 1 B  | Octetos en el resto de la trama, **excluyendo** los CRC. Máx. 255.   |
| 3      | Control        | 1 B  | Bits DIR / PRM / FCB / FCV + un código de función de enlace de 4 bits. |
| 4–5    | Destination    | 2 B  | Dirección lógica del receptor (little-endian).                        |
| 6–7    | Source         | 2 B  | Dirección lógica del emisor (little-endian).                          |
| 8–9    | CRC            | 2 B  | CRC de 16 bits calculado sobre los 8 bytes anteriores (solo a nivel de enlace). |

Tras esta cabecera, el payload se divide en bloques de 16 bytes, cada uno seguido de su propio CRC de 2 bytes.

> [!NOTE]
> Las **direcciones de la capa de enlace no son direcciones IP** — son IDs numéricos cortos que identifican al master y a la outstation a nivel de aplicación DNP3. Dos dispositivos pueden compartir la misma IP y aun así distinguirse por estas direcciones, y la misma dirección puede migrar a una IP diferente sin cambiar de identidad. Los CRC aquí protegen solo contra errores de transmisión; **no** son criptográficos.

## 📨 Capa de aplicación (Application) — función + objetos

Cada PDU de aplicación contiene:

1. Un byte de **Application Control** (bits FIR/FIN/CON/UNS + un número de secuencia de 4 bits).
2. Un **Function Code** (1 byte) — lo que el emisor quiere hacer.
3. Para respuestas, un campo **IIN** (Internal Indications) — 2 bytes de flags de estado sobre la outstation.
4. Cero o más **Object headers**, cada uno seguido de sus datos.

Cada Object header transporta:

| Campo           | Significado                                                                  |
|-----------------|-----------------------------------------------------------------------------|
| Group           | La clase del punto (binary input, analog input, counter, etc.).             |
| Variation       | Cómo se codifica ese punto (con/sin flags, 16-bit vs 32-bit, float, …).     |
| Qualifier       | Cómo se expresan los índices que siguen (range, count, prefixed, …).        |
| Range / Count   | Qué índices abarca el bloque de datos.                                       |
| Data            | Los valores reales de los puntos (la interpretación depende de Group + Variation). |

## 📋 Tabla de códigos de función (los más comunes)

**Peticiones** master → outstation:

| Código (dec / hex) | Nombre            | Efecto                                                        |
|-------------------:|-------------------|---------------------------------------------------------------|
| 0  / `0x00`        | CONFIRM           | Confirma un fragmento. No transporta objetos.                |
| 1  / `0x01`        | READ              | Pide a la outstation que devuelva valores de puntos.         |
| 2  / `0x02`        | WRITE             | Escribe un valor (p. ej. en el objeto de tiempo, bits IIN).  |
| 3  / `0x03`        | SELECT            | Selecciona un punto de control para un OPERATE posterior.    |
| 4  / `0x04`        | OPERATE           | Opera un punto previamente seleccionado (Select-Before-Operate). |
| 5  / `0x05`        | DIRECT_OPERATE    | Opera un punto de control en un solo paso (sin Select).      |
| 6  / `0x06`        | DIRECT_OPERATE_NR | Igual que `0x05` pero sin respuesta esperada.                |
| 13 / `0x0D`        | COLD_RESTART      | Fuerza un reinicio total de la outstation.                   |
| 14 / `0x0E`        | WARM_RESTART      | Fuerza un reinicio parcial de la outstation.                 |
| 23 / `0x17`        | DELAY_MEASURE     | Usado en la sincronización de tiempo.                        |

**Respuestas** outstation → master:

| Código (dec / hex) | Nombre                | Efecto                                                |
|-------------------:|-----------------------|-------------------------------------------------------|
| 129 / `0x81`       | RESPONSE              | Respuesta a una petición READ (u otra) del master.    |
| 130 / `0x82`       | UNSOLICITED_RESPONSE  | Reporte espontáneo de la outstation, no solicitado.   |
| 131 / `0x83`       | AUTHENTICATE_RESPONSE | Respuesta dentro de los intercambios de DNP3 Secure Authentication. |

> [!NOTE]
> Wireshark muestra el nombre simbólico entre paréntesis después del byte hex (p. ej. `Function Code: READ (0x01)`). No necesitas memorizar números — pero conocer las familias (petición 0–127, respuesta 128–255) ayuda a leer filtros.

## 🗂️ Grupos de objetos probables en telemetría básica

(Para la biblioteca completa de objetos DNP3 consulta la especificación del protocolo — este es un pequeño subconjunto útil.)

| Group | Clase              | Qué transporta                                    |
|------:|--------------------|---------------------------------------------------|
| 1     | Binary Input       | Puntos de estado on/off (p. ej. interruptor abierto/cerrado). |
| 2     | Binary Input Event | Cambios con marca temporal de puntos Binary Input. |
| 10    | Binary Output      | Estado de las coils de salida.                    |
| 12    | Binary Command     | Comandos de control para salidas binarias.        |
| 30    | Analog Input       | Valores analógicos medidos (tensión, corriente, …). |
| 32    | Analog Input Event | Cambios con marca temporal de puntos Analog Input. |
| 41    | Analog Output      | Puntos de comando analógico de salida.            |
| 50    | Time and Date      | Usado para la sincronización de tiempo.           |

Una *variation* selecciona la codificación: p. ej. Group 30 var 1 = entero de 32 bits con flags, var 2 = entero de 16 bits con flags, var 5 = float de 32 bits, var 6 = float de 64 bits. Wireshark muestra la variation como parte del object header.

## 🔍 Filtros de visualización de Wireshark (cheat sheet)

| Objetivo                                        | Filtro                                                |
|-------------------------------------------------|-------------------------------------------------------|
| Solo tramas DNP3                                | `dnp3`                                                |
| Solo DNP3 desde/hacia un endpoint TCP concreto  | `dnp3 && tcp.port == 20000`                           |
| Solo tramas con origen en una IP                | `dnp3 && ip.src == <ip>`                              |
| Solo peticiones con un código de función dado   | `dnp3.al.func == <code>` (p. ej. `dnp3.al.func == 1`) |
| Filtrar por la dirección de origen del enlace   | `dnp3.src == <id>`                                    |
| Filtrar por la dirección de destino del enlace  | `dnp3.dst == <id>`                                    |
| Mostrar solo tramas con objetos de un grupo     | `dnp3.al.obj == <group_variation_combined>` *         |

\* Wireshark expresa Group/Variation como un único entero (Group × 256 + Variation). En caso de duda, haz clic en el campo en Packet Details — Wireshark muestra la expresión de filtro exacta en la parte inferior de la ventana.

## 🧭 Navegación útil en Wireshark

| Lo que quieres                                           | Cómo                                                                              |
|----------------------------------------------------------|----------------------------------------------------------------------------------|
| Inspeccionar los bytes en bruto de una trama             | Panel inferior (**Packet Bytes**). Haz clic en un campo para resaltar los bytes. |
| Ver el nombre simbólico de cualquier campo DNP3          | **Packet Details**; la expresión de filtro aparece en la barra de estado inferior izquierda. |
| Medir el tiempo entre paquetes filtrados                 | **View → Time Display Format → Seconds Since Previous Displayed Packet**.        |
| Visualizar la periodicidad                               | **Statistics → I/O Graph**, con tu filtro y un intervalo de 1 s.                 |
| Seguir una conversación TCP en bytes                     | Clic derecho en un paquete → **Follow → TCP Stream**.                            |
| Exportar una única PDU en bytes                          | Clic derecho en Packet Bytes → **Copy → … as Hex Stream**.                       |

## 🔖 Siglas

- **PDU**: Protocol Data Unit — un mensaje autónomo en una capa dada del protocolo.
- **APDU / ALPDU**: PDU de la capa de aplicación.
- **CRC**: Cyclic Redundancy Check — código de detección de errores (no criptográfico).
- **IIN**: Internal Indications — flags de estado de la outstation transportadas en las respuestas.
- **SBO**: Select-Before-Operate — secuencia de control en dos pasos (`SELECT` y luego `OPERATE`).
- **DIR / PRM / FCB / FCV**: Direction, Primary, Frame Count Bit, Frame Count Valid — bits de control en la cabecera de la capa de enlace.
