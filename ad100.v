module ad100();

reg clk = 0;
always
  #50 clk = ~clk; // 10MHz

reg  [31:0] ram [8191:0]; // 32kB
wire [29:0] addr_1, addr_2;
reg  [31:0] read_1, read_2;
wire [31:0] write_2, rom_1;
wire        write_enable_2;

// RAM is mapped into a contiguous address range starting from 0x7000000
always @*
  if (addr_1[29:15] == 15'b011100000000000)
    read_1 = ram[addr_1[14:0]];
  else if (addr_1[29:10] == 20'hFF000)
    read_1 = rom_1;
  else
    read_1 = 0;

// Note that boot firmware in ROM can't be read out from memory port 2!
// This means that it's "invisible" to load instructions
// No particular reason for this, except to simplify the following code
always @*
  if (addr_2[29:15] == 15'b011100000000000)
    read_2 = ram[addr_2[14:0]];
  else
    read_2 = 0;

always @(posedge clk)
  if (write_enable_2 && addr_2[29:15] == 15'b011100000000000)
    ram[addr_2[14:0]] <= write_2;

ad100_cpu cpu(
  .clk(clk),
  .addr_1(addr_1),
  .read_1(read_1),
  .addr_2(addr_2),
  .read_2(read_2),
  .write_2(write_2),
  .write_enable_2(write_enable_2));

ad100_rom rom(
  .addr(addr_1[9:0]),
  .read(rom_1));

endmodule
