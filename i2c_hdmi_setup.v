module i2c_hdmi_setup(	
					iCLK,
					iRST_N,
					//	I2C Side
					I2C_SCLK,
					I2C_SDAT,
					HDMI_TX_INT,
					READY
					 );

input				iCLK;
input				iRST_N;

output			I2C_SCLK;
inout				I2C_SDAT;
input				HDMI_TX_INT;
output READY ; 


reg	[15:0]	mI2C_CLK_DIV;
reg	[23:0]	mI2C_DATA;
reg				mI2C_CTRL_CLK;
reg				mI2C_GO;
wire				mI2C_END;
wire				mI2C_ACK;
reg	[15:0]	LT_DATA;
reg	[5:0]		LT_INDEX;
reg	[3:0]		mSetup_ST;
reg READY ; 


parameter	CLK_Freq	=	50000000;	//	50	MHz
parameter	I2C_Freq	=	20000;		//	20	KHz

parameter	LT_SIZE	=	31;

always@(posedge iCLK or negedge iRST_N)
begin
	if(!iRST_N)
	begin
		mI2C_CTRL_CLK	<=	0;
		mI2C_CLK_DIV	<=	0;
	end
	else
	begin
		if( mI2C_CLK_DIV	< (CLK_Freq/I2C_Freq) )
			mI2C_CLK_DIV	<=	mI2C_CLK_DIV+1;
		else
		begin
			mI2C_CLK_DIV	<=	0;
			mI2C_CTRL_CLK	<=	~mI2C_CTRL_CLK;
		end
	end
end


i2c_controller control(	.CLOCK(mI2C_CTRL_CLK),	//	Controller Work Clock
						.I2C_SCLK(I2C_SCLK),				//	I2C CLOCK
 	 	 	 	 	 	.I2C_SDAT(I2C_SDAT),				//	I2C DATA
						.I2C_DATA(mI2C_DATA),			//	DATA:[SLAVE_ADDR,SUB_ADDR,DATA]
						.GO(mI2C_GO),						//	GO transfor
						.END(mI2C_END),					//	END transfor 
						.ACK(mI2C_ACK),					//	ACK
						.RESET(iRST_N)	);

						
always@(posedge mI2C_CTRL_CLK or negedge iRST_N)
begin
	if(!iRST_N)
	begin
	READY<=0;
		LT_INDEX	<=	0;
		mSetup_ST	<=	0;
		mI2C_GO		<=	0;
	end
	else
	begin
		if(LT_INDEX<LT_SIZE)
		begin
		READY<=0;
			case(mSetup_ST)
			0:	begin
					mI2C_DATA	<=	{8'h72,LT_DATA};
					mI2C_GO		<=	1;
					mSetup_ST	<=	1;
				end
			1:	begin
					if(mI2C_END)
					begin
						if(!mI2C_ACK)
						mSetup_ST	<=	2;
						else
						mSetup_ST	<=	0;							
						mI2C_GO		<=	0;
					end
				end
			2:	begin
					LT_INDEX	<=	LT_INDEX+1;
					mSetup_ST	<=	0;
				end
			endcase
		end
		else
		begin
		  READY<=1; 
		  if(!HDMI_TX_INT)
		  begin
		    LT_INDEX <= 0;
		  end
		  else
		    LT_INDEX <= LT_INDEX;
		end
	end
end



always
begin
	case(LT_INDEX)
	
	//	Video Config Data
	0	:	LT_DATA	<=	16'h9803;  //Must be set to 0x03 for proper operation
	1	:	LT_DATA	<=	16'h0100;  //Set 'N' value at 6144
	2	:	LT_DATA	<=	16'h0218;  //Set 'N' value at 6144
	3	:	LT_DATA	<=	16'h0300;  //Set 'N' value at 6144
	4	:	LT_DATA	<=	16'h1470;  // Set Ch count in the channel status to 8.
	5	:	LT_DATA	<=	16'h1520;  //Input 444 (RGB or YCrCb) with Separate Syncs, 48kHz fs
	6	:	LT_DATA	<=	16'h1630;  //Output format 444, 24-bit input
	7	:	LT_DATA	<=	16'h1846;  //Disable CSC
	8	:	LT_DATA	<=	16'h4080;  //General control packet enable
	9	:	LT_DATA	<=	16'h4110;  //Power down control
	10	:	LT_DATA	<=	16'h49A8;  //Set dither mode - 12-to-10 bit
	11	:	LT_DATA	<=	16'h5510;  //Set RGB in AVI infoframe
	12	:	LT_DATA	<=	16'h5608;  //Set active format aspect
	13	:	LT_DATA	<=	16'h96F6;  //Set interrup
	14	:	LT_DATA	<=	16'h7307;  //Info frame Ch count to 8
	15	:	LT_DATA	<=	16'h761f;  //Set speaker allocation for 8 channels
	16	:	LT_DATA	<=	16'h9803;  //Must be set to 0x03 for proper operation
	17	:	LT_DATA	<=	16'h9902;  //Must be set to Default Value
	18	:	LT_DATA	<=	16'h9ae0;  //Must be set to 0b1110000
	19	:	LT_DATA	<=	16'h9c30;  //PLL filter R1 value
	20	:	LT_DATA	<=	16'h9d61;  //Set clock divide
	21	:	LT_DATA	<=	16'ha2a4;  //Must be set to 0xA4 for proper operation
	22	:	LT_DATA	<=	16'ha3a4;  //Must be set to 0xA4 for proper operation
	23	:	LT_DATA	<=	16'ha504;  //Must be set to Default Value
	24	:	LT_DATA	<=	16'hab40;  //Must be set to Default Value
	25	:	LT_DATA	<=	16'haf16;  //Select HDMI mode
	26	:	LT_DATA	<=	16'hba60;  //No clock delay
	27	:	LT_DATA	<=	16'hd1ff;  //Must be set to Default Value
	28	:	LT_DATA	<=	16'hde10;  //Must be set to Default for proper operation
	29	:	LT_DATA	<=	16'he460;  //Must be set to Default Value
	30	:	LT_DATA	<=	16'hfa7d;  //Nbr of times to look for good phase

	default:		LT_DATA	<=	16'h9803;
	endcase
end


endmodule