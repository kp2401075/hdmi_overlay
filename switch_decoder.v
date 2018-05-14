//This module takes the four slide switch inputs and decodes them 
//into hexadecimal. Then using a case statement produces an output 
//offset for use in the font engine.

module switch_decoder
(			input [3:0] switch_bus,				// "real world"slide switch inputs
			input clk_50MHz,						// clock input		
			
			output reg [9:0] offset				// output register
);

always @ (posedge clk_50MHz)
			begin
				case(switch_bus)
						  0:begin offset <= 10'h000; end
						  1:begin offset <= 10'h0FF; end
						  2:begin offset <= 10'h080; end
						  3:begin offset <= 10'h0c0; end
						  4:begin offset <= 10'h100; end
						  5:begin offset <= 10'h140; end
						  6:begin offset <= 10'h180; end
						  7:begin offset <= 10'h1c0; end
						  8:begin offset <= 10'h200; end
						  9:begin offset <= 10'h240; end
						 10:begin offset <= 10'h280; end	//A
						 11:begin offset <= 10'h2c0; end	//B
						 12:begin offset <= 10'h300; end	//C
						 13:begin offset <= 10'h340; end	//D
						 14:begin offset <= 10'h380; end	//E
						 15:begin offset <= 10'h3c0; end	//F
				  default:begin offset <= 10'h000; end	//0
				endcase
			end	
endmodule
