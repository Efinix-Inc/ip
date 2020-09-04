module pwm
#(
	parameter	CNT_W	= 20
)
(
	input	i_arst,
	input	i_sysclk,
	input	i_pv,
	input	[CNT_W-1:0]i_period,
	input	[CNT_W-1:0]i_hpw,
	
	output	o_pa,
	output	o_pwm
);

reg		r_en_1P;
reg		[CNT_W-1:0]r_period_1P;
reg		[CNT_W-1:0]r_hpw_1P;
reg		[CNT_W-1:0]r_cnt_1P;
reg		r_pa_1P;
reg		r_pwm_1P;

always@(posedge i_arst or posedge i_sysclk)
begin
	if (i_arst)
	begin
		r_en_1P		<= 1'b0;
		r_period_1P	<= {CNT_W{1'b0}};
		r_hpw_1P	<= {CNT_W{1'b0}};
		r_cnt_1P	<= {CNT_W{1'b0}};
		r_pa_1P		<= 1'b0;
		r_pwm_1P	<= 1'b0;
	end
	else
	begin
		r_pa_1P		<= 1'b0;
		
		if (~r_en_1P)
		begin
			if (i_pv)
			begin
				r_en_1P		<= 1'b1;
				r_period_1P	<= i_period;
				r_hpw_1P	<= i_hpw;
				r_pa_1P		<= 1'b1;
				r_pwm_1P	<= 1'b1;
			end
		end
		else
		begin
			r_cnt_1P	<= r_cnt_1P+1'b1;
			if (r_cnt_1P == r_period_1P-1'b1)
			begin
				r_cnt_1P	<= {CNT_W{1'b0}};
//				r_pwm_1P	<= ~r_pwm_1P;
				r_pwm_1P	<= 1'b1;
				if (i_pv)
				begin
					r_period_1P	<= i_period;
					r_hpw_1P	<= i_hpw;
					r_pa_1P		<= 1'b1;
				end
			end
			else if (r_cnt_1P == r_hpw_1P-1'b1)
//				r_pwm_1P	<= ~r_pwm_1P;
				r_pwm_1P	<= 1'b0;
		end
	end
end

assign	o_pa	= r_pa_1P;
assign	o_pwm	= r_pwm_1P;

endmodule
