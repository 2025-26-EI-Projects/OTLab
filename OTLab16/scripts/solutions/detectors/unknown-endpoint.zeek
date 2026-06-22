@load ../baseline.zeek

module DNP3Anomaly;

export {
	redef enum Notice::Type += { Unknown_Endpoint, };
	const dnp3_port = 20000/tcp &redef;
}

function check_endpoints(c: connection, kind: string, fc: count)
	{
	local o = c$id$orig_h;
	local r = c$id$resp_h;
	if ( o !in DNP3Baseline::expected_endpoints ||
	     r !in DNP3Baseline::expected_endpoints )
		NOTICE([$note = Unknown_Endpoint,
		        $msg  = fmt("DNP3 %s on %s -> %s (fc=%d): endpoint outside baseline",
		                    kind, o, r, fc),
		        $conn = c]);
	}

event dnp3_application_request_header(c: connection, is_orig: bool, application: count, fc: count)
	{ check_endpoints(c, "request", fc); }

event dnp3_application_response_header(c: connection, is_orig: bool, application: count, fc: count, iin: count)
	{ check_endpoints(c, "response", fc); }

event new_connection(c: connection)
	{
	if ( c$id$resp_p == dnp3_port && c$id$orig_h !in DNP3Baseline::expected_endpoints )
		NOTICE([$note = Unknown_Endpoint,
		        $msg  = fmt("TCP/%s from unexpected source %s -> %s",
		                    c$id$resp_p, c$id$orig_h, c$id$resp_h),
		        $conn = c]);
	}
