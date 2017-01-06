`timescale 1ns/1ps
module test_post_switch;

reg rst;
reg clk;
reg [7:0] up_data;
reg up_dv;
reg up_er;
reg mac_valid;
reg trigger;

wire [7:0] down_data;
wire down_dv;
wire down_er;

post_switch #(.ARP_REPEAT(3)) dut(
	.rst(rst),
	.clk(clk),
	.mac_address(48'h112233AABBCC),
	.mac_valid(mac_valid),
	.trigger(trigger),
	.up_data(up_data),
	.up_dv(up_dv),
	.up_er(up_er),
	.down_data(down_data),
	.down_dv(down_dv),
	.down_er(down_er)
);

task test_normal_pkt(input integer size);
	begin:TEST_PKT
		integer i;
		@(posedge clk);
		up_dv <= 1'b1;
		repeat(7) begin
			up_data <= 8'h55;
			@(posedge clk);
		end
		up_data <= 8'h5D;
		@(posedge clk);
		for(i=0;i<size;i=i+1) begin
			up_data <= i;
			up_er <= 1'b0;
			@(posedge clk);
		end
		up_dv <= 1'b0;
		@(posedge clk);
	end
endtask

task test_switch;
	begin
		trigger <= 1;
		@(posedge clk);
		trigger <= 0;
		@(posedge clk);
	end
endtask

initial begin
	clk = 0;
	forever #4 clk = !clk;
end

initial begin
	$dumpfile("test_post_switch.vcd");
	$dumpvars(0);

	trigger = 0;
	mac_valid = 0;
	up_data = 0;
	up_dv = 0;
	up_er = 0;

	rst = 1;
	#100 rst = 0;

	test_normal_pkt(60);

	mac_valid <= 1;

	test_normal_pkt(128);

	test_switch();

	#10000;

	test_normal_pkt(128);

	#10000;

	$finish;
end

endmodule
