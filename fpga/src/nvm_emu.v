module nvm_emu(
	input cs_n,
	input sck,
	input si,
	output so,
	input	[47:0] mac
);

localparam [7:0] OP_READ = 8'b00000011;
localparam [7:0] OP_RDSR = 8'b00000101;
localparam [7:0] DEFAULT_RDSR = 8'b00000000;
/*
* NOTE: The Checksum word (3Fh) is calculated such that after adding all words (00h-3Fh),
* including the Checksum word itself, the sum should equal BABAh. The initial value in
* the 16-bit summing register should be 0000h and the carry bit should be ignored after
* each addition. 
*/

reg [4:0] in_bits;
reg [15:0] in_data;
wire [7:0] opcode;

reg [2:0] out_bits;
reg [7:0] out_data;
reg out_en;
reg out_bit;

wire [15:0] start_addr;
reg [15:0] offset;

reg [15:0] rom_addr;
wire [7:0] rom_data;

integer state, state_next;
localparam S_IDLE=0, S_READ_ADDR=1, S_READ_DATA=2, S_RDSR=3, S_UNSUPPORT=4;

assign opcode = in_data[7:0];
assign start_addr = in_data[15:0];

assign so = out_en ? out_bit : 1'bz;

nvm_rom rom_i(
	.clk(!sck),
	.addr(rom_addr),
	.data(rom_data),
	.mac(mac)
);

always @(posedge sck, posedge cs_n)
begin
	if(cs_n) begin
		in_bits <= 'b0;
		in_data <= 'bx;
	end
	else if(in_bits != 24) begin
		in_bits <= in_bits+1;
		in_data <= {in_data[14:0], si};
	end
end

always @(negedge sck, posedge cs_n)
begin
	if(cs_n)
		state <= S_IDLE;
	else
		state <= state_next;
end

always @(*)
begin
	case(state)
		S_IDLE: begin
			if(in_bits == 8) begin
				if(opcode == OP_READ)
					state_next = S_READ_ADDR;
				else if(opcode == OP_RDSR)
					state_next = S_RDSR;
				else 
					state_next = S_UNSUPPORT;
			end
			else begin
				state_next = S_IDLE;
			end
		end
		S_READ_ADDR: begin
			if(in_bits == 24) 
				state_next = S_READ_DATA;
			else 
				state_next = S_READ_ADDR;
		end
		S_READ_DATA: begin
			state_next = S_READ_DATA;
		end
		S_RDSR: begin
			if(out_bits == 0)
				state_next = S_UNSUPPORT;
			else
				state_next = S_RDSR;
		end
		S_UNSUPPORT: begin
			state_next = S_UNSUPPORT;
		end
		default: begin
			state_next = 'bx;
		end
	endcase
end

always @(negedge sck, posedge cs_n)
begin
	if(cs_n) begin
		out_bits <= 7'b0;
		out_data <= 7'bx;
		out_en <= 1'b0;
		offset <= 16'b0;
	end
	else case(state_next)
		S_IDLE: begin
		end
		S_READ_ADDR: begin
		end
		S_READ_DATA: begin
			out_en <= 1'b1;

			if(out_bits==1) begin
				out_data <= {rom_data[6:0],1'b0};
				offset <= offset+1;
			end
			else begin
				out_data <= {out_data[6:0],1'b0};
			end

			out_bits <= out_bits+1;
		end
		S_RDSR: begin
			out_en <= 1'b1;

			if(out_bits==0)
				out_data <= DEFAULT_RDSR;
			else
				out_data <= {out_data[6:0],1'b0};

			out_bits <= out_bits+1;
		end
		S_UNSUPPORT: begin
			out_en <= 1'b0;
			out_bits <= out_bits+1;
		end
	endcase
end

always @(*)
begin
	rom_addr = start_addr + offset;
end

always @(*)
begin
	if(state==S_READ_DATA && out_bits==1) out_bit = rom_data[7];
	else out_bit = out_data[7];
end

endmodule

