@load ../baseline.zeek

module DNP3Anomaly;

export {
	redef enum Notice::Type += { Link_Vs_IP_Mismatch, };
}

event dnp3_header_block(c: connection, is_orig: bool, len: count, ctrl: count,
                        dest_addr: count, src_addr: count)
	{
	local sender_ip = is_orig ? c$id$orig_h : c$id$resp_h;
	if ( src_addr in DNP3Baseline::link_addr_to_ip &&
	     DNP3Baseline::link_addr_to_ip[src_addr] != sender_ip )
		NOTICE([$note = Link_Vs_IP_Mismatch,
		        $msg  = fmt("DNP3 link src %d arrived from %s, expected %s (spoof)",
		                    src_addr, sender_ip, DNP3Baseline::link_addr_to_ip[src_addr]),
		        $conn = c]);
	}
