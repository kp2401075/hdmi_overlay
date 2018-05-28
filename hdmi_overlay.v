//hdmi_overlay 
// revision 23/05/2018
//Jay Patel
module hdmi_overlay(
     
      input              FPGA_CLK_50,


     
      inout              HDMI_I2C_SCL,
      inout              HDMI_I2C_SDA,
		
		
		
		

      output             HDMI_TX_CLK,
      output      [23:0] HDMI_TX_D,
      output             HDMI_TX_DE,
      output             HDMI_TX_HS,
      input              HDMI_TX_INT,
      output             HDMI_TX_VS,

      
      input       [1:0]  KEY,

     
      //output      [7:0]  LED,

    
      input       [3:0]  SW
);

reg 	[7:0] 		ppe_red ;
reg 	[7:0]  		ppe_green;
reg 	[7:0]  		ppe_blue;	



 //I2c Controller
I2C_CONTROLLER i2c_master(

	.clk(HDMI_CLK_50),
	.I2C_SDA(HDMI_I2C_SDA),
	.I2C_SCL(HDMI_I2C_SCL),
	.reset(KEY[0]) 
	
	// try with setting it to 1
	//.interupt(HDMI_INT)



);

// I2C_HDMI_Config I2C_HDMI_Config_1 (
	// .iCLK(FPGA_CLK_50),
	// .iRST_N(KEY[0]),
	// .I2C_SCLK(HDMI_I2C_SCL),
	// .I2C_SDAT(HDMI_I2C_SDA),
	// .HDMI_TX_INT(HDMI_TX_INT)
	 // );


//pll for display
pll_108 pll_1(
		.refclk( FPGA_CLK_50),   //  refclk.clk
		.rst(!KEY[0]),      //   reset.reset
		.outclk_0(HDMI_TX_CLK)  // outclk0.clk
);


//signal gen
signal_gen sig_gen_1(                                    
  .clk(HDMI_TX_CLK),                
 .reset_n(KEY[0]),                                                
  .hdmi_hs(HDMI_TX_HS),             
 .hdmi_vs(HDMI_TX_VS),           
  .hdmi_de(HDMI_TX_DE)

  
);



forn_rom rom1(
		.address(rom_address),
		.clock(HDMI_TX_CLK),
		.q(rom_dataIn)
);



//position change block

always @(posedge HDMI_TX_VS)
begin
	if(!KEY[1])
		begin
			x_pos <= x_pos + 10;
			y_pos <= y_pos + 18;
		end
	else
		begin
			x_pos <= x_pos;
			y_pos <= y_pos;
		end

end
//
//
//
//
//wire rom_dataIn;
reg overlay_enable;
reg [12:0] rom_address=0;
wire[12:0] rom_address_offset;
reg [12:0] reg_rom_address_offset=0;
reg [10:0] font_counter= 0;

//
//
//// for keeping track of current pixel and changing overlay position
reg [11:0] x_counter = 0;
reg [11:0] y_counter = 0;
reg [10:0] x_pos = 300;
reg [10:0] y_pos = 500;
//
//
//
////font counter and offset counter
always @(posedge HDMI_TX_CLK)
begin
	
	if(overlay_enable && font_counter< 512 )
	begin
	
		rom_address <= (rom_address_offset + font_counter); 
		font_counter <= font_counter +1'b1;
		
	end
	else if(font_counter == 512 || (!HDMI_TX_VS))
	begin
		font_counter <= 0;
		rom_address <= reg_rom_address_offset;
	
	end




end


always @(*)
begin
	reg_rom_address_offset <=rom_address_offset;
		
	if(x_counter >= x_pos  && x_counter < (x_pos + 16))
		begin
			if(y_counter >= y_pos && y_counter <(y_pos + 32))
			begin
				overlay_enable <=1'b1;
			end
		end
	else
		begin
			overlay_enable <=1'b0;
		end
		

end
//
//
//
//
//// bit repitor
wire      [23:0] obr_out;
overlayBitRepiter obr(
  
  .dataIn(rom_dataIn), //should be connected to rom
  .dataOut(obr_out) //should be connected to 
);
//
//
//
//
// bit combiner connect also try 
bit_combiner bitcon(
	.PPE_IN({ppe_red,ppe_green,ppe_blue}), 			// Pixel Processing Engine
	.OBR_IN(obr_out),				// Overlay Bit Repeater
	.overlay_enable(overlay_enable),			// set this enable when you want this exact pixel produce an overlay
	.pixel_data_out(HDMI_TX_D)	// output pixel colour value
);


//
//
//
//
//
//
////////////////Y counter block
//
always @(negedge HDMI_TX_HS)
begin
	if(!HDMI_TX_VS)
		begin
			y_counter <= 0;
		end
	else
		begin
			y_counter <= y_counter + 1'b1;
		end
end
//
//
//
//
//
//
/////////////// x_counter block
always @(posedge HDMI_TX_CLK)
begin
    if(!HDMI_TX_HS)
		begin
			x_counter <=0;
		end
    else 
		begin
			x_counter <=x_counter + 1'b1;
		end
end



//instance of switch decoder
switch_decoder sw_dec_1
(			.switch_bus(SW),				// "real world"slide switch inputs
			
			.offset(rom_address_offset)			// output register
);
//
//
//
//
//
//
//
/////////////////////Patten Generator ///////////////////////
//
////coutter and genarating custom patter
//
reg [11:0] counter_pat= 0;
//
always @(negedge HDMI_TX_VS)
begin
		
		counter_pat <=counter_pat +1;
		if(counter_pat == 255)
			begin
				counter_pat <= 0;
			end
		else if(counter_pat <255)
			begin
					
					ppe_red <= counter_pat;
					ppe_green<= counter_pat -1;
					ppe_blue <= counter_pat -1;
			end
		else 
			begin
				
				ppe_red <= 10;
				ppe_green<= 10;
				ppe_blue <= 10;
			end
end


endmodule
