---
title: "Lab 16 - Emulación del protocolo DNP3 y respuesta a incidentes"
description: "Gestionar una intrusión OT en vivo a través del ciclo de vida NIST SP 800-61r3 / CSF 2.0: triaje, contención quirúrgica que preserva el proceso DNP3, recuperación e informe post-incidente."
categories: ["Laboratorios"]
difficulty: "Avanzado"
tags: ["OT", "ICS", "DNP3", "Respuesta a Incidentes", "NIST SP 800-61", "NIST SP 800-82", "CSF 2.0", "Modelo Purdue", "Contención", "SCADA"]
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

## Escenario

Este es el **tercer y último laboratorio** de la historia de la subestación. En el OTLab14 leíste DNP3 del cable con Wireshark y anotaste la baseline. En el OTLab15 convertiste esa baseline en allowlists de Zeek y construiste detectores conductuales — y lo último que produjiste fue un `notice.log` y un resumen de incidente de una página.

**Esta vez la alarma es real.** El `notice.log` ya no es un artefacto de aula: es la **detección que abre un incidente en vivo**. La intrusión que comenzó cuando **María, de Finanzas**, conectó el USB del aparcamiento se ha abierto camino por el segmento corporativo y ahora está sondeando — y falsificando (*spoof*) — hacia la OT, donde un interruptor de alimentador real puede ser accionado. Dejas de ser el ingeniero de detección y pasas a ser el **responsable de respuesta a incidentes**.

