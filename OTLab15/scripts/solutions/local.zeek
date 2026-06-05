@load local       # stock site policy: conn, dnp3, notice, ...

# Docker veth delivers TCP packets with bad checksums; without this Zeek drops
# the payloads and never parses DNP3. Lab-only — never in production.
redef ignore_checksums = T;

@load ./baseline.zeek

@load ./detectors/unknown-endpoint.zeek
@load ./detectors/unexpected-function-code.zeek
@load ./detectors/link-vs-ip-mismatch.zeek
