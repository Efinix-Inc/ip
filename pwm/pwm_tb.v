`timescale 1ns/1ns

module pwm_tb();

localparam	CNT_W	= 20;

reg		r_arst;
reg		r_sysclk;
reg		r_pv;
reg		[CNT_W-1:0]r_period;
reg		[CNT_W-1:0]r_hpw;

wire	w_pa;
wire	w_pwm;

pwm
#(
	.CNT_W(CNT_W)
)
inst_pwm
(
	.i_arst		(r_arst),
	.i_sysclk	(r_sysclk),
	.i_pv		(r_pv),
	.i_period	(r_period),
	.i_hpw		(r_hpw),
	
	.o_pa		(w_pa),
	.o_pwm		(w_pwm)
);

initial
begin
	r_arst		<= 1'b1;
	r_pv		<= 1'b1;
	r_period	<= 'd4;
	r_hpw		<= 'd2;
	#10		r_arst		<= 1'b0;
	#10		r_pv		<= 1'b0;
	#200	r_hpw		<= 'd3;
	#200	r_pv		<= 1'b1;
	#200	r_period	<= 'd10;
			r_hpw		<= 'd8;
end

initial
begin
	r_sysclk	<= 1'b1;
	forever
		#5	r_sysclk	<= ~r_sysclk;
end
/*
always@(posedge r_arst or posedge r_sysclk)
begin
	if (r_arst)
	begin
		r_period	<= {CNT_W{1'b0}};
	end
	else
	begin
		r_period	<= 
	end
end
*/
endmodule
