
//Parity Latch for holding the parity super cool yup

module CtrlStateLatch #()(		 // W = data path width (leave at 8); D = address pointer width
	input	Clk,
	input [1:0] StateIn,
	
	output logic[1:0] StateOut
    );

always_ff @ (posedge Clk) begin
	ParityOut <= ParityIn;
end

endmodule