module control_logic (
    input  [6:0] opcode,      
    output reg   RegWrite,    
    output reg   MemWrite,    
    output reg   ALUSrc,      
    output reg   ResultSrc,   
    output reg   PCSrc,       
    output reg [1:0] ALUOp,   
    output reg [1:0] ImmSrc   
);

    parameter R_TYPE      = 7'b0110011;
    parameter I_TYPE_LOAD = 7'b0000011;
    parameter I_TYPE_ALU  = 7'b0010011;
    parameter S_TYPE      = 7'b0100011;
    parameter B_TYPE      = 7'b1100011;
    parameter J_TYPE      = 7'b1101111;
    parameter IMM_I = 2'b00;
    parameter IMM_S = 2'b01;
    parameter IMM_B = 2'b10;
    parameter IMM_J = 2'b11;
    always @(*) begin
        case (opcode)
            R_TYPE: begin
                RegWrite  = 1; MemWrite  = 0; ALUSrc    = 0; ResultSrc = 0;
                PCSrc     = 0; ALUOp     = 2'b10; ImmSrc    = 2'b00; // Don't care
            end
            I_TYPE_LOAD: begin // lw
                RegWrite  = 1; MemWrite  = 0; ALUSrc    = 1; ResultSrc = 1;
                PCSrc     = 0; ALUOp     = 2'b00; ImmSrc    = IMM_I;
            end
            I_TYPE_ALU: begin // addi, slti, etc.
                RegWrite  = 1; MemWrite  = 0; ALUSrc    = 1; ResultSrc = 0;
                PCSrc     = 0; ALUOp     = 2'b10; ImmSrc    = IMM_I;
            end
            S_TYPE: begin // sw
                RegWrite  = 0; MemWrite  = 1; ALUSrc    = 1; ResultSrc = 0; // Don't care
                PCSrc     = 0; ALUOp     = 2'b00; ImmSrc    = IMM_S;
            end
            B_TYPE: begin // beq
                RegWrite  = 0; MemWrite  = 0; ALUSrc    = 0; ResultSrc = 0; // Don't care
                PCSrc     = 1; ALUOp     = 2'b01; ImmSrc    = IMM_B;
            end
            J_TYPE: begin // jal
                RegWrite  = 1; MemWrite  = 0; ALUSrc    = 0; ResultSrc = 2; // Not used in this simplified model
                PCSrc     = 2; ALUOp     = 2'b11; ImmSrc    = IMM_J;
            end
            default: begin
                RegWrite  = 0; MemWrite  = 0; ALUSrc    = 0; ResultSrc = 0;
                PCSrc     = 0; ALUOp     = 2'b00; ImmSrc    = 2'bxx; // Don't care
            end
        endcase
    end

endmodule
