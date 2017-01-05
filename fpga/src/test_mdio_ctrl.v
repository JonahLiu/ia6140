`timescale 1ns/1ps
module test_mdio_ctrl;

reg clk;
reg rst;
wire mdc;
wire mdio_i;
wire mdio_o;
wire mdio_oe;
reg [4:0] phy_addr;
reg [4:0] reg_addr;
reg [15:0] wdata;
wire [15:0] rdata;
reg [1:0] op;
reg start;
wire ready;
wire error;

mdio_ctrl dut(
	.clk(clk),
	.rst(rst),
	.mdc(mdc),
	.mdio_i(mdio_i),
	.mdio_o(mdio_o),
	.mdio_oe(mdio_oe),
	.phy_addr(phy_addr),
	.reg_addr(reg_addr),
	.wdata(wdata),
	.rdata(rdata),
	.op(op),
	.start(start),
	.ready(ready),
	.error(error)
);

initial begin
	clk = 0;
	forever #4 clk = !clk;
end

task mdio_write(
	input [4:0] phyaddr,
	input [4:0] regaddr,
	input [15:0] data
);
begin
	@(posedge clk);
	phy_addr <= phyaddr;
	reg_addr <= regaddr;
	wdata <= data;
	op <= 2'b01;
	start <= 1'b1;
	@(posedge clk);
	start <= 1'b0;
	@(posedge clk);
	while(!ready) @(posedge clk);
end
endtask


initial begin
	$dumpfile("test_mdio_ctrl.vcd");
	$dumpvars(0);
	start = 0;
	rst = 1;
	#100 rst = 0;
	#100;

	mdio_write(0,1,16'h55aa);
	mdio_write(1,16,16'h1234);

	#1000;
end

endmodule
