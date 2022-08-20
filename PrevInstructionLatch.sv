
//Parity Latch for holding the parity super cool yup

module PrevInstructionLatch #()(		 // W = data path width (leave at 8); D = address pointer width
	input	Clk,
	input[8:0]In,
	
	output logic[8:0] Out
    );

always_ff @ (posedge Clk) begin
	Out <= In;
end

endmodule