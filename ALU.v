/******************************************************************
*
* Module: ALU.v
* Description: A 32-bit Arithmetic Logic Unit.
* - Performs operations based on the 4-bit ALUControl input.
* - Outputs the 32-bit result and a 1-bit Zero flag.
*
******************************************************************/

module ALU (
    input  [31:0] a,          // 32-bit operand A
    input  [31:0] b,          // 32-bit operand B
    input  [3:0]  ALUControl, // 4-bit control signal from ALU Control Unit
    output reg [31:0] ALUResult,  // 32-bit result of the operation
    output        zero        // 1-bit flag, high if result is zero
);

    // Define constants for ALU operations
    parameter ALU_AND  = 4'b0000;
    parameter ALU_OR   = 4'b0001;
    parameter ALU_ADD  = 4'b0010;
    parameter ALU_SUB  = 4'b0110;
    parameter ALU_SLT  = 4'b0111; // Set on Less Than
    parameter ALU_NOR  = 4'b1100; // Not in basic RISC-V, but common

    // Perform the operation based on ALUControl
    always @(*) begin
        case (ALUControl)
            ALU_AND: ALUResult = a & b;
            ALU_OR:  ALUResult = a | b;
            ALU_ADD: ALUResult = a + b;
            ALU_SUB: ALUResult = a - b;
            ALU_SLT: ALUResult = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0;
            ALU_NOR: ALUResult = ~(a | b);
            default: ALUResult = 32'hxxxxxxxx; // Default to undefined
        endcase
    end

    // The 'zero' flag is asserted if the result is 0.
    // This is used for branch instructions like BEQ.
    assign zero = (ALUResult == 32'b0);

endmodule
