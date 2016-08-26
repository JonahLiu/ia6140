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
parameter CLK_PERIOD_NS = 10;
parameter SLOW_PERIOD_MS = 1000;
parameter FAST_PERIOD_MS = 100;

function integer clogb2 (input integer size);
begin
	size = size - 1;
	for (clogb2=1; size>1; clogb2=clogb2+1)
		size = size >> 1;
end
endfunction

localparam SLOW_TMR_MSB = clogb2(SLOW_PERIOD_MS*1000000/CLK_PERIOD_NS)-1;
localparam FAST_TMR_MSB = clogb2(FAST_PERIOD_MS*1000000/CLK_PERIOD_NS)-1;
localparam DIV_LSB = clogb2(1000000/CLK_PERIOD_NS)-1;

reg [31:0] led_tmr;

reg [15:0] led_p;

always @(posedge clk)
begin
	led_tmr <= led_tmr+1;
end

assign always_on = 1'b1;
assign blink_slow = led_tmr[SLOW_TMR_MSB];
assign blink_fast = led_tmr[FAST_TMR_MSB];

always @(*)
begin
	case(led0) /* synthesis full_case */
		2'b00: led_p[0] = 1'b0;
		2'b01: led_p[0] = blink_slow;
		2'b10: led_p[0] = blink_fast;
		2'b11: led_p[0] = always_on;
	endcase
	case(led1) /* synthesis full_case */
		2'b00: led_p[1] = 1'b0;
		2'b01: led_p[1] = blink_slow;
		2'b10: led_p[1] = blink_fast;
		2'b11: led_p[1] = always_on;
	endcase
	case(led2) /* synthesis full_case */
		2'b00: led_p[2] = 1'b0;
		2'b01: led_p[2] = blink_slow;
		2'b10: led_p[2] = blink_fast;
		2'b11: led_p[2] = always_on;
	endcase
	case(led3) /* synthesis full_case */
		2'b00: led_p[3] = 1'b0;
		2'b01: led_p[3] = blink_slow;
		2'b10: led_p[3] = blink_fast;
		2'b11: led_p[3] = always_on;
	endcase
	case(led4) /* synthesis full_case */
		2'b00: led_p[4] = 1'b0;
		2'b01: led_p[4] = blink_slow;
		2'b10: led_p[4] = blink_fast;
		2'b11: led_p[4] = always_on;
	endcase
	case(led5) /* synthesis full_case */
		2'b00: led_p[5] = 1'b0;
		2'b01: led_p[5] = blink_slow;
		2'b10: led_p[5] = blink_fast;
		2'b11: led_p[5] = always_on;
	endcase
	case(led6) /* synthesis full_case */
		2'b00: led_p[6] = 1'b0;
		2'b01: led_p[6] = blink_slow;
		2'b10: led_p[6] = blink_fast;
		2'b11: led_p[6] = always_on;
	endcase
	case(led7) /* synthesis full_case */
		2'b00: led_p[7] = 1'b0;
		2'b01: led_p[7] = blink_slow;
		2'b10: led_p[7] = blink_fast;
		2'b11: led_p[7] = always_on;
	endcase
	case(led8) /* synthesis full_case */
		2'b00: led_p[8] = 1'b0;
		2'b01: led_p[8] = blink_slow;
		2'b10: led_p[8] = blink_fast;
		2'b11: led_p[8] = always_on;
	endcase
	case(led9) /* synthesis full_case */
		2'b00: led_p[9] = 1'b0;
		2'b01: led_p[9] = blink_slow;
		2'b10: led_p[9] = blink_fast;
		2'b11: led_p[9] = always_on;
	endcase
	case(led10) /* synthesis full_case */
		2'b00: led_p[10] = 1'b0;
		2'b01: led_p[10] = blink_slow;
		2'b10: led_p[10] = blink_fast;
		2'b11: led_p[10] = always_on;
	endcase
	case(led11) /* synthesis full_case */
		2'b00: led_p[11] = 1'b0;
		2'b01: led_p[11] = blink_slow;
		2'b10: led_p[11] = blink_fast;
		2'b11: led_p[11] = always_on;
	endcase
	case(led12) /* synthesis full_case */
		2'b00: led_p[12] = 1'b0;
		2'b01: led_p[12] = blink_slow;
		2'b10: led_p[12] = blink_fast;
		2'b11: led_p[12] = always_on;
	endcase
	case(led13) /* synthesis full_case */
		2'b00: led_p[13] = 1'b0;
		2'b01: led_p[13] = blink_slow;
		2'b10: led_p[13] = blink_fast;
		2'b11: led_p[13] = always_on;
	endcase
	case(led14) /* synthesis full_case */
		2'b00: led_p[14] = 1'b0;
		2'b01: led_p[14] = blink_slow;
		2'b10: led_p[14] = blink_fast;
		2'b11: led_p[14] = always_on;
	endcase
	case(led15) /* synthesis full_case */
		2'b00: led_p[15] = 1'b0;
		2'b01: led_p[15] = blink_slow;
		2'b10: led_p[15] = blink_fast;
		2'b11: led_p[15] = always_on;
	endcase
end

always @(posedge clk)
begin
	case(led_tmr[DIV_LSB-1:DIV_LSB-2]) /* synthesis full_case */
		0: scan_y <= 4'b1110;
		1: scan_y <= 4'b1101;
		2: scan_y <= 4'b1011;
		3: scan_y <= 4'b0111;
	endcase
end

always @(posedge clk)
begin
	case(led_tmr[DIV_LSB-1:DIV_LSB-4]) /* synthesis full_case */
		0: scan_x <= {3'b000,led_p[0]};
		1: scan_x <= {2'b00,led_p[1],1'b0};
		2: scan_x <= {1'b0,led_p[2],2'b00};
		3: scan_x <= {led_p[3],3'b000};

		4: scan_x <= {3'b000,led_p[4]};
		5: scan_x <= {2'b00,led_p[5],1'b0};
		6: scan_x <= {1'b0,led_p[6],2'b00};
		7: scan_x <= {led_p[7],3'b000};

		8: scan_x <= {3'b000,led_p[8]};
		9: scan_x <= {2'b00,led_p[9],1'b0};
		10: scan_x <= {1'b0,led_p[10],2'b00};
		11: scan_x <= {led_p[11],3'b000};

		12: scan_x <= {3'b000,led_p[12]};
		13: scan_x <= {2'b00,led_p[13],1'b0};
		14: scan_x <= {1'b0,led_p[14],2'b00};
		15: scan_x <= {led_p[15],3'b000};
	endcase
end

endmodule
