module overlay_enable_controll(


	input [11:0] x_counter,
	input [11:0] y_counter,
	input slow_clock,
	input KEY_1,
	output reg overlay_enable


);

reg [10:0] x_pos = 300;
reg [10:0] y_pos = 500;

always @(posedge slow_clock)
begin
	if(!KEY_1)
		begin
			x_pos <= x_pos + 10;
			y_pos <= y_pos + 18;
		end
	else
		begin
			x_pos <= x_pos;
			y_pos <= y_pos;
		end

end


////////overlay enable controll block
always @(*)
begin
		
	if(x_counter >= x_pos  && x_counter < (x_pos + 16))
		begin
			if(y_counter >= y_pos && y_counter <(y_pos + 32))
			begin
				overlay_enable <=1'b1;
			end
		end
	else
		begin
			overlay_enable <=1'b0;
		end
end

endmodule
