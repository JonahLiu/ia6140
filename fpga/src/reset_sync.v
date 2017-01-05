module reset_sync(
	input	clk,
	input	rst_in,
	output	reg rst_out
);

(* ASYNC_REG = "TRUE" *)
reg [1:0] rst_sync;
always @(posedge clk, posedge rst_in)
begin
	if(rst_in)
		rst_sync <= 'b0;
	else
		rst_sync <= {rst_sync,1'b1};
end
always @(posedge clk)
begin
	rst_out <= !rst_sync[1];
end

endmodule
