module bit_combiner(
	input [23:0] PPE_IN, 			// Pixel Processing Engine
	input [23:0] OBR_IN,				// Overlay Bit Repeater
	//input clk,							// clock in from higher entity
	input overlay_enable,			// set this enable when you want this exact pixel produce an overlay
	
	output [23:0] pixel_data_out	// output pixel colour value
);

assign pixel_data_out = (overlay_enable == 1'b1) ? OBR_IN : PPE_IN; //conditinal assignment

endmodule