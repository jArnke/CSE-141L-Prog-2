module TwoSwap #(parameter W=8)(				
	input Select,

	input [W-1:0]   A,
			B,

	output logic [W-1:0] OutMain, OutSecondary
);


always_comb begin
	OutMain = A;
	OutSecondary = B;
	case (Select)
		'b0: begin OutMain = A; OutSecondary = B; end
		'b1: begin OutMain = B; OutSecondary = A; end
	endcase
end

endmodule