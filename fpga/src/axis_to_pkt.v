module axis_to_pkt(
	input	axis_aclk,
	input	axis_aresetn,
	input	[7:0] axis_tdata,
	input	[0:0] axis_tuser,
	input	axis_tlast,
	input	axis_tvalid,
	output	reg axis_tready,

	output	tx_clk,
	output	reg [7:0] tx_data,
	output	reg tx_en,
	output	reg tx_er
);
parameter IFG=192;

reg [7:0] ifg_cnt;

assign tx_clk = axis_aclk;

always @(posedge axis_aclk, negedge axis_aresetn)
begin
	if(!axis_aresetn) begin
		ifg_cnt <= 'b0;
	end
	else if(axis_tvalid && !axis_tready) begin
		ifg_cnt <= ifg_cnt+1;
	end
	else begin
		ifg_cnt <= 'b0;
	end
end

always @(posedge axis_aclk, negedge axis_aresetn)
begin
	if(!axis_aresetn) begin
		axis_tready <= 1'b0;
	end
	else if(ifg_cnt==IFG) begin
		axis_tready <= 1'b1;
	end
	else if(axis_tvalid && axis_tlast && axis_tready) begin
		axis_tready <= 1'b0;
	end
end

always @(posedge axis_aclk, negedge axis_aresetn)
begin
	if(!axis_aresetn) begin
		tx_data <= 'bx;
		tx_en <= 1'b0;
		tx_er <= 1'b0;
	end
	else begin
		tx_data <= axis_tdata;
		tx_en <= axis_tready;
		tx_er <= axis_tready ? axis_tuser : 1'b0;
	end
end

endmodule
