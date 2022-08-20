// Create Date:    2022.08.19
// Design Name:    
// Module Name:    LFSR
// Revision:       2022.05.04
// Additional Comments: 	

module LFSR(
  input              	Clk,
                     	Advance,	// 1: advance to next state; 0: hold current state
			init,		// 1: initialize tap ptrn
			set,		// 1: set current state to start input

  input       [6:0] 	in,		  // parity feedback pattern

  output logic[6:0]  	state);	  // current state

  logic[6:0] taptrn;			  // or just use taps input, if it never changes

  always @(posedge Clk)
	if(init) begin
	  taptrn <= in;			  // load tap pattern (should match data_mem[62])
	end
	else if (set) begin
		state <= in;
	end
	else if(Advance)					  // advance to next state
	  state  <= {state[6:0],^(state&taptrn)};

endmodule