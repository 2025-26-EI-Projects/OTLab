##! Notice when DNP3 traffic carries a function code outside
##! DNP3Baseline::expected_func_codes.

@load ../baseline.zeek

module DNP3Anomaly;

export {
	redef enum Notice::Type += { Unexpected_Function_Code, };
}

# TODO (cycle 2.2): hook BOTH directions — an attacker can probe with weird `fc`
# in requests (DELAY_MEASURE, WRITE, OPERATE, ...) and the outstation's
# responses also carry an `fc` worth checking. Emit a NOTICE when `fc` is
# outside DNP3Baseline::expected_func_codes.
# Note: Zeek's binpac parser may skip unassigned function codes entirely — your
# detector will not see those via this event (see the fingerprint cycle in
# OTLab15.md).
#
# event dnp3_application_request_header(c: connection, is_orig: bool, application: count, fc: count)
#     { }
#
# event dnp3_application_response_header(c: connection, is_orig: bool, application: count, fc: count, iin: count)
#     { }
