module post_switch (
	input	rst,
	input	clk,
	input	speed,
	input	select,
	input	[7:0] up_data,
	input	up_dv,
	input	up_er,
	output	reg [7:0] down_data,
	output	reg down_dv,
	output	reg down_er
);

parameter IFG_CLOCKS=128;
parameter ARP_REPEAT=16;

integer s1, s1_next;
integer s2, s2_next;

localparam S1_IDLE=0,
	S1_REPEAT=1,
	S1_FETCH=2,
	S1_LATENCY=3,
	S1_DATA=4,
	S1_IFG=5; 

localparam S2_IDLE=0,
	S2_SETUP=1,
	S2_RECORD=2,
	S2_BYPASS=3;

wire [8:0] ram_raddr;
reg [7:0] ram_rdata;

wire [8:0] ram_waddr;
reg [7:0] ram_wdata;
reg ram_wen;

reg switched;
reg previous;
reg captured;
reg [7:0] pkt_length;
reg [7:0] pkt_cnt;
reg [7:0] byte_cnt;
reg cap_idx;
reg [7:0] cap_length;
reg hit_high;
reg hit_low;
reg hit_high_2;
reg hit_high_3;
reg hit_low_2;
reg hit_low_3;

reg [15:0] ifg_cnt;
reg read_idx;
reg [7:0] read_offset;
reg write_idx;
reg [7:0] write_offset;

assign ram_raddr = {read_idx, read_offset};
assign ram_waddr = {write_idx, write_offset};

always @(posedge clk, posedge rst)
begin
	if(rst)
		previous <= 1'b0;
	else 
		previous <= select;
end

always @(posedge clk, posedge rst)
begin
	if(rst) 
		switched <= 1'b0;
	else if(previous != select)
		switched <= 1'b1;
	else if(s1_next!= S1_IDLE)
		switched <= 1'b0;
end


always @(posedge clk, posedge rst)
begin
	if(rst) 
		s1 = S1_IDLE;
	else
		s1 = s1_next;
end

always @(*)
begin
	case(s1)
		S1_IDLE: begin
			if(switched && captured)
				s1_next = S1_REPEAT;
			else
				s1_next = S1_IDLE;
		end
		S1_REPEAT: begin
			if(pkt_cnt==ARP_REPEAT)
				s1_next = S1_IDLE;
			else
				s1_next = S1_FETCH;
		end
		S1_FETCH: begin
			s1_next = S1_LATENCY;
		end
		S1_LATENCY: begin
			s1_next = S1_DATA;
		end
		S1_DATA: begin
			if(byte_cnt==pkt_length)
				s1_next = S1_IFG;
			else
				s1_next = S1_DATA;
		end
		S1_IFG: begin
			if(ifg_cnt==IFG_CLOCKS)
				s1_next = S1_REPEAT;
			else
				s1_next = S1_IFG;
		end
		default: begin
			s1_next = 'bx;
		end
	endcase
end

always @(posedge clk, posedge rst)
begin
	if(rst) begin
		down_data <= 'bx;
		down_dv <= 1'b0;
		down_er <= 1'b0;
		pkt_cnt <= 'bx;
		byte_cnt <= 'bx;
		pkt_length <= 'bx;
		ifg_cnt <= 'bx;
		read_offset <= 'bx;
		read_idx <= 'bx;
	end
	else case(s1_next)
		S1_IDLE: begin
			down_data <= up_data;
			down_dv <= up_dv;
			down_er <= up_er;
			pkt_cnt <= 'b0;
		end
		S1_REPEAT: begin
			down_dv <= 1'b0;
			down_er <= 1'b0;
			ifg_cnt <= 'b0;
			byte_cnt <= 'b0;
		end
		S1_FETCH: begin
			read_idx <= cap_idx;
			read_offset <= 'b0;
			pkt_length <= cap_length;
			pkt_cnt <= pkt_cnt+1;
		end
		S1_LATENCY: begin
			read_offset <= read_offset+1;
		end
		S1_DATA: begin
			read_offset <= read_offset+1;
			byte_cnt <= byte_cnt+1;
			down_data <= ram_rdata;
			down_dv <= 1'b1;
		end
		S1_IFG: begin
			ifg_cnt <= ifg_cnt + 1;
			down_dv <= 1'b0;
		end
	endcase
end

always @(posedge clk, posedge rst)
begin
	if(rst) 
		s2 = S2_IDLE;
	else
		s2 = s2_next;
end

always @(*)
begin
	case(s2)
		S2_IDLE: begin
			if(up_dv)
				s2_next = S2_SETUP;
			else
				s2_next = S2_IDLE;
		end
		S2_SETUP: begin
			s2_next = S2_RECORD;
		end
		S2_RECORD: begin
			if(!up_dv)
				s2_next = S2_IDLE;
			else if(&write_offset) // all 1s
				s2_next = S2_BYPASS;
			else
				s2_next = S2_RECORD;
		end
		S2_BYPASS: begin
			if(!up_dv)
				s2_next = S2_IDLE;
			else
				s2_next = S2_BYPASS;
		end
		default: begin
			s2_next = 'bx;
		end
	endcase
end

always @(posedge clk, posedge rst)
begin
	if(rst) begin
		ram_wen <= 1'b0;
		write_idx <= 'b0;
		write_offset <= 'b0;
	end
	else case(s2_next)
		S2_IDLE: begin
			ram_wen <= 1'b0;
		end
		S2_SETUP: begin
			write_idx <= !cap_idx;
			write_offset <= 'b0;
			ram_wdata <= up_data;
			ram_wen <= 1'b1;
		end
		S2_RECORD: begin
			write_offset <= write_offset+1;
			ram_wdata <= up_data;
		end
		S2_BYPASS: begin
			ram_wen <= 1'b0;
		end
	endcase
end

always @(posedge clk, posedge rst)
begin
	if(rst) begin
		cap_idx <= 1'b0;
		captured <= 1'b0;
		cap_length <= 'bx;
		hit_high <= 1'bx;
		hit_low <= 1'bx;
	end
	else begin
		if(write_offset==20)
			hit_high <= ram_wdata==8'h08;
		if(write_offset==21)
			hit_low <= ram_wdata==8'h06;
		if(write_offset==40)
			hit_high_2 <= ram_wdata[3:0]==4'h8;
		if(write_offset==41)
			hit_high_3 <= ram_wdata[3:0]==4'h0;
		if(write_offset==42)
			hit_low_2 <= ram_wdata[3:0]==4'h6;
		if(write_offset==43)
			hit_low_3 <= ram_wdata[3:0]==4'h0;

		if(!up_dv && ram_wen) begin
			if((speed && hit_high && hit_low) 
				|| (!speed && hit_high_2 && hit_high_3 && hit_low_2 && hit_low_3)) begin
				captured <= 1'b1;
				cap_length <= write_offset+1;
				cap_idx <= !cap_idx;
			end
		end
	end
end

reg [7:0] mem[0:511];

always @(posedge clk)
begin
	if(ram_wen)
		mem[ram_waddr] <= ram_wdata;

	ram_rdata <= mem[ram_raddr];
end

////////////////////////////////////////////////////////////////////////
// Debug
wire [35:0] control0;
wire [31:0] trig0;

icon icon_i(
	.CONTROL0(control0)
);

ila32 ila_i(
	.CLK(clk),
	.CONTROL(control0),
	.TRIG0(trig0)
);

assign trig0 = {
	speed,
	cap_idx,
	captured,
	switched,
	select,
	up_data,
	up_dv,
	up_er,
	down_data,
	down_dv,
	down_er
};
endmodule
