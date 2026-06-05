module DNP3Baseline;

export {
	const expected_endpoints: set[addr] = {
		192.168.21.20,    # master
		192.168.20.10,    # outstation
	} &redef;

	const expected_func_codes: set[count] = {
		0x01,   # READ
		0x81,   # RESPONSE
		0x00,   # CONFIRM
		0x82,   # UNSOLICITED_RESPONSE
	} &redef;

	const link_addr_to_ip: table[count] of addr = {
		[1] = 192.168.20.10,   # outstation
		[2] = 192.168.21.20,   # master
	} &redef;
}
