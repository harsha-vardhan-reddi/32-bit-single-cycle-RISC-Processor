/******************************************************************
*
* Module: instruction_mem.v
* Description: A 32-bit instruction memory (ROM).
* - It stores up to 1024 instructions.
* - The output is the instruction located at the address specified by the PC.
* - The address is word-aligned, so we use PC[11:2] as the index.
*
******************************************************************/

module instruction_mem (
    input  [31:0] a,    // Address input (from PC)
    output [31:0] rd    // Instruction output
);

    // Declare a memory (RAM) to store instructions. 1024 entries, 32 bits each.
    reg [31:0] ram[1023:0];

    // Initialize memory with some sample RISC-V instructions.
    // This block is executed only once at the beginning of the simulation.
    initial begin
        // Example instructions:
        // 0: addi x1, x0, 5      (x1 = 5)
        // 4: addi x2, x0, 10     (x2 = 10)
        // 8: add x3, x1, x2      (x3 = x1 + x2 = 15)
        // 12: sw x3, 0(x0)       (Store x3 to data memory at address 0)
        // 16: lw x4, 0(x0)       (Load value from data memory at address 0 into x4)
        // 20: beq x1, x1, 8      (Branch to PC+8 if x1 == x1, i.e., branch to instruction at address 28)
        // 24: jal x0, 0          (Jump and link to address 0, effectively a loop)
        // 28: sub x5, x2, x1      (x5 = x2 - x1 = 5)

        $readmemh("instructions.mem", ram); // Or load from a file
        
        /*
        // If not loading from file, you can manually initialize like this:
        ram[0] = 32'h00500093; // addi x1, x0, 5
        ram[1] = 32'h00A00113; // addi x2, x0, 10
        ram[2] = 32'h002081B3; // add x3, x1, x2
        ram[3] = 32'h00302023; // sw x3, 0(x0)
        ram[4] = 32'h00002203; // lw x4, 0(x0)
        ram[5] = 32'h00108463; // beq x1, x1, 8 (offset is 8 bytes -> 2 instructions)
        ram[6] = 32'h0000006F; // jal x0, 0
        ram[7] = 32'h401102B3; // sub x5, x2, x1
        */
    end

    // The instruction address is word-aligned (multiples of 4).
    // We divide the byte address by 4 to get the word index.
    // This is equivalent to right-shifting by 2 bits.
    // The memory is read combinationally.
    assign rd = ram[a[11:2]];

endmodule
