##! Site policy for the OTLab15 EWS sensor.
##!
##! Load this from the Zeek command line:
##!   zeek -i <iface> /opt/zeek-lab/local.zeek
##!
##! It pulls in the stock site policy (so conn.log/dnp3.log/notice.log behave
##! as expected), the baseline allowlists, and every detector you write under
##! detectors/. The detectors ship as skeletons — they will not emit notices
##! until you implement their event handlers and fill DNP3Baseline's constants.

@load local       # stock site policy: conn, dns, ssl, dnp3, notice, ...

# Docker veth interfaces deliver TCP packets with bad checksums (the host NIC
# computes them after the packet leaves the namespace). Without this, Zeek
# drops the payloads and never parses DNP3. Safe inside the lab; do NOT carry
# this redef into production sensors.
redef ignore_checksums = T;

@load ./baseline.zeek

@load ./detectors/unknown-endpoint.zeek
@load ./detectors/unexpected-function-code.zeek
@load ./detectors/link-vs-ip-mismatch.zeek
