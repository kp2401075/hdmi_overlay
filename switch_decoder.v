//This module takes the four slide switch inputs and decodes them 
//into hexadecimal. Then using a case statement produces an output 
//offset for use in the font engine.

module switch_decoder
(			input [3:0] switch_bus,				// "real world"slide switch inputs
			input clk_50MHz,						// clock input		
			
			output [10:0] offset				// output register
);

reg [10:0] reg_offset;
always @ (posedge clk_50MHz)
			begin
				case(switch_bus)
						  0:begin reg_offset <= 11'h000; end
						  1:begin reg_offset <= 11'h200; end
						  2:begin reg_offset <= 11'h400; end
						  3:begin reg_offset <= 11'h0c0; end
						  4:begin reg_offset <= 11'h100; end
						  5:begin reg_offset <= 11'h140; end
						  6:begin reg_offset <= 11'h180; end
						  7:begin reg_offset <= 11'h1c0; end
						  8:begin reg_offset <= 11'h200; end
						  9:begin reg_offset <= 11'h240; end
						 10:begin reg_offset <= 11'h280; end	//A
						 11:begin reg_offset <= 11'h2c0; end	//B
						 12:begin reg_offset <= 11'h300; end	//C
						 13:begin reg_offset <= 11'h340; end	//D
						 14:begin reg_offset <= 11'h380; end	//E
						 15:begin reg_offset <= 11'h3c0; end	//F
				  default:begin reg_offset <= 11'h000; end	//0
				endcase
			end
			assign offset = reg_offset;
endmodule