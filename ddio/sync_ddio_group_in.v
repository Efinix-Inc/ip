module sync_ddio_group_in
#(
	parameter	DW		= 1,
	parameter	SYNC	= "RISING"
)
(
	input	arst_c_x1,
	input	arst_c_x2,
	input	c_x1,
	input	c_x2,
	input	[DW-1:0]d,
	output	[DW-1:0]q0,
	output	[DW-1:0]q1
);

reg		[DW-1:0]r_d_x2_1P;
reg		[DW-1:0]r_d_x2_2P;

reg		[DW-1:0]r_d0_x1_2P;
reg		[DW-1:0]r_d1_x1_2P;

//always@(posedge arst or posedge c_x2)
always@(posedge arst_c_x2 or posedge c_x2)
begin
//	if (arst)
	if (arst_c_x2)
	begin
		r_d_x2_1P	<= {DW{1'b0}};
		r_d_x2_2P	<= {DW{1'b0}};
	end
	else
	begin
		r_d_x2_1P	<= d;
		r_d_x2_2P	<= r_d_x2_1P;
	end
end

//always@(posedge arst or posedge c_x1)
always@(posedge arst_c_x1 or posedge c_x1)
begin
//	if (arst)
	if (arst_c_x1)
	begin
		r_d0_x1_2P	<= {DW{1'b0}};
		r_d1_x1_2P	<= {DW{1'b0}};
	end
	else
	begin
		if (SYNC == "FALLING")
		begin
			r_d0_x1_2P	<= r_d_x2_1P;
			r_d1_x1_2P	<= r_d_x2_2P;
		end
		else
		begin
			r_d0_x1_2P	<= r_d_x2_2P;
			r_d1_x1_2P	<= r_d_x2_1P;
		end
	end
end

assign	q0	= r_d0_x1_2P;
assign	q1	= r_d1_x1_2P;

endmodule
