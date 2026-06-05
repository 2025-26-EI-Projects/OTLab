#!/usr/bin/env python3
# Scenario: fingerprint — capability probing via function codes outside the
# steady-state read loop.
#
# In steady state the legitimate master only emits READ (and CONFIRM for
# unsolicited responses). Here the attacker sends a series of non-read function
# codes to see how the outstation reacts (NAK? IIN bits? silence?), which helps
# fingerprint the stack and configuration.
#
# Default probes (non-destructive):
#   - DELAY_MEASURE       (23 / 0x17)  -> measures propagation delay; reply reveals support
#   - ENABLE_UNSOLICITED  (20 / 0x14)  -> with object header Group 60 var 2 (class 1)
#   - DISABLE_UNSOLICITED (21 / 0x15)  -> idem
#   - UNDEFINED_0x70      (112 / 0x70) -> unassigned function code; forces an error reply
#
# COLD_RESTART (13 / 0x0D) and WARM_RESTART (14 / 0x0E) are commented out: on
# real equipment they restart the outstation. On the emulated stack
# (dnp3-python) they should be ignored/NAKed, but stay disabled by default so
# the lab is repeatable. The function-code detector picks them up just the same
# if re-enabled.
#
# Link addresses: dst=1 (outstation), src=2 (the legitimate master's link ID).
# The outstation tends to close the connection after these requests; Dnp3Channel
# transparently reconnects.
import sys
import time

from _dnp3 import (Dnp3Channel, build_app_request, build_link_frame, obj_header_all,
                   transport_segment)

OUTSTATION_IP = sys.argv[1] if len(sys.argv) > 1 else "192.168.20.10"
PORT = int(sys.argv[2]) if len(sys.argv) > 2 else 20000
DST_LINK, SRC_LINK = 1, 2

PROBES = [
    ("DELAY_MEASURE",       0x17, b""),
    ("ENABLE_UNSOLICITED",  0x14, obj_header_all(60, 2)),
    ("DISABLE_UNSOLICITED", 0x15, obj_header_all(60, 2)),
    ("UNDEFINED_0x70",      0x70, b""),
]


def _probe_frame(fc, objs, seq):
    return build_link_frame(DST_LINK, SRC_LINK,
                            transport_segment(build_app_request(fc, objs, seq=seq)))


def main():
    print(f"[fingerprint] Probing {OUTSTATION_IP}:{PORT} with non-baseline function codes")
    seq = 0
    with Dnp3Channel(OUTSTATION_IP, PORT, recv_timeout=0.4) as chan:
        for name, fc, objs in PROBES:
            try:
                reply = chan.send_recv(_probe_frame(fc, objs, seq))
                outcome = reply.hex() if reply else "no reply"
            except OSError as exc:
                outcome = f"send failed ({exc})"
            print(f"[fingerprint]  {name:<20} fc=0x{fc:02X} -> {outcome}")
            seq = (seq + 1) & 0x0F
            time.sleep(0.3)
    print("[fingerprint] Done — on the EWS, check the DNP3 function codes for "
          "anything the master never sends.")


if __name__ == "__main__":
    main()
