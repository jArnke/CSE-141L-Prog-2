module LFSRExtender (
	input [6:0] LFIn,
	output logic[7:0] LFOut
);

always_comb begin
	LFOut[6:0] = LFIn;
	LFOut[7] = 1'b0;
end

endmodule
