//-------------------------------------------------------------------------
//      Mem2IO.vhd                                                       --
//      Stephen Kempf                                                    --
//                                                                       --
//      Revised 03-15-2006                                               --
//              03-22-2007                                               --
//              07-26-2013                                               --
//              03-04-2014                                               --
//              02-13-2017                                               --
//                                                                       --
//      For use with ECE 385 Experiment 6                                --
//      UIUC ECE Department                                              --
//-------------------------------------------------------------------------


module  Mem2IO ( 	input logic Clk, Reset,
						input logic [19:0]  ADDR, 
						input logic CE, UB, LB, OE, WE,
						input logic [15:0] Data_from_CPU, Data_from_SRAM,
						output logic [15:0] Data_out, Data_to_SRAM,
						output logic [7:0] out
					 );

   
	// Load data from switches when address is xFFFF, and from SRAM otherwise.
	always_comb
    begin 
        if (WE && ~OE) 
				Data_out = Data_from_SRAM[7:0];
		  else Data_out = '0;


    end

    // Pass data from CPU to SRAM
	//assign Data_to_SRAM = Data_from_CPU;

	// Write to LEDs when WE is active and address is xFFFF.
	always_ff @ (posedge Clk) begin 
		//if (Reset) 
		//else if ( ~WE & (ADDR[15:0] == 16'hFFFF) ) 
		if (ADDR == 0)
			out = Data_from_SRAM[7:0];
	
    end
       


endmodule

//------------------------------------------------------------------------------
// Company: 		 UIUC ECE Dept.
// Engineer:		 Stephen Kempf
//
// Create Date:    
// Design Name:    ECE 385 Lab 6 Given Code - Tristate buffer for SRAM
// Module Name:    tristate
//
// Comments:
//    Revised 02-13-2017
//    Spring 2017 Distribution
//
//------------------------------------------------------------------------------



module tristate #(N = 16) (
	input logic Clk, 
	input logic tristate_output_enable,
	input logic [N-1:0] Data_write, // Data from Mem2IO
	output logic [N-1:0] Data_read, // Data to Mem2IO
	inout wire [N-1:0] Data // inout bus to SRAM
);

// Registers are needed between synchronized circuit and asynchronized SRAM 
logic [N-1:0] Data_write_buffer, Data_read_buffer;

always_ff @(posedge Clk)
begin
	// Always read data from the bus
	Data_read_buffer <= Data;
	// Always updated with the data from Mem2IO which will be written to the bus
	Data_write_buffer <= Data_write;
end

// Drive (write to) Data bus only when tristate_output_enable is active.
assign Data = tristate_output_enable ? Data_write_buffer : {N{1'bZ}};

assign Data_read = Data_read_buffer;

endmodule
