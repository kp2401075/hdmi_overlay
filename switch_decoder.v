//This module takes the four slide switch inputs and decodes them 
//into hexadecimal. Then using a case statement produces an output 
//offset for use in the font engine.
module switch_decoder
(			input [3:0] switch_bus,				// "real world"slide switch inputs
			//input clk_50MHz,						// clock input	not required	
			output [12:0] offset				// output register
);

reg [12:0] reg_offset;
assign offset = reg_offset;

always @ (*)
			begin
				case(switch_bus)
						  4'b0000:begin reg_offset <= 000; end
						  4'b0001:begin reg_offset <= 512; end
						  4'b0010:begin reg_offset <= 1024; end
						  4'b0011:begin reg_offset <= 1536; end
						  4'b0100:begin reg_offset <= 2048; end
						  4'b0101:begin reg_offset <= 2560; end
						  4'b0110:begin reg_offset <= 3072; end
						  4'b0111:begin reg_offset <= 3584; end
						  4'b1000:begin reg_offset <= 4096; end
						  4'b1001:begin reg_offset <= 4608; end
						  4'b1010:begin reg_offset <= 5120; end	//A
						  4'b1011:begin reg_offset <= 5632; end	//B
						  4'b1100:begin reg_offset <= 6144; end	//C
						  4'b1101:begin reg_offset <= 6656; end	//D
						  4'b1110:begin reg_offset <= 7168; end	//E
						  4'b1111:begin reg_offset <= 7680; end	//F
				  default:begin reg_offset <= 0000; end	//0
				endcase
			end
			
endmodule