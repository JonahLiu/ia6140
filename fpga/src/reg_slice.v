module reg_slice_1b
#(
parameter STAGE = 1
)(
	input clk_i,
	input i,
	output o
);

generate
begin:G0
	if(STAGE==0) begin:G1
		assign o = i;
	end
	else begin:G2
		reg [STAGE-1:0] r;
		always @(posedge clk_i)
		begin
		r <= {r,i};
		end
		assign o = r[STAGE-1];
	end
end
endgenerate
endmodule

module reg_slice
#(
parameter STAGE = 0,
parameter WIDTH = 1
)(
	input clk_i,
	input [WIDTH-1:0] d,
	output [WIDTH-1:0] q
);

genvar i;
generate
	for(i=0;i<WIDTH;i=i+1)
	begin:G0
		reg_slice_1b #(.STAGE(STAGE)) pl1b (.clk_i(clk_i), .i(d[i]), .o(q[i]));
	end
endgenerate

endmodule
