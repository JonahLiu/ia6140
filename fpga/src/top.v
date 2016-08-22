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
wire rst;

wire [1:0] led0;
wire [1:0] led1;
wire [1:0] led2;
wire [1:0] led3;
wire [1:0] led4;
wire [1:0] led5;
wire [1:0] led6;
wire [1:0] led7;
wire [1:0] led8;
wire [1:0] led9;
wire [1:0] led10;
wire [1:0] led11;

wire [31:0] gpio_i;
wire [31:0] gpio_o;
wire [31:0] gpio_t;

wire up_rx_clk;
wire [7:0] up_rx_data;
wire up_rx_dv;
wire up_rx_er;
wire up_tx_clk;
wire [7:0] up_tx_data;
wire up_tx_en;
wire up_tx_er;

wire p1_rx_clk;
wire [7:0] p1_rx_data;
wire p1_rx_dv;
wire p1_rx_er;
wire p1_tx_clk;
wire [7:0] p1_tx_data;
wire p1_tx_en;
wire p1_tx_er;

wire p2_rx_clk;
wire [7:0] p2_rx_data;
wire p2_rx_dv;
wire p2_rx_er;
wire p2_tx_clk;
wire [7:0] p2_tx_data;
wire p2_tx_en;
wire p2_tx_er;

wire mux_select;

assign flash_cs_n = 1'bz;
assign flash_sclk = 1'bz;
assign flash_mosi = 1'bz;

led_ctrl led_i(
	.rst(rst),
	.clk(clk),
	.led0(led0),
	.led1(led1),
	.led2(led2),
	.led3(led3),
	.led4(led4),
	.led5(led5),
	.led6(led6),
	.led7(led7),
	.led8(led8),
	.led9(led9),
	.led10(led10),
	.led11(led11),
	.led12(2'b00),
	.led13(2'b00),
	.led14(2'b00),
	.led15(2'b00),
	.scan_x(led_x),
	.scan_y(led_y)
);


assign led0 = 2'b00;
assign led1 = 2'b00;
assign led2 = 2'b00;
assign led3 = 2'b00;
assign led4 = 2'b00;
assign led5 = mux_select?2'b00:2'b11;
assign led6 = 2'b00;
assign led7 = 2'b00;
assign led8 = 2'b11;
assign led9 = mux_select?2'b11:2'b00;
assign led10 = 2'b00;
assign led11 = 2'b00;

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
	.RESETOUT(rst),
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

assign gpio_i[24] = gpio_o[24];
assign mux_select = gpio_o[24];

rgmii_if up_if_i(
	.rgmii_rxclk(phy0_rxclk),
	.rgmii_rxdat(phy0_rxd),
	.rgmii_rxctl(phy0_rxctl),
	.rgmii_txclk(phy0_txclk),
	.rgmii_txdat(phy0_txd),
	.rgmii_txctl(phy0_txctl),

	.rx_clk(up_rx_clk),
	.rx_data(up_rx_data),
	.rx_dv(up_rx_dv),
	.rx_er(up_rx_er),

	.tx_clk(up_tx_clk),
	.tx_data(up_tx_data),
	.tx_en(up_tx_en),
	.tx_er(up_tx_er)
);

rgmii_if p1_if_i(
	.rgmii_rxclk(phy1_rxclk),
	.rgmii_rxdat(phy1_rxd),
	.rgmii_rxctl(phy1_rxctl),
	.rgmii_txclk(phy1_txclk),
	.rgmii_txdat(phy1_txd),
	.rgmii_txctl(phy1_txctl),

	.rx_clk(p1_rx_clk),
	.rx_data(p1_rx_data),
	.rx_dv(p1_rx_dv),
	.rx_er(p1_rx_er),

	.tx_clk(p1_tx_clk),
	.tx_data(p1_tx_data),
	.tx_en(p1_tx_en),
	.tx_er(p1_tx_er)
);

rgmii_if p2_if_i(
	.rgmii_rxclk(phy2_rxclk),
	.rgmii_rxdat(phy2_rxd),
	.rgmii_rxctl(phy2_rxctl),
	.rgmii_txclk(phy2_txclk),
	.rgmii_txdat(phy2_txd),
	.rgmii_txctl(phy2_txctl),

	.rx_clk(p2_rx_clk),
	.rx_data(p2_rx_data),
	.rx_dv(p2_rx_dv),
	.rx_er(p2_rx_er),

	.tx_clk(p2_tx_clk),
	.tx_data(p2_tx_data),
	.tx_en(p2_tx_en),
	.tx_er(p2_tx_er)
);

wire [7:0] p1_mux_data;
wire p1_mux_en;
wire p1_mux_er;

wire [7:0] p2_mux_data;
wire p2_mux_en;
wire p2_mux_er;

assign up_tx_clk = clk;
assign up_tx_data = mux_select ? p2_mux_data : p1_mux_data;
assign up_tx_en = mux_select ? p2_mux_en : p1_mux_en;
assign up_tx_er = mux_select ? p2_mux_er : p1_mux_er;

pkt_fifo p1_rx_fifo_i(
	.rst(mux_select),
	.rx_clk(p1_rx_clk),
	.rx_data(p1_rx_data),
	.rx_dv(p1_rx_dv),
	.rx_er(p1_rx_er),
	.tx_clk(up_tx_clk),
	.tx_data(p1_mux_data),
	.tx_en(p1_mux_en),
	.tx_er(p1_mux_er)
);

pkt_fifo p2_rx_fifo_i(
	.rst(!mux_select),
	.rx_clk(p2_rx_clk),
	.rx_data(p2_rx_data),
	.rx_dv(p2_rx_dv),
	.rx_er(p2_rx_er),
	.tx_clk(up_tx_clk),
	.tx_data(p2_mux_data),
	.tx_en(p2_mux_en),
	.tx_er(p2_mux_er)
);

assign p1_tx_clk = clk;
pkt_fifo p1_tx_fifo_i(
	.rst(mux_select),
	.rx_clk(up_rx_clk),
	.rx_data(up_rx_data),
	.rx_dv(up_rx_dv),
	.rx_er(up_rx_er),
	.tx_clk(p1_tx_clk),
	.tx_data(p1_tx_data),
	.tx_en(p1_tx_en),
	.tx_er(p1_tx_er)
);

assign p2_tx_clk = clk;
pkt_fifo p2_tx_fifo_i(
	.rst(!mux_select),
	.rx_clk(up_rx_clk),
	.rx_data(up_rx_data),
	.rx_dv(up_rx_dv),
	.rx_er(up_rx_er),
	.tx_clk(p2_tx_clk),
	.tx_data(p2_tx_data),
	.tx_en(p2_tx_en),
	.tx_er(p2_tx_er)
);

endmodule

