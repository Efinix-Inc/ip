/////////////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2013-2018 Efinix Inc. All rights reserved.
//
// single_port_rom_tb.v
//
// This is the test bench for single_port_rom.v
//
// *******************************
// Revisions:
// 0.0 Initial rev
// 0.1 Support GTKWAVE
// *******************************

`resetall
`timescale 1ns/10ps

// TOP MODULE
module sim
#(
	parameter DATA_WIDTH = 16,
	parameter ADDR_WIDTH = 8,
	parameter OUTPUT_REG = "FALSE",
	parameter RAM_INIT_FILE = "rom.inithex"
)
();

	reg [ADDR_WIDTH - 1 : 0] ADDR;
	reg clock;
	reg [DATA_WIDTH - 1 : 0] expected;
	wire [DATA_WIDTH - 1 : 0] OUT;
	integer cycle_count;

	single_port_rom
	#(
		.DATA_WIDTH(DATA_WIDTH),
		.ADDR_WIDTH(ADDR_WIDTH),
		.OUTPUT_REG(OUTPUT_REG),
		.RAM_INIT_FILE(RAM_INIT_FILE)
	)
	dut
	(
		.clk(clock),
		.addr(ADDR),
		.data(OUT)
	);

	// Initialize inputs
	initial begin
		$dumpfile("outflow/single_port_rom.vcd");
		$dumpvars(0, sim);
   
		ADDR = 0;
		clock = 0;
		cycle_count = -2;
	end

	// Generate the clock
	always #100 clock = ~clock;

	// Simulate
	always @(negedge clock) begin
		if (cycle_count == -1) begin
		end
	   
		else if (cycle_count >= 0) begin
			$display("=== === === Cycle:%d === === ===", cycle_count);
			$display("ADDR : %x", ADDR);
			$display("\tOUT : %x", OUT);
		
			// ROM with the pattern 3F .. 30
			expected = 16'hFF - (cycle_count % 256);
		
			// increament address every cycle
			ADDR = ADDR + 1;
		
			if (expected !== OUT) begin
				$display("\tMISMATCH: Expected %x got OUT : %x", expected, OUT);
				$display("TEST : FAIL");
				$finish();
			end
		
			if (cycle_count == 320) begin
				$display("TEST : PASS");
				$finish;
			end
		end
	
		cycle_count = cycle_count + 1;
	
	end

endmodule
