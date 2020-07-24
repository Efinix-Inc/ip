module shift_reg
#(
	parameter	D_WIDTH	= 1,
	parameter	TAPE	= 1
)
(
	input	i_arst,
	input	i_clk,
	
	input	[D_WIDTH-1:0]i_d,
	output	[D_WIDTH-1:0]o_q
);

reg		[D_WIDTH-1:0]r_q[0:TAPE-1];

always@(posedge i_arst or posedge i_clk)
begin
	if (i_arst)
		r_q[0]	<= {D_WIDTH{1'b0}};
	else
		r_q[0]	<= i_d;
end

genvar i;
generate
	for (i=1; i<TAPE; i=i+1)
	begin: shift
		always@(posedge i_arst or posedge i_clk)
		begin
			if (i_arst)
				r_q[i]	<= {D_WIDTH{1'b0}};
			else
				r_q[i]	<= r_q[i-1];
		end
	end
endgenerate

assign	o_q	= r_q[TAPE-1];

endmodule
