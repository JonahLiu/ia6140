module pkt_fifo(
	input	rst,

	input	rx_clk,
	input	[7:0] rx_data,
	input	rx_dv,
	input	rx_er,

	input	tx_clk,
	output	[7:0] tx_data,
	output	tx_en,
	output	tx_er
);
parameter THRESHOLD=8;

wire [9:0] fifo_din;
wire fifo_wr_en;
wire [9:0] fifo_dout;
reg fifo_rd_en;
wire fifo_prog_empty;
wire rx_last;
wire tx_last;

reg [7:0] rx_data_0;
reg rx_dv_0;
reg rx_er_0;

/*
//wire [10:0] fifo_rd_count;
fifo_async #(.DSIZE(10),.ASIZE(10),.MODE("FWFT")) fifo_i(
	.wr_rst(rst),
	.wr_clk(rx_clk),
	.din(fifo_din),
	.wr_en(fifo_wr_en),
	.full(),
	.wr_count(),
	.rd_rst(rst),
	.rd_clk(tx_clk),
	.dout(fifo_dout),
	.rd_en(fifo_rd_en),
	.empty(),
	.rd_count(fifo_rd_count)
);
assign fifo_prog_empty = fifo_rd_count<THRESHOLD;
*/
pkt_fifo_core fifo_i(
  .rst(rst), // input rst
  .wr_clk(rx_clk), // input wr_clk
  .rd_clk(tx_clk), // input rd_clk
  .din(fifo_din), // input [9 : 0] din
  .wr_en(fifo_wr_en), // input wr_en
  .rd_en(fifo_rd_en), // input rd_en
  .prog_empty_thresh(THRESHOLD), // input [10 : 0] prog_empty_thresh
  .prog_full_thresh(THRESHOLD), // input [10 : 0] prog_full_thresh
  .dout(fifo_dout), // output [9 : 0] dout
  .full(), // output full
  .empty(), // output empty
  .prog_full(), // output prog_full
  .prog_empty(fifo_prog_empty) // output prog_empty
);

always @(posedge rx_clk, posedge rst)
begin
	if(rst) begin
		rx_data_0 <= 8'bx;
		rx_dv_0 <= 1'b0;
		rx_er_0 <= 1'b0;
	end
	else begin
		rx_data_0 <= rx_data;
		rx_dv_0 <= rx_dv;
		rx_er_0 <= rx_er;
	end
end

assign rx_last = rx_dv_0 && !rx_dv;

assign fifo_din[9] = rx_last;
assign fifo_din[8] = rx_er_0;
assign fifo_din[7:0] = rx_data_0;
assign fifo_wr_en = rx_dv_0;

assign tx_last = fifo_dout[9];
assign tx_er = fifo_dout[8];
assign tx_data = fifo_dout[7:0];
assign tx_en = fifo_rd_en;

always @(posedge tx_clk, posedge rst)
begin
	if(rst) begin
		fifo_rd_en <= 1'b0;
	end
	else if(!fifo_rd_en && !fifo_prog_empty) begin
		fifo_rd_en <= 1'b1;
	end
	else if(fifo_rd_en && tx_last) begin
		fifo_rd_en <= 1'b0;
	end
end



endmodule
