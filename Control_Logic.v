/******************************************************************
*
* Module: control_logic.v
* Description: The main control unit for the single-cycle RISC-V processor.
* - It decodes the opcode of the instruction to generate control signals.
* - The signals determine the operation of the datapath components.
*
******************************************************************/

module control_logic (
    input  [6:0] opcode,      // Instruction opcode [6:0]
    output reg   RegWrite,    // Enable writing to the register file
    output reg   MemWrite,    // Enable writing to data memory
    output reg   ALUSrc,      // Selects ALU's second operand (register or immediate)
    output reg   ResultSrc,   // Selects what to write back to a register (ALU result or memory data)
    output reg   PCSrc,       // Selects the next PC (PC+4 or branch target)
    output reg [1:0] ALUOp    // Specifies the operation type for the ALU Control Unit
);

    // Opcodes for different RISC-V instruction types
    parameter R_TYPE  = 7'b0110011;
    parameter I_TYPE_LOAD = 7'b0000011;
    parameter I_TYPE_ALU  = 7'b0010011;
    parameter S_TYPE  = 7'b0100011;
    parameter B_TYPE  = 7'b1100011;
    parameter J_TYPE  = 7'b1101111; // JAL

    // Combinational logic to generate control signals based on the opcode
    always @(*) begin
        case (opcode)
            R_TYPE: begin
                RegWrite  = 1;
                MemWrite  = 0;
                ALUSrc    = 0; // Operand B from register file
                ResultSrc = 0; // Result from ALU
                PCSrc     = 0; // Next PC is PC+4
                ALUOp     = 2'b10; // ALU control will decode funct3/funct7
            end
            I_TYPE_LOAD: begin // lw
                RegWrite  = 1;
                MemWrite  = 0;
                ALUSrc    = 1; // Operand B is immediate
                ResultSrc = 1; // Result from Data Memory
                PCSrc     = 0;
                ALUOp     = 2'b00; // ALU performs addition for address calculation
            end
            I_TYPE_ALU: begin // addi, slti, etc.
                RegWrite  = 1;
                MemWrite  = 0;
                ALUSrc    = 1; // Operand B is immediate
                ResultSrc = 0; // Result from ALU
                PCSrc     = 0;
                ALUOp     = 2'b10; // ALU control will decode funct3
            end
            S_TYPE: begin // sw
                RegWrite  = 0;
                MemWrite  = 1;
                ALUSrc    = 1; // Operand B is immediate
                ResultSrc = 0; // Not used, but set to a safe value
                PCSrc     = 0;
                ALUOp     = 2'b00; // ALU performs addition for address calculation
            end
            B_TYPE: begin // beq
                RegWrite  = 0;
                MemWrite  = 0;
                ALUSrc    = 0; // Operand B from register file
                ResultSrc = 0; // Not used
                PCSrc     = 1; // Decision based on ALU Zero flag
                ALUOp     = 2'b01; // ALU performs subtraction for comparison
            end
            J_TYPE: begin // jal
                RegWrite  = 1;
                MemWrite  = 0;
                ALUSrc    = 0; // Not used
                ResultSrc = 2; // Result is PC+4
                PCSrc     = 2; // Jump to target
                ALUOp     = 2'b11; // Not used
            end
            default: begin
                // Default to safe values (effectively a NOP)
                RegWrite  = 0;
                MemWrite  = 0;
                ALUSrc    = 0;
                ResultSrc = 0;
                PCSrc     = 0;
                ALUOp     = 2'b00;
            end
        endcase
    end

endmodule
