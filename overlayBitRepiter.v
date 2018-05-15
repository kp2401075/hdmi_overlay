module overlayBitRepiter(

 //try making conditional clock signal
  input dataIn, //should be connected to rom

  output reg[23:0] dataOut //should be connected to 
);

always @ ( dataIn) 
	begin
		if(dataIn == 1'b1)
			begin
				dataOut <= 24'b111111111111111111111111;
			end
			
		else if(dataIn == 1'b0)
			begin
				dataOut <= 0;
			end
	end
endmodule
