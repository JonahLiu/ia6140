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
	input	[1:0] phy2_det,

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
wire clk;

reg [23:0] led_tmr;
reg [3:0] scan_x;
reg [2:0] scan_y;

wire [31:0] gpio_i;
wire [31:0] gpio_o;
wire [31:0] gpio_t;

// currently unused
assign phy0_txclk = phy0_rxclk;
assign phy0_txctl = 1'b0;
assign phy0_txd = 4'b0;
//assign phy0_mdio = 1'bz;
//assign phy0_mdc = 1'bz;
//assign phy0_reset_n = 1'b1;

assign phy1_txclk = phy1_rxclk;
assign phy1_txctl = 1'b0;
assign phy1_txd = 4'b0;
//assign phy1_mdio = 1'bz;
//assign phy1_mdc = 1'bz;
//assign phy1_reset_n = 1'b1;

assign phy2_txclk = phy2_rxclk;
assign phy2_txctl = 1'b0;
assign phy2_txd = 4'b0;
//assign phy2_mdio = 1'bz;
//assign phy2_mdc = 1'bz;
//assign phy2_reset_n = 1'b1;

assign led_x = scan_x;
assign led_y = scan_y;

assign flash_cs_n = 1'bz;
assign flash_sclk = 1'bz;
assign flash_mosi = 1'bz;

always @(posedge clk)
begin
	led_tmr <= led_tmr+1;
end

always @(posedge clk)
begin
	case(led_tmr[17:14])
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

mcu mcu_i(
	.CLKIN(clk125m),
	.CLKOUT(clk),
	.RESET(1'b0),
	.GPIO_I(gpio_i),
	.GPIO_O(gpio_o),
	.GPIO_T(gpio_t)
);

assign gpio_i[0] = phy0_mdc;
assign gpio_i[1] = phy0_mdio;
assign gpio_i[7] = phy0_reset_n;
assign phy0_mdc = gpio_t[0]?1'bz:gpio_o[0];
assign phy0_mdio = gpio_t[1]?1'bz:gpio_o[1];
assign phy0_reset_n = gpio_t[7]?1'bz:gpio_o[7];

assign gpio_i[8] = phy1_mdc;
assign gpio_i[9] = phy1_mdio;
assign gpio_i[15] = phy1_reset_n;
assign phy1_mdc = gpio_t[8]?1'bz:gpio_o[8];
assign phy1_mdio = gpio_t[9]?1'bz:gpio_o[9];
assign phy1_reset_n = gpio_t[15]?1'bz:gpio_o[15];

assign gpio_i[16] = phy2_mdc;
assign gpio_i[17] = phy2_mdio;
assign gpio_i[23] = phy2_reset_n;
assign phy2_mdc = gpio_t[16]?1'bz:gpio_o[16];
assign phy2_mdio = gpio_t[17]?1'bz:gpio_o[17];
assign phy2_reset_n = gpio_t[23]?1'bz:gpio_o[23];

assign gpio_i[31:30] = sw;
endmodule

