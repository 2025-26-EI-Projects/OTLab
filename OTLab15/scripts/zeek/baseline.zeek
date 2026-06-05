##! Baseline allowlists for the OTLab15 DNP3 environment.
##!
##! Source of truth for each constant:
##!   - expected_endpoints  : the two IPs you documented talking on 20000/tcp.
##!   - expected_func_codes : the four function codes observed in steady state
##!                           (READ, RESPONSE, CONFIRM, UNSOLICITED_RESPONSE).
##!   - link_addr_to_ip     : the DNP3 link-layer address <-> IP mapping.
##!
##! These ship EMPTY on purpose. Fill them from your OTLab14 write-up — an empty
##! allowlist makes every Phase 2 detector fire on every packet (`!in {}` is
##! always true), so filling them is what gives Phase 2 a clean signal.

module DNP3Baseline;

export {
	## IPs allowed on 20000/tcp.
	## TODO (Phase 1, from OTLab14): add the master and outstation IPs.
	const expected_endpoints: set[addr] = {
	} &redef;

	## Function codes expected in steady state.
	## TODO (Phase 1): the four codes you observe
	## (READ, RESPONSE, CONFIRM, UNSOLICITED_RESPONSE).
	const expected_func_codes: set[count] = {
	} &redef;

	## DNP3 link-layer address <-> expected IP mapping.
	## TODO (cycle 2.3): map link addr 1 and 2 to the outstation/master IPs.
	const link_addr_to_ip: table[count] of addr = {
	} &redef;
}
