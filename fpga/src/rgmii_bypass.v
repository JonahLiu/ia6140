module rgmii_bypass(
	input	rxclk,
	input	[3:0]	rxdat,
	input	rxctl,
	output	txclk,
	output	[3:0]	txdat,
	output	txctl
);

wire [7:0] rxdata;
wire rxdv;
wire rxer;

wire [7:0] txdata;
wire txdv;
wire txer;

reg [7:0] data_0, data_1;
reg dv_0, dv_1;
reg er_0, er_1;

assign {txer, txdv, txdata} = {er_1, dv_1, data_1};

IDDR2 #(.DDR_ALIGNMENT("NONE"),.SRTYPE("ASYNC")) rxdat_iddr_0(.D(rxdat[0]),.C0(rxclk),.C1(!rxclk),.CE(1'b1),.R(1'b0),.S(1'b0),.Q0(rxdata[0]),.Q1(rxdata[4]));
IDDR2 #(.DDR_ALIGNMENT("NONE"),.SRTYPE("ASYNC")) rxdat_iddr_1(.D(rxdat[1]),.C0(rxclk),.C1(!rxclk),.CE(1'b1),.R(1'b0),.S(1'b0),.Q0(rxdata[1]),.Q1(rxdata[5]));
IDDR2 #(.DDR_ALIGNMENT("NONE"),.SRTYPE("ASYNC")) rxdat_iddr_2(.D(rxdat[2]),.C0(rxclk),.C1(!rxclk),.CE(1'b1),.R(1'b0),.S(1'b0),.Q0(rxdata[2]),.Q1(rxdata[6]));
IDDR2 #(.DDR_ALIGNMENT("NONE"),.SRTYPE("ASYNC")) rxdat_iddr_3(.D(rxdat[3]),.C0(rxclk),.C1(!rxclk),.CE(1'b1),.R(1'b0),.S(1'b0),.Q0(rxdata[3]),.Q1(rxdata[7]));

IDDR2 #(.DDR_ALIGNMENT("NONE"),.SRTYPE("ASYNC")) rxctl_iddr_i(.D(rxctl),.C0(rxclk),.C1(!rxclk),.CE(1'b1),.R(1'b0),.S(1'b0),.Q0(rxdv),.Q1(rxer));

always @(posedge rxclk)
begin
	data_0 <= rxdata;
	dv_0 <= rxdv;
	er_0 <= rxer;

	data_1 <= data_0;
	dv_1 <= dv_0;
	er_1 <= er_0;
end

ODDR2 #(.DDR_ALIGNMENT("C0"),.SRTYPE("ASYNC")) txdat_oddr_0(.D0(txdata[0]),.D1(txdata[4]),.C0(rxclk),.C1(!rxclk),.CE(1'b1),.R(1'b0),.S(1'b0),.Q(txdat[0]));
ODDR2 #(.DDR_ALIGNMENT("C0"),.SRTYPE("ASYNC")) txdat_oddr_1(.D0(txdata[1]),.D1(txdata[5]),.C0(rxclk),.C1(!rxclk),.CE(1'b1),.R(1'b0),.S(1'b0),.Q(txdat[1]));
ODDR2 #(.DDR_ALIGNMENT("C0"),.SRTYPE("ASYNC")) txdat_oddr_2(.D0(txdata[2]),.D1(txdata[6]),.C0(rxclk),.C1(!rxclk),.CE(1'b1),.R(1'b0),.S(1'b0),.Q(txdat[2]));
ODDR2 #(.DDR_ALIGNMENT("C0"),.SRTYPE("ASYNC")) txdat_oddr_3(.D0(txdata[3]),.D1(txdata[7]),.C0(rxclk),.C1(!rxclk),.CE(1'b1),.R(1'b0),.S(1'b0),.Q(txdat[3]));

ODDR2 #(.DDR_ALIGNMENT("C0"),.SRTYPE("ASYNC")) txctl_oddr_i(.D0(txdv),.D1(txer),.C0(rxclk),.C1(!rxclk),.CE(1'b1),.R(1'b0),.S(1'b0),.Q(txctl));
ODDR2 #(.DDR_ALIGNMENT("C0"),.SRTYPE("ASYNC")) txclk_oddr_i(.D0(1'b1),.D1(1'b0),.C0(rxclk),.C1(!rxclk),.CE(1'b1),.R(1'b0),.S(1'b0),.Q(txclk));

endmodule
