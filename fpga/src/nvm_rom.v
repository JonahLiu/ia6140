module nvm_rom(
	input	clk,
	input	[15:0] addr,
	output	[7:0] data,
	input	[47:0] mac
);

reg [15:0] rom [0:4095];
reg [15:0] rom_word;
reg [15:0] read_word;
reg [15:0] addr_r;

// Byte swapped. See datasheet.
wire [15:0] mac_sum = {mac[39:32],mac[47:40]}+{mac[23:16],mac[31:24]}+{mac[7:0],mac[15:8]};

assign data = addr_r[0] ? rom_word[15:8] : rom_word[7:0];

initial
  $readmemh("eeprom.hex", rom);

always @(posedge clk)
	addr_r <= addr;

always @(posedge clk)
	read_word <= rom[addr[12:1]];

always @(*)
begin
	case(addr_r[12:1])
		15'h0000: rom_word = {mac[39:32],mac[47:40]};
		15'h0001: rom_word = {mac[23:16],mac[31:24]};
		15'h0002: rom_word = {mac[7:0],mac[15:8]};
		15'h003F: rom_word = read_word-mac_sum;
		default: rom_word = read_word;
	endcase
end

endmodule
