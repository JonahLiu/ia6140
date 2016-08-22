module led_ctrl(
	input	rst,
	input	clk,

	input	[1:0] led0,
	input	[1:0] led1,
	input	[1:0] led2,
	input	[1:0] led3,
	input	[1:0] led4,
	input	[1:0] led5,
	input	[1:0] led6,
	input	[1:0] led7,
	input	[1:0] led8,
	input	[1:0] led9,
	input	[1:0] led10,
	input	[1:0] led11,
	input	[1:0] led12,
	input	[1:0] led13,
	input	[1:0] led14,
	input	[1:0] led15,

	output reg	[3:0] scan_x,
	output reg	[3:0] scan_y
);

reg [31:0] led_tmr;

reg [15:0] led_p;

always @(posedge clk)
begin
	led_tmr <= led_tmr+1;
end

assign always_on = led_tmr[19:16]==0;
assign blink_slow = led_tmr[28]&always_on;
assign blink_fast = led_tmr[24]&always_on;

always @(*)
begin
	case(led0)
		2'b00: led_p[0] = 1'b0;
		2'b01: led_p[0] = blink_slow;
		2'b10: led_p[0] = blink_fast;
		2'b11: led_p[0] = always_on;
	endcase
	case(led1)
		2'b00: led_p[1] = 1'b0;
		2'b01: led_p[1] = blink_slow;
		2'b10: led_p[1] = blink_fast;
		2'b11: led_p[1] = always_on;
	endcase
	case(led2)
		2'b00: led_p[2] = 1'b0;
		2'b01: led_p[2] = blink_slow;
		2'b10: led_p[2] = blink_fast;
		2'b11: led_p[2] = always_on;
	endcase
	case(led3)
		2'b00: led_p[3] = 1'b0;
		2'b01: led_p[3] = blink_slow;
		2'b10: led_p[3] = blink_fast;
		2'b11: led_p[3] = always_on;
	endcase
	case(led4)
		2'b00: led_p[4] = 1'b0;
		2'b01: led_p[4] = blink_slow;
		2'b10: led_p[4] = blink_fast;
		2'b11: led_p[4] = always_on;
	endcase
	case(led5)
		2'b00: led_p[5] = 1'b0;
		2'b01: led_p[5] = blink_slow;
		2'b10: led_p[5] = blink_fast;
		2'b11: led_p[5] = always_on;
	endcase
	case(led6)
		2'b00: led_p[6] = 1'b0;
		2'b01: led_p[6] = blink_slow;
		2'b10: led_p[6] = blink_fast;
		2'b11: led_p[6] = always_on;
	endcase
	case(led7)
		2'b00: led_p[7] = 1'b0;
		2'b01: led_p[7] = blink_slow;
		2'b10: led_p[7] = blink_fast;
		2'b11: led_p[7] = always_on;
	endcase
	case(led8)
		2'b00: led_p[8] = 1'b0;
		2'b01: led_p[8] = blink_slow;
		2'b10: led_p[8] = blink_fast;
		2'b11: led_p[8] = always_on;
	endcase
	case(led9)
		2'b00: led_p[9] = 1'b0;
		2'b01: led_p[9] = blink_slow;
		2'b10: led_p[9] = blink_fast;
		2'b11: led_p[9] = always_on;
	endcase
	case(led10)
		2'b00: led_p[10] = 1'b0;
		2'b01: led_p[10] = blink_slow;
		2'b10: led_p[10] = blink_fast;
		2'b11: led_p[10] = always_on;
	endcase
	case(led11)
		2'b00: led_p[11] = 1'b0;
		2'b01: led_p[11] = blink_slow;
		2'b10: led_p[11] = blink_fast;
		2'b11: led_p[11] = always_on;
	endcase
	case(led12)
		2'b00: led_p[12] = 1'b0;
		2'b01: led_p[12] = blink_slow;
		2'b10: led_p[12] = blink_fast;
		2'b11: led_p[12] = always_on;
	endcase
	case(led13)
		2'b00: led_p[13] = 1'b0;
		2'b01: led_p[13] = blink_slow;
		2'b10: led_p[13] = blink_fast;
		2'b11: led_p[13] = always_on;
	endcase
	case(led14)
		2'b00: led_p[14] = 1'b0;
		2'b01: led_p[14] = blink_slow;
		2'b10: led_p[14] = blink_fast;
		2'b11: led_p[14] = always_on;
	endcase
	case(led15)
		2'b00: led_p[15] = 1'b0;
		2'b01: led_p[15] = blink_slow;
		2'b10: led_p[15] = blink_fast;
		2'b11: led_p[15] = always_on;
	endcase
end

always @(posedge clk)
begin
	case(led_tmr[15:14])
		0: begin scan_x <= led_p[3:0]; scan_y <= 3'b1110; end
		1: begin scan_x <= led_p[7:4]; scan_y <= 3'b1101; end
		2: begin scan_x <= led_p[11:8]; scan_y <= 3'b1011; end
		3: begin scan_x <= led_p[15:12]; scan_y <= 3'b0111; end
	endcase
end

endmodule
