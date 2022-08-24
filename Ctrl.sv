// CSE141L
import Definitions::*;
// control decoder (combinational, not clocked)
// inputs from instrROM, ALU flags
// outputs to program_counter (fetch unit)
module Ctrl (
  input[8:0]   Instruction,	   // machine code
  input[8:0]   PrevInstruction,
  input[1:0]   CurrState,
  input[2:0]   CMPBits,

  output logic  BranchEn,

		MemAddrCtrl,
		MemValueCtrl,
		MemWrEn,	   // write to mem (store only)

		AccLoadCtrl,  // Mem or ALU to Acc/Reg   1 or 0 respectively
		RegLoadCtrl,	
		AccLoadEn,	
		RegLoadEn,
		AccClr,
		RegClr,

		CMPLoadEn,
		
		Ack,      // "done w/ program"

		LFSRSetState,
		LFSRSetTapPtrn,
		LFSRShift,


  output logic[2:0] OPCode,
  output logic[1:0] ALUInput,
  output logic[1:0] NextState,
  output logic[8:0] PrevInstructionOut,
  output logic[2:0] CMPBitsOut,

  output logic[8:0] BranchTarget,
  output logic[7:0] ImmediateOut,
  output logic[8:0] MemoryTarget
  );

	

		//States: 
		//Target  Mode:  01
		//NOP     Mode:  11
		//Imm 	  Mode:  10
		//Regular Mode:  00


	//OUTPUTS:
		//End Prog Flag

		//ALU OP Code
		
		//Immediate Out

		//Memory Target 
		//Memory Adress Control - 1 = Target 0 = Mem Reg Value
		//Mem Write En
		//Memory Value Control - 1 = Acc 0 = Mem Reg

		//Instruction Target
		//ALU B Control - 2 bits 00 = Mem, 01 = Data from Target, 10 = Immediate

		//BranchEn -  1 = Take Branch  0 = PC + 1

		//LFSR Inc		1 = Inc   0 = stay
		//LFSR Set State	1 = force state  0 = stay
		//LFSR Set Tap Pattern  1 = update tap pattern   0 = stay

		
		//CMP
			//A00 0 bit 
			//0A0 equal to bit
			//00A 0 = LT 1 = GT

		
		

/* ***** All numerical values are completely arbitrary and for illustration only *****
*/


