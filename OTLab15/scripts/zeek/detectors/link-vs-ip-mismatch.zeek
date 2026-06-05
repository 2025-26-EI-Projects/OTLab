##! Notice when a DNP3 link-layer source address does not match the expected IP
##! in DNP3Baseline::link_addr_to_ip.

@load ../baseline.zeek

module DNP3Anomaly;

export {
	redef enum Notice::Type += { Link_Vs_IP_Mismatch, };
}

# TODO (cycle 2.3): hook dnp3_header_block — it surfaces the link-layer
# src/dest addresses, which dnp3.log does NOT record. This is the only place to
# catch spoofed frames that present a legitimate link address from the wrong IP.
# Pick the side via is_orig: if is_orig=T the originator IP is c$id$orig_h and
# the link source is `src_addr`. Compare against DNP3Baseline::link_addr_to_ip
# and emit a NOTICE on mismatch.
#
# event dnp3_header_block(c: connection, is_orig: bool, len: count, ctrl: count,
#                         dest_addr: count, src_addr: count)
#     { }