Vas a gestionar el incidente a través del ciclo de vida del **[NIST SP 800-61r3](https://csrc.nist.gov/pubs/sp/800/61/r3/final)**, expresado como las **funciones del [CSF 2.0](https://csrc.nist.gov/pubs/cswp/29/the-nist-cybersecurity-framework-csf-20/final)**: *Govern · Identify · Protect* como **Preparación**, luego *Detect · Respond · Recover* como la **Respuesta a Incidentes** en vivo, cerrando con *Improve*. Para el ángulo OT te apoyarás en el **[NIST SP 800-82](https://csrc.nist.gov/pubs/sp/800/82/r3/final)** (Guide to OT Security).

La lección más importante de este laboratorio: **en OT, la respuesta a incidentes no es "desenchufar".** Hay *seguridad física (safety)* y *disponibilidad* que proteger — el polling legítimo master↔outstation **debe seguir funcionando** mientras expulsas al atacante. Ese compromiso es lo que hace la IR en OT diferente de la IR en IT, y es el hilo conductor de todas las tareas de abajo.

> [!NOTE]
> **El entregable del OTLab15 es la entrada aquí.** Mantén tu `notice.log` y el resumen de incidente de una página del OTLab15 abiertos — son ellos los que *desencadenan* este incidente. Mantén también la baseline del OTLab14 abierta (endpoints, códigos de función, rangos de valores); la usarás de nuevo para declarar el "todo despejado".

> [!NOTE]
> Dos compañeros viven en el directorio de este laboratorio. `IRPlaybookReference-ES.md` resume el ciclo de vida [NIST SP 800-61r3](https://csrc.nist.gov/pubs/sp/800/61/r3/final) / [800-82](https://csrc.nist.gov/pubs/sp/800/82/r3/final), la matriz de severidad OT y las recetas de contención/verificación. `PurdueModelReference-ES.md` es el corazón visual del laboratorio — la arquitectura *actual (insegura)* vs *objetivo (endurecida)*. Registra tu trabajo en `IR_Template-ES.md` (tres artefactos: registro corriente, registro de decisión de contención, informe de incidente).

## 📝 Tareas

> [!WARNING]
> Todas las tareas se realizan dentro de los contenedores del laboratorio. **No ejecutes ningún escenario de ataque, escáner o regla de contención contra hosts fuera de este laboratorio.** El `-incident` emite PDUs DNP3 reales y válidas y el `-contain` edita reglas de firewall del host; apuntados a equipos de producción, pueden interrumpir procesos industriales reales.

Las siete acciones de abajo están etiquetadas, cada una, con su función CSF 2.0 y la superposición Purdue que ejercita.

### Preparación — `Govern` · `Identify`  *(opcional, hacer una vez)*

- 1️⃣ **Acción 1 — Mapear el parque a Purdue, antes del incidente.** Levanta el laboratorio con `./OTLab16.sh -start` y `-status` (los cuatro contenedores del OTLab15 regresan). Usando `PurdueModelReference-ES.md`, coloca cada host de los Labs 14/15 en un nivel Purdue y escríbelo en la cabecera del **Artefacto 1** (registro corriente). Nombra ya el **contacto de operaciones / autorizador** — la persona a la que debes llamar antes de cortar lo que sea.
    - *Pista: la outstation/RTU es L`{x}`, el master es L`{x}`, la EWS es el host de frontera L`{x.x}` y el interruptor es L`{x}`. El plan de IR debe nombrar un contacto de operaciones `{antes|después}` del incidente, no durante.*

### Detección (Detect)

> [!NOTE]
> **Abre el incidente en vivo — arranca primero el sensor.** La EWS solo registra el ataque si Zeek ya está capturando cuando ocurre. Entra en la EWS con `./OTLab16.sh -run`, encuentra sus interfaces con `ip -br a` y luego inicia la política lista en un directorio de trabajo, dejándola corriendo:
> ```
> mkdir -p ~/ir && cd ~/ir
> zeek -i <iface> /opt/zeek-lab/local.zeek
> ```
> El enlace orientado a OT (`192.168.20.100`) es el que transporta el spoof hasta L1. Con Zeek capturando, abre un **segundo terminal en el host** y dispara la kill-chain:
> ```
> ./OTLab16.sh -incident
> ```
> Cuando termine, detén Zeek con `Ctrl+C`; `conn.log`, `dnp3.log` y `notice.log` esperan en `~/ir` — esa es la detección que abre este incidente. *(¿Prefieres reutilizar el `notice.log` que produjiste en el OTLab15? Sáltate el `-incident` y apunta el triaje de abajo a ese fichero.)*

- 2️⃣ **Acción 2 — Triaje y declaración.** Abre el `notice.log` que acabas de generar con el `-incident` (o reutiliza el del OTLab15). Decide: ¿incidente real o falso positivo? Justifica con evidencia de `conn.log`/`dnp3.log`. Luego **declara el incidente** — indica el alcance y **qué nivel(es) Purdue están afectados**. En OT la pregunta no es "qué datos se filtraron" sino **qué proceso está en riesgo**.
    - *Pista: un único READ falsificado que llega a la outstation L`{x}` es más grave que un scan ruidoso que nunca sale de L`{x.x}`. Enfócate en el impacto sobre el proceso vs datos vulnerados.*

### Respuesta (Respond)

- 3️⃣ **Acción 3 — Reconstruir la cronología y nombrar el conduit.** A partir de los logs Zeek reconstruye una cronología ordenada del incidente (`ts`, origen, técnica, función CSF) en el **Artefacto 1**. Identifica el **conduit** que el atacante está abusando — descríbelo en términos Purdue.
    - *Pista: `cat notice.log | zeek-cut -u ts note src id.resp_h | sort` esboza la cronología — la flag `-u` presenta `ts` como un timestamp UTC legible en lugar del epoch bruto (usa `-d` para hora local). El conduit abusado es el camino L`{x.x}`→L`{x}` que la EWS dual-homed hace de puente — el mismo que usa el poll legítimo del master, y es exactamente por eso que no puedes simplemente bloquearlo todo.*

- 4️⃣ **Acción 4 — Cortar el conduit (aislar, no apagar).** Ejecuta `./OTLab16.sh -contain`. Aplica la segmentación de referencia: un **DROP quirúrgico** del host atacante hacia OT, mientras el poll sancionado master→outstation sigue fluyendo. **Verifica con Zeek**: los flujos del atacante se detienen *y* el `dnp3.log` muestra el polling continuando dentro de los rangos del OTLab14. Registra la decisión, la reversibilidad y las verificaciones post-acción en el **Artefacto 2** (Registro de Decisión de Contención).
    - *Pista: la contención inserta `DROP -s {xxx.xxx.xx.xx} -d 192.168.20.0/24` en la parte superior de la chain `FORWARD` de la EWS — la EWS dual-homed enruta todo el tráfico corp↔OT, por lo que su chain `FORWARD` es el verdadero punto de estrangulamiento. Aislar vs apagar: el alimentador debe seguir siendo consultado. Confirma con `cat conn.log | zeek-cut id.orig_h id.resp_h service | sort -u` — la fila del `{IP del atacante}` desapareció, la fila del `{IP del master}` permanece.*

- 5️⃣ **Acción 5 — Erradicar el punto de apoyo.** Elimina el punto de apoyo del atacante en el PC corporativo comprometido y cierra el vector inicial (el USB / el IP-forwarding de la EWS que dejó al corporativo llegar a la OT). Anota en tu registro **lo que no pudiste parchear a demanda** y por qué.
    - *Pista: los dispositivos de campo (la outstation/RTU L`{x}`) no pueden parchearse ni reiniciarse a demanda en mitad del incidente — la erradicación en OT a menudo significa cortar el alcance ahora y agendar la corrección para una ventana de mantenimiento, no un reinicio en vivo.*

### Recuperación (Recover)

- 6️⃣ **Acción 6 — Ejecutar la verificación de baseline (proceso verificado, no solo amenaza eliminada).** Ejecuta `./OTLab16.sh -restore` para volver al estado limpio y monitorizado, luego vuelve a ejecutar tu baseline Zeek. La recuperación solo se aprueba **cuando**: el `notice.log` no muestra nuevas alertas, los endpoints/códigos de función coinciden con las allowlists del OTLab14, y la telemetría de la outstation vuelve a los rangos (tensión `{xxx–xxx}` V, corriente `{x.x–xx}` A).
    - *Pista: "recuperar" significa que el **proceso** está verificado como normal, no solo que el atacante desapareció. Pide al contacto de operaciones de la Acción 1 que autorice el "todo despejado" en el Artefacto 3.*

### Recuperación · Mejora (Recover · Improve)

- 7️⃣ **Acción 7 — Escribir el informe post-incidente.** Completa el **Artefacto 3** (Informe de Incidente): resumen ejecutivo, alcance en términos Purdue, resumen de la cronología, **causa raíz**, acciones del atacante mapeadas al **MITRE ATT&CK for ICS**, IOCs que convertirías en reglas de SIEM, acciones de respuesta etiquetadas por función CSF, lo que deliberadamente **no** hiciste y por qué, aprobación de la recuperación y lecciones aprendidas. Tu principal recomendación debe realimentar la arquitectura: introducir la **IDMZ / segmentación** de `PurdueModelReference-ES.md` para que este conduit no pueda volver a ser abusado. **Este documento cierra la trilogía OTLab14/15/16.**
    - *Pista: la causa raíz no es "el USB" solo — es `{USB}` + `{IT/OT plana}` + `{EWS dual-homed sin DMZ}`. La corrección que previene la recurrencia es la arquitectura Purdue **objetivo**, que conecta Recover de vuelta con Improve.*

## 🎯 Competencias

**Prácticas:** Triaje de Incidentes · Análisis Forense de Logs (Zeek) · Contención de Red · Endurecimiento de Arquitectura OT

**Aplicando [MITRE ATT&CK for ICS](https://attack.mitre.org/matrices/ics/) — Mitigaciones:**

[![M0930 Network Segmentation](https://img.shields.io/badge/ATT%26CK_ICS-M0930_Network_Segmentation-blue)](https://attack.mitre.org/mitigations/M0930/)
[![M0937 Filter Network Traffic](https://img.shields.io/badge/ATT%26CK_ICS-M0937_Filter_Network_Traffic-blue)](https://attack.mitre.org/mitigations/M0937/)
[![M0931 Network Intrusion Prevention](https://img.shields.io/badge/ATT%26CK_ICS-M0931_Network_Intrusion_Prevention-blue)](https://attack.mitre.org/mitigations/M0931/)

**Mapeado al ciclo de vida de respuesta a incidentes [NIST SP 800-61r3](https://csrc.nist.gov/pubs/sp/800/61/r3/final) (funciones [CSF 2.0](https://csrc.nist.gov/pubs/cswp/29/the-nist-cybersecurity-framework-csf-20/final)):** las siete acciones recorren *Govern/Identify* (Preparación) → *Detect* → *Respond* → *Recover/Improve*.

## 🔖 Nomenclatura

- ATT&CK for ICS: base de conocimiento de MITRE sobre comportamiento de adversarios en sistemas de control industrial; las *Mitigaciones* son las contrapartes defensivas de las *Técnicas*.
- conduit: en el sentido Purdue/IEC 62443, el camino de comunicación controlado entre dos zonas de seguridad.
- CSF: [NIST Cybersecurity Framework](https://csrc.nist.gov/pubs/cswp/29/the-nist-cybersecurity-framework-csf-20/final); la versión 2.0 organiza el trabajo en las funciones *Govern, Identify, Protect, Detect, Respond, Recover*.
- CSIRT: Equipo de respuesta a incidentes de seguridad informática (*Computer Security Incident Response Team*).
- DNP3: Distributed Network Protocol version 3 — protocolo SCADA ampliamente usado en servicios eléctricos, de agua y de petróleo y gas.
- EWS: Estación de trabajo de ingeniería (*engineering workstation*) — el host operado por ingenieros de control para configurar, programar y monitorizar dispositivos de campo.
- ICS: Sistema de control industrial (*industrial control system*).
- IDMZ: Zona desmilitarizada industrial (*Industrial Demilitarised Zone*) — el buffer de nivel Purdue 3.5 que intermedia todo el tráfico IT↔OT.
- IOC: Indicador de compromiso (*indicator of compromise*) — un artefacto observable de red o host que sugiere una intrusión.
- IR / IRP: Respuesta a incidentes / plan de respuesta a incidentes.
- NSM: Monitorización de seguridad de red (*network security monitoring*) — observación pasiva del tráfico; Zeek es una herramienta NSM.
- OT: Tecnología operativa (*operational technology*).
- PERA / Purdue: Purdue Enterprise Reference Architecture — el modelo de referencia en capas (L0–L5) para segmentación de redes ICS.
- RTO / RPO: Objetivo de tiempo de recuperación / objetivo de punto de recuperación (*recovery time/point objective*).
- RTU: Unidad terminal remota (*remote terminal unit*) — el papel de dispositivo de campo que normalmente desempeña una outstation DNP3.
- SCADA: Supervisión, control y adquisición de datos (*supervisory control and data acquisition*).
- [SP 800-61](https://csrc.nist.gov/pubs/sp/800/61/r3/final) / [SP 800-82](https://csrc.nist.gov/pubs/sp/800/82/r3/final): guías NIST para el tratamiento de incidentes y para seguridad OT, respectivamente.

## 🛠️ Uso

```
Usage: ./OTLab16.sh -start [kali|ubuntu] | -stop | -clean | -run | -restart | -status
                    | -attack <scenario> | -incident | -contain | -restore

  -start     Inicia el entorno DNP3_IR usando la distro indicada (por defecto: ubuntu)
             Opciones válidas: kali (rolling) o ubuntu (22.04)
  -run       Abre un terminal dentro del contenedor otlab-student (EWS)
  -clean     Elimina contenedores, volúmenes y la red (revierte todas las reglas iptables)
  -stop      Detiene todos los contenedores
  -restart   Reinicia contenedores previamente detenidos
  -status    Muestra el estado actual de los contenedores
  -attack    Dispara un único escenario de ataque controlado (scan | fingerprint | spoof)
  -incident  Repite la kill-chain completa (scan → fingerprint → spoof) para abrir el incidente
  -contain   Aplica la contención de referencia: DROP quirúrgico del atacante hacia OT,
             preservando el poll legítimo master→outstation
  -restore   Levanta la contención y vuelve al estado limpio y monitorizado
```

> [!NOTE]
> Cuando se ejecuta en **WSL2**, el script detecta automáticamente el entorno y aplica las reglas a nivel de kernel (`bridge-nf-call-iptables=0` y dos reglas `DOCKER-USER` ACCEPT) necesarias para que el tráfico se enrute entre los dos *bridges* de Docker. El `-contain` aplica entonces su `DROP` quirúrgico en la **propia chain `FORWARD` de la EWS** (vía `docker exec`, sin `sudo` en el host), y el `-restore` lo elimina — una regla `DOCKER-USER` en el host sería silenciosamente inerte en WSL2, ya que el tráfico entre bridges se conmuta a L2. Las reglas `ACCEPT` entre bridges requieren `sudo` y se revierten con `-clean`. En Linux nativo y en Docker Desktop de macOS las reglas entre bridges se omiten — consulta `IRPlaybookReference-ES.md` para los detalles de la contención.

## Soluciones

Este laboratorio es **operacional, no código-para-rellenar**: el estudiante conduce el incidente a través de los verbos del `OTLab16.sh` y registra el razonamiento en `IR_Template-ES.md`. La clave del instructor es el contenido esperado de los tres artefactos más la contención de referencia:

- **Contención (referencia):** un único drop quirúrgico en la chain `FORWARD` de la EWS — `docker exec otlab-student iptables -I FORWARD 1 -s 192.168.21.30 -d 192.168.20.0/24 -j DROP` — insertado en la parte superior para ganar a las reglas de reenvío. El master (192.168.21.20) sigue consultando la outstation (192.168.20.10); solo el atacante (192.168.21.30) pierde su camino hacia OT. Esto es lo que el `-contain` aplica y el `-restore` elimina.
- **Verificación de baseline (criterios de "todo despejado"):** `notice.log` limpio, endpoints y códigos de función de vuelta dentro de las allowlists del OTLab14, y telemetría en los rangos (110–130 V, 0,5–15 A) con el interruptor alternando en su cadencia de ~100 s.
- **Causa raíz:** malware vía USB **+** IT/OT plana sin segmentación **+** EWS dual-homed haciendo de puente entre los dos segmentos sin IDMZ. La corrección recomendada es la arquitectura *objetivo* en `PurdueModelReference-ES.md`.
