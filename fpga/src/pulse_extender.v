module pulse_extender(
	input	rst,
	input	clk,
	input	d,
	output reg	q
);

parameter MIN_PULSE_CYCLES = 16;

integer i;
reg d_0;

always @(posedge clk, posedge rst)
begin
	if(rst) begin
		d_0 <= 1'b0;
	end
	else begin
		d_0 <= d;
	end
end

always @(posedge clk, posedge rst)
begin
	if(rst) begin
		i <= 'b0;
	end
	else if(d && !d_0) begin
		i <= 'b0;
	end
	else if(i!=MIN_PULSE_CYCLES) begin
		i <= i+1;
	end
end

always @(posedge clk, posedge rst)
begin
	if(rst) begin
		q <= 1'b0;
	end
	else if(d) begin
		q <= 1'b1;
	end
	else if(i==MIN_PULSE_CYCLES) begin
		q <= 1'b0;
	end
end


endmodule
