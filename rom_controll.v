module rom_controll(
	input HDMI_TX_CLK,
	input HDMI_TX_VS,
	input rom_address_offset,
	input overlay_enable,
	output reg [12:0] rom_address
	



);

wire rom_dataIn;


//wire[12:0] rom_address_offset;
//reg [12:0] reg_rom_address_offset=0;
//wire slow_clock;


reg [4:0] font_horiz = 0;
reg [5:0] font_vert = 0;


reg [12:0] font_counter= 0;


////font counter and offset counter
always @(posedge HDMI_TX_CLK)
begin
	
	if(overlay_enable && font_counter< 512 )
	begin
	
		rom_address <= (rom_address_offset + font_counter); 
		font_counter <= font_counter +1'b1;
		
	end
	else if(font_counter == 512 || (!HDMI_TX_VS))
	begin
		font_counter <= 0;
		rom_address <= rom_address_offset;
	
	end
end

//always @(negedge HDMI_TX_VS)
//begin
//		reg_rom_address_offset <=rom_address_offset;
//end
//
endmodule
