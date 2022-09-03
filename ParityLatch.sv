//Parity Latch for holding the parity super cool yup

module ParityLatch #()(		 // W = data path width (leave at 8); D = address pointer width
	input	Clk,
		In,
	
	output logic Out
    );

always_ff @ (posedge Clk) begin
	Out <= In;
end

endmodule
