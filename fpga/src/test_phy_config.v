module test_phy_config;
reg clk;
reg rst;
wire mdc;
wire mdio_i;
wire mdio_o;
wire mdio_oe;

phy_config #(.PRESCALE(128)) dut(
	.clk(clk),
	.rst(rst),
	.mdc(mdc),
	.mdio_i(mdio_i),
	.mdio_o(mdio_o),
	.mdio_oe(mdio_oe)
);

initial begin
	clk = 0;
	forever #4 clk = !clk;
end

initial begin
	$dumpfile("test_phy_config.vcd");
	$dumpvars(0);
	rst = 1;
	#100 rst = 0;

end

endmodule
