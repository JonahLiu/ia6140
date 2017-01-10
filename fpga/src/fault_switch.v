module fault_switch(
	input	clk,
	input	rst,
	input	link1_ok,
	input	link2_ok,
	output	reg link1_enable,
	output	reg link2_enable,
	output	reg pre_switch,
	output	reg post_switch
);
parameter SWITCH_HOLDOFF=4_000_000;

reg [23:0] timer;
reg [3:0] pre_cnt;
reg [3:0] post_cnt;
integer s1, s1_next;

localparam S1_IDLE=0, S1_LINK1=1, S1_LINK2=2, S1_HOLDOFF=3;

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
			if(link1_ok)
				s1_next = S1_LINK1;
			else if(link2_ok)
				s1_next = S1_LINK2;
			else
				s1_next = S1_IDLE;
		end
		S1_LINK1: begin
			if(!link1_ok)
				s1_next = S1_HOLDOFF;
			else
				s1_next = S1_LINK1;
		end
		S1_LINK2: begin
			if(!link2_ok)
				s1_next = S1_HOLDOFF;
			else
				s1_next = S1_LINK2;
		end
		S1_HOLDOFF: begin
			if(timer==SWITCH_HOLDOFF)
				s1_next = S1_IDLE;
			else
				s1_next = S1_HOLDOFF;
		end
		default: begin
			s1_next = 'bx;
		end
	endcase
end

always @(posedge clk, posedge rst)
begin
	if(rst) begin
		link1_enable <= 1'b0;
		link2_enable <= 1'b0;
		timer <= 'b0;
	end
	else case(s1_next)
		S1_IDLE: begin
			link1_enable <= 1'b0;
			link2_enable <= 1'b0;
			timer <= 'b0;
		end
		S1_LINK1: begin
			link1_enable <= 1'b1;
		end
		S1_LINK2: begin
			link2_enable <= 1'b1;
		end
		S1_HOLDOFF: begin
			link1_enable <= 1'b0;
			link2_enable <= 1'b0;
			timer <= timer + 1;
		end
	endcase
end

always @(posedge clk, posedge rst)
begin
	if(rst) begin
		pre_cnt <= 'b0;
	end
	else if(s1_next==S1_HOLDOFF && s1!=S1_HOLDOFF) begin
		pre_cnt <= 4'b1111;
	end
	else if(pre_cnt) begin
		pre_cnt <= pre_cnt-1;
	end
end
always @(posedge clk, posedge rst)
begin
	if(rst)
		pre_switch <= 1'b0;
	else
		pre_switch <= pre_cnt!=0;
end

always @(posedge clk, posedge rst)
begin
	if(rst) begin
		post_cnt <= 'b0;
	end
	else if(s1 ==S1_HOLDOFF && s1_next!=S1_HOLDOFF) begin
		post_cnt <= 4'b1111;
	end
	else if(post_cnt) begin
		post_cnt <= post_cnt-1;
	end
end
always @(posedge clk, posedge rst)
begin
	if(rst)
		post_switch <= 1'b0;
	else
		post_switch <= post_cnt!=0;
end

endmodule
