module rgmii_if(
	input	rgmii_rxclk,
	input	[3:0]	rgmii_rxdat,
	input	rgmii_rxctl,
	output	rgmii_txclk,
	output	[3:0]	rgmii_txdat,
	output	rgmii_txctl,

	output	reg link_up,
	output	reg speed,
	output	reg duplex,

	output	rx_clk,
	output	[7:0] rx_data,
	output	rx_dv,
	output	rx_er,

	input	tx_clk,
	input	[7:0] tx_data,
	input	tx_en,
	input	tx_er
);
wire rx_er_xor;
wire tx_er_xor;

assign rx_clk = rgmii_rxclk;
assign rx_er = rx_dv^rx_er_xor;
assign tx_er_xor = tx_en^tx_er;

IDDR2 #(.DDR_ALIGNMENT("NONE"),.SRTYPE("ASYNC")) rxdat_iddr_0(.D(rgmii_rxdat[0]),.C0(rx_clk),.C1(!rx_clk),.CE(1'b1),.R(1'b0),.S(1'b0),.Q0(rx_data[0]),.Q1(rx_data[4]));
IDDR2 #(.DDR_ALIGNMENT("NONE"),.SRTYPE("ASYNC")) rxdat_iddr_1(.D(rgmii_rxdat[1]),.C0(rx_clk),.C1(!rx_clk),.CE(1'b1),.R(1'b0),.S(1'b0),.Q0(rx_data[1]),.Q1(rx_data[5]));
IDDR2 #(.DDR_ALIGNMENT("NONE"),.SRTYPE("ASYNC")) rxdat_iddr_2(.D(rgmii_rxdat[2]),.C0(rx_clk),.C1(!rx_clk),.CE(1'b1),.R(1'b0),.S(1'b0),.Q0(rx_data[2]),.Q1(rx_data[6]));
IDDR2 #(.DDR_ALIGNMENT("NONE"),.SRTYPE("ASYNC")) rxdat_iddr_3(.D(rgmii_rxdat[3]),.C0(rx_clk),.C1(!rx_clk),.CE(1'b1),.R(1'b0),.S(1'b0),.Q0(rx_data[3]),.Q1(rx_data[7]));

IDDR2 #(.DDR_ALIGNMENT("NONE"),.SRTYPE("ASYNC")) rxctl_iddr_i(.D(rgmii_rxctl),.C0(rx_clk),.C1(!rx_clk),.CE(1'b1),.R(1'b0),.S(1'b0),.Q0(rx_dv),.Q1(rx_er_xor));



ODDR2 #(.DDR_ALIGNMENT("C0"),.SRTYPE("ASYNC")) txdat_oddr_0(.D0(tx_data[0]),.D1(tx_data[4]),.C0(tx_clk),.C1(!tx_clk),.CE(1'b1),.R(1'b0),.S(1'b0),.Q(rgmii_txdat[0]));
ODDR2 #(.DDR_ALIGNMENT("C0"),.SRTYPE("ASYNC")) txdat_oddr_1(.D0(tx_data[1]),.D1(tx_data[5]),.C0(tx_clk),.C1(!tx_clk),.CE(1'b1),.R(1'b0),.S(1'b0),.Q(rgmii_txdat[1]));
ODDR2 #(.DDR_ALIGNMENT("C0"),.SRTYPE("ASYNC")) txdat_oddr_2(.D0(tx_data[2]),.D1(tx_data[6]),.C0(tx_clk),.C1(!tx_clk),.CE(1'b1),.R(1'b0),.S(1'b0),.Q(rgmii_txdat[2]));
ODDR2 #(.DDR_ALIGNMENT("C0"),.SRTYPE("ASYNC")) txdat_oddr_3(.D0(tx_data[3]),.D1(tx_data[7]),.C0(tx_clk),.C1(!tx_clk),.CE(1'b1),.R(1'b0),.S(1'b0),.Q(rgmii_txdat[3]));

ODDR2 #(.DDR_ALIGNMENT("C0"),.SRTYPE("ASYNC")) txctl_oddr_i(.D0(tx_en),.D1(tx_er_xor),.C0(tx_clk),.C1(!tx_clk),.CE(1'b1),.R(1'b0),.S(1'b0),.Q(rgmii_txctl));
ODDR2 #(.DDR_ALIGNMENT("C0"),.SRTYPE("ASYNC")) txclk_oddr_i(.D0(1'b1),.D1(1'b0),.C0(tx_clk),.C1(!tx_clk),.CE(1'b1),.R(1'b0),.S(1'b0),.Q(rgmii_txclk));

always @(posedge rx_clk)
begin
	if(!rx_dv && !rx_er) begin
		link_up <= rx_data[0];
		speed <= rx_data[2:1];
		duplex <= rx_data[3];
	end
end

endmodule
