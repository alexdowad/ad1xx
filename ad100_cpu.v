// Basic single-issue, in-order, RISC-V CPU
// Only supports the basic, 32-bit RISC-V ISA (RV32I) without any of the standard ISA extensions
// Little-endian

// Ref: https://riscv.org/technical/specifications/
// Also see ./ad100.txt for architectural details not determined by RISC-V specification

// Different types of conditional branches
`define BEQ   3'b000
`define BNE   3'b001
`define BLT   3'b100
`define BGE   3'b101
`define BLTU  3'b110
`define BGEU  3'b111

// Different types of loads
`define LB    3'b000
`define LH    3'b001
`define LW    3'b010
`define LBU   3'b100
`define LHU   3'b101

module ad100_cpu
(
  input clk,

  // memory subsystem must have 1x 32-bit read port and 1x read/write port
  // we only read and write to/from memory in 32-bit words
  output     [29:0] addr_1, // used for reading instructions
  input      [31:0] read_1,

  output     [29:0] addr_2, // used for reading/writing data
  input      [31:0] read_2,
  output reg [31:0] write_2,
  output reg        write_enable_2
);

// Memory read port 1 is always used to read the instruction we should execute
wire [29:0] program_counter;
assign addr_1 = program_counter;
wire [31:0] alu_result;
// Loads/stores always get pointer by adding offset either to program counter or to a register
// Rather than gating `addr_2` on whether the current instruction is a load/store or not,
// we just hard-wire the ALU output to `addr_2` and ignore the value which comes back
// when we don't need it
assign addr_2 = alu_result[31:2];

wire [31:0] instruction = read_1;

// Picking various fields out of current instruction
wire [4:0] opcode1 = instruction[6:2];
wire [2:0] opcode2 = instruction[14:12];
wire       opcode3 = instruction[30];

wire [4:0] dest_reg  = instruction[11:7];
wire [4:0] src_reg_1 = instruction[19:15];
wire [4:0] src_reg_2 = instruction[24:20];

wire [19:0] immed1 = instruction[31:12]; // for LUI, AUIPC
wire [11:0] immed2 = instruction[31:20]; // for L{B,H,W,BU,HU}, ADDI, SLTI...
wire [11:0] immed3 = {instruction[31:25], instruction[11:7]}; // for stores

// For JAL, the bits in the immediate part of the word are permuted
// The immediate represents a multiple of 2 bytes, but our program counter
// is a multiple of 4 bytes
wire [18:0] jal_immed = {immed1[19], immed1[7:0], immed1[8], immed1[18:10]};

// For conditional branches, bits in the immediate are permuted
// As with JAL, the immediate represents a multiple of 2 bytes
wire [10:0] b_immed = {instruction[31], instruction[7], instruction[30:25], instruction[11:9]};

wire [31:0] reg1; // value of source register 1
wire [31:0] reg2; // value of source register 2

// should we jump?
reg jump;
always @*
  case (opcode1)
    5'b11011: jump = 1; // JAL
    5'b11001: jump = 1; // JALR
    5'b11000: // conditional branch
      case (opcode2)
        `BEQ:    jump = (reg1 == reg2);
        `BNE:    jump = (reg1 != reg2);
        `BLT:    jump = ($signed(reg1) <  $signed(reg2));
        `BGE:    jump = ($signed(reg1) >= $signed(reg2));
        `BLTU:   jump = (reg1 <  reg2);
        `BGEU:   jump = (reg1 >= reg2);
        default: jump = 0;
      endcase
    default: jump = 0;
  endcase

function [29:0] drop_bottom_2_bits(input [31:0] val32);
  drop_bottom_2_bits = val32[31:2];
endfunction

// if we should jump, then where to?
reg [29:0] jump_dest;
always @*
  case (opcode1)
    5'b11011: // JAL
      jump_dest = program_counter + {{11{jal_immed[18]}}, jal_immed};
    5'b11001: // JALR
      jump_dest = drop_bottom_2_bits(reg1 + {{20{immed2[11]}}, immed2});
    5'b11000: // branches
      jump_dest = program_counter + {{19{b_immed[10]}}, b_immed};
    default:
      jump_dest = 0;
  endcase

// what should be written to memory, if anything?
always @*
  write_enable_2 = (opcode1 == 5'b01000); // store?
always @*
  case (opcode2)
    3'b000: // store byte
      // since we only read/write memory in 32-bit units, must mask out specific
      // range of bits and insert the bits we want to write in their place
      case (alu_result[1:0])
        2'b00: write_2 = {read_2[31:8], reg2[7:0]};
        2'b01: write_2 = {read_2[31:16], reg2[7:0], read_2[7:0]};
        2'b10: write_2 = {read_2[31:24], reg2[7:0], read_2[15:0]};
        2'b11: write_2 = {reg2[7:0], read_2[23:0]};
      endcase
    3'b001: // store halfword
      case (alu_result[1])
        1'b0: write_2 = {read_2[31:16], reg2[15:0]};
        1'b1: write_2 = {reg2[15:0], read_2[15:0]};
      endcase
    3'b010: // store word
      write_2 = reg2;
    default:
      write_2 = 0;
  endcase

// should we store results to destination register?
reg [4:0] write_reg;
always @*
  case (opcode1)
    5'b01101: write_reg = dest_reg; // LUI
    5'b00101: write_reg = dest_reg; // AUIPC
    5'b11011: write_reg = dest_reg; // JAL
    5'b11001: write_reg = dest_reg; // JALR
    5'b00000: write_reg = dest_reg; // LB, LH, LW, LBU, LHU
    5'b00100: write_reg = dest_reg; // arith/logical, with immediate operand
    5'b01100: write_reg = dest_reg; // arith/logical, with register operand
    default:  write_reg = 0;
  endcase

// if we will write to destination register, what value should we store there?
reg [31:0] write_reg_val;
always @*
  case (opcode1)
    5'b00000: // load
      case (opcode2)
        `LB:
          case (alu_result[1:0])
            2'b00: write_reg_val = {{24{read_2[7]}},  read_2[7:0]};
            2'b01: write_reg_val = {{24{read_2[15]}}, read_2[15:8]};
            2'b10: write_reg_val = {{24{read_2[23]}}, read_2[23:16]};
            2'b11: write_reg_val = {{24{read_2[31]}}, read_2[31:24]};
          endcase
        `LH:
          case (alu_result[1])
            1'b0: write_reg_val = {{16{read_2[15]}}, read_2[15:0]};
            1'b1: write_reg_val = {{16{read_2[31]}}, read_2[31:16]};
          endcase
        `LBU:
          case (alu_result[1:0])
            2'b00: write_reg_val = {24'b0, read_2[7:0]};
            2'b01: write_reg_val = {24'b0, read_2[15:8]};
            2'b10: write_reg_val = {24'b0, read_2[23:16]};
            2'b11: write_reg_val = {24'b0, read_2[31:24]};
          endcase
        `LHU:
          case (alu_result[1])
            1'b0: write_reg_val = {16'b0, read_2[15:0]};
            1'b1: write_reg_val = {16'b0, read_2[31:16]};
          endcase
        `LW:     write_reg_val = read_2; // load entire word
        default: write_reg_val = 0;
      endcase
    default: write_reg_val = alu_result;
  endcase

