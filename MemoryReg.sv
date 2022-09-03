
// Create Date:    2022.08.19
// Design Name:    
// Module Name:    MemoryReg
// Revision:       2022.05.04
// Additional Comments: 	

module MemoryReg #(parameter W=8)(		 // W = data path width (leave at 8); D = address pointer width
  input                Clk,
                       Reset,	             // note use of Reset port
                       WriteEn,
  input        [W-1:0] DataIn,
  output       [W-1:0] DataOut		 
);

// W bits wide [W-1:0] and 2**4 registers deep 	 
logic [W-1:0] Register;

assign DataOut = Register;

// sequential (clocked) writes 
always_ff @ (posedge Clk)begin
  if (Reset) begin
	Register <= 'h0;
  end
  else if (WriteEn)	                         // works just like data_memory writes
    Register <= DataIn;
end

endmodule