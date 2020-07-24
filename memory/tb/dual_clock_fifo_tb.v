`timescale 1ns/1ps

module sim();

localparam	GENERIC_DATA_WIDTH		= 8;
localparam	GENERIC_ADDR_WIDTH		= 8;
localparam	GENERIC_LATENCY			= 2;
localparam	GENERIC_FIFO_MODE		= "STD_FIFO";
localparam	GENERIC_RAM_INIT_FILE	= "";

localparam	E_COMPATIBILITY	= "E";
localparam	E_OUTPUT_REG	= "TRUE";
localparam	E_CHECK_FULL	= "TRUE";
localparam	E_CHECK_EMPTY	= "TRUE";

localparam	A_COMPATIBILITY	= "A";
localparam	A_OUTPUT_REG	= "DONT_CARE";
localparam	A_CHECK_FULL	= "TRUE";
localparam	A_CHECK_EMPTY	= "TRUE";

localparam	X_COMPATIBILITY	= "X";
localparam	X_OUTPUT_REG	= "TRUE";
localparam	X_CHECK_FULL	= "DONT_CARE";
localparam	X_CHECK_EMPTY	= "DONT_CARE";

reg		r_arst;
reg		r_wclk;
reg		r_we;
reg		[GENERIC_DATA_WIDTH-1:0]	r_wdata;

reg		r_rclk;
reg		r_re;

reg		r_we_P;
reg		[GENERIC_DATA_WIDTH-1:0]	r_wdata_P;
reg		r_re_P;

wire	w_efx_full;
wire	w_efx_empty;
wire	[GENERIC_DATA_WIDTH-1:0]	w_efx_rdata;

wire	w_alt_full;
wire	w_alt_empty;
wire	[GENERIC_DATA_WIDTH-1:0]	w_alt_rdata;

wire	w_xil_full;
wire	w_xil_empty;
wire	[GENERIC_DATA_WIDTH-1:0]	w_xil_rdata;

integer	i, j;

dual_clock_fifo_wrapper
#(
	.DATA_WIDTH		(GENERIC_DATA_WIDTH),
	.ADDR_WIDTH		(GENERIC_ADDR_WIDTH),
	.LATENCY		(GENERIC_LATENCY),
	.FIFO_MODE		(GENERIC_FIFO_MODE),
	.RAM_INIT_FILE	(GENERIC_RAM_INIT_FILE),
	.COMPATIBILITY	(E_COMPATIBILITY),
	.OUTPUT_REG		(E_OUTPUT_REG),
	.CHECK_FULL		(E_CHECK_FULL),
	.CHECK_EMPTY	(E_CHECK_EMPTY)
)
inst_efx_fifo
(
	.i_arst		(r_arst),
	.i_wclk		(r_wclk),
	.i_we		(r_we_P),
	.i_wdata	(r_wdata_P),
	.i_rclk		(r_rclk),
	.i_re		(r_re_P),
	
	.o_full		(w_efx_full),
	.o_empty	(w_efx_empty),
	.o_rdata	(w_efx_rdata)
);

dual_clock_fifo_wrapper
#(
	.DATA_WIDTH		(GENERIC_DATA_WIDTH),
	.ADDR_WIDTH		(GENERIC_ADDR_WIDTH),
	.LATENCY		(GENERIC_LATENCY),
	.FIFO_MODE		(GENERIC_FIFO_MODE),
	.RAM_INIT_FILE	(GENERIC_RAM_INIT_FILE),
	.COMPATIBILITY	(A_COMPATIBILITY),
	.OUTPUT_REG		(A_OUTPUT_REG),
	.CHECK_FULL		(A_CHECK_FULL),
	.CHECK_EMPTY	(A_CHECK_EMPTY)
)
inst_alt_fifo
(
	.i_arst		(r_arst),
	.i_wclk		(r_wclk),
	.i_we		(r_we_P),
	.i_wdata	(r_wdata_P),
	.i_rclk		(r_rclk),
	.i_re		(r_re_P),
	
	.o_full		(w_alt_full),
	.o_empty	(w_alt_empty),
	.o_rdata	(w_alt_rdata)
);

dual_clock_fifo_wrapper
#(
	.DATA_WIDTH		(GENERIC_DATA_WIDTH),
	.ADDR_WIDTH		(GENERIC_ADDR_WIDTH),
	.LATENCY		(GENERIC_LATENCY),
	.FIFO_MODE		(GENERIC_FIFO_MODE),
	.RAM_INIT_FILE	(GENERIC_RAM_INIT_FILE),
	.COMPATIBILITY	(X_COMPATIBILITY),
	.OUTPUT_REG		(X_OUTPUT_REG),
	.CHECK_FULL		(X_CHECK_FULL),
	.CHECK_EMPTY	(X_CHECK_EMPTY)
)
inst_xil_fifo
(
	.i_arst		(r_arst),
	.i_wclk		(r_wclk),
	.i_we		(r_we_P),
	.i_wdata	(r_wdata_P),
	.i_rclk		(r_rclk),
	.i_re		(r_re_P),
	
	.o_full		(w_xil_full),
	.o_empty	(w_xil_empty),
	.o_rdata	(w_xil_rdata)
);

initial
begin
	$dumpfile("outflow/dual_clock_fifo.vcd");
	$dumpvars(0, sim);
	
	r_arst		= 1'b1;
	r_we		= 1'b0;
	r_wdata		= {GENERIC_DATA_WIDTH{1'b0}};
	r_we_P		= 1'b0;
	r_wdata_P	= {GENERIC_DATA_WIDTH{1'b0}};
	
	#20		r_arst	= 1'b0;
	#200;
	
	for (i=0; i<16; i=i+1)
	begin
		#10		r_we	<= 1'b1;
				r_wdata	<= r_wdata+1'b1;
	end
		
	#10		r_we	<= 1'b1;
			r_wdata	<= r_wdata+1'b1;
		
	#10		r_we	<= 1'b0;
	
	#320	r_we	<= 1'b1;
			r_wdata	<= r_wdata+1'b1;
	
	#10		r_we	<= 1'b1;
			r_wdata	<= r_wdata+1'b1;
	
	#10		r_we	<= 1'b1;
			r_wdata	<= r_wdata+1'b1;
	
	#10		r_wdata	<= {GENERIC_DATA_WIDTH{1'b0}};
	
	for (i=0; i<270; i=i+1)
		#10		r_wdata	<= r_wdata+1'b1;
	
	r_we	<= 1'b0;
	
	#40;
	#10;
	#80;
	
	#3000;
	#10		r_we	<= 1'b1;
	#100	r_we	<= 1'b0;
	#10;
	#10;
end

initial
begin
	r_re	= 1'b0;
	
	#20;
	#200;
	
	for (j=0; j<16; j=j+1)
	begin
		#10		r_re	<= 1'b1;
	end
		
	#10		r_re	<= 1'b1;
		
	#10		r_re	<= 1'b1;
		
	#320;
	
	#10;
	
	#10;
	
	#10		r_re	<= 1'b0;
	
	for (j=0; j<270; j=j+1)
		#10;
	
	#40		r_re	<= 1'b1;
	#10		r_re	<= 1'b0;
	#80		r_re	<= 1'b1;
	
	#3000	r_re	<= 1'b0;
	#10;
	#100;
	#10		r_re	<= 1'b1;
	#10		r_re	<= 1'b0;
	
	$finish;
end

initial
begin
	r_wclk	= 1'b0;
	forever
		#5	r_wclk	= ~r_wclk;
end

initial
begin
	r_rclk	= 1'b0;
	forever
		#5	r_rclk	= ~r_rclk;
end

always@(posedge r_wclk)
begin
	r_we_P		<= r_we;
	r_wdata_P	<= r_wdata;
end

always@(posedge r_rclk)
begin
	r_re_P		<= r_re;
end

endmodule
