module signal_gen(                                    
   input						clk,                
  input						reset_n,                                                
  output	reg				hdmi_hs,             
  output	reg				hdmi_vs,           
  output	reg				hdmi_de

  
);

reg			[11:0]	h_total;           
reg			[11:0]	h_sync;           
reg			[11:0]	h_start;             
reg	   	[11:0]	h_end;                                                    
reg			[11:0]	v_total;           
reg			[11:0]	v_sync;            
reg			[11:0]	v_start;           
reg			[11:0]	v_end; 

initial 
begin
	{h_total, h_sync, h_start, h_end} = {12'd2199, 12'd43, 12'd189, 12'd2109}; 
	{v_total, v_sync, v_start, v_end} = {12'd1124, 12'd4, 12'd40, 12'd1120}; 
end

reg	[11:0]	h_count;

reg	[11:0]	v_count;
reg				h_act; 
reg				h_act_d;
reg				v_act; 
reg				v_act_d; 
reg				pre_hdmi_de;
wire				h_max, hs_end, hr_start, hr_end;
wire				v_max, vs_end, vr_start, vr_end;
reg				boarder;
reg	[3:0]		color_mode;


assign h_max = h_count == h_total;
assign hs_end = h_count >= h_sync;
assign hr_start = h_count == h_start; 
assign hr_end = h_count == h_end;
assign v_max = v_count == v_total;
assign vs_end = v_count >= v_sync;
assign vr_start = v_count == v_start; 
assign vr_end = v_count == v_end;


//horizontal control signals
always @ (posedge clk or negedge reset_n)
	if (!reset_n)
	begin
		h_act_d	<=	1'b0;
		h_count	<=	12'b0;
		hdmi_hs	<=	1'b1;
		h_act		<=	1'b0;
	end
	else
	begin
		h_act_d	<=	h_act;

		if (h_max)
			h_count	<=	12'b0;
		else
			h_count	<=	h_count + 12'b1;
		if (hs_end && !h_max)
			hdmi_hs	<=	1'b1;
		else
			hdmi_hs	<=	1'b0;
		if (hr_start)
			h_act		<=	1'b1;
		else if (hr_end)
			h_act		<=	1'b0;
	end

//vertical control signals
always@(posedge clk or negedge reset_n)
	if(!reset_n)
	begin
		v_act_d		<=	1'b0;
		v_count		<=	12'b0;
		hdmi_vs		<=	1'b1;
		v_act			<=	1'b0;
		
	end
	else 
	begin		
		if (h_max)
		begin		  
			v_act_d	  <=	v_act;
		  
			if (v_max)
				v_count	<=	12'b0;
			else
				v_count	<=	v_count + 12'b1;
			if (vs_end && !v_max)
				hdmi_vs	<=	1'b1;
			else
				hdmi_vs	<=	1'b0;

			if (vr_start)
				v_act <=	1'b1;
			else if (vr_end)
				v_act <=	1'b0;

		end
	end

// display enable
always @(posedge clk or negedge reset_n)
begin
	if (!reset_n)
	begin
		hdmi_de		<=	1'b0;
		pre_hdmi_de	<=	1'b0;
		boarder		<=	1'b0;		
	end
	else
	begin
		hdmi_de		<=	pre_hdmi_de;
		pre_hdmi_de	<=	v_act && h_act;		
	end
end	

endmodule