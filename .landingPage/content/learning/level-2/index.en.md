---
title: "Level 2 — Protocol & Traffic Analysis"
description: "Inspect and analyze network traffic to understand protocol behavior." 
level: 2
---

## Goal
Interpret packet captures, understand protocol behavior and extract relevant information.

## Concepts
- TCP three-way handshake, retransmissions, flags
- Payload analysis and data extraction
- Filtering and BPF expressions

## Tools
- `tcpdump`, `tshark`, `Wireshark`
- `ngrep`, `scapy` (for packet manipulation/generation)

## Suggested labs
{{< labs-by-level level="2" >}}
## Practical exercises
- Capture the TCP handshake between client and server and identify SYN/ACK fields
- Filter traffic by IP/port and export pcap for Wireshark analysis
