#!/bin/bash
# Scenario: scan — OT-network reconnaissance from the corporate segment.
#
# What it does:
#   1) TCP SYN sweep of the OT subnet looking for hosts answering on 20000/tcp (DNP3).
#   2) Service/version probe (-sV) against responsive hosts — opens full TCP
#      handshakes that close without any DNP3 PDU.
#
# Expected Zeek signal (running on the EWS):
#   - conn.log: a brand-new orig_h (the attacker) absent from the Lab 1 baseline.
#   - several flows in state S0/REJ/RSTOS0 to 20000/tcp (SYNs with no application data).
#   - with -sV: established flows with ~0 bytes exchanged before the reset.
#
set -u
OT_SUBNET="${1:-192.168.20.0/24}"
DNP3_PORT="${2:-20000}"

echo "[scan] TCP SYN sweep of ${OT_SUBNET} on ${DNP3_PORT}/tcp. . ."
nmap -n -Pn -sS -p "${DNP3_PORT}" --open "${OT_SUBNET}"

echo "[scan] Service/version probe on responsive hosts. . ."
nmap -n -Pn -sV -p "${DNP3_PORT}" "${OT_SUBNET}"

echo "[scan] Done — inspect conn.log on the EWS for the new source and SYN-only flows."