// where should ALU operands come from?
reg [31:0] operand1;
reg [31:0] operand2;
always @* begin
  operand1 = 0;
  operand2 = 0;
  case (opcode1)
    5'b01101: // LUI
      operand1 = {immed1, 12'b0};
    5'b00101: begin // AUIPC
      operand1 = {immed1, 12'b0};
      operand2 = {program_counter, 2'b00};
    end
    5'b11011: begin // JAL
      operand1 = 4;
      operand2 = {program_counter, 2'b00};
    end
    5'b11001: begin // JALR
      operand1 = 4;
      operand2 = {program_counter, 2'b00};
    end
    5'b00000: begin // loads
      operand1 = reg1;
      operand2 = {{20{immed2[11]}}, immed2};
    end
    5'b01000: begin // stores
      operand1 = reg1;
      operand2 = {{20{immed3[11]}}, immed3};
    end
    5'b00100: begin // arithmetic with immediate
      operand1 = reg1;
      operand2 = {{20{immed2[11]}}, immed2};
    end
    5'b01100: begin // arithmetic with register
      operand1 = reg1;
      operand2 = reg2;
    end
  endcase
end

register_file regfile(
  .clk(clk),
  .read_select_1(src_reg_1),
  .read_1(reg1),
  .read_select_2(src_reg_2),
  .read_2(reg2),
  .write_select(write_reg),
  .write(write_reg_val));

program_counter prog_cnt(
  .clk(clk),
  .jump_dest(jump_dest),
  .jump(jump),
  .pc(program_counter));

alu alu(
  .opcode1(opcode1),
  .opcode2(opcode2),
  .opcode3(opcode3),
  .operand1(operand1),
  .operand2(operand2),
  .result(alu_result));

endmodule
