module watch_dog(
	input	en,
	input	sclk,
	input	sdat,
	output	[56:0] dna,
	output	reset
);
parameter CYCLES_1S = 1000000000/20;

wire [63:0] key_value;

reg [31:0] timer;
reg global_reset;
reg key_match;

assign reset = global_reset;

initial begin
	global_reset = 0;
	timer = 0;
	key_match = 0;
end

STARTUP_SPARTAN6 glb_i(
	.CLK(1'b0),
	.GSR(1'b0),
	.GTS(1'b0),
	.KEYCLEARB(1'b1),
	.CFGCLK(),
	.CFGMCLK(cfgclk),
	.EOS()
);

dna dna_i(
	.clk(cfgclk),
	.id(dna),
	.valid()
);

shift_reg #(.BITS(64)) reg_i(
	.rst(1'b0),
	.clk(sclk),
	.en(en),
	.si(sdat),
	.q(key_value)
);

always @(posedge cfgclk)
begin
	if(key_value[56:0] == dna[56:0])
		key_match <= 1'b1;
	else
		key_match <= 1'b0;
end

always @(posedge cfgclk)
begin
	if(key_match) begin
		timer <= 0;
	end
	else if(timer == CYCLES_1S) begin
		timer <= 0;
	end
	else begin
		timer <= timer+1;
	end
end

always @(posedge cfgclk)
begin
	if(timer == CYCLES_1S) begin
		global_reset <= 1'b1;
	end
	else begin
		global_reset <= 1'b0;
	end
end

endmodule
