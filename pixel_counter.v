module pixel_counter(
	input HDMI_TX_HS,
	input HDMI_TX_VS,
	input HDMI_TX_CLK,
	output reg [11:0] x_counter,
	output reg [11:0] y_counter



);

//reg [11:0] x_counter = 0;
//reg [11:0] y_counter = 0;

//////////////Y counter block

initial
begin
	x_counter = 0;
	y_counter = 0;
end

always @(negedge HDMI_TX_HS)
begin
	if(!HDMI_TX_VS)
		begin
			y_counter <= 0;
		end
	else
		begin
			y_counter <= y_counter + 1'b1;
		end
end






///////////// x_counter block
always @(posedge HDMI_TX_CLK)
begin
    if(!HDMI_TX_HS)
		begin
			x_counter <=0;
		end
    else 
		begin
			x_counter <=x_counter + 1'b1;
		end
end
endmodule
