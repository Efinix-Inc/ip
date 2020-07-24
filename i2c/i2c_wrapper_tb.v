module i2c_wrapper_tb();

localparam	DEVICE_ADDRESS	= 8'h00;
localparam	ADDRESSING		= 7;
localparam	SYSCLK_FREQ		= 100;
localparam	MODE			= "ULTRA_FAST";
localparam	SLAVE_ENABLE	= "FALSE";

reg		r_arst;
reg		r_sysclk;
reg		r_m_en_1P;
reg		r_m_wr_1P;
wire	[7:0]w_ov5640_reg;
reg		r_last_1P;
wire	w_ack;
wire	w_last;
wire	[7:0]w_data;

reg		r_sda_1P;
wire	w_sda;
wire	w_sda_oe;
reg		r_scl_1P;
wire	w_scl;
wire	w_scl_oe;

////////////////////////////////

assign	w_sda	= ~w_sda_oe;
assign	w_scl	= ~w_scl_oe;

localparam	s_S_IDLE	= 3'b000;
localparam	s_S_START	= 3'b001;
localparam	s_S_SHIFT	= 3'b010;
localparam	s_S_ACK		= 3'b011;
localparam	s_S_STOP	= 3'b100;

reg		[2:0]r_i2c_slave_state_1P;
reg		[2:0]r_i2c_bit_cnt_1P;
reg		[6:0]r_timer_1P;

