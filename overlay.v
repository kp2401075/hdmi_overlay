module overlay(
      ///////// FPGA /////////
      input              FPGA_CLK1_50,
      input              FPGA_CLK2_50,
      input              FPGA_CLK3_50,

      ///////// HDMI /////////
      inout              HDMI_I2C_SCL,
      inout              HDMI_I2C_SDA,
      inout              HDMI_I2S,
      inout              HDMI_LRCLK,
      inout              HDMI_MCLK,
      inout              HDMI_SCLK,
      output             HDMI_TX_CLK,
      output      [23:0] HDMI_TX_D,
      output             HDMI_TX_DE,
      output             HDMI_TX_HS,
      input              HDMI_TX_INT,
      output             HDMI_TX_VS,

      ///////// KEY /////////
      input       [1:0]  KEY,

      ///////// LED /////////
      output      [7:0]  LED,

      ///////// SW /////////
      input       [3:0]  SW
);

//=======================================================
//  REG/WIRE declarations
//=======================================================
wire				reset_n;
wire				pll_1200k;
reg	[12:0]	counter_1200k;
reg				en_150;
wire				vpg_mode_change;
wire	[3:0]		vpg_mode;
wire 			   AUD_CTRL_CLK;

//Video Pattern Generator
wire	[3:0]		vpg_disp_mode;
wire				vpg_pclk;
wire				vpg_de, vpg_hs, vpg_vs;
wire	[23:0]	vpg_data;

wire 	[7:0] 	pixel_red ;
wire 	[7:0]  	pixel_green;
wire 	[7:0]  	pixel_blue;	

reg 	[7:0] 	ppe_red ;
reg 	[7:0]  	ppe_green;
reg 	[7:0]  	ppe_blue;	

//=======================================================
//  Structural coding
//=======================================================
assign LED[3:0] = vpg_mode;
//assign reset_n = 1'b1;
assign LED[7] = counter_1200k[12];

//system clock
sys_pll sys_pll_1 (
	.refclk(FPGA_CLK1_50),
	.rst(!KEY[0]),
	.outclk_0(pll_1200k),		// 1.2M Hz
	.outclk_1(AUD_CTRL_CLK),	// 1.536M Hz
	.locked(reset_n) );



assign vpg_mode_change = 1'b0;
assign vpg_mode = `FHD_1920x1080p60;




//pixel Engine
pixel_proc pixel_proc_1(
	.clk_50(FPGA_CLK2_50),
	.reset_n(reset_n),
	.mode(vpg_mode),
	//.mode_change(vpg_mode_change),
	.vpg_pclk(HDMI_TX_CLK),
	.vpg_de(HDMI_TX_DE),
	.vpg_hs(HDMI_TX_HS),
	.vpg_vs(HDMI_TX_VS),
	// .vpg_r(HDMI_TX_D[23:16]),
	// .vpg_g(HDMI_TX_D[15:8]),
	// .vpg_b(HDMI_TX_D[7:0]),
	.pixel_red(pixel_red),
	.pixel_green(pixel_green),
	.pixel_blue(pixel_blue)	);

//HDMI I2C
i2c_hdmi_setup I2c_master (
	.iCLK(FPGA_CLK1_50),
	.iRST_N(reset_n),
	.I2C_SCLK(HDMI_I2C_SCL),
	.I2C_SDAT(HDMI_I2C_SDA),
	.HDMI_TX_INT(HDMI_TX_INT)
	 );



always@(posedge pll_1200k or negedge reset_n)
begin
	if (!reset_n)
	begin
		counter_1200k <= 13'b0;
		en_150 <= 1'b0;				//frequency divider
	end
	else
	begin
		counter_1200k <= counter_1200k + 13'b1;
		en_150 <= &counter_1200k;
	end
end



///////////////////////font engine /////////////////////////
wire rom_clk;
reg rom_rden;
wire rom_dataIn;
reg overlay_enable;
reg [10:0] rom_address=0;
wire[10:0] rom_address_offset;
reg [10:0] reg_rom_address_offset=0;

//assign reg_rom_address_offset =(overlay_enable == 1'b1 )?rom_address_offset:0;


reg [4:0] font_horiz = 0;
reg [5:0] font_vert = 0;

parameter x_pos = 300;

reg [10:0] font_counter= 0;
always @(*)
begin
		
	if(x_counter == x_pos )
	begin
		overlay_enable <=1'b1;
		
		
	end
	else if(x_counter > x_pos && x_counter < (x_pos+20) && font_counter < 512)
	begin
		font_counter = font_counter + 1;
		rom_address <= rom_address +1;
		
	
	end
	else if(font_counter == 512)
	begin
		font_counter <=0;
		rom_address <= rom_address_offset;
	end
	else if(x_counter == (x_pos + 20))
	begin
	overlay_enable <=1'b0;
	rom_address <= rom_address_offset;
	end
	


end
assign rom_clk = (overlay_enable == 1'b1)?HDMI_TX_CLK:1'b0;



///instantiating rom
font_rom rom1(
		.address(rom_address),
		.clock(rom_clk),
		
		.q(rom_dataIn)




);
//instance of switch decoder
switch_decoder sw_dec_1
(			.switch_bus(SW),				// "real world"slide switch inputs
			.clk_50MHz(HDMI_TX_CLK),						// clock input		
			
			.offset(rom_address_offset)			// output register
);

// bit repitor
wire      [23:0] obr_out;
overlayBitRepiter obr(

  //try making conditional clock signal
  .dataIn(rom_dataIn), //should be connected to rom

  .dataOut(obr_out) //should be connected to 




);

// bit combiner connect
bit_combiner bitcon(
	.PPE_IN({ppe_red,ppe_green,ppe_blue}), 			// Pixel Processing Engine
	.OBR_IN(obr_out),				// Overlay Bit Repeater
	//input clk,							// clock in from higher entity
	.overlay_enable(overlay_enable),			// set this enable when you want this exact pixel produce an overlay
	
	.pixel_data_out(HDMI_TX_D)	// output pixel colour value
);



reg [11:0] x_counter = 0;
reg [11:0] y_counter = 0;

//increseing x and y counter and controlling pattern

always @(negedge HDMI_TX_HS)
begin
	if(y_counter == 1124)
	begin
		y_counter <= 0;
		
	end
	else
	begin
		y_counter <= y_counter + 1'b1;
	end
end



//// x_counter block



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

///////////////////Patten Generator ///////////////////////

//coutter and genarating custom patter

reg [11:0] counter_pat= 0;

always @(negedge HDMI_TX_VS)
begin
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
				counter_pat <=counter_pat +1;
				
				ppe_red <= 10;
				ppe_green<= 10;
				ppe_blue <= 10;
			end
	
	





end

endmodule
