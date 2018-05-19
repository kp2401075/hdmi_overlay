module i2c_controller(
	input  CLOCK,
	input  [23:0]I2C_DATA,	
	input  GO,
	input  RESET,	
	input  W_R,
 	inout  I2C_SDAT,	
	output I2C_SCLK,
	output END,	
	output ACK
);

wire SDAO ; 

assign I2C_SDAT = SDAO?1'bz :0  ; 

i2c_writer  i2c_writer1(
   .RESET_N  ( RESET),
	.PT_CK    ( CLOCK),
	.GO       ( GO   ),
	.END_OK   ( END  ),
	.ACK_OK   ( ACK  ),
	.BYTE_NUM ( 2    ),  	
	.SDAI     ( I2C_SDAT ),
	.SDAO     ( SDAO     ),
	.SCLO     ( I2C_SCLK ),	
	.SLAVE_ADDRESS( I2C_DATA[23:16] ),
	.REG_DATA     ( I2C_DATA[15:0]  )	
);	
	
	

endmodule
