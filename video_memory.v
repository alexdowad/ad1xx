// 2400-byte memory holding 80 columns x 30 rows of 8-bit characters
// Organized into 600 32-bit words (so addresses are 10 bits)

// Each of the 4 bytes in a word has a separate write-enable line, so it
// is possible to choose which bytes to write

// Note: This is designed to use Block RAM on a Xilinx Spartan-6 FPGA
// Ref: https://www.xilinx.com/support/documentation/user_guides/ug383.pdf

// Spartan-6 BRAMs can be configured with separately clocked read and write ports
// They can be configured with 8/16/32 bit wide data path on each port
// And if the data path is wider than 8 bits, there is a separate write enable
// for each byte
// This will be very helpful when writing to video memory using a RISC-V CPU,
// since stores can be byte, halfword, or word size

module video_memory
(
	// Use dual-ported RAM with separate read and write clocks
	// The read clock will be the VGA clock, and the write clock will be the CPU clock
	input read_clk, write_clk,

	input [11:0] addr_read,
	output reg [7:0] data_read,

	input [9:0] addr_write,
	input [31:0] data_write,
	// Out of the input word, `write_enable1` controls writing of the least-significant
	// 8 bits (which represent the character furthest to the left; remember this is
	// a little-endian machine)
	// `write_enable2` are the next 8 bits, and so on
	input write_enable_1, write_enable_2, write_enable_3, write_enable_4
);

reg [7:0] ram[2399:0];

wire [11:0] addr_write_byte = addr_write << 2;

// For VGA controller to read characters which should be displayed
always @ (posedge read_clk)
	data_read <= ram[addr_read];

// For CPU to write characters
always @ (posedge write_clk) begin
	if (write_enable_1)
		ram[addr_write_byte] <= data_write[7:0];
	if (write_enable_2)
		ram[addr_write_byte+1] <= data_write[15:8];
	if (write_enable_3)
		ram[addr_write_byte+2] <= data_write[23:16];
	if (write_enable_4)
		ram[addr_write_byte+3] <= data_write[31:24];
end

endmodule
