module overlayBitRepiter(

 //try making conditional clock signal
  input dataIn, //should be connected to rom


  output reg[23:0] dataOut //should be connected to 
);

always @ (*) //this might fix the latency issue
	begin
		if(dataIn == 1'b1)
			begin
				dataOut <= 24'b111111111111111111111111;
			end
			
		else if(dataIn == 1'b0)
			begin
				dataOut <= 0;//{2'b00,ppeIN[23:18],2'b00,ppeIN[15:10],2'b00,ppeIN[7:2]}; //trying for the transparencey
			end
	end
endmodule
