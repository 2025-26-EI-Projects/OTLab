---
title: "Lab 06 - Industrial Protocols and Web Interface Exposure"
description: "Discovery of industrial devices through subnet enumeration, service analysis, web interface inspection, and SNMP information gathering."
categories: ["Laboratories"]
difficulty: "Intermediate"
tags: ["OT", "ICS", "Industrial Protocols", "Web Interface", "SNMP", "OID", "Conpot", "Plcscan", "Tcpdump", "Network Discovery", "Nmap", "Masscan", "Netdiscover"]
estimated_time: "75 min"
level: 3
area: "detection"
---

![](https://raw.githubusercontent.com/substationworm/OTLab/main/OTLab-SecondHeader.png "OTLab06")

[![Curriculum Lattes](https://img.shields.io/badge/Lattes-white)](http://lattes.cnpq.br/8846358506427099)
[![ORCID](https://img.shields.io/badge/ORCID-grey)](https://orcid.org/0000-0002-6254-7306)
[![SciProfiles](https://img.shields.io/badge/SciProfiles-black)](https://sciprofiles.com/profile/lffreitas-gutierres)
[![Scopus](https://img.shields.io/badge/Scopus-white)](https://www.scopus.com/authid/detail.uri?authorId=57195542368)
[![Web of Science](https://img.shields.io/badge/ResearcherID-grey)](https://www.webofscience.com/wos/author/record/Q-8444-2016)
[![substationworm](https://img.shields.io/badge/substationworm-black)](https://github.com/substationworm)
[![LFFreitasGutierres](https://img.shields.io/badge/LFFreitasGutierres-white)](https://github.com/LFFreitas-Gutierres)

## 📝 Tasks

- 1️⃣ Verify the IP address of the `otlab-student` workstation. `OTLab06{XXX.XXX.X2.XXX}`
- 2️⃣ Discover the IP addresses of active hosts within the same subnet as identified in the previous answer. `OTLab06{XXX.XXX.XX.2X, XXX.XXX.XX.XX, XXX.XXX.XX.XXX}`
- 3️⃣ Determine which ports are open on the IP address matching the format `XXX.XXX.XX.2X`, identified in the previous question. `OTLab06{XXXX, XXXX, XXXX, XXXXX, XXXXX}`
- 4️⃣ Identify the MAC address of the active host corresponding to the IP address matching the format `XXX.XXX.XX.2X` from question 2. `OTLab06{XX:XX:XX:XX:XX:XX}`
- 5️⃣ Locate the hidden flag on a web interface exposed by the active host mentioned in question 3.
  - _Use `curl`. No further hints are provided._
- 6️⃣ Which port is open on the IP address matching the format `XXX.XXX.XX.XX` from question 2? `OTLab06{XXX}`
- 7️⃣ Determine the emulated base firmware version running on the active host referenced in the previous question. `OTLab06{X.X.X.X}`
- 8️⃣ Two devices on different bridge-configured networks are communicating. What is the MAC address of the only active host on the other bridge segment? `OTLab06{XX:XX:XX:XX:XX:XX}`
- 9️⃣ Two devices on different bridge-configured networks are communicating. What message is being transmitted? `OTLab06{Xxxx xxx Xxxxxxxxxxx xx Xxxxxxxx xxx Xxxxxxxxxx xxx XX-XXX!}`
- 🔟 Which OID can be extracted through the SNMP service from an active host operating with an industrial communication protocol? `OTLab06{(XXXX) X:XX:XX.XX}`

#### Note: `plc03-scada` is based on [Conpot](http://conpot.org/), which remaps standard protocol and service ports to non-privileged ports. Refer to the [link](https://github.com/substationworm/OTLab/blob/main/OTLab01/ConpotDefaultPorts.md) for a list of some default and remapped ports. The `opt/plcscan/plcscan.py` tool ([meeas/plcscan](https://github.com/meeas/plcscan)) must be executed using `python2`.

## 🛠️ Tools

- The following tools are available on the `otlab-student` workstation for completing OTLab 06: `ifconfig`, `masscan`, `netdiscover`, `nmap`, `snmpwalk`, `plcscan`, and `tcpdump`.

## 🔖 Nomenclature

- IP: Internet Protocol.
- MAC: Media Access Control.
- OID: Object Identifier.
- SNMP: Simple Network Management Protocol.