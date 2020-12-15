`timescale	1ns/1ns

module mult_tb();

localparam	A_WIDTH		= 3;
localparam	B_WIDTH		= 3;
localparam	LATENCY		= 1;
	
reg	r_arst;
reg	r_clk;

reg		[A_WIDTH-1:0]r_pa;
reg		[A_WIDTH-1:0]r_na;
reg		[B_WIDTH-1:0]r_pb;
reg		[B_WIDTH-1:0]r_nb;
wire	[A_WIDTH+B_WIDTH:0]w_ppo;
wire	[A_WIDTH+B_WIDTH:0]w_pno;
wire	[A_WIDTH+B_WIDTH:0]w_npo;
wire	[A_WIDTH+B_WIDTH:0]w_nno;

initial
begin
	r_arst	<= 1'b1;
	#10	r_arst	<= 1'b0;
end

initial
begin
	r_clk	<= 1'b1;
	forever
		#5	r_clk	<= ~r_clk;
end

initial
begin
	r_pa	<= 3'd3;
	r_pb	<= 3'd3;
	r_na	<= -3'd3;
	r_nb	<= -3'd3;
end

mult_wrapper
#(
	.A_WIDTH	(A_WIDTH),
	.B_WIDTH	(B_WIDTH),
	.A_SIGNED	("TRUE"),
	.B_SIGNED	("TRUE"),
	.LATENCY	(LATENCY)
)
inst_mult_a_signed_b_signed
(
	.arst(r_arst),
	.clk(r_clk),
	.a(r_na),
	.b(r_nb),
	.o(w_nno)
);

mult_wrapper
#(
	.A_WIDTH	(A_WIDTH),
	.B_WIDTH	(B_WIDTH),
	.A_SIGNED	("TRUE"),
	.B_SIGNED	("FALSE"),
	.LATENCY	(LATENCY)
)
inst_mult_a_signed_b_unsigned
(
	.arst(r_arst),
	.clk(r_clk),
	.a(r_na),
	.b(r_pb),
	.o(w_npo)
);

mult_wrapper
#(
	.A_WIDTH	(A_WIDTH),
	.B_WIDTH	(B_WIDTH),
	.A_SIGNED	("FALSE"),
	.B_SIGNED	("TRUE"),
	.LATENCY	(LATENCY)
)
inst_mult_a_unsigned_b_signed
(
	.arst(r_arst),
	.clk(r_clk),
	.a(r_pa),
	.b(r_nb),
	.o(w_pno)
);

mult_wrapper
#(
	.A_WIDTH	(A_WIDTH),
	.B_WIDTH	(B_WIDTH),
	.A_SIGNED	("false"),
	.B_SIGNED	("false"),
	.LATENCY	(LATENCY)
)
inst_mult_a_unsigned_b_unsigned
(
	.arst(r_arst),
	.clk(r_clk),
	.a(r_pa),
	.b(r_pb),
	.o(w_ppo)
);

endmodule
