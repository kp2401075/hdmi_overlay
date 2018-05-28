//This module takes the four slide switch inputs and decodes them 
//into hexadecimal. Then using a case statement produces an output 
//offset for use in the font engine.
module switch_decoder
(			input [3:0] switch_bus,					// "real world"slide switch inputs
			//input clk_50MHz,						// clock input	not required	
			output [12:0] offset						// output register
);

reg [12:0] reg_offset;
assign offset = reg_offset;

always @ (*)
			begin
				case(switch_bus)
						  0:begin reg_offset <= 13'h000; end
						  1:begin reg_offset <= 13'h200; end
						  2:begin reg_offset <= 13'h400; end
						  3:begin reg_offset <= 13'h600; end
						  4:begin reg_offset <= 13'h800; end
						  5:begin reg_offset <= 13'ha00; end
						  6:begin reg_offset <= 13'hc00; end
						  7:begin reg_offset <= 13'he00; end
						  8:begin reg_offset <= 13'h1000; end
						  9:begin reg_offset <= 13'h1200; end
						 10:begin reg_offset <= 13'h1400; end	//A
						 11:begin reg_offset <= 13'h1600; end	//B
						 12:begin reg_offset <= 13'h1800; end	//C
						 13:begin reg_offset <= 13'h1a00; end	//D
						 14:begin reg_offset <= 13'h1c00; end	//E
						 15:begin reg_offset <= 13'h1e00; end	//F
				  default:begin reg_offset <= 13'h000; end	//0
				endcase
			end
			
endmodule