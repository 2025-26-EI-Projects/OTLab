@load ../baseline.zeek

module DNP3Anomaly;

export {
	redef enum Notice::Type += { Unexpected_Function_Code, };
}

function check_fc(c: connection, kind: string, fc: count)
	{
	if ( fc !in DNP3Baseline::expected_func_codes )
		NOTICE([$note = Unexpected_Function_Code,
		        $msg  = fmt("DNP3 %s fc=0x%02x outside baseline on %s -> %s",
		                    kind, fc, c$id$orig_h, c$id$resp_h),
		        $conn = c]);
	}

event dnp3_application_request_header(c: connection, is_orig: bool, application: count, fc: count)
	{ check_fc(c, "request", fc); }

event dnp3_application_response_header(c: connection, is_orig: bool, application: count, fc: count, iin: count)
	{ check_fc(c, "response", fc); }
