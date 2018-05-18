//Pattern generator for hdmi overlay
module hdmi_pattern_gen(
	input HDMI_TX_VS,
	output reg 	[7:0] 		ppe_red,
	output reg 	[7:0]  		ppe_green,
	output reg 	[7:0]  		ppe_blue	




);

reg [11:0] counter_pat= 0;

always @(negedge HDMI_TX_VS)
begin
		//reg_rom_address_offset <=rom_address_offset;
		counter_pat <=counter_pat +1;
		if(counter_pat == 255)
			begin
				counter_pat <= 0;
			end
		else if(counter_pat <255)
			begin
					
					ppe_red <= counter_pat;
					ppe_green<= counter_pat -1;
					ppe_blue <= counter_pat -1;
			end
		else 
			begin
				
				ppe_red <= 10;
				ppe_green<= 10;
				ppe_blue <= 10;
			end
end





endmodule
