/******************************************************************
*
* Module: ALU_Control_unit.v
* Description: Generates the specific control signal for the ALU.
* - For R-type and I-type ALU instructions, it decodes funct3/funct7.
* - For loads/stores, it forces an ADD operation.
* - For branches, it forces a SUB operation.
*
******************************************************************/

module ALU_Control_unit (
    input  [1:0]  ALUOp,      // From main control unit
    input  [2:0]  funct3,     // Instruction bits [14:12]
    input         funct7_5,   // Instruction bit [30]
    output reg [3:0]  ALUControl  // 4-bit control signal for the ALU
);

    // Define constants for ALU operations
    parameter ALU_AND  = 4'b0000;
    parameter ALU_OR   = 4'b0001;
    parameter ALU_ADD  = 4'b0010;
    parameter ALU_SUB  = 4'b0110;
    parameter ALU_SLT  = 4'b0111;

    // Define constants for funct3 field
    parameter F3_ADD_SUB = 3'b000;
    parameter F3_SLT   = 3'b010;
    parameter F3_OR    = 3'b110;
    parameter F3_AND   = 3'b111;

    always @(*) begin
        case (ALUOp)
            2'b00: // Load/Store (LW/SW)
                ALUControl = ALU_ADD; // Always perform addition for address calculation
            2'b01: // Branch (BEQ)
                ALUControl = ALU_SUB; // Always perform subtraction for comparison
            2'b10: // R-type or I-type ALU
                case (funct3)
                    F3_ADD_SUB: begin
                        if (funct7_5) // Check bit 30
                            ALUControl = ALU_SUB; // It's a SUB instruction
                        else
                            ALUControl = ALU_ADD; // It's an ADD or ADDI
                    end
                    F3_SLT:
                        ALUControl = ALU_SLT;
                    F3_OR:
                        ALUControl = ALU_OR;
                    F3_AND:
                        ALUControl = ALU_AND;
                    default:
                        ALUControl = 4'bxxxx; // Undefined for other funct3
                endcase
            default: // Should not happen
                ALUControl = 4'bxxxx;
        endcase
    end

endmodule