always@(posedge r_arst or posedge r_sysclk)
begin
	if (r_arst)
	begin
		r_i2c_slave_state_1P	<= s_S_IDLE;
		r_i2c_bit_cnt_1P		<= {3{1'b0}};
		r_sda_1P				<= 1'b1;
		r_scl_1P				<= 1'b1;
		r_timer_1P				<= {7{1'b0}};
	end
	else
	begin
		r_sda_1P	<= w_sda;
		r_scl_1P	<= w_scl;
		
		case (r_i2c_slave_state_1P)
			s_S_IDLE:
			begin
				if (~w_sda && r_sda_1P && w_scl)
					r_i2c_slave_state_1P	<= s_S_START;
			end
			
			s_S_START:
			begin
				if (w_scl && ~r_scl_1P)
				begin
					r_i2c_slave_state_1P	<= s_S_SHIFT;
					r_i2c_bit_cnt_1P		<= {3{1'b0}};
				end
			end
			
			s_S_SHIFT:
			begin
				if (~w_sda && r_sda_1P && w_scl)
					r_i2c_slave_state_1P	<= s_S_START;
				
				if (w_scl && ~r_scl_1P)
					r_i2c_bit_cnt_1P	<= r_i2c_bit_cnt_1P+1'b1;
				
				if (~w_scl && r_scl_1P)
					if (r_i2c_bit_cnt_1P == 3'd7)
					begin
						r_i2c_slave_state_1P	<= s_S_ACK;
						r_i2c_bit_cnt_1P		<= {3{1'b0}};
						r_sda_1P				<= 1'b0;
					end
			end
			
			s_S_ACK:
			begin
				if (~w_sda_oe)
					r_sda_1P	<= 1'b0;
				
				r_timer_1P	<= r_timer_1P+1'b1;
				if (~w_scl && r_scl_1P)
				begin
					r_i2c_slave_state_1P	<= s_S_START;
					r_timer_1P				<= {7{1'b0}};
				end
				else if (r_timer_1P[6])
				begin
					r_i2c_slave_state_1P	<= s_S_STOP;
					r_timer_1P				<= {7{1'b0}};
				end
			end
			
			s_S_STOP:
			begin
				if (w_sda && ~r_sda_1P && w_scl)
					r_i2c_slave_state_1P	<= s_S_IDLE;
			end
			
			default:
			begin
				r_i2c_slave_state_1P	<= s_S_IDLE;
				r_i2c_bit_cnt_1P		<= {3{1'b0}};
				r_timer_1P				<= {7{1'b0}};
			end
		endcase
	end
end

i2c_wrapper_map
//#(
//	.DEVICE_ADDRESS	(DEVICE_ADDRESS),
//	.ADDRESSING		(ADDRESSING),
//	.SYSCLK_FREQ	(SYSCLK_FREQ),
//	.MODE			(MODE),
//	.SLAVE_ENABLE	(SLAVE_ENABLE)
//)
inst_i2c
(
	.i_arst		(r_arst),
	.i_sysclk	(r_sysclk),
	.i_m_en		(r_m_en_1P),
	.i_m_wr		(r_m_wr_1P),
	.i_last		(r_last_1P),
	.i_addr		(7'h3C),
	.i_data		(w_ov5640_reg),
//	.o_s_en		(w_s_en),
//	.o_s_wr		(w_s_wr),
	.o_ack		(w_ack),
	.o_last		(w_last),
	.o_data		(w_data),
	.i_sda		(r_sda_1P),
	.o_sda_oe	(w_sda_oe),
	.i_scl		(r_scl_1P),
	.o_scl_oe	(w_scl_oe)
);

reg		r_pll_locked;

initial
begin
	r_sysclk	<= 1'b1;
	forever
		#5	r_sysclk	<= ~r_sysclk;
end

initial
begin
		r_arst			<= 1'b1;
		r_pll_locked	<= 1'b1;
	#10	r_arst			<= 1'b0;
end

////////////////////////////////////////////////

localparam	s_IDLE		= 2'b01;
localparam	s_CONFIG	= 2'b10;
localparam	s_DONE		= 2'b00;

reg		[1:0]r_i2c_config_state_1P;
reg		[9:0]r_addr_1P;
reg		[1:0]r_byte_cnt_1P;
reg		[8:0]r_reg_cnt_1P;

ov5640_reg
inst_ov5640_reg
(
	.i_addr(r_addr_1P),
	.o_data(w_ov5640_reg)
);

always@(posedge r_arst or posedge r_sysclk)
begin
	if (r_arst)
	begin
		r_i2c_config_state_1P	<= s_IDLE;
		r_addr_1P				<= {10{1'b0}};
		r_m_en_1P				<= 1'b0;
		r_m_wr_1P				<= 1'b0;
		r_last_1P				<= 1'b0;
		
		r_byte_cnt_1P			<= {2{1'b0}};
		r_reg_cnt_1P			<= {9{1'b0}};
	end
	else
	begin
		case (r_i2c_config_state_1P)
			s_IDLE:
			begin
				if (r_pll_locked)
				begin
					r_i2c_config_state_1P	<= s_CONFIG;
					r_addr_1P				<= {10{1'b0}};
					r_m_en_1P				<= 1'b1;
					r_m_wr_1P				<= 1'b0;
					r_last_1P				<= 1'b0;
					
					r_byte_cnt_1P			<= {2{1'b0}};
					r_reg_cnt_1P			<= {9{1'b0}};
				end
			end
			
			s_CONFIG:
			begin
				r_m_en_1P		<= 1'b1;
				r_last_1P		<= 1'b0;
				if (w_ack)
				begin
					if (r_reg_cnt_1P != 9'd305)
					begin
						r_addr_1P		<= r_addr_1P+1'b1;
						r_byte_cnt_1P	<= r_byte_cnt_1P+1'b1;
						if (r_byte_cnt_1P == 2'b10)
						begin
							r_m_en_1P		<= 1'b0;
							r_last_1P		<= 1'b1;
							r_byte_cnt_1P	<= {2{1'b0}};
							r_reg_cnt_1P	<= r_reg_cnt_1P+1'b1;
						end
					end
					else
						r_i2c_config_state_1P	<= s_DONE;
				end
			end
			
			s_DONE:
			begin
			end
			
			default:
			begin
				r_i2c_config_state_1P	<= s_IDLE;
				r_addr_1P				<= {10{1'b0}};
				r_m_en_1P				<= 1'b0;
				r_m_wr_1P				<= 1'b0;
				
				r_byte_cnt_1P			<= {2{1'b0}};
				r_reg_cnt_1P			<= {9{1'b0}};
			end
		endcase
	end
end

endmodule