// alternative -- case format
always_comb	begin

	//Defaults:

	//State Controls
	NextState = 2'b00;
	PrevInstructionOut = Instruction;

	//Branch Controsl
	BranchTarget = 9'b000000010;
	BranchEn = 'b0;

	CMPBitsOut = CMPBits;
	CMPLoadEn = 'b0;

	//Memory Controls
	MemoryTarget = Instruction[7:0];
	MemAddrCtrl = 'b0;
	MemValueCtrl = 'b0;
	MemWrEn = 'b0;

	//ALU Controls
	OPCode = 3'b000;
	ImmediateOut = Instruction[7:0];
	ALUInput = 2'b00;

	//Register Controls
	AccLoadCtrl = 'b0;
	RegLoadCtrl = 'b0;
	AccLoadEn = 'b0;
	RegLoadEn = 'b0;
	AccClr = 'b0;
	RegClr = 'b0;

	//LFSR Control
	LFSRSetState = 'b0;
	LFSRSetTapPtrn = 'b0;
	LFSRShift = 'b0;
	Ack = 'b0;

   	case(CurrState)
	2'b00: begin //Regular Mode:
		//if branching:
		if (Instruction[8])
			case(Instruction[7:4])
				4'b1000: begin
					NextState = 'b01;
				end
				4'b1001: begin
					if(CMPBits[2])
						NextState = 'b01;
					else
						BranchEn = 'b1;
				end
				4'b1010: begin //Greater Than
					if(CMPBits[0])
						NextState = 'b01;
					else
						BranchEn = 'b1;
				end
				4'b1011: begin //GT or equal
					if(CMPBits[0] || CMPBits[1])
						NextState = 'b01;
					else
						BranchEn = 'b1;
				end
				4'b1100: begin //LT
					if(~CMPBits[0])
						NextState = 'b01;
					else
						BranchEn = 'b1;
				end
				4'b1101: begin //LTE
					if(~CMPBits[0] || CMPBits[1])
						NextState = 'b01;
					else
						BranchEn = 'b1;
				end
				4'b1110: begin //Equal To
					if(CMPBits[1])
						NextState = 'b01;
					else
						BranchEn = 'b1;
				end
			endcase
		else
			if(Instruction[7:4] == 4'b0000) // No OP codes:
			begin
				case(Instruction[3:2])
					4'b0000: begin  //NO OP
					end
					4'b0001: begin //CLR ACC
						AccClr = 'b1;
					end
					4'b0010: begin //Clear Mem
						RegClr = 'b1;
					end
					4'b0011: begin  //LFSR set seed
						LFSRSetState = 'b1;
					end
					4'b0100: begin  //LFSR set ptrn
						LFSRSetTapPtrn = 'b1;
					end
					4'b0101: begin  //LFSR shift
						LFSRShift = 'b1;
					end
					4'b0110: begin  
					end	
					4'b0111: begin  
					end
					4'b1000: begin  //CMP 
						//TODO
					end
					4'b1001: begin
					end
					4'b1010: begin
					end
					4'b1011: begin
					end
					4'b1100: begin  //STR
						NextState = 'b01; // Handle in Target mode
					end
					4'b1101: begin  //STR Mem
						NextState = 'b01; // Handle in Target mode
					end
					4'b1110: begin  //STR ACC with mem as pointer
						MemAddrCtrl = 'b0;
						MemValueCtrl = 'b1;
						MemWrEn = 'b1;
					end
					4'b1111: begin  //Done
						Ack = 'b1;
					end
				endcase
			end
			else // Math
			begin
				case(Instruction[3:2])  //Argument Field
					2'b00:  //Use memory as argument
						case(Instruction[7:4])
							4'b0001: begin 
								OPCode = ADD;
								AccLoadCtrl = 'b1;
							end //ADD
							4'b0010: begin 
								OPCode = SUB;
								AccLoadCtrl = 'b1;
							end //SUB
							4'b0011: begin
								OPCode = ADD;
								RegLoadCtrl = 'b1;
							end //ADM
							4'b0100: begin end
							4'b0101: begin 
								OPCode = AND;
								AccLoadCtrl = 'b1;
							end //AND
							4'b0110: begin 
								OPCode = OR;
								AccLoadCtrl = 'b1;
							end //OR
							4'b0111: begin 
								OPCode = XOR;
								AccLoadCtrl = 'b1;
							end //XOR
							4'b1000: begin 
								OPCode = XORA;
								AccLoadCtrl = 'b1; 
							end //XORA
						endcase
					2'b10:  //Use Immediate
						NextState = 'b10;
					2'b01:  //Use Target value
						NextState = 'b01;
				endcase
			end
	end
	2'b01: begin	//Target Mode
		//if prev instruction[8] = 1 branch stuff

		//else case instruction[7:4]
			//arithmetic:

	end
	2'b10: begin	//Immediate Mode
		//copy over math section from normal state
		OPCode = ADD;
		ALUInput = 'b10;
		ImmediateOut = Instruction[6:0];
		AccLoadCtrl = 'b1; 


	end
	2'b11: begin	//NOP
	
		//Deprecated, shouldn't need this

	end
   endcase
end

/*
assign Ack = ProgCtr == 971;
// alternative Ack = Instruction == 'b111_000_111

// ALU commands
//assign ALU_inst = Instruction[2:0]; 

// STR commands only -- write to data_memory
assign MemWrEn = Instruction[8:6]==3'b110;

// all but STR and NOOP (or maybe CMP or TST) -- write to reg_file
assign RegWrEn = Instruction[8:7]!=2'b11;

// route data memory --> reg_file for loads
//   whenever instruction = 9'b110??????; 
assign LoadInst = Instruction[8:6]==3'b110;  // calls out load specially

assign tapSel = LoadInst &&	 DatMemAddr=='d62;
// jump enable command to program counter / instruction fetch module on right shift command
// equiv to simply: assign Jump = Instruction[2:0] == RSH;
always_comb
  if(Instruction[2:0] ==  RSH)
    Branch = 1;
  else
    Branch = 0;

// branch every time instruction = 9'b?????1111;
assign BranchEn = &Instruction[3:0];

// whenever branch or jump is taken, PC gets updated or incremented from "Target"
//  PCTarg = 2-bit address pointer into Target LUT  (PCTarg in --> Target out
assign PCTarg  = Instruction[3:2];

// reserve instruction = 9'b111111111; for Ack
assign Ack = &Instruction; // = ProgCtr == 385;
*/
endmodule

