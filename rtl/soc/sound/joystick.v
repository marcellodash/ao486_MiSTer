module joystick
(
	////////////////////////	clk Input	 	////////////////////////
	input rst_n,
	input clk,

	// GamePort Joystick 200-207h (supposed to be at 0x201, but Qsys won't directly allow the odd addresses). ElectronAsh.
	input [2:0] joy_address,
	input joy_read,
	output [7:0] joy_readdata,
	
	input joy_write,
	input [7:0] joy_writedata,
	
	input [15:0] joystick_0,
	input [15:0] joystick_1
);

	assign joy_readdata = {!JOY2_BUT2, !JOY2_BUT1, !JOY1_BUT2, !JOY1_BUT1, JOY2_Y>0, JOY2_X>0, JOY1_Y>0, JOY1_X>0};


reg [8:0] JOY1_X;
reg [8:0] JOY1_Y;

reg [8:0] JOY2_X;
reg [8:0] JOY2_Y;


// When using the 90.5 MHz clk, an 8-bit CLK_DIV and 9-bit X/Y value gives a reading of around 1400 microseconds using the JoyCheck DOS program (by Henrik K Jensen).
//
// The "standard" maximum X/Y timing value for old-skool PC joysticks is around 1124 microseconds, so have a good range now for ao486.
//
// 
// It should be possible to increase the resolution of the X/Y counters by also decreasing the width of CLK_DIV. eg...
//
//  9-bit X/Y counter. 8-bit CLK_DIV.
// 10-bit X/Y counter. 7-bit CLK_DIV.
// 11-bit X/Y counter. 6-bit CLK_DIV.
// 12-bit X/Y counter. 5-bit CLK_DIV.
//
//
// (For digital joysticks / joypads, the "resolution" obviously isn't too important, but the aim is to add support for analog joysticks later.)
// 
//
// Notes...
//
// 90.5 MHz = 11.05ns per clk tick.
//
// So, assuming an 8-bit clk divider...
//
// 24us   (standard minimum value) = 2172 clk ticks.
// 1124us (standard maximum value) = 101,719 clk ticks.
//
// With an 8-bit clk divider, the min X/Y counter value would then be around 8.
// And the max X/Y counter value would be around 397.
//
//
reg [7:0] CLK_DIV;

wire JOY1_RIGHT = joystick_0[0];
wire JOY1_LEFT  = joystick_0[1];
wire JOY1_DOWN  = joystick_0[2];
wire JOY1_UP 	 = joystick_0[3];
wire JOY1_BUT1  = joystick_0[4];
wire JOY1_BUT2  = joystick_0[5];
wire JOY1_BUT3  = joystick_0[6];
wire JOY1_BUT4  = joystick_0[7];

wire JOY2_RIGHT = joystick_1[0];
wire JOY2_LEFT  = joystick_1[1];
wire JOY2_DOWN  = joystick_1[2];
wire JOY2_UP 	 = joystick_1[3];
wire JOY2_BUT1  = joystick_1[4];
wire JOY2_BUT2  = joystick_1[5];
wire JOY2_BUT3  = joystick_1[6];
wire JOY2_BUT4  = joystick_1[7];


always @(posedge clk or negedge rst_n)
if (!rst_n) begin
	JOY1_X <= 9'd197;
	JOY1_Y <= 9'd197;
	JOY2_X <= 9'd197;
	JOY2_Y <= 9'd197;
end
else begin
	CLK_DIV <= CLK_DIV + 1'b1;

	if (joy_write && joy_address==3'd1) begin
		JOY1_X <= (JOY1_LEFT) ? 9'd8 : (JOY1_RIGHT) ? 9'd399 : 9'd197;
		JOY1_Y <= (JOY1_UP)   ? 9'd8 : (JOY1_DOWN)  ? 9'd399 : 9'd197;
		
		JOY2_X <= (JOY2_LEFT) ? 9'd8 : (JOY2_RIGHT) ? 9'd399 : 9'd197;
		JOY2_Y <= (JOY2_UP)   ? 9'd8 : (JOY2_DOWN)  ? 9'd399 : 9'd197;
		
		CLK_DIV <= 1;
	end
	
	if (CLK_DIV==0) begin
		if (JOY1_X>0) JOY1_X <= JOY1_X - 1'b1;
		if (JOY1_Y>0) JOY1_Y <= JOY1_Y - 1'b1;
		if (JOY2_X>0) JOY2_X <= JOY2_X - 1'b1;
		if (JOY2_Y>0) JOY2_Y <= JOY2_Y - 1'b1;
	end
end


endmodule