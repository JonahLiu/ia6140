module shift_reg #(
	parameter BITS=32
)(
	input	rst,
	input	clk,
	input	en,
	input	si,
	output reg	[BITS-1:0] q
);

always @(posedge clk, posedge rst)
begin
	if(rst) begin
		q <= {BITS{1'b0}};
	end
	else if(en) begin
		q <= {q,si};
	end
end

endmodule
