// Module Name:    ALU
// Project Name:   CSE141L
//
// Additional Comments:
//   combinational (unclocked) ALU

// includes package "Definitions"
// be sure to adjust "Definitions" to match your final set of ALU opcodes
import Definitions::*;

module ALU #(parameter W=8)(
  input        [W-1:0]   InputA,       // data inputs
                         InputB,
  input [3:0]OP,// ALU opcode, part of microcode
  output logic [W-1:0]   Out         // data output

  // you may provide additional status flags, if desired
  // comment out or delete any you don't need
);
logic SC_out;
logic SC_in;
always_comb begin
// No Op = default
// add desired ALU ops, delete or comment out any you don't need
  Out = 8'b0;				                        // don't need NOOP? Out = 8'bx
  SC_out = 1'b0;	
  SC_in = 1'b0; 							// 	 will flag any illegal opcodes
  case(OP)
    ADD : {SC_out,Out} = InputA + InputB + SC_in;  // unsigned add with carry-in and carry-out
    LSH : {SC_out,Out} = {InputA[7:0],SC_in};       // shift left, fill in with SC_in, fill SC_out with InputA[7]
// for logical left shift, tie SC_in = 0
    LSHZ: {SC_out,Out} = {InputA[7:0],1'b0};
    RSH : {Out,SC_out} = {SC_in, InputA[7:0]};      // shift right
    RSHZ: {Out,SC_out} = {1'b0, InputA[7:0]};      // shift right
    XOR : Out = InputA ^ InputB;                    // bitwise exclusive OR
    OR  : Out = InputA | InputB;
    AND : Out = InputA & InputB;                    // bitwise AND
    SUB : {SC_out,Out} = InputA + (~InputB) + 1;	// InputA - InputB;
    CLR : {SC_out,Out} = 'b0;
    XORA: Out[7] = ^InputA[6:0];
  endcase
end



endmodule


