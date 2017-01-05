module pkt_to_axis(
	input	rst,

	input	rx_clk,
	input	[7:0] rx_data,
	input	rx_dv,
	input	rx_er,

	output	axis_aclk,
	output	axis_aresetn,
	output reg	[7:0] axis_tdata,
	output reg	[0:0] axis_tuser,
	output reg 	axis_tlast,
	output reg	axis_tvalid,
	input	axis_tready
);

reg [7:0] data_0;
reg dv_0;
reg er_0;

assign axis_aresetn = !rst;
assign axis_aclk = rx_clk;

always @(posedge rx_clk)
begin
	data_0 <= rx_data;
	dv_0 <= rx_dv;
	er_0 <= rx_er;
end

always @(posedge rx_clk)
begin
	axis_tdata <= data_0;
	axis_tuser <= er_0;
end

always @(posedge rx_clk, posedge rst)
begin
	if(rst) begin
		axis_tvalid <= 1'b0;
	end
	else if(dv_0) begin
		axis_tvalid <= 1'b1;
		axis_tlast <= !rx_dv;
	end
	/* fail-safe recover */
	else if(axis_tlast && axis_tready)begin
		axis_tvalid <= 1'b0;
	end
end

endmodule
