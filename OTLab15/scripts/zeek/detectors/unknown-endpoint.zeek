##! Notice when a DNP3 conversation involves an endpoint outside
##! DNP3Baseline::expected_endpoints.

@load ../baseline.zeek

module DNP3Anomaly;

export {
	redef enum Notice::Type += { Unknown_Endpoint, };
	const dnp3_port = 20000/tcp &redef;
}

# TODO (cycle 2.1): hook dnp3_application_request_header and/or
# dnp3_application_response_header and emit a NOTICE when c$id$orig_h or
# c$id$resp_h is outside DNP3Baseline::expected_endpoints.
# Optional extension: also subscribe to `new_connection` and flag any TCP/20000
# flow from an unknown source before any DNP3 PDU is parsed (catches `scan`).
# This detector is worked end-to-end in DNP3LabZeekReference.md §3 — use it as
# the template for the others.
#
# event dnp3_application_request_header(c: connection, is_orig: bool, application: count, fc: count)
#     { }
#
# event dnp3_application_response_header(c: connection, is_orig: bool, application: count, fc: count, iin: count)
#     { }
