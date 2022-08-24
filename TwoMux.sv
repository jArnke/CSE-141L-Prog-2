
module FourMux #(parameter W=8)(				
	input Select,

	input [W-1:0]   A,
			B,

	output logic [W-1:0] Out
);


always_comb begin
	Out = A;
	case (Select)
		'b0: Out = A;
		'b1: Out = B;
	endcase
end

endmodule