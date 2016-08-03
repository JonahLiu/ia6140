module nvm_rom(
	input	clk,
	input	[15:0] addr,
	output [7:0] data
);

reg byte_sel;
reg [15:0] rom [0:4095];
reg [15:0] rom_word;

//assign data = byte_sel ? rom_word[7:0] : rom_word[15:8];
assign data = byte_sel ? rom_word[15:8] : rom_word[7:0];

initial
  $readmemh("eeprom.hex", rom);

always @(posedge clk)
	 byte_sel <= addr[0];

always @(posedge clk)
	 rom_word <= rom[addr[12:1]];

endmodule
