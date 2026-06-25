---
title: "Lab 14 - Emulación del protocolo DNP3 y análisis de tráfico con Wireshark"
description: "Emulación de tráfico DNP3 entre un master y una outstation y su análisis con Wireshark en una red OT."
categories: ["Laboratorios"]
difficulty: "Avanzado"
tags: ["OT", "ICS", "DNP3", "Wireshark", "tshark", "Análisis de Tráfico", "Captura de Paquetes", "SCADA", "Reconocimiento de Red", "Análisis de Protocolo"]
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

## Escenario

Una pequeña empresa eléctrica opera una subestación remota que publica telemetría mediante **DNP3** hacia un centro de control situado en la red corporativa. Tú — el estudiante — estás en la **estación de trabajo de ingeniería (EWS/otlab-student)**, que tiene una interfaz en cada segmento (`OT` y `corporativo`) y reenvía tráfico entre ambos.

Tu tarea en este laboratorio es **comprender cómo el DNP3 transporta la conversación** entre el master y la outstation: dónde se ubica cada host, qué aspecto tienen los intercambios del protocolo en el cable, qué puntos de datos se están consultando (*polled*) y qué *no* hace el protocolo (atención: confidencialidad y autenticación).

Este es el primer laboratorio de una historia en tres partes. El OTLab15 introducirá tráfico anómalo en la misma topología, que detectarás con Zeek. El OTLab16 recorrerá los pasos de respuesta a incidentes desencadenados por lo que el OTLab15 revele.

> [!NOTE]
> Mientras analizas el tráfico capturado, consulta `DNP3WiresharkReference-ES.md` para los nombres de los campos del disector de Wireshark, la estructura de la trama DNP3, la tabla de códigos de función y filtros de visualización útiles. Sirve como tarjeta de consulta — mantenla abierta en otra pestaña.

## 📝 Tareas

> [!WARNING]
> Todas las tareas se realizan dentro de los contenedores del laboratorio. **No apuntes ningún cliente DNP3, escáner o captura a hosts fuera de este laboratorio** — los dispositivos DNP3 en producción son frágiles y los sondeos no autenticados pueden interrumpir procesos industriales reales.

- 1️⃣ Verifica las direcciones IP y las interfaces de la estación `otlab-student` y confirma que tiene un pie en cada subred.
Pista: {xxx.xxx.x0.xxx} y {xxx.xxx.x1.xxx}

- 2️⃣ Usando nmap, identifica los hosts relevantes escaneando las subredes a las que tienes acceso. Intenta averiguar cuál es el segmento OT y cuál el segmento IT. Pista: {xxx.xxx.x0.x/xx} y {xxx.xxx.x1.x/xx}

- 3️⃣ Confirma que el reenvío de IP (*IP forwarding*) está activo en la (`EWS/otlab-student`) haciendo ping a la `outstation` y al `master` para verificar que ambos segmentos son alcanzables.

- 4️⃣ Desde la `EWS/otlab-student`, escanea el host de la outstation con nmap e identifica el número del puerto TCP abierto que sirve el DNP3. Pista: {xxxxx/tcp}

- 5️⃣ Accede al escritorio del otlab-student a través del navegador en http://localhost:3000/, captura tráfico en vivo en su interfaz del lado OT usando Wireshark y aísla la conversación DNP3 entre `master` y `outstation`. Para abrir Wireshark necesitas ejecutar el comando `wireshark` en el emulador de terminal dentro de la estación otlab-student.

- 6️⃣ Identifica las **dos capas DNP3** visibles en cada trama y explica, con tus propias palabras, el papel de cada una.
    - *Pista: la {capa xxxx xxxx} (con los bytes iniciales `0x05 0x64`) y la {capa xxxxxxxxxxx}.*

- 7️⃣ En el intercambio capturado, localiza y documenta:
    - La **dirección del master** y la **dirección de la outstation** en la capa de enlace de datos.
    - El **código de función de aplicación** usado por el master para consultar la outstation.
    - El **código de función de aplicación** usado por la outstation para responder.

- 8️⃣ Decodifica al menos un mensaje de respuesta e **infiere** qué objeto/índice DNP3 corresponde a cada variable de proceso simulada (`Voltage`, `Current`, `BreakerOpen`). El DNP3 no transporta etiquetas en el cable — justifica tu mapeo basándote en el tipo de objeto (Analógico vs Binario), la magnitud de los valores y la dinámica temporal descrita en la nota de abajo.

