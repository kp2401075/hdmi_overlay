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


reg [7:0] pixel_red = 100;
reg [7:0]  pixel_green= 100;
reg [7:0]  pixel_blue=100;	


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
	.vpg_r(HDMI_TX_D[23:16]),
	.vpg_g(HDMI_TX_D[15:8]),
	.vpg_b(HDMI_TX_D[7:0]),
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

//coutter and genarating custom patter

reg [11:0] counter_pat= 0;

always @(posedge HDMI_TX_CLK)
begin
	
	if(!HDMI_TX_HS)
	begin
	counter_pat <=0;
	
	end
	else
	begin
		counter_pat <=counter_pat+1'b1;
		if(counter_pat < 100)
			begin
				pixel_red <=0;
				pixel_green<= 255;
				pixel_blue <= 0;
				
			end
		else if(counter_pat >100 && counter_pat  < 300)
			begin
				pixel_red <= 255;
				pixel_green<= 0;
				pixel_blue <= 50;
				
			end
		else if(counter_pat >300 && counter_pat  < 500)
			begin
				pixel_red <= 0;
				pixel_green<= 0;
				pixel_blue <= 255;
				
			end
		else
			begin
				pixel_red <= 255;
				pixel_green<= 255;
				pixel_blue <= 255;
			end
	end
	

end

endmodule
