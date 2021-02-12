// Instructions in the basic RISC-V ISA are always aligned to a multiple of 4 bytes

module program_counter
(
  input clk,

  input  [29:0] jump_dest,
  input         jump,

  output [29:0] pc
);

// For FPGA synthesis, it is OK to set initial values of registers
// For an ASIC, we would need to have a reset line
reg [29:0] counter = {28'hFF00000, 2'b00}; // map boot firmware to 0xFF000000

always @(posedge clk)
  if (jump)
    counter <= jump_dest;
  else
    counter++;

assign pc = counter;

endmodule
