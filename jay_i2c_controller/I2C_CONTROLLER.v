module I2C_CONTROLLER(

	input clk,
	inout I2C_SDA,
	inout I2C_SCL,
	input reset



);


reg	[23:0]	I2C_DATA;
//initial
//begin
//	I2C_SDA=1'b1;
//	I2C_SCL=1'b1;
//	
//end

reg [9:0] count=0;
wire slow_i2c_clk;


// make counter loop to slow the clock down for i2c
always @(posedge(clk))
begin
	count <= count + 1;
	
end

assign slow_i2c_clk = count[9];
wire i2c_done;
reg [5:0] LT_INDEX=0;

reg ready = 0;

i2c_sub sub1(

	.i2c_sclk(I2C_SCL), //serial clock signal
	.i2c_sdat(I2C_SDA), // serial data signal
	.reset(reset),
	.clk(slow_i2c_clk),
	.done(i2c_done),
	.i2c_data(I2C_DATA)

);

always @(posedge i2c_done)
begin
	if(LT_INDEX == 30)
	begin
		ready = 1'b1;
	end
	else if(LT_INDEX <30)
	begin
		LT_INDEX <= LT_INDEX + 1;
	end
	

end


always
begin
	case(LT_INDEX)
	
	//	Video Config Data
	0	:	I2C_DATA	<=	24'h729803;  //Must be set to 0x03 for proper operation
	1	:	I2C_DATA	<=	24'h720100;  //Set 'N' value at 6144
	2	:	I2C_DATA	<=	24'h720218;  //Set 'N' value at 6144
	3	:	I2C_DATA	<=	24'h720300;  //Set 'N' value at 6144
	4	:	I2C_DATA	<=	24'h721470;  // Set Ch count in the channel status to 8.
	5	:	I2C_DATA	<=	24'h721520;  //Input 444 (RGB or YCrCb) with Separate Syncs, 48kHz fs
	6	:	I2C_DATA	<=	24'h721630;  //Output format 444, 24-bit input
	7	:	I2C_DATA	<=	24'h721846;  //Disable CSC
	8	:	I2C_DATA	<=	24'h724080;  //General control packet enable
	9	:	I2C_DATA	<=	24'h724110;  //Power down control
	10	:	I2C_DATA	<=	24'h7249A8;  //Set dither mode - 12-to-10 bit
	11	:	I2C_DATA	<=	24'h725510;  //Set RGB in AVI infoframe
	12	:	I2C_DATA	<=	24'h725608;  //Set active format aspect
	13	:	I2C_DATA	<=	24'h7296F6;  //Set interrup
	14	:	I2C_DATA	<=	24'h727307;  //Info frame Ch count to 8
	15	:	I2C_DATA	<=	24'h72761f;  //Set speaker allocation for 8 channels
	16	:	I2C_DATA	<=	24'h729803;  //Must be set to 0x03 for proper operation
	17	:	I2C_DATA	<=	24'h729902;  //Must be set to Default Value
	18	:	I2C_DATA	<=	24'h729ae0;  //Must be set to 0b1110000
	19	:	I2C_DATA	<=	24'h729c30;  //PLL filter R1 value
	20	:	I2C_DATA	<=	24'h729d61;  //Set clock divide
	21	:	I2C_DATA	<=	24'h72a2a4;  //Must be set to 0xA4 for proper operation
	22	:	I2C_DATA	<=	24'h72a3a4;  //Must be set to 0xA4 for proper operation
	23	:	I2C_DATA	<=	24'h72a504;  //Must be set to Default Value
	24	:	I2C_DATA	<=	24'h72ab40;  //Must be set to Default Value
	25	:	I2C_DATA	<=	24'h72af16;  //Select HDMI mode
	26	:	I2C_DATA	<=	24'h72ba60;  //No clock delay
	27	:	I2C_DATA	<=	24'h72d1ff;  //Must be set to Default Value
	28	:	I2C_DATA	<=	24'h72de10;  //Must be set to Default for proper operation
	29	:	I2C_DATA	<=	24'h72e460;  //Must be set to Default Value
	30	:	I2C_DATA	<=	24'h72fa7d;  //Nbr of times to look for good phase

	default:		I2C_DATA	<=	24'h729803;
	endcase
end




endmodule
