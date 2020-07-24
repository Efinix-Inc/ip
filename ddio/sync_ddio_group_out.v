module sync_ddio_group_out
#(
	parameter	DW		= 1,
	parameter	INIT	= 1'b0,
	parameter	SYNC	= "RISING"
)
(
	input	arst_c_x1,
	input	arst_c_x2,
	input	[DW-1:0]d0,
	input	[DW-1:0]d1,
	input	c_x1,
	input	c_x2,
	input	lock,
	output	c,
	output	[DW-1:0]q
);

reg		[DW-1:0]r_d0_x1_1P;
reg		[DW-1:0]r_d1_x1_1P;

reg		r_c_x2_1P;
reg		r_s_x2_1P;
reg		[DW-1:0]r_d_x2_2P;

wire	w_c_rst;

generate
	if (SYNC == "FALLING")
		assign	w_c_rst	= 1'b1;
	else
		assign	w_c_rst	= 1'b0;
endgenerate

always@(posedge arst_c_x1 or posedge c_x1)
//always@(posedge arst or posedge c_x1)
//always@(negedge arst or posedge c_x1)
begin
	if (arst_c_x1)
//	if (arst)
//	if (~arst)
	begin
		r_d0_x1_1P	<= {DW{INIT}};
		r_d1_x1_1P	<= {DW{INIT}};
	end
	else if (lock)
	begin
		r_d0_x1_1P	<= d0;
		r_d1_x1_1P	<= d1;
	end
end

always@(posedge arst_c_x2 or posedge c_x2)
//always@(posedge arst or posedge c_x2)
//always@(negedge arst or posedge c_x2)
begin
	if (arst_c_x2)
//	if (arst)
//	if (~arst)
	begin
		r_c_x2_1P	<= w_c_rst;
		r_s_x2_1P	<= 1'b0;
		r_d_x2_2P	<= {DW{INIT}};
	end
	else if (lock)
	begin
		r_c_x2_1P	<= ~r_c_x2_1P;
		r_s_x2_1P	<= ~r_s_x2_1P;
		if (r_s_x2_1P)
			r_d_x2_2P	<= r_d1_x1_1P;
		else
			r_d_x2_2P	<= r_d0_x1_1P;
	end
end

assign	c	= r_c_x2_1P;
assign	q	= r_d_x2_2P;

endmodule
