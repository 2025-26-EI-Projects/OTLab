---
title: "Lab 11 - Bypass de MFA mediante AiTM"
description: "Simulación de un ataque adversary-in-the-middle para capturar cookies de sesión y eludir MFA en un entorno OT-ICS."
categories: ["Laboratorios"]
difficulty: "Avanzado"
tags: ["OT", "ICS", "AiTM", "MFA", "Session Hijacking", "Phishing", "Credential Theft", "Cookie Theft", "Web Security", "HMI", "Curl", "Adversary Simulation"]
estimated_time: "90 min"
level: 2
area: "response"
---

![](https://raw.githubusercontent.com/substationworm/OTLab/main/OTLab-SecondHeader.png "OTLab11")

[![Curriculum Lattes](https://img.shields.io/badge/Lattes-white)](http://lattes.cnpq.br/8846358506427099)
[![ORCID](https://img.shields.io/badge/ORCID-grey)](https://orcid.org/0000-0002-6254-7306)
[![SciProfiles](https://img.shields.io/badge/SciProfiles-black)](https://sciprofiles.com/profile/lffreitas-gutierres)
[![Scopus](https://img.shields.io/badge/Scopus-white)](https://www.scopus.com/authid/detail.uri?authorId=57195542368)
[![Web of Science](https://img.shields.io/badge/ResearcherID-grey)](https://www.webofscience.com/wos/author/record/Q-8444-2016)
[![substationworm](https://img.shields.io/badge/substationworm-black)](https://github.com/substationworm)
[![LFFreitasGutierres](https://img.shields.io/badge/LFFreitasGutierres-white)](https://github.com/LFFreitas-Gutierres)

## 📝 Resumen del problema

### Hosts en contenedores

- user-browser (estación víctima): sistema cliente legítimo usado por el operador para acceder a la interfaz web industrial. Es el objetivo del robo de credenciales y del compromiso de sesión.
- phishing-proxy (proxy AiTM): servicio malicioso que retransmite de forma transparente las comunicaciones entre la estación víctima y el servidor HMI legítimo mientras captura credenciales y cookies de sesión.
- legit-hmi (servidor HMI autorizado): sistema HMI legítimo que proporciona control y supervisión operativa dentro del entorno industrial.
- attacker (atacante): actor malicioso que despliega y gestiona la infraestructura de phishing para realizar robo de credenciales, secuestro de sesión y persistencia de acceso.

## 📝 Tareas

- 1️⃣ Accede al contenedor víctima (`user-browser`) y abre el navegador web en modo texto con: `elinks http://phishing.test`. El usuario cree que está accediendo al HMI legítimo, pero en realidad se conecta a un dominio falso y malicioso diseñado para parecerse al auténtico.
- 2️⃣ Autentícate con las credenciales siguientes: operator (usuario), otlab123 (contraseña), 000111 (código MFA). Tras la autenticación, explora la interfaz web del HMI. No cierres sesión todavía.
- 3️⃣ En otra terminal, accede al contenedor atacante y ejecuta: `tail -f /loot/cookies.log`. El proxy de phishing interceptará y registrará la cookie de sesión de la víctima, permitiendo el bypass de MFA y el secuestro de sesión.
- 4️⃣ Asigna la cookie capturada a una variable llamada COOKIE en el sistema atacante. Después reutiliza la cookie para acceder a la aplicación a través del proxy de phishing: `curl -H "Cookie: ihhmsession=$COOKIE" -H "Host: phishing.test" http://172.30.0.20/home -L`. Se espera acceso exitoso sin confirmación MFA.
- 5️⃣ En el sistema atacante, prueba el acceso directo al servidor HMI autorizado usando la cookie robada: `curl -H "Cookie: ihhmsession=$COOKIE" http://legit-hhm:8000/home` o `curl -H "Cookie: ihhmsession=$COOKIE" -H "Host: legit.test" http://172.30.10.40:8000/home`. Este paso simula el uso de una sesión válida directamente contra la infraestructura legítima.
- 6️⃣ Realiza un cierre de sesión global haciendo clic en Log out en la sesión de `user-browser`. Después, intenta reutilizar de nuevo la cookie desde el sistema atacante: `curl -i -H "Cookie: ihhmsession=$COOKIE" -H "Host: phishing.test" http://172.30.0.20/home`. La solicitud debe redirigirse a la página de inicio de sesión, indicando que la sesión ya no es válida.

## 🛠️ Herramientas

- Las siguientes herramientas están disponibles para completar OTLab 11: `curl`, `elinks` y `tail`.

## 🔖 Nomenclatura

- AiTM: adversary-in-the-middle.
- HMI: interfaz hombre-máquina.
- ICS: sistema de control industrial.
- MFA: autenticación multifactor.
- OT: tecnología operativa.
- SaaS: software como servicio.
- VPN: red privada virtual.
