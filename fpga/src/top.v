module top(
	input clk125m,

	input	phy0_rxctl,
	input	phy0_rxclk,
	input	[3:0] phy0_rxd,
	output	phy0_txclk,
	output	phy0_txctl,
	output	[3:0] phy0_txd,
	input	phy0_int_n,
	inout	phy0_mdio,
	output	phy0_mdc,
	output	phy0_reset_n,

	input	phy1_rxctl,
	input	phy1_rxclk,
	input	[3:0] phy1_rxd,
	output	phy1_txclk,
	output	phy1_txctl,
	output	[3:0] phy1_txd,
	input	phy1_int_n,
	inout	phy1_mdio,
	output	phy1_mdc,
	output	phy1_reset_n,
	input	[1:0] phy1_det,

	input	phy2_rxctl,
	input	phy2_rxclk,
	input	[3:0] phy2_rxd,
	output	phy2_txclk,
	output	phy2_txctl,
	output	[3:0] phy2_txd,
	input	phy2_int_n,
	inout	phy2_mdio,
	output	phy2_mdc,
	output	phy2_reset_n,
	input	phy2_det0,
	input	phy2_det1,

	input	eep_sclk,
	input	eep_mosi,
	input	eep_cs_n,
	output	eep_miso,

	output	[3:0] led_x,
	output	[2:0] led_y,

	input	[1:0] sw,

	output	flash_cs_n,
	output	flash_sclk,
	output	flash_mosi,
	input	flash_miso
);
reg [23:0] led_tmr;
reg [3:0] scan_x;
reg [2:0] scan_y;

// currently unused
assign phy0_txclk = 1'b0;
assign phy0_txctl = 1'b0;
assign phy0_txd = 4'b0;
assign phy0_mdio = 1'bz;
assign phy0_mdc = 1'bz;
assign phy0_reset_n = 1'b1;

assign phy1_txclk = 1'b0;
assign phy1_txctl = 1'b0;
assign phy1_txd = 4'b0;
assign phy1_mdio = 1'bz;
assign phy1_mdc = 1'bz;
assign phy1_reset_n = 1'b1;

assign phy2_txclk = 1'b0;
assign phy2_txctl = 1'b0;
assign phy2_txd = 4'b0;
assign phy2_mdio = 1'bz;
assign phy2_mdc = 1'bz;
assign phy2_reset_n = 1'b1;

assign led_x = scan_x;
assign led_y = scan_y;

assign flash_cs_n = 1'bz;
assign flash_sclk = 1'bz;
assign flash_mosi = 1'bz;

always @(posedge clk125m)
begin
	led_tmr <= led_tmr+1;
end

always @(posedge clk125m)
begin
	case(led_tmr[19:16])
		0: begin scan_x <= 4'b0001; scan_y <= 3'b110; end
		1: begin scan_x <= 4'b0010; scan_y <= 3'b110; end
		2: begin scan_x <= 4'b0100; scan_y <= 3'b110; end
		3: begin scan_x <= 4'b1000; scan_y <= 3'b110; end
		4: begin scan_x <= 4'b0001; scan_y <= 3'b101; end
		5: begin scan_x <= 4'b0010; scan_y <= 3'b101; end
		6: begin scan_x <= 4'b0100; scan_y <= 3'b101; end
		7: begin scan_x <= 4'b1000; scan_y <= 3'b101; end
		8: begin scan_x <= 4'b0001; scan_y <= 3'b011; end
		9: begin scan_x <= 4'b0010; scan_y <= 3'b011; end
		10: begin scan_x <= 4'b0100; scan_y <= 3'b011; end
		11: begin scan_x <= 4'b1000; scan_y <= 3'b011; end
		default: begin scan_x <= 4'b0000; scan_y <= 3'b111; end
	endcase
end

nvm_emu nvm_i(
	.cs_n(eep_cs_n),
	.sck(eep_sclk),
	.si(eep_mosi),
	.so(eep_miso)
);

endmodule
