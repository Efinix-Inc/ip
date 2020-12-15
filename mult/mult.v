module mult_wrapper
#(
	parameter	A_WIDTH		= 3,
	parameter	B_WIDTH		= 3,
	parameter	A_SIGNED	= "FALSE",
	parameter	B_SIGNED	= "FALSE",
	parameter	LATENCY		= 1
)
(
	// input
	arst,
	clk,
	
	// output
	a,
	b,
	o
);

localparam	Q_WIDTH		= A_WIDTH+B_WIDTH;

input	arst;
input	clk;
	
input	[A_WIDTH-1:0]	a;
input	[B_WIDTH-1:0]	b;
output	[Q_WIDTH  :0]	o;

generate
	if (A_SIGNED == "TRUE" && B_SIGNED == "TRUE")
	begin
		wire	[Q_WIDTH-1:0]w_o;
		
		mult_a_signed_b_signed
		#(
			.A_WIDTH(A_WIDTH),
			.B_WIDTH(B_WIDTH),
			.Q_WIDTH(Q_WIDTH),
			.LATENCY(LATENCY)
		)
		inst_mult_a_signed_b_signed
		(
			.arst(arst),
			.clk(clk),
			.a(a),
			.b(b),
			.o(w_o)
		);
		
		assign	o = {w_o[Q_WIDTH-1], w_o};
	end
	else if (A_SIGNED == "TRUE")
	begin
		wire	[Q_WIDTH:0]w_o;
		
		mult_a_signed_b_signed
		#(
			.A_WIDTH(A_WIDTH),
			.B_WIDTH(B_WIDTH+1),
			.Q_WIDTH(Q_WIDTH+1),
			.LATENCY(LATENCY)
		)
		inst_mult_a_signed_b_unsigned
		(
			.arst(arst),
			.clk(clk),
			.a(a),
			.b({1'b0, b}),
			.o(w_o)
		);
		
		assign	o = w_o;
	end
	else if (B_SIGNED == "TRUE")
	begin
		wire	[Q_WIDTH:0]w_o;
		
		mult_a_signed_b_signed
		#(
			.A_WIDTH(A_WIDTH+1),
			.B_WIDTH(B_WIDTH),
			.Q_WIDTH(Q_WIDTH+1),
			.LATENCY(LATENCY)
		)
		inst_mult_a_unsigned_b_signed
		(
			.arst(arst),
			.clk(clk),
			.a({1'b0, a}),
			.b(b),
			.o(w_o)
		);
		
		assign	o = w_o;
	end
	else
	begin
		wire	[Q_WIDTH-1:0]w_o;
		
		mult_a_unsigned_b_unsigned
		#(
			.A_WIDTH(A_WIDTH),
			.B_WIDTH(B_WIDTH),
			.Q_WIDTH(Q_WIDTH),
			.LATENCY(LATENCY)
		)
		inst_mult_a_unsigned_b_unsigned
		(
			.arst(arst),
			.clk(clk),
			.a(a),
			.b(b),
			.o(w_o)
		);
		
		assign	o = {1'b0, w_o};
	end
endgenerate

endmodule

module mult_a_unsigned_b_unsigned
#(
	parameter	A_WIDTH		= 3,
	parameter	B_WIDTH		= 3,
	parameter	Q_WIDTH		= A_WIDTH+B_WIDTH,
	parameter	LATENCY		= 1
)
(
	input	arst,
	input	clk,
	
	input	[A_WIDTH-1:0]	a,
	input	[B_WIDTH-1:0]	b,
	output	[Q_WIDTH-1:0]	o
);

reg		[A_WIDTH-1:0]r_a_1P;
reg		[B_WIDTH-1:0]r_b_1P;
reg		[Q_WIDTH-1:0]r_q_P[LATENCY:0];

wire	[Q_WIDTH-1:0]w_q;
wire	[Q_WIDTH-1:0]w_o;

genvar i;
generate
	if (LATENCY < 1)
		assign	w_q	= a*b;
	else
	begin
		always@(posedge arst or posedge clk)
		begin
			if (arst)
			begin
				r_a_1P	<= {A_WIDTH{1'b0}};
				r_b_1P	<= {B_WIDTH{1'b0}};
			end
			else
			begin
				r_a_1P	<= a;
				r_b_1P	<= b;
			end
		end
		
		assign	w_q	= r_a_1P*r_b_1P;
	end
	
	always@(posedge arst or posedge clk)
	begin
		if (arst)
			r_q_P[0]	<= {Q_WIDTH{1'b0}};
		else
			r_q_P[0]	<= w_q;
	end
	
	for (i=1; i<LATENCY; i=i+1)
	begin: pipeline
		always@(posedge arst or posedge clk)
		begin
			if (arst)
				r_q_P[i]	<= {Q_WIDTH{1'b0}};
			else
				r_q_P[i]	<= r_q_P[i-1];
		end
	end
	
	if (LATENCY < 2)
		assign	w_o	= w_q;
	else if (LATENCY < 3)
		assign	w_o	= r_q_P[0];
	else
		assign	w_o	= r_q_P[LATENCY-2];
	
endgenerate

assign	o	= w_o;

endmodule

module mult_a_signed_b_signed
#(
	parameter	A_WIDTH		= 3,
	parameter	B_WIDTH		= 3,
	parameter	Q_WIDTH		= A_WIDTH+B_WIDTH,
	parameter	LATENCY		= 1
)
(
	input	arst,
	input	clk,
	
	input signed	[A_WIDTH-1:0]	a,
	input signed	[B_WIDTH-1:0]	b,
	output signed	[Q_WIDTH-1:0]	o
);

reg signed	[A_WIDTH-1:0]r_a_1P;
reg signed	[B_WIDTH-1:0]r_b_1P;
reg signed	[Q_WIDTH-1:0]r_q_P[LATENCY:0];

wire signed	[Q_WIDTH-1:0]w_q;
wire signed	[Q_WIDTH-1:0]w_o;

genvar i;
generate
	if (LATENCY < 1)
		assign	w_q	= a*b;
	else
	begin
		always@(posedge arst or posedge clk)
		begin
			if (arst)
			begin
				r_a_1P	<= {A_WIDTH{1'b0}};
				r_b_1P	<= {B_WIDTH{1'b0}};
			end
			else
			begin
				r_a_1P	<= a;
				r_b_1P	<= b;
			end
		end
		
		assign	w_q	= r_a_1P*r_b_1P;
	end
	
	always@(posedge arst or posedge clk)
	begin
		if (arst)
			r_q_P[0]	<= {Q_WIDTH{1'b0}};
		else
			r_q_P[0]	<= w_q;
	end
	
	for (i=1; i<LATENCY; i=i+1)
	begin: pipeline
		always@(posedge arst or posedge clk)
		begin
			if (arst)
				r_q_P[i]	<= {Q_WIDTH{1'b0}};
			else
				r_q_P[i]	<= r_q_P[i-1];
		end
	end
	
	if (LATENCY < 2)
		assign	w_o	= w_q;
	else if (LATENCY < 3)
		assign	w_o	= r_q_P[0];
	else
		assign	w_o	= r_q_P[LATENCY-2];
	
endgenerate

assign	o	= w_o;

endmodule
