// opcodes for basic, 32-bit RISC-V arithmetic instructions (no extensions)
// (as well as other instructions which require the ALU to calculate
//  the target address of a memory store or load)

// if the 32-bit instruction is `i`, these are `i[6:2]`
`define LUI    5'b01101
`define AUIPC  5'b00101
`define JAL    5'b11011
`define JALR   5'b11001
`define BRANCH 5'b11000 // includes BEQ, BNE, BLT, BGE, BLTU, BGEU

// includes LB, LH, LW, LBU, LHU, SB, SH, SW; all get pointer by adding offset to register
// the 2nd bit determines if it is a load or a store
`define MEM    5'b0?000

// includes {ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND}{,I}
// if the 2nd bit is 1, the operands are both in registers
// if the 2nd bit is 0, one operand is immediate
`define ARITH  5'b0?100
`define IMMED  5'b00100

// if the 32-bit instruction is `i`, these are `i[14:12]`
`define ADD   3'b000 // includes ADD, SUB, ADDI
`define SLT   3'b010 // includes SLT, SLTI
`define SLTU  3'b011 // includes SLTU, SLTUI
`define XOR   3'b100 // includes XOR, XORI
`define OR    3'b110 // includes OR, ORI
`define AND   3'b111 // includes AND, ANDI
`define SL    3'b001 // includes SLLI, SLL
`define SR    3'b101 // includes SRL, SRLI, SRA, SRAI

// if the 32-bit instruction is `i`, these are `i[30]`
`define _ADD  1'b0 // ADD and SUB are differentiated by 1 bit
`define _SUB  1'b1

`define _LOGICAL    1'b0 // SRL and SRA are differentiated by 1 bit
`define _ARITHMETIC 1'b1

module alu
(
  input [4:0] opcode1, // instruction[6:2]
  input [2:0] opcode2, // instruction[14:12]
  input       opcode3, // instruction[30]

  input [31:0] operand1,
  input [31:0] operand2,
  output reg [31:0] result
);

always @*
  casez (opcode1)
    `LUI:    result = operand1;
    `AUIPC:  result = operand1 + operand2;
    `JAL:    result = operand1 + operand2;
    `JALR:   result = operand1 + operand2;
    `MEM:    result = operand1 + operand2;
    `BRANCH: result = operand1 + operand2;
    `ARITH:
      case (opcode2)
        `ADD:  result = (opcode3 == `_ADD || opcode1 == `IMMED) ? (operand1 + operand2) : (operand1 - operand2);
        `SLT:  result = ($signed(operand1) < $signed(operand2));
        `SLTU: result = (operand1 < operand2);
        `XOR:  result = (operand1 ^ operand2);
        `OR:   result = (operand1 | operand2);
        `AND:  result = (operand1 & operand2);
        `SL:   result = (operand1 << operand2);
        `SR:   if (opcode3 == `_LOGICAL)
                  result = operand1 >> operand2[4:0];
               else
                  result = $signed(operand1) >>> operand2[4:0];
      endcase
    default: result = 32'bx;
  endcase

endmodule
