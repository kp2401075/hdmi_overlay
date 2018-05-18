//HDMI Overlay Project
// Jay Patel s3488667
// SOmewhat inspired by demo from systemcd
module overlay(
      
      input              FPGA_CLK1_50,
      inout              HDMI_I2C_SCL,
      inout              HDMI_I2C_SDA,
      output             HDMI_TX_CLK,
      output      [23:0] HDMI_TX_D,
      output             HDMI_TX_DE,
      output             HDMI_TX_HS,
      input              HDMI_TX_INT,
      output             HDMI_TX_VS,
      input       [1:0]  KEY,
      input       [3:0]  SW
);


wire					reset_n;
wire					clk_12k;
reg	[12:0]		counter_1200k;
reg					en_150;
wire					hdmi_mode_change;
wire	[3:0]			hdmi_mode;


assign reset_n = KEY[0];

wire 	[7:0] 		ppe_red ;
wire 	[7:0]  		ppe_green;
wire	[7:0]  		ppe_blue;	






assign hdmi_mode_change = 1'b0;
assign hdmi_mode = `FHD_1920x1080p60;


//pixel Engine fpr genrating control signals
pixel_proc pixel_proc_1(
	.clk_50(FPGA_CLK1_50),
	.reset_n(reset_n),
	.mode(hdmi_mode),
	.hdmi_pclk(HDMI_TX_CLK),
	.hdmi_de(HDMI_TX_DE),
	.hdmi_hs(HDMI_TX_HS),
	.hdmi_vs(HDMI_TX_VS)
	);

//HDMI I2C for setting up i2c
i2c_hdmi_setup I2c_master (
	.iCLK(FPGA_CLK1_50),
	.iRST_N(reset_n),
	.I2C_SCLK(HDMI_I2C_SCL),
	.I2C_SDAT(HDMI_I2C_SDA),
	.HDMI_TX_INT(HDMI_TX_INT)
	 );


	 
	 
hdmi_pattern_gen pat_gen(
	 .HDMI_TX_VS(HDMI_TX_VS),
	.ppe_red(ppe_red),
	.ppe_green(ppe_green),
	.ppe_blue(ppe_blue)	

);


///////////////////////font engine /////////////////////////


wire rom_dataIn;

wire[12:0] rom_address;
wire[12:0] rom_address_offset;

wire slow_clock;


rom_controll rom_controll_1(
	.HDMI_TX_CLK(HDMI_TX_CLK),
	.HDMI_TX_VS(HDMI_TX_VS),
	.rom_address_offset(rom_address_offset),
	.overlay_enable(overlay_enable),
	.rom_address(rom_address)
	
);


wire overlay_enable;


overlay_enable_controll overlay_enable_controll_1(
	.x_counter(x_counter),
	.y_counter(y_counter),
	.slow_clock(slow_clock),
	.KEY_1(KEY[1]),
	.overlay_enable(overlay_enable)

);


///instantiating rom 
font_rom rom1(
		.address(rom_address),
		.clock(HDMI_TX_CLK), //changed from rom clk to hdmi clk
		.q(rom_dataIn)
);


//instance of switch decoder
switch_decoder sw_dec_1
(			.switch_bus(SW),				// "real world"slide switch inputs
			.offset(rom_address_offset)			// output register
);


// bit repitor
wire      [23:0] obr_out;
overlayBitRepiter obr(
  .ppeIN({ppe_red,ppe_green,ppe_blue}),
  .dataIn(rom_dataIn), //should be connected to rom
  .dataOut(obr_out) //should be connected to 
);


// bit combiner connect 
bit_combiner bitcon(
	.PPE_IN({ppe_red,ppe_green,ppe_blue}), 			// Pixel Processing Engine
	.OBR_IN(obr_out),				// Overlay Bit Repeater
	.overlay_enable(overlay_enable),			// set this enable when you want this exact pixel produce an overlay
	.pixel_data_out(HDMI_TX_D)	// output pixel colour value
);

//instance of slow clock
// slow clock for detecting key input
slow_clock cl1(
			.clock(FPGA_CLK1_50),
			.hzSig(slow_clock)
			);


wire [11:0] x_counter;
wire [11:0] y_counter;

// pixel counter counts x and y position 
pixel_counter pix_count(
	.HDMI_TX_HS(HDMI_TX_HS),
	.HDMI_TX_VS(HDMI_TX_VS),
	.HDMI_TX_CLK(HDMI_TX_CLK),
	.x_counter(x_counter),
	.y_counter(y_counter)
);

endmodule