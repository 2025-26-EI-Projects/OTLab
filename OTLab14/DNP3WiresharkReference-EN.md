# DNP3 — Wireshark Reference

Reference card for analysing DNP3 traffic with Wireshark. Use this alongside `OTLab14.md` when you need to look up a dissector field, a function code, or the layout of a DNP3 frame. This document **describes the protocol generically** — it does not state which addresses, function codes or object groups appear in your specific capture; that is for you to observe.

## 🧩 Frame layout overview

A DNP3 PDU travels inside a single TCP segment (default port `20000/tcp`). The dissector breaks it into three layers:

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

Read top-down when you want to understand *intent* (start with Application). Read bottom-up when you want to understand *delivery* (start with Data Link).

## 🔌 Getting Wireshark to dissect DNP3

If a packet shows only as **TCP** with payload bytes starting in `05 64`, the dissector did not engage. Force it:

> **Right-click on the packet → Decode As… → set "TCP port" to `20000` and "Current" to `DNP 3.0`**

After this, the *Protocol* column displays **DNP 3.0** and the Packet Details pane gains the three layers above.

## 🛰️ Data Link Layer — fixed 10-byte header

| Offset | Field          | Size | Notes                                                                 |
|-------:|----------------|-----:|-----------------------------------------------------------------------|
| 0–1    | Start bytes    | 2 B  | Always `0x05 0x64`. Marks the beginning of every DNP3 frame on the wire. |
| 2      | Length         | 1 B  | Octets in the rest of the frame, **excluding** CRCs. Max 255.         |
| 3      | Control        | 1 B  | DIR / PRM / FCB / FCV bits + a 4-bit data-link function code.         |
| 4–5    | Destination    | 2 B  | Logical address of the receiver (little-endian).                      |
| 6–7    | Source         | 2 B  | Logical address of the sender (little-endian).                        |
| 8–9    | CRC            | 2 B  | 16-bit CRC computed over the previous 8 bytes (link-level only).      |

After this header, the payload is split into 16-byte blocks each followed by its own 2-byte CRC.

> [!NOTE]
> The data-link **addresses are not IP addresses** — they are short numeric IDs that identify the master and the outstation at the DNP3 application level. Two devices can share the same IP and still be distinguished by these addresses, and the same address can roam to a different IP without changing identity. The CRCs here protect against transmission errors only; they are **not** cryptographic.

## 📨 Application Layer — function + objects

Every Application PDU contains:

1. An **Application Control** byte (FIR/FIN/CON/UNS bits + a 4-bit sequence number).
2. A **Function Code** (1 byte) — what the sender wants to do.
3. For responses, an **IIN** (Internal Indications) field — 2 bytes of status flags about the outstation.
4. Zero or more **Object headers**, each followed by their data.

Each Object header carries:

| Field           | Meaning                                                                     |
|-----------------|-----------------------------------------------------------------------------|
| Group           | The class of point (binary input, analog input, counter, etc.).             |
| Variation       | How that point is encoded (with/without flags, 16-bit vs 32-bit, float, …). |
| Qualifier       | How the indices that follow are expressed (range, count, prefixed, …).      |
| Range / Count   | Which indices the data block covers.                                        |
| Data            | The actual point values (interpretation depends on Group + Variation).      |

## 📋 Function code table (commonly seen)

Master → outstation **requests**:

| Code (dec / hex) | Name              | Effect                                                        |
|-----------------:|-------------------|---------------------------------------------------------------|
| 0  / `0x00`      | CONFIRM           | Acknowledges a fragment. Carries no objects.                  |
| 1  / `0x01`      | READ              | Asks the outstation to return point values.                   |
| 2  / `0x02`      | WRITE             | Writes a value (e.g. into the time object, IIN bits).         |
| 3  / `0x03`      | SELECT            | Selects a control point for a subsequent OPERATE.             |
| 4  / `0x04`      | OPERATE           | Operates a previously selected point (Select-Before-Operate). |
| 5  / `0x05`      | DIRECT_OPERATE    | Operates a control point in one shot (no Select).             |
| 6  / `0x06`      | DIRECT_OPERATE_NR | Same as `0x05` but no response expected.                      |
| 13 / `0x0D`      | COLD_RESTART      | Forces a full outstation restart.                             |
| 14 / `0x0E`      | WARM_RESTART      | Forces a partial outstation restart.                          |
| 23 / `0x17`      | DELAY_MEASURE     | Used in time synchronisation.                                 |

