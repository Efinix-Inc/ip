/////////////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2013-2018 Efinix Inc. All rights reserved.
//
// true_dual_port_ram_tb.v
//
// This is the test bench for true_dual_port_ram.v
//
// *******************************
// Revisions:
// 0.0 Initial rev
// 0.1 Support GTKWAVE
// *******************************

`resetall
`timescale 1ns/10ps

module sim
#(
	parameter DATA_WIDTH	= 8,
	parameter ADDR_WIDTH	= 9,
	parameter WRITE_MODE_1	= "READ_FIRST",
	parameter WRITE_MODE_2	= "READ_FIRST",
	parameter OUTPUT_REG_1	= "FALSE",
	parameter OUTPUT_REG_2	= "FALSE",
	parameter RAM_INIT_FILE	= "ram_init_file.mem"
)
();

	localparam MAX_DATA = (1<<DATA_WIDTH)-1;
	
	reg [DATA_WIDTH-1:0] wdata1, wdata2, expected1, expected2;
	reg [ADDR_WIDTH-1:0] addr1, addr2;
	reg clka, clkb, we1, we2, clock;
	wire [DATA_WIDTH-1:0] rdata1, rdata2;
	integer cycle_count1, cycle_count2;

	// Instantiate the DUT (design under test)
	true_dual_port_ram
	#(
		.DATA_WIDTH(DATA_WIDTH),
		.ADDR_WIDTH(ADDR_WIDTH),
		.WRITE_MODE_1(WRITE_MODE_1),
		.WRITE_MODE_2(WRITE_MODE_2),
		.OUTPUT_REG_1(OUTPUT_REG_1),
		.OUTPUT_REG_2(OUTPUT_REG_2),
		.RAM_INIT_FILE(RAM_INIT_FILE)
	)
	dut
	(
		.din1(wdata1),
		.din2(wdata2),
		.addr1(addr1),
		.clka(clka),
		.clkb(clkb),
		.we1(we1),
		.we2(we2),
		.addr2(addr2),
		.dout1(rdata1),
		.dout2(rdata2)
	);
	
	initial begin
		$dumpfile("outflow/true_dual_port_ram.vcd");
		$dumpvars(0, sim);
		
		// Initialize the DUT inputs
		wdata1 = 15;
		wdata2 = 15;
		addr1 = 0;
		clka = 0;
		clkb = 0;
		we1 = 0;
		we2 = 0;
		addr2 = 0;
		clock = 0;
		   
		// Give 2 cycles for initial state to settle
		cycle_count1 = -2;
		cycle_count2 = -2;
	end // initial begin
	
	// Generate the clocks
	// drive read & write clock from same system clock
	always #75 begin
		clock = ~clock;
		clka = ~clka;
		clkb = ~clkb;
	end
	
	// Increment the cycle counter on the postive clock
	always @(posedge clock) begin
		cycle_count1 = cycle_count1 + 1;
		cycle_count2 = cycle_count2 + 1;
	
		// Allow 3 complete traversals of the memory address space
		if ((cycle_count1 == 761) && (cycle_count2 == 761))
		begin
			$display("TEST : PASS");
			$finish;
		end
	end
	
	always @(negedge clka) begin
	// let some cycles go before starting the writing and reading
		if (cycle_count1 == -1) begin
		// Enable writing just before cycle 0
			we1 = 1;
		end
		else if (cycle_count1 >= 0) begin
			$display("%t === === === Write Cycle Port A:%d === === ===", $time, cycle_count1);
			$display("WDATA : %d\tWADDR : %d\tWE : %d", wdata1, addr1, we1);
	
			// Increment data and address
			wdata1 = wdata1 + 2;
			addr1 = addr1 + 1;
		end
	end
	
	always @(negedge clkb) begin
		// let some cycles go before starting the writing and reading
			if (cycle_count2 == -1) begin
			// Enable writing just before cycle 0
			we2 = 1;
		end
		else if (cycle_count2 >= 0) begin
			$display("%t === === === Write Cycle Port B:%d === === ===", $time, cycle_count2);
			$display("WDATA : %d\tWADDR : %d\tWE : %d", wdata2, addr2, we2);
	
			// Increment data and address
			wdata2 = wdata2 + 2;
			addr2 = addr2 + 1;
		end
	end
	
	always @(negedge clka) begin
		// let some cycles go before starting the writing and reading
		if (cycle_count1 >= 0) begin
			$display("%t === === === Read Cycle Port A: %d === === ===", $time, cycle_count1);
			$display("RADDR : %d\tRE : %d", addr1);
			$display("\tRDATA : %d", rdata1);
	  
			if (cycle_count1 < 512) begin
				expected1 = MAX_DATA - cycle_count1;
			end
		
			if (cycle_count1 >= 512) begin
				expected1 = 15 + ((cycle_count1 - 512) * 2);
			end

			if (expected1 !== rdata1) begin
				$display("\tMISMATCH: Expected %d got RDATA Port A : %d", expected1, rdata1);
				$display("TEST : FAIL");
				$finish();
			end
	
		end
	end
	
	always @(negedge clkb) begin
		// let some cycles go before starting the writing and reading
		if (cycle_count2 >= 0) begin
			$display("%t === === === Read Cycle Port B: %d === === ===", $time, cycle_count2);
			$display("RADDR : %d\tRE : %d", addr2);
			$display("\tRDATA : %d", rdata2);
	
			if (cycle_count2 < 512) begin
				expected2 = MAX_DATA - cycle_count2;
			end
	
			if (cycle_count2 >= 512) begin
				expected2 = 15 + ((cycle_count2 - 512) * 2);
			end
	 	 		 		 
			if (expected2 !== rdata2) begin
				$display("\tMISMATCH: Expected %d got RDATA Port B: %d", expected2, rdata2);
				$display("TEST : FAIL");
				$finish();
			end
	
		end
	end

endmodule
