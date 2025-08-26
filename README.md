Documentation for the Single-Cycle 32-bit RISC-V Processor
1. Top-Level Datapath (Datapath.v)
Overview
The datapath.v module is the top-level entity that integrates all the individual hardware components into a functioning single-cycle processor. It physically connects the Program Counter (PC), instruction memory, register file, control logic, ALU, and data memory according to the processor's architectural diagram. In a single-cycle design, an entire instruction is executed within one clock cycle, passing through all five stages sequentially.

Key Stages of Execution
Instruction Fetch:

The Program Counter (PC), a 32-bit register, holds the memory address of the current instruction.

On each clock cycle, the PC's value is sent to the Instruction Memory (imem), which retrieves the corresponding 32-bit instruction.

Simultaneously, an adder calculates PC + 4 to determine the address of the next sequential instruction.

Instruction Decode & Register File Read:

The fetched instruction is passed to the Control Logic (ctrl) and the Register File (rf).

The control_logic decodes the instruction's opcode (bits [6:0]) to generate all necessary control signals for the datapath.

The register_file reads the values from the source registers specified by rs1 (bits [19:15]) and rs2 (bits [24:20]) of the instruction.

Execute:

This stage is centered around the Arithmetic Logic Unit (ALU).

A multiplexer (Mux) controlled by the ALUSrc signal selects the ALU's second operand: it's either the data from register rs2 or the sign-extended immediate value from the instruction.

The ALU Control Unit (alu_ctrl) generates a specific 4-bit operation code for the ALU based on the instruction's funct3 and funct7 fields.

The ALU performs the specified operation (e.g., addition, subtraction, AND, OR) and outputs the result. It also sets a zero flag if the result is 0, which is crucial for branch instructions.

Memory Access:

This stage is active for load (lw) and store (sw) instructions.

The result from the ALU (which represents the memory address) is passed to the Data Memory (dmem).

For a sw instruction, the MemWrite signal is asserted, and the data from register rs2 is written into the calculated memory address.

For a lw instruction, data is read from the memory at the calculated address.

Write Back:

The final stage where the result of the operation is written back into the Register File.

A multiplexer controlled by the ResultSrc signal selects what data to write: it's either the result from the ALU or the data loaded from Data Memory.

The RegWrite signal must be asserted for the write operation to occur. The destination register is specified by the rd field (bits [11:7]) of the instruction.

2. Control Logic (control_logic.v)
Overview
This module is the "brain" of the processor. It is a combinational logic block that decodes the opcode field of the current instruction and generates the primary control signals that command the datapath components.

Signal

Description

RegWrite

1: Enables writing the result to the register file. Used for R-type, I-type, and load instructions.

MemWrite

1: Enables writing to the data memory. Used only for store (sw) instructions.

ALUSrc

0: The ALU's second operand comes from the register file (read_data_2). 1: The second operand comes from the sign-extended immediate.

ResultSrc

0: The value written to the register file comes from the ALU result. 1: The value comes from the data memory (for loads).

PCSrc

1: A branch condition is met. The next PC address should be the calculated branch target. 0: The next PC is PC + 4.

ALUOp

A 2-bit signal sent to the ALU_Control_unit to specify the general category of the ALU operation (e.g., memory access, branch, or R-type).

3. ALU Control Unit (ALU_Control_unit.v)
Overview
This is a secondary, specialized control unit. It takes the 2-bit ALUOp from the main control unit and the funct3/funct7 fields from the instruction to generate the precise 4-bit code that tells the ALU which specific operation to perform.

If ALUOp indicates a load/store, it forces an ADD operation for address calculation.

If ALUOp indicates a branch, it forces a SUB operation for comparison.

If ALUOp indicates an R-type or I-type ALU instruction, it decodes funct3 and funct7 to determine the exact operation (e.g., ADD, SUB, AND, OR, SLT).

4. Arithmetic Logic Unit (ALU.v)
Overview
The ALU is the computational core of the processor. It is a combinational block that performs arithmetic and logical operations on two 32-bit inputs (a and b).

ALUControl

Operation

4'b0000

a AND b

4'b0001

a OR b

4'b0010

a + b (Addition)

4'b0110

a - b (Subtraction)

4'b0111

Set on Less Than (SLT)

It produces a 32-bit ALUResult and a 1-bit zero flag that is asserted if the result is exactly zero.

5. Register File (register_file.v)
Overview
The register file is a state element containing the processor's 32 general-purpose 32-bit registers.

Two Read Ports: It can read two registers simultaneously and combinationally. The addresses are provided by the a1 (rs1) and a2 (rs2) inputs.

One Write Port: It writes data (wd3) to the register specified by a3 (rd). The write operation is synchronous and only occurs on the rising edge of the clock if the we3 (RegWrite) signal is high.

Register x0: This register is hardwired to the value zero. The logic ensures that any read from x0 returns 0 and any write to x0 is ignored.

6. Instruction Memory (instruction_mem.v)
Overview
This module models a Read-Only Memory (ROM) that stores the program's instructions.

It takes a 32-bit byte address (a) from the PC.

Since instructions are word-aligned (4 bytes), it uses the upper bits of the address (a[11:2]) as an index to look up the 32-bit instruction from its internal storage (ram).

The read operation is combinational; the instruction is available as soon as the address is provided.

In this implementation, the memory is pre-loaded with a sample program using an initial block.

7. Data Memory (data_mem.v)
Overview
This module models the main Random Access Memory (RAM) that the processor uses for load and store operations.

Address Input (a): Comes from the ALU result.

Write Data (wd): Comes from the second register read port (read_data_2).

Write Enable (we): Controlled by the MemWrite signal. Writing is synchronous and happens on the rising clock edge.

Read Data (rd): The read operation is combinational. The data at the specified address is always available at this output.
