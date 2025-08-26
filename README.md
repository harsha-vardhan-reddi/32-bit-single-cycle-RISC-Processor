Documentation for the Single-Cycle 32-bit RISC-V Processor
1. Top-Level Datapath (datapath.v)
Overview
The datapath.v module is the highest-level component that physically connects all the individual hardware modules to form a complete, functioning single-cycle processor. It orchestrates the flow of data and control signals through the five stages of instruction execution, all within a single clock cycle.

Key Stages of Execution
Instruction Fetch:

The Program Counter (PC) holds the address of the instruction to be fetched.

The address is sent to the Instruction Memory, which returns the 32-bit instruction.

An adder calculates PC + 4 to prepare for fetching the next sequential instruction.

Instruction Decode & Register File Read:

The fetched instruction's opcode is sent to the Control Logic to generate all necessary control signals.

The instruction's source register identifiers (rs1, rs2) are sent to the Register File, which reads and outputs their corresponding data values.

The Immediate Generator block uses the ImmSrc control signal to correctly extract and sign-extend the immediate value from the instruction based on its format (I, S, B, or J).

Execute:

This stage is centered around the Arithmetic Logic Unit (ALU).

A multiplexer, controlled by ALUSrc, selects the ALU's second operand: either the data from register rs2 or the sign-extended immediate.

The ALU Control Unit generates the specific 3-bit operation code for the ALU.

The ALU performs the operation and outputs the result, along with a zero flag if the result is 0.

Memory Access:

This stage is active for load (lw) and store (sw) instructions.

The ALU result (which serves as the memory address) is sent to the Data Memory.

For a sw instruction, the MemWrite signal is asserted, and data from register rs2 is written to memory.

For a lw instruction, data is read from memory.

Write Back:

The final result is written back into the Register File.

A multiplexer, controlled by ResultSrc, selects what data to write: either the result from the ALU or the data loaded from memory.

The RegWrite signal enables the write operation to the destination register (rd).

2. Control Logic (control_logic.v)
Overview
This module is the processor's main decoder. It is a combinational logic block that interprets the instruction's opcode and generates the primary control signals that direct the datapath's operation for that instruction.

Signal

Description

RegWrite

1: Enables writing the result to the register file.

MemWrite

1: Enables writing to the data memory (for store instructions).

ALUSrc

0: The ALU's second operand is from the register file. 1: The second operand is the immediate value.

ResultSrc

0: The value written to the register file is from the ALU. 1: The value is from the data memory.

PCSrc

1: A branch condition is met; the next PC should be the branch target. 0: The next PC is PC + 4.

ALUOp

A 2-bit signal sent to the ALU_Control_unit to specify the general category of the ALU operation.

ImmSrc

A 2-bit signal sent to the Immediate Generator to specify the immediate format (I, S, B, or J).

3. ALU Control Unit (ALU_Control_unit.v)
Overview
This is a secondary, specialized decoder that generates the final 3-bit command for the ALU. It uses the general ALUOp signal from the main control unit along with the instruction's funct3 and funct7 fields to determine the precise operation.

If ALUOp indicates a load/store, it forces an ADD operation (3'b000).

If ALUOp indicates a branch, it forces a SUB operation (3'b001).

If ALUOp indicates an R-type or I-type ALU instruction, it decodes funct3/funct7 to select the exact operation (ADD, SUB, AND, OR, SLT).

4. Arithmetic Logic Unit (ALU.v)
Overview
The ALU is the computational core of the processor. It performs arithmetic and logical operations on two 32-bit inputs based on the 3-bit ALUControl signal.

ALUControl

Operation

Description

3'b000

a + b

Addition

3'b001

a - b

Subtraction

3'b010

a & b

Bitwise AND

3'b011

a | b

Bitwise OR

3'b100

a < b

Set on Less Than (signed)

It produces a 32-bit ALUResult and a 1-bit zero flag that is asserted if the result is zero.

5. Register File (register_file.v)
Overview
The register file is a state element containing the processor's 32 general-purpose 32-bit registers.

Two Asynchronous Read Ports: It can read two registers (rs1, rs2) simultaneously. The data is available combinationally.

One Synchronous Write Port: It writes data to a destination register (rd) on the rising edge of the clock, but only if the we3 (RegWrite) signal is high.

Register x0: This register is hardwired to zero. Any read from x0 returns 0, and any write to x0 is ignored.

6. Instruction Memory (instruction_mem.v)
Overview
This module models a Read-Only Memory (ROM) that stores the program's instructions.

Functionality: It takes a 32-bit byte address from the PC and outputs the 32-bit instruction stored at that location.

Addressing: Since the memory array is indexed by words but the PC provides a byte address, the address is converted using a[11:2]. This effectively divides the byte address by 4 to get the correct word index.

Initialization: An initial block is used to pre-load the memory with a sample program at the start of the simulation.

7. Data Memory (data_mem.v)
Overview
This module models the main Random Access Memory (RAM) used for load and store operations.

Functionality: It can read from or write to a memory location specified by the address from the ALU.

Reading: The read operation is combinational (asynchronous). The data at the specified address is always available at the rd output.

Writing: The write operation is synchronous. If the we (MemWrite) signal is high, the wd data is written to the specified address on the rising edge of the clock.
