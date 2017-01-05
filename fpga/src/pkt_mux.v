module pkt_mux(
	input	rst,

	input	p0_clk,
	input	[7:0] p0_data,
	input	p0_dv,
	input	p0_er,

	input	p1_clk,
	input	[7:0] p1_data,
	input	p1_dv,
	input	p1_er,

	input	tx_clk,
	output	[7:0] tx_data,
	output	tx_en,
	output	tx_er
);


endmodule