- 9️⃣ Mide el **intervalo de polling** observado en el cable (a partir de las marcas de tiempo de peticiones consecutivas master→outstation) y confirma que coincide con la cadencia configurada indicada en la nota de abajo.
    - *Pista: en Wireshark, construye un filtro de visualización que mantenga solo las peticiones de poll del master (tramas con origen en el master y con el código de función de aplicación que identificaste en la tarea anterior) y luego ve a* **View → Time Display Format → Seconds Since Previous Displayed Packet** *— la columna* **Time** *mostrará entonces directamente el delta entre polls. Como verificación visual,* **Statistics → I/O Graph** *con el mismo filtro muestra los picos periódicos.*

- 🔟 Inspecciona los bytes de un único mensaje de aplicación DNP3 y responde: *¿Hay algún campo cifrado? ¿Está autenticado el master? ¿Qué aprendería — o cambiaría — un atacante al interceptar este tráfico?*

- 1️⃣1️⃣ Documenta brevemente tus conclusiones (un párrafo) describiendo el comportamiento del protocolo y las propiedades de seguridad (o su ausencia) que observaste. **Este documento es la entrada para el OTLab15.**

> [!NOTE]
> La outstation simula el interruptor de un alimentador: publica una lectura de tensión en el rango 110–130 V y una lectura de corriente en el rango 0,5–15 A cada 5 segundos, y alterna una *flag* `BreakerOpen` cada 20 actualizaciones (≈100 s). El master hace poll cada 10 segundos. Conocer la baseline *esperada* de este laboratorio — incluyendo los rangos de valores — es lo que te permitirá mapear los índices DNP3 a las variables correctas y detectar anomalías en el OTLab15.

## 🎯 Competencias

**Prácticas:** Reconocimiento de Red · Captura de Paquetes (Wireshark) · Disección del Protocolo DNP3 · Análisis de Seguridad OT/ICS

**Mapeadas al [MITRE ATT&CK for ICS](https://attack.mitre.org/matrices/ics/):**

[![T0846 Remote System Discovery](https://img.shields.io/badge/ATT%26CK_ICS-T0846_Remote_System_Discovery-red)](https://attack.mitre.org/techniques/T0846/)
[![T0840 Network Connection Enumeration](https://img.shields.io/badge/ATT%26CK_ICS-T0840_Network_Connection_Enumeration-red)](https://attack.mitre.org/techniques/T0840/)
[![T0842 Network Sniffing](https://img.shields.io/badge/ATT%26CK_ICS-T0842_Network_Sniffing-red)](https://attack.mitre.org/techniques/T0842/)
[![T0861 Point & Tag Identification](https://img.shields.io/badge/ATT%26CK_ICS-T0861_Point_%26_Tag_Identification-red)](https://attack.mitre.org/techniques/T0861/)

## 🔖 Nomenclatura

- DNP3: Distributed Network Protocol version 3 — protocolo SCADA ampliamente usado en servicios eléctricos, de agua y de petróleo y gas.
- EWS: Estación de trabajo de ingeniería (*engineering workstation*) — el host operado por ingenieros de control para configurar, programar y monitorizar dispositivos de campo.
- ICS: Sistema de control industrial (*industrial control system*).
- IP: Protocolo de Internet (*internet protocol*).
- MAC: Control de acceso al medio (*media access control*).
- OT: Tecnología operativa (*operational technology*).
- PLC: Controlador lógico programable (*programmable logic controller*).
- RTU: Unidad terminal remota (*remote terminal unit*) — el papel de dispositivo de campo que normalmente desempeña una outstation DNP3.
- SCADA: Supervisión, control y adquisición de datos (*supervisory control and data acquisition*).
- TCP: Protocolo de control de transmisión (*transmission control protocol*).

## 🛠️ Uso

```
Usage: ./OTLab14.sh -start [kali|ubuntu] | -stop | -clean | -run | -web | -restart | -status

  -start     Inicia el entorno del DNP3Lab usando la distro indicada (por defecto: ubuntu)
             Opciones válidas: kali (rolling) o ubuntu (22.04)
  -run       Abre un terminal dentro del contenedor otlab-student
  -web       Muestra la URL noVNC para acceder al escritorio del estudiante
  -clean     Elimina contenedores, volúmenes y la red
  -stop      Detiene todos los contenedores
  -restart   Reinicia contenedores previamente detenidos
  -status    Muestra el estado actual de los contenedores
```

> [!NOTE]
> Cuando se ejecuta en **WSL2**, el script detecta automáticamente el entorno y aplica las reglas a nivel de kernel (`bridge-nf-call-iptables=0` y dos reglas `DOCKER-USER` ACCEPT) necesarias para que el tráfico se enrute entre los dos *bridges* de Docker. Estas reglas requieren `sudo` y se revierten con `-clean`. En Linux nativo y en Docker Desktop de macOS las reglas se omiten — los valores por defecto de Docker ya permiten el reenvío entre *bridges*.
