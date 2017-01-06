module mdio_shift(
	input	clk,
	input	rst,

	output	mdc,
	output	mdo,
	input	mdi,
	output	mdo_oe,

	input	[4:0] phyaddr,
	input	[4:0] regaddr,
	input	[15:0] wdata,
	output	[15:0] rdata,
	input	[1:0] op,
	input	start,
	output	ready
);
parameter PRESCALE=16;

reg [7:0] clk_div;
reg [5:0] bit_cnt;

always @(posedge clk)
begin
	if(shift_en) begin
		if(clk_div==PRESCALE-1)
			clk_div <= 'b0;
		else
			clk_div <= clk_div+1;
	end
	else begin
		clk_div <= 'b0;
	end
end

always @(posedge clk)
begin
	if(shift_en) begin
		if(clk_div == PRESCALE-2)
			bit_cnt <= bit_cnt+1;
	end
	else begin
		bit_cnt <= 'b0;
	end
end

always @(posedge clk)
begin
end

endmodule
