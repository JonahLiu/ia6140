module phy_config(
	input	clk,
	input	rst,
	output	mdc,
	input	mdio_i,
	output	mdio_o,
	output	mdio_oe
);

parameter PRESCALE=128;

reg [4:0] phy_addr;
reg [4:0] reg_addr;
reg [15:0] wdata;
reg valid;
reg [1:0] op;
wire ready;

mdio_ctrl #(.PRESCALE(PRESCALE)) mdio_ctrl_i(
	.clk(clk),
	.rst(rst),
	.mdc(mdc),
	.mdio_i(mdio_i),
	.mdio_o(mdio_o),
	.mdio_oe(mdio_oe),
	.phy_addr(phy_addr),
	.reg_addr(reg_addr),
	.wdata(wdata),
	.rdata(),
	.op(op),
	.valid(valid),
	.ready(ready),
	.error()
);
integer s1, s1_next;
localparam S1_IDLE=0, S1_EPSC=2, S1_RESET=3, S1_DONE=4;

always @(posedge clk, posedge rst)
begin
	if(rst)
		s1 <= S1_IDLE;
	else
		s1 <= s1_next;
end

always @(*)
begin
	case(s1)
		S1_IDLE: begin
			s1_next = S1_EPSC;
		end
		S1_EPSC: begin
			if(ready) 
				s1_next = S1_RESET;
			else
				s1_next = S1_EPSC;
		end
		S1_RESET: begin
			if(ready)
				s1_next = S1_DONE;
			else
				s1_next = S1_RESET;
		end
		S1_DONE: begin
			s1_next = S1_DONE;
		end
	endcase
end

always @(posedge clk, posedge rst)
begin
	if(rst) begin
		phy_addr <= 'bx;
		reg_addr <= 'bx;
		op <= 'bx;
		valid <= 1'b0;
	end
	else case(s1_next) 
		S1_IDLE: begin
		end
		S1_EPSC: begin
			phy_addr <= 'b0;
			reg_addr <= 20;
			op <= 2'b01;
			wdata <= 16'h0CE6;
			valid <= 1'b1;
		end
		S1_RESET: begin
			phy_addr <= 'b0;
			reg_addr <= 0;
			op <= 2'b01;
			wdata <= 16'h9140;
			valid <= 1'b1;
		end
		S1_DONE: begin
			valid <= 1'b0;
		end
	endcase
end

endmodule
