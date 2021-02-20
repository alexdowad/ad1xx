module ad100();

reg clk = 0;
always
  #50 clk = ~clk; // 10MHz

reg  [7:0] ram [32767:0]; // 32kB
wire [29:0] addr_1, addr_2;
reg  [31:0] read_1, read_2;
wire [31:0] write_2;
// Which of the 4 bytes in `write_2` should be written into RAM?
wire        write_enable_1, write_enable_2, write_enable_3, write_enable_4;
wire [31:0] rom_1;

wire [14:0] lobits_1 = {addr_1[14:0], 2'b00};
wire [14:0] lobits_2 = {addr_2[14:0], 2'b00};

// RAM is mapped into a contiguous address range starting from 0x7000000
always @*
  if (addr_1[29:15] == 15'b011100000000000) // 0x70000000-0x70007FFF
    read_1 = {ram[lobits_1+3], ram[lobits_1+2], ram[lobits_1+1], ram[lobits_1]};
  else if (addr_1[29:10] == 20'hFF000)
    read_1 = rom_1;
  else
    read_1 = 0;

// Note that boot firmware in ROM can't be read out from memory port 2!
// This means that it's "invisible" to load instructions
// No particular reason for this, except to simplify the following code
always @*
  if (addr_2[29:15] == 15'b011100000000000)
    read_2 = {ram[lobits_2+3], ram[lobits_2+2], ram[lobits_2+1], ram[lobits_2]};
  else
    read_2 = 0;

always @(posedge clk)
  if (addr_2[29:15] == 15'b011100000000000) begin // 0x70000000-0x70007FFF
    if (write_enable_1)
      ram[lobits_2] <= write_2[7:0];
    if (write_enable_2)
      ram[lobits_2+1] <= write_2[15:8];
    if (write_enable_3)
      ram[lobits_2+2] <= write_2[23:16];
    if (write_enable_4)
      ram[lobits_2+3] <= write_2[31:24];
  end

ad100_cpu cpu(
  .clk(clk),
  .addr_1(addr_1),
  .read_1(read_1),
  .addr_2(addr_2),
  .read_2(read_2),
  .write_2(write_2),
  .write_enable_1(write_enable_1),
  .write_enable_2(write_enable_2),
  .write_enable_3(write_enable_3),
  .write_enable_4(write_enable_4));

ad100_rom rom(
  .addr(addr_1[9:0]),
  .read(rom_1));

endmodule
