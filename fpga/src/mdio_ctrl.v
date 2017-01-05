`timescale 1ns/1ns
module mdio_ctrl
(
	input	clk,
	input	rst,

	output reg	mdc,
	input	mdio_i,
	output reg	mdio_o,
	output reg	mdio_oe,

	input	[4:0]	phy_addr,
	input	[4:0] 	reg_addr,
	input	[15:0]	wdata,
	output  [15:0]	rdata,
	input	[1:0]	op,
	input	start,
	output	ready,
	output  error
);
parameter PRESCALE=16;
parameter OP_READ = 2'b10, OP_WRITE = 2'b01;
localparam SOF=2'b01,TA=2'b10;


reg [7:0] ccnt;
reg [7:0] bcnt;
reg busy;
reg clk_f;
reg [31:0] shift_reg;
reg op_r;

integer s1, s1_next;
localparam S1_IDLE=0, S1_PRE=1, S1_SOF=2, S1_OP=3, S1_PADR=4,
	S1_RADR=5, S1_TA=6, S1_DATA=7, S1_DONE=8;

assign ready = !busy;
assign rdata = shift_reg[15:0];
assign error = !busy ? shift_reg[16]: 1'b0;

always @(posedge clk, posedge rst)
begin
	if(rst) begin
		ccnt <= 'b0;
	end
	else if(ccnt==PRESCALE-1) begin
		ccnt <= 'b0;
	end
	else begin
		ccnt <= ccnt+1;
	end
end

always @(posedge clk, posedge rst)
begin
	if(rst) begin
		clk_f <= 1'b0;
	end
	else if(ccnt==(PRESCALE/2-1)) begin
		clk_f <= 1'b1;
	end
	else begin
		clk_f <= 1'b0;
	end
end

always @(posedge clk)
begin
	if(s1_next==S1_IDLE) begin
		mdc <= 1'b1;
	end
	else if(ccnt==(PRESCALE-PRESCALE/4)) begin
		mdc <= 1'b0;
	end
	else if(ccnt==PRESCALE/4) begin
		mdc <= 1'b1;
	end
end

always @(posedge clk, posedge rst)
begin
	if(rst) begin
		busy <= 1'b0;
		op_r <= 1'bx;
	end
	else if(!busy && start) begin
		busy <= 1'b1;
		op_r <= op;
	end
	else if(clk_f && s1==S1_DONE) begin
		busy <= 1'b0;
	end
end

always @(posedge clk, posedge rst)
begin
	if(rst) begin
		s1 <= S1_IDLE;
	end
	else if(clk_f) begin
		s1 <= s1_next;
	end
end

always @(*)
begin
	case(s1)
		S1_IDLE: begin
			if(busy)
				s1_next = S1_PRE;
			else
				s1_next = S1_IDLE;
		end
		S1_PRE: begin
			if(bcnt==32)
				s1_next = S1_SOF;
			else
				s1_next = S1_PRE;
		end
		S1_SOF: begin
			if(bcnt==34)
				s1_next = S1_OP;
			else
				s1_next = S1_SOF;
		end
		S1_OP: begin
			if(bcnt==36)
				s1_next = S1_PADR;
			else
				s1_next = S1_OP;
		end
		S1_PADR: begin
			if(bcnt==41)
				s1_next = S1_RADR;
			else
				s1_next = S1_PADR;
		end
		S1_RADR: begin
			if(bcnt==46)
				s1_next = S1_TA;
			else
				s1_next = S1_RADR;
		end
		S1_TA: begin
			if(bcnt==48)
				s1_next = S1_DATA;
			else
				s1_next = S1_TA;
		end
		S1_DATA: begin
			if(bcnt==64)
				s1_next = S1_DONE;
			else
				s1_next = S1_DATA;
		end
		S1_DONE: begin
			s1_next = S1_IDLE;
		end
		default: begin
			s1_next = 'bx;
		end
	endcase
end

always @(posedge clk, posedge rst)
begin
	if(rst) begin
		mdio_oe <= 1'b0;
	end
	else if(clk_f) begin
		case(s1_next)
			S1_IDLE: begin
				mdio_oe <= 1'b0;
			end
			S1_PRE: begin
			end
			S1_SOF: begin
				mdio_oe <= 1'b1;
			end
			S1_OP: begin
			end
			S1_PADR: begin
			end
			S1_RADR: begin
			end
			S1_TA: begin
				if(op_r==OP_READ)
					mdio_oe <= 1'b0;
			end
			S1_DATA: begin
			end
			S1_DONE: begin
				mdio_oe <= 1'b0;
			end
		endcase
	end
end

always @(posedge clk)
begin
	if(!busy && start) begin
		{mdio_o,shift_reg} <= {1'b1,SOF[1:0],op[1:0],phy_addr[4:0],reg_addr[4:0],TA[1:0],wdata};
	end
	else if(s1_next!=S1_IDLE && s1_next!=S1_PRE && clk_f) begin
		{mdio_o,shift_reg} <= {shift_reg,mdio_i};
	end
end

always @(posedge clk)
begin
	if(s1_next==S1_IDLE) 
		bcnt <= 'b0;
	else if(clk_f) 
		bcnt <= bcnt+1;
end

endmodule
