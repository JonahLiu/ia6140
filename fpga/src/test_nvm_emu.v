`timescale 1ns/1ps
module test_nvm_emu;

reg cs_n;
reg sck;
reg si;
wire so;

nvm_emu dut(
	.cs_n(cs_n),
	.sck(sck),
	.si(si),
	.so(so)
);

task strobe(input in);
	begin
		cs_n = 0;
		sck = 0;
		#10 si = in;
		#90 sck = 1;
		#100 sck = 0;
	end
endtask

initial
begin
	sck = 0;
	cs_n = 1;

	#100;

	cs_n = 0;

	strobe(0);
	strobe(0);
	strobe(0);
	strobe(0);
	strobe(0);
	strobe(0);
	strobe(1);
	strobe(1);
	repeat(16) strobe(0);
	repeat(8*4096*2) strobe(0);

	cs_n = 1;
	$stop;
end

endmodule
