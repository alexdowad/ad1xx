// RISC-V has 31 general registers, numbered from 1-31; 'register 0' cannot be
// set and its value is always zero

// (In other words, instructions which use 'register zero' as a source register
//  are actually just using a constant zero as operand)

module register_file
(
  input clk,

  input [4:0] read_select_1,
  output reg [31:0] read_1,

  input [4:0] read_select_2,
  output reg [31:0] read_2,

  input [4:0] write_select, // if write_select = 0, don't write anything
  input [31:0] write
);

reg [31:0] registers [31:1];

always @(posedge clk)
  if (write_select != 0)
    registers[write_select] <= write;

always @*
  if (read_select_1 == 0)
    read_1 = 0;
  else
    read_1 = registers[read_select_1];

always @*
  if (read_select_2 == 0)
    read_2 = 0;
  else
    read_2 = registers[read_select_2];

endmodule
