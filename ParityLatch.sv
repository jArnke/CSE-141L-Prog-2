//Parity Latch for holding the parity super cool yup

module ParityLatch #()(		 // W = data path width (leave at 8); D = address pointer width
	input	Clk,
		ParityIn,
	
	output logic ParityOut
    );

always_ff @ (posedge Clk) begin
	ParityOut <= ParityIn;
end

endmodule
