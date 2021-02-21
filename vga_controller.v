module vga_controller
(
	input vga_clk, // 25.1MHz clock for 640x480 resolution at 60fps
	output reg hsync, vsync, pixel, // to screen

	// to CPU
	// software needs to know when the screen is in its 'blanking interval',
	// when it is safe to modify video RAM without glitches, etc
	output reg blanking,

	// to video memory
	// 12-bit address space to store 80 colums x 30 rows of 1-byte characters
	output [11:0] addr, // address to read from video memory
	input [7:0] char, // character to show at current position

	// to font ROM
	// give it character/pixel you need, it returns white/black pixel value
	output [3:0] font_row, // each char is 16 pixels high
	output [2:0] font_col, // each char is 8 pixels wide
	output [6:0] font_char, // which character we want to retrieve
	input font_pixel // 1 = white, 0 = black
);

reg [9:0] hcount = 0; // X-position of current pixel, 0-799
reg [9:0] vcount = 0; // Y-position of current pixel, 0-524
reg [9:0] next_hcount, next_vcount; // intermediate values

// Each pixel is one clock tick, each line is 800 pixels, each screen is 525 lines

// Timing:
// =======
// 480 visible lines
// 10 empty lines
// 2 lines for vertical sync (vsync low)
// 33 empty lines

// And within each line:
// ---------------------
// 640 visible pixels
// 16 empty pixels
// 96 ticks for horizontal sync (hsync low)
// 48 empty pixels

always @* begin
	next_vcount = vcount;
	next_hcount = hcount + 1;
	if (next_hcount == 800) begin
		next_hcount = 0;
		next_vcount = vcount + 1;
		if (next_vcount == 525)
			next_vcount = 0;
	end
end

always @ (posedge vga_clk) begin
	// Updates to the outputs (`pixel`, `hsync`, etc.) are always one clock behind
	// updates to the internal counters
	// This is because it takes one cycle to read a value out of video RAM
	pixel    <= (hcount < 640) & (vcount < 480) & font_pixel;
	hsync    <= (hcount < 656) | (hcount >= 752);
	vsync    <= (vcount < 490) | (vcount >= 492);
	blanking <= (vcount >= 480);

	vcount   <= next_vcount;
	hcount   <= next_hcount;
end

// Intermediate for calculating byte to retrieve from video RAM
// Since each row of characters is 80 wide, and characters are stored in row-major order,
// the byte we want to read from video memory is H + (V * 80)
// ...and since each character is 8 pixels wide and 16 pixels high, we get the character
// indices by chopping off the low 3 bits of hcount and the low 4 bits of vcount
// (V * 80) == (V << 4) + (V << 6)
wire [7:0] hi_addr_bits = next_hcount[9:7] + next_vcount[9:4] + (next_vcount[9:4] << 2);
assign addr = {hi_addr_bits, next_hcount[6:3]};

assign font_row = vcount[3:0];
assign font_col = hcount[2:0];
// The font ROM only has glyphs for bytes 0-127; if the byte we find in video RAM
// is > 127, then just show a blank
assign font_char = char[7] ? 0 : char[6:0];

endmodule
