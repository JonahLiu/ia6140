module fault_detect(
	input	clk,
	input	rst,
	input	link,
	input	[1:0] line_sample,
	output	reg link_ok
);

parameter LINK_UP_HOLD_OFF = 65535;
parameter FAULT_TIMEOUT = 127;

reg [1:0] sample_0, sample_1, sample_2;
always @(posedge clk)
begin
	sample_0 = line_sample;
	sample_1 = sample_0;
	sample_2 = sample_1;
end

reg	[15:0] hold_timer;
reg [7:0] ctmr0;
reg [7:0] ctmr1;
reg carrier_fault;

integer s1, s1_next;
localparam S1_IDLE=0, S1_HOLD=2, S1_UP=3;

always @(posedge clk)
begin
	if(sample_2[1]!=sample_1[1])
		ctmr1 <= 'b0;
	else if(ctmr1 != FAULT_TIMEOUT);
		ctmr1 <= ctmr1+1;

	if(sample_2[0]!=sample_1[0])
		ctmr0 <= 'b0;
	else if(ctmr0 != FAULT_TIMEOUT);
		ctmr0 <= ctmr0+1;

	carrier_fault <= (ctmr0==FAULT_TIMEOUT) || (ctmr1==FAULT_TIMEOUT);
end

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
			if(link)
				s1_next = S1_HOLD;
			else
				s1_next = S1_IDLE;
		end
		S1_HOLD: begin
			if(!link || carrier_fault)
				s1_next = S1_IDLE;
			else if(hold_timer == LINK_UP_HOLD_OFF) 
				s1_next = S1_UP;
			else
				s1_next = S1_HOLD;
		end
		S1_UP: begin
			if(!link || carrier_fault)
				s1_next = S1_IDLE;
			else
				s1_next = S1_UP;
		end
		default: begin
			s1_next = 'bx;
		end
	endcase
end

always @(posedge clk, posedge rst)
begin
	if(rst) begin
		link_ok <= 1'b0;
		hold_timer <= 'bx;
	end
	else case(s1_next)
		S1_IDLE: begin
			link_ok <= 1'b0;
			hold_timer <= 'b0;
		end
		S1_HOLD: begin
			hold_timer <= hold_timer+1;
		end
		S1_UP: begin
			link_ok <= 1'b1;
		end
	endcase
end

endmodule
