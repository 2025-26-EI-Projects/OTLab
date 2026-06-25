# IR Playbook Reference — Respuesta a Incidentes alineada con el NIST para OT

> Tarjeta de consulta para el OTLab16. Mantenla abierta en otra pestaña mientras
> trabajas el incidente. Condensa el ciclo de vida de respuesta a incidentes del NIST,
> las reglas de enfrentamiento específicas de OT, una matriz de severidad y las recetas
> de contención/verificación usadas en las tareas. Fichero compañero:
> `PurdueModelReference-ES.md` (arquitectura).

---

## 1. El ciclo de vida — NIST SP 800-61r3 / CSF 2.0

El OTLab16 usa el enfoque de la **Rev 3** del *Computer Security Incident Handling*,
que mapea el ciclo de vida en las **funciones del CSF 2.0** en lugar del antiguo ciclo
de cuatro fases.

| Función CSF 2.0 | Papel en este laboratorio                             | Cuándo               |
|------------------|-------------------------------------------------------|----------------------|
| **Govern**       | Roles, autoridad para actuar, quién firma el "todo despejado" | Preparación (antes) |
| **Identify**     | Inventario de activos mapeado a niveles Purdue (Labs 14/15) | Preparación (antes) |
| **Protect**      | Los detectores/allowlists del OTLab15 ya implementados | Preparación (antes)  |
| **Detect**       | Triaje del `notice.log`; declarar el incidente        | Durante              |
| **Respond**      | Cronología, contención, erradicación                  | Durante              |
| **Recover**      | Restaurar el proceso monitorizado; verificación de baseline | Durante / después |
| **Improve**      | Lecciones aprendidas; realimentar correcciones en la baseline | Después          |

> [!NOTE]
> **Relación con el SP 800-61r2.** El ciclo clásico r2 — *Preparation → Detection &
> Analysis → Containment, Eradication & Recovery → Post-Incident Activity* — todavía
> mapea bien: Preparation = *Govern/Identify/Protect*; Detection & Analysis =
> *Detect*; Containment/Eradication/Recovery = *Respond/Recover*; Post-Incident =
> *Improve*. Usa el vocabulario que exija la plantilla de tu informe.

## 2. Qué es diferente en la IR en OT (NIST SP 800-82)

El SP 800-82 (*Guide to OT Security*) invierte algunos reflejos de IT. El orden de
prioridad en OT es **Safety → Disponibilidad → Integridad → Confidencialidad** —
el espejo del estándar C-I-A de IT.

- **No "desenchufar".** Desconectar o reiniciar un controlador puede disparar un
  proceso físico. La disponibilidad del bucle de control es, ella misma, un control
  de seguridad física.
- **Contener quirúrgicamente.** Preserva el tráfico legítimo del proceso (el poll
  master↔outstation) mientras cortas al adversario. El aislamiento total es una
  interrupción del servicio, no una respuesta.
- **Los dispositivos de campo no pueden parchearse a demanda.** La erradicación en
  L0–L1 a menudo significa *cortar el alcance ahora* y agendar la corrección para
  una ventana de mantenimiento.
- **Coordinar con operaciones/ingeniería.** Ninguna acción de contención o
  recuperación avanza sin el autorizador de operaciones nombrado durante la Preparación.
- **Recuperación = el proceso está verificado como normal**, no solo que el malware
  desapareció. La telemetría debe estar de vuelta en su rango conocido-bueno.

## 3. Matriz de severidad / escalamiento (ponderada para OT)

Clasifica por el impacto sobre el **proceso**, no sobre los datos. Elige la fila más
alta que aplique.

| Severidad    | Impacto en Safety / Disponibilidad                   | Ejemplo en este laboratorio                   |
|--------------|------------------------------------------------------|-----------------------------------------------|
| **Crítica**  | Manipulación de un dispositivo de campo / interruptor plausible | Control falsificado hacia la outstation L1 |
| **Alta**     | El adversario tiene un camino alcanzable hacia OT (L0–L2) | Tráfico del atacante cruzando el conduit corp→OT |
| **Media**    | Recon/fingerprinting dentro de OT, aún sin control   | Códigos de función inesperados en el `dnp3.log` |
| **Baja**     | Actividad confinada a IT/L3.5, sin alcance a OT      | Scan que nunca sale del segmento corporativo  |

## 4. Checklist de incidente (mapear a las 7 acciones del laboratorio)

- [ ] **Identify** — activos colocados en niveles Purdue; contacto de operaciones nombrado *(Acción 1)*
- [ ] **Detect** — `notice.log` triado; incidente declarado con alcance + niveles Purdue *(Acción 2)*
- [ ] **Respond** — cronología reconstruida; conduit abusado nombrado *(Acción 3)*
- [ ] **Respond** — conduit cortado quirúrgicamente; verificado que el poll sigue fluyendo *(Acción 4)*
- [ ] **Respond** — punto de apoyo erradicado; vector inicial cerrado *(Acción 5)*
- [ ] **Recover** — verificación de baseline pasa; operaciones autoriza el "todo despejado" *(Acción 6)*
- [ ] **Improve** — informe post-incidente; recomendación de arquitectura *(Acción 7)*

## 5. Receta de contención (quirúrgica, no total)

El master legítimo vive en el segmento **corporativo** (`192.168.21.20`) y su poll
cruza hacia OT por la EWS dual-homed. Por eso **no puedes** dropear corp→OT en bloque
— eso mata el proceso. Dropea **solo al atacante** y aplícalo donde el tráfico es
realmente enrutado: la **propia chain `FORWARD` de la EWS** (la EWS es el conduit). La
regla va en la parte superior para ganar a las reglas de reenvío:

```bash
# Applied automatically by ./OTLab16.sh -contain :
docker exec otlab-student iptables -I FORWARD 1 -s 192.168.21.30 -d 192.168.20.0/24 -j DROP
# Lift it with ./OTLab16.sh -restore :
docker exec otlab-student iptables -D FORWARD     -s 192.168.21.30 -d 192.168.20.0/24 -j DROP
```

> [!NOTE]
> **¿Por qué la EWS y no el host?** Cada paquete corp↔OT es enrutado por la EWS
> dual-homed (`ip_forward=1`), por lo que su chain `FORWARD` es el verdadero punto de
> estrangulamiento — y se comporta igual en WSL2, Linux nativo y macOS, sin `sudo` en
> el host. Un DROP en la chain `DOCKER-USER` del host **no** funciona en WSL2: el
> tráfico entre bridges se conmuta a L2 y, con `bridge-nf-call-iptables=0` (definido
> para que el enrutamiento entre bridges funcione siquiera), nunca atraviesa el
> netfilter del host — por lo que esa regla queda silenciosamente inerte.

> Verifica que la regla está aplicada y atrapando paquetes:
> ```bash
> docker exec otlab-student iptables -L FORWARD -n -v --line-numbers | grep 21.30
> ```

## 6. Receta de verificación (Zeek)

Tras la contención, prueba **ambas** mitades del compromiso OT desde la EWS:

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

El "todo despejado" (Acción 6) solo se aprueba cuando: `notice.log` limpio, endpoints
y códigos de función de vuelta dentro de las allowlists del OTLab14, y telemetría en
el rango (**110–130 V**, **0,5–15 A**, interruptor alternando en su cadencia de ~100 s).