Outstation → master **responses**:

| Code (dec / hex) | Name                  | Effect                                                |
|-----------------:|-----------------------|-------------------------------------------------------|
| 129 / `0x81`     | RESPONSE              | Reply to a master's READ (or other) request.          |
| 130 / `0x82`     | UNSOLICITED_RESPONSE  | Spontaneous report from the outstation, not solicited.|
| 131 / `0x83`     | AUTHENTICATE_RESPONSE | Reply within DNP3 Secure Authentication exchanges.    |

> [!NOTE]
> Wireshark prints the symbolic name in parentheses after the hex byte (e.g. `Function Code: READ (0x01)`). You don't need to memorise numbers — but knowing the families (request 0–127, response 128–255) helps you read filters.

## 🗂️ Object groups likely to appear in basic telemetry

(For the full DNP3 object library see the protocol specification — this is a small useful subset.)

| Group | Class              | What it carries                                  |
|------:|--------------------|--------------------------------------------------|
| 1     | Binary Input       | On/off status points (e.g. breaker open/closed). |
| 2     | Binary Input Event | Time-tagged changes of Binary Input points.      |
| 10    | Binary Output      | Output coil status.                              |
| 12    | Binary Command     | Control commands for binary outputs.             |
| 30    | Analog Input       | Measured analog values (voltage, current, …).    |
| 32    | Analog Input Event | Time-tagged changes of Analog Input points.      |
| 41    | Analog Output      | Output analog command points.                    |
| 50    | Time and Date      | Used for time sync.                              |

A *variation* selects the encoding: e.g. Group 30 var 1 = 32-bit int with flags, var 2 = 16-bit int with flags, var 5 = 32-bit float, var 6 = 64-bit float. Wireshark shows the variation as part of the object header.

## 🔍 Wireshark display filters (cheat sheet)

| Goal                                            | Filter                                                |
|-------------------------------------------------|-------------------------------------------------------|
| Only DNP3 frames                                | `dnp3`                                                |
| Only DNP3 to/from a specific TCP endpoint       | `dnp3 && tcp.port == 20000`                           |
| Only frames sourced from one IP                 | `dnp3 && ip.src == <ip>`                              |
| Only requests with a given function code        | `dnp3.al.func == <code>` (e.g. `dnp3.al.func == 1`)   |
| Filter on the data-link source address          | `dnp3.src == <id>`                                    |
| Filter on the data-link destination address     | `dnp3.dst == <id>`                                    |
| Show only frames carrying objects of a group    | `dnp3.al.obj == <group_variation_combined>` *         |

\* Wireshark expresses Group/Variation as a single integer (Group × 256 + Variation). When in doubt, click the field in Packet Details — Wireshark shows the exact filter expression at the bottom of the window.

## 🧭 Useful Wireshark navigation

| What you want                                            | How                                                                              |
|----------------------------------------------------------|----------------------------------------------------------------------------------|
| Inspect raw bytes of a frame                             | Bottom pane (**Packet Bytes**). Click a field to highlight bytes.                |
| See the symbolic name of any DNP3 fiel                   |  **Packet Details**; the filter expression appears at the bottom-left status bar.|
| Measure time between filtered packets                    | **View → Time Display Format → Seconds Since Previous Displayed Packet**.        |
| Visualise periodicity                                    | **Statistics → I/O Graph**, with your filter and a 1 s interval.                 |
| Follow a TCP conversation as bytes                       | Right-click a packet → **Follow → TCP Stream**.                                  |
| Export a single PDU as bytes                             | Right-click in Packet Bytes → **Copy → … as Hex Stream**.                        |

## 🔖 Acronyms

- **PDU**: Protocol Data Unit — one self-contained message at a given protocol layer.
- **APDU / ALPDU**: Application-layer PDU.
- **CRC**: Cyclic Redundancy Check — error-detection code (not cryptographic).
- **IIN**: Internal Indications — outstation status flags carried in responses.
- **SBO**: Select-Before-Operate — two-step control sequence (`SELECT` then `OPERATE`).
- **DIR / PRM / FCB / FCV**: Direction, Primary, Frame Count Bit, Frame Count Valid — control bits in the data-link header.
