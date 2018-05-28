module i2c_sub(
	
	inout i2c_sclk, //serial clock signal
	inout i2c_sdat, // serial data signal
	input reset,
	input clk,
	output reg done,
	input [23:0] i2c_data

);
reg [6:0]SD_counter;
reg SCLK;
reg SDI;
reg GO;

//state machine state counter
always @(posedge(clk) or negedge(reset))
begin
	if(!reset)
		begin
			SD_counter <=6'b0;
		end
	else
		begin
			if(SD_counter == 31)
			begin
			
			SD_counter <=6'b0;
			end
			else if(SD_counter < 31)
					begin
						SD_counter <= SD_counter + 1;
						
					end
			end
		
end





//i2c operations
always @(posedge(clk) or negedge(reset))
begin
	if(!reset) //because reset is active low
	begin
		SCLK <=1;
		SDI <=1;
		
	end
	else
		begin
			case(SD_counter)
			6'd0: begin SDI <=1; SCLK<=1;done <= 1'b0; end
			//starting transfer
			6'd1:SDI <=0;
			6'd2:SCLK <=0;
			//Slave address
			6'd3:SDI <=i2c_data[0];
			6'd4:SDI <=i2c_data[1];
			6'd5:SDI <=i2c_data[2];
			6'd6:SDI <=i2c_data[3];
			6'd7:SDI <=i2c_data[4];
			6'd8:SDI <=i2c_data[5];
			6'd9:SDI <=i2c_data[6];
			6'd10:SDI <=i2c_data[7];
			6'd11:SDI <=1'bz; //for slave acknowlege
			//Sub address
			6'd12:SDI <=i2c_data[0];
			6'd13:SDI <=i2c_data[1];
			6'd14:SDI <=i2c_data[2];
			6'd15:SDI <=i2c_data[3];
			6'd16:SDI <=i2c_data[4];
			6'd17:SDI <=i2c_data[5];
			6'd18:SDI <=i2c_data[6];
			6'd19:SDI <=i2c_data[7];
			6'd20:SDI <=1'bz; // for slave acknowlege
			//Data transfer
			6'd21:SDI <=i2c_data[0];
			6'd22:SDI <=i2c_data[1];
			6'd23:SDI <=i2c_data[2];
			6'd24:SDI <=i2c_data[3];
			6'd25:SDI <=i2c_data[4];
			6'd26:SDI <=i2c_data[5];
			6'd27:SDI <=i2c_data[6];
			6'd28:SDI <=i2c_data[7];
			6'd29:SDI <=1'bz; // for slave acknowlege
			
			//Stop condition
			6'd30: begin SDI <= 1'b0; SCLK <= 1'b1 ;done <= 1'b1; end
			6'd31:begin SDI <= 1'b1;  done <= 1'b0; end
						
			endcase
		
		
			
		end






end


assign i2c_sclk = ((SD_counter >= 4) & (SD_counter <=31))? ~clk :SCLK;
assign i2c_sdat = SDI;




endmodule
