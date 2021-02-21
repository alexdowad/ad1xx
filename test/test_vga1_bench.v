module test_vga1_bench;

reg vga_clk = 0;
always
  #20 vga_clk = ~vga_clk; // this should actually be 19.86ns for 25.175MHz clock

reg cpu_clk = 0;
always
  #50 cpu_clk = ~cpu_clk; // 10MHz

wire [6:0] rom_char;
wire [3:0] rom_row;
wire [2:0] rom_col;
wire rom_output;

wire [11:0] ram_addr;
wire [7:0] ram_output;

reg [9:0] ram_write_addr;
reg [31:0] ram_write_val;
reg ram_we_1, ram_we_2, ram_we_3, ram_we_4;

wire hsync, vsync, pixel, blanking;

font_rom fontrom(
  .char(rom_char),
  .row(rom_row),
  .col(rom_col),
  .pixel(rom_output));
video_memory vidmem(
  .read_clk(vga_clk),
  .write_clk(cpu_clk),
  .addr_read(ram_addr),
  .data_read(ram_output),
  .addr_write(ram_write_addr),
  .data_write(ram_write_val),
  .write_enable_1(ram_we_1),
  .write_enable_2(ram_we_2),
  .write_enable_3(ram_we_3),
  .write_enable_4(ram_we_4));
vga_controller cntrl(
  .vga_clk(vga_clk),
  .hsync(hsync),
  .vsync(vsync),
  .pixel(pixel),
  .blanking(blanking),
  .addr(ram_addr),
  .char(ram_output),
  .font_row(rom_row),
  .font_col(rom_col),
  .font_char(rom_char),
  .font_pixel(rom_output));

task write_video_mem(input [9:0] addr, input [31:0] value);
  begin
    ram_write_addr = addr;
    ram_write_val = value;
    ram_we_1 = 1;
    ram_we_2 = 1;
    ram_we_3 = 1;
    ram_we_4 = 1;
    #100
    ram_we_1 = 0;
    ram_we_2 = 0;
    ram_we_3 = 0;
    ram_we_4 = 0;
  end
endtask

integer i, j;
reg [7:0] byte;
wire [7:0] byte1 = byte + 1;
wire [7:0] byte2 = byte + 2;
wire [7:0] byte3 = byte + 3;

initial begin
  // Fill video RAM with data
  // Each line will display the same sequence of ASCII characters
  for (i = 0; i < 30; i++) begin // line #
    for (j = 0; j < 20; j++) begin
      byte = (j * 4) + 33;
      write_video_mem((i*20)+j, {byte3, byte2, byte1, byte});
    end
  end

  // Bump simulation forward until we find the rising edge of vsync
  @ (posedge vsync);

  // Start recording what happens
  for (i = 0; i < 800 * 525; i++)
    #40 $display("%d,%d,%d", hsync, vsync, pixel);

  $finish();
end

endmodule
