module Comparator #(parameter W=8)(
  input        [W-1:0]   InputA,       // data inputs
                         InputB,
  input                  En,        // CMP inputs
			 Clk,

  output logic [2:0]     Out         // data output
);

always_ff @ (posedge Clk) begin
	Out[2] <= ~(|InputA);
	Out[1] <= (InputA == InputB);
	Out[0] <= (InputA > InputB);
end

endmodule


