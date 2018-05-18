module slow_clock(



	input clock,
	output reg hzSig
	);
initial
	begin
	
	hzSig <= 1'b0;
	
	
	end
	
reg [26:0] count = 0;

always @(posedge(clock))
	begin
		if(count < 2500000) // 25000000
			begin
				count = count + 1;
			end
		else if( count == 2500000)
			begin
				hzSig = ~hzSig;
				count = 0;
				 //non blocking code there for will introduce slight delay
				
			end
		end
		
	
	
endmodule
	