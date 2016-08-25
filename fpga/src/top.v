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
parameter CLK_PERIOD_NS = 8;
parameter PULSE_EXTEND_MS = 500;
localparam PULSE_EXTEND_CYCLES = PULSE_EXTEND_MS*1000000/CLK_PERIOD_NS;

wire clk;
wire rst;

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

wire phy0_link;
wire [1:0] phy0_speed;
wire phy0_duplex;
wire phy1_link;
wire [1:0] phy1_speed;
wire phy1_duplex;
wire phy2_link;
wire [1:0] phy2_speed;
wire phy2_duplex;

assign flash_cs_n = 1'bz;
assign flash_sclk = 1'bz;
assign flash_mosi = 1'bz;

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
assign phy0_link = gpio_o[2];
assign phy0_speed = gpio_o[4:3];
assign phy0_duplex = gpio_o[5];
assign phy0_reset_n = gpio_t[7]?1'bz:gpio_o[7];

assign gpio_i[8] = phy1_mdc;
assign gpio_i[9] = phy1_mdio;
assign gpio_i[15] = phy1_reset_n;
assign phy1_mdc = gpio_t[8]?1'bz:gpio_o[8];
assign phy1_mdio = gpio_t[9]?1'bz:gpio_o[9];
assign phy1_link = gpio_o[10];
assign phy1_speed = gpio_o[12:11];
assign phy1_duplex = gpio_o[13];
assign phy1_reset_n = gpio_t[15]?1'bz:gpio_o[15];

assign gpio_i[16] = phy2_mdc;
assign gpio_i[17] = phy2_mdio;
assign gpio_i[23] = phy2_reset_n;
assign phy2_mdc = gpio_t[16]?1'bz:gpio_o[16];
assign phy2_mdio = gpio_t[17]?1'bz:gpio_o[17];
assign phy2_link = gpio_o[18];
assign phy2_speed = gpio_o[20:19];
assign phy2_duplex = gpio_o[21];
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

wire phy1_active;
pulse_extender #(.MIN_PULSE_CYCLES(PULSE_EXTEND_CYCLES)) p1_pe_i(
	.rst(rst),
	.clk(clk),
	.d(p1_tx_en|p1_rx_dv),
	.q(phy1_active)
);

wire phy2_active;
pulse_extender #(.MIN_PULSE_CYCLES(PULSE_EXTEND_CYCLES)) p2_pe_i(
	.rst(rst),
	.clk(clk),
	.d(p2_tx_en|p2_rx_dv),
	.q(phy2_active)
);

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
led_ctrl #(
	.CLK_PERIOD_NS(CLK_PERIOD_NS),
	.SLOW_PERIOD_MS(1000),
	.FAST_PERIOD_MS(200),
	.DUTY_CYCLE_DIV(16)
)led_i(
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


// LEDs on External Connector
assign led0 = phy1_link ? (mux_select ? 2'b01 : 2'b11) : 2'b00; // LED 0
assign led1 = phy1_active ? 2'b10 : (phy1_link ? 2'b11 : 2'b00); // LED 1
assign led2 = phy0_link ? 2'b11 : 2'b00; // LED 2
assign led3 = phy2_link ? (mux_select ? 2'b11 : 2'b01) : 2'b00; // LED 3
assign led4 = phy2_active ? 2'b10 : (phy2_link ? 2'b11 : 2'b00); // LED 4

// LEDs on board
assign led5 = mux_select ? 2'b00 : 2'b11; // D16
assign led6 = phy1_link ? 2'b11 : 2'b00; // D15
assign led7 = phy1_active ? 2'b10 : (phy1_link ? 2'b11 : 2'b00); // D14
assign led8 = phy0_link? 2'b11 : 2'b00; // D13
assign led9 = mux_select?2'b11:2'b00; // D12
assign led10 = phy2_link ? 2'b11 : 2'b00; // D11
assign led11 = phy2_active ? 2'b10 : (phy2_link ? 2'b11 : 2'b00); // D10

endmodule

