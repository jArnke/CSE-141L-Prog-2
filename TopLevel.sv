// Revision Date:    2020.08.05
// Design Name:    BasicProcessor
// Module Name:    TopLevel 
// CSE141L
// partial only										   
module TopLevel(		   // you will have the same 3 ports
    input        Reset,	   // init/reset, active high
			     Start,    // start next program
	             Clk,	   // clock -- posedge used inside design
    output logic Ack	   // done flag from DUT
    );

wire [ 9:0] PgmCtr;        // program counter
wire [ 8:0] PCTarg;
wire	    BranchEn;

wire [ 8:0] Instruction;   // our 9-bit opcode
wire [ 8:0] InstructionOut;
wire [ 8:0] PrevOut;

wire [ 1:0] CtrlState;
wire [ 1:0] NextCtrlState;

wire [ 2:0] CMPBits;
wire 	    CMPEn;

wire 	    AccLoadEn;
wire        AccClr;
wire [ 7:0] AccOut;
wire 	    RegLoadEn;
wire 	    RegClr;
wire [ 7:0] RegOut;

wire LFSRShift;
wire LFSRSetSeed;
wire LFSRSetTap;
wire [ 6:0] LFSRIn;
wire [ 6:0] LFSROut;
wire [7:0]  LFSRToAlu;


wire ALUBSelectCtrl;
wire [ 7:0] InA, InB, 	   // ALU operand inputs
            ALU_out;       // ALU result
wire [ 3:0] OPCode;

wire [ 7:0] MemWriteValue, // data in to data_memory
	    MemReadValue,  // data out from data_memory
	    MemTarget,	   //CTRL to Memory Mux
	    ReadTarget;    //Mux to Memory
wire	    MemAddrCtrl,
	    MemValueCtrl;
wire        MemWrite,	   // data_memory write enable
			
Zero;		   // ALU output = 0 flag
logic[15:0] CycleCt;	   // standalone; NOT PC!

// Fetch stage = Program Counter + Instruction ROM
InstFetch IF1 (		       // this is the program counter module
	.Reset        (Reset   ) ,  // reset to 0
	.Start        (Start   ) ,  // SystemVerilog shorthand for .grape(grape) is just .grape 
	.Clk          (Clk     ) ,  //    here, (Clk) is required in Verilog, optional in SystemVerilog
	.CMP_Flag    (BranchEn) ,  // branch enable
    	.Target       (PCTarg  ) ,  // "where to?" or "how far?" during a jump or branch
	.ProgCtr      (PgmCtr  )	   // program count = index to instruction memory
	);					  


// instruction ROM -- holds the machine code pointed to by program counter
InstROM #(.W(9)) IR1(
	.InstAddress  (PgmCtr) , 
	.InstOut      (Instruction)
);

PreviousInstructionLatch PIL(
	.Clk(Clk),
	.In(InstructionOut),
	.Out(PrevOut)
);

CtrlStateLatch CSL(
	.Clk(Clk),
	.In(NextCtrlState),
	.Out(CtrlState)
);

Comparator COMP(
	.Clk(Clk),
	.InputA(AccOut),
	.InputB(RegOut),
	.En(CMPEn),
	.Out(CMPBits)
);
// Decode stage = Control Decoder + Reg_file
// Control decoder
Ctrl Ctrl1 (
	.Instruction  (Instruction) ,  // from instr_ROM
	.PrevInstrunction (PrevOut),
	.PrevInstructionOut (InstructionOut),

	.CurrState (CtrlState),
	.NextState (NextCtrlState),

	.CMPBits (CMPBits),
	.CMPLoadEn (CMPEn),

	
	.BranchEn     (BranchEn) ,  // to PC
	.BranchTarget (PCTarg),

	.AccLoadEn	(AccLoadEn),
	.RegLoadEn	(RegLoadEn),
	.AccClr	(AccClr),
	.RegClr	(RegClr),

	.LFSRSetState(LFSRSetSeed),
	.LFSRSetTapPtrn(LFSRSetTap),
	.LFSRShift,	
	.LFSRInput(LFSRIn),
	
	.MemWrEn      (MemWrite   ) ,  // data memory write enable
	.MemAddrCtrl,
	.MemValueCtrl,
	.MemoryTarget (MemTarget),

	.ImmediateOut (Immediate),

    	.Ack          (Ack)    // "done" flag
  );

LFSRExtend LEx (
	In(LFSROut),
	Out(LFSRToAlu)
);


FourMux ALUInputBSelector(
	.Select(ALUBSelectCtrl),
	.A(RegOut),
	.B(MemReadValue),
	.C(Immediate),
	.D(LFSRToAlu),//Sign extend LFSR)
	.Out(InB)
);

ParityLatch SCL(
	In (SCFromAlu),
	Out(SCToAlu)
);

ALU ALU1  (
	  .InputA  (AccOut),
	  .InputB  (InB), 
	  .SC_in   (SCToAlu),
	  .OP      (OPCode),
	  .Out     (ALU_out),	
	  .Zero,		
	  .SC_out (SCFromAlu)               // status flag; may have others, if desired
);


MemoryReg MemReg (
	.Clk,
	.WriteEn (RegLoadEn),
	.Reset   (RegClr),
	.DataIn  (ALU_out),
	.DataOut (RegOut)
);
Accumulator Acc(
	.Clk,
	.WriteEn (AccLoadEn),
	.Reset   (AccClr),
	.DataIn  (ALU_out),
	.DataOut (AccOut)
);

LFSR LFSRReg(
	.Clk,
	.Advance (LFSRShift),
	.init 	 (LFSRSetTap),
	.set     (LFSRSetSeed),
	.in      (LFSRIn),
	.out	 (LFSROut)
);

TwoMux MemValueSelector(
	.Select(MemValCtrl),
	.A(RegOut),
	.B(AccOut),
	.Out(MemWriteValue)
);

TwoMux MemAddressSelector(
	.Select(MemAddrCtrl),
	.A(RegOut),
	.B(MemTarget),
	.Out(ReadTarget)
);

DataMem DM1(
		.DataAddress  (ReadTarget), 
		.WriteEn      (MemWrite), 
		.DataIn       (MemWriteValue), 
		.DataOut      (MemReadValue), 
		.Clk,
		.Reset	      (Reset)
);
	


/* count number of instructions executed
      not part of main design, potentially useful
      This one halts when Ack is high  
*/
always_ff @(posedge Clk)
  if (Reset == 1)	   // if(start)
  	CycleCt <= 0;
  else if(Ack == 0)   // if(!halt)
  	CycleCt <= CycleCt+16'b1;

endmodule
