module ALU_Control_unit (
    input  [1:0]  ALUOp,      
    input  [2:0]  funct3,     
    input funct7_5,   
    output reg [2:0]  ALUControl
);
    parameter ALU_ADD  = 3'b000;
    parameter ALU_SUB  = 3'b001;
    parameter ALU_AND  = 3'b010;
    parameter ALU_OR   = 3'b011;
    parameter ALU_SLT  = 3'b100;
    parameter F3_ADD_SUB = 3'b000;
    parameter F3_SLT   = 3'b010;
    parameter F3_OR    = 3'b110;
    parameter F3_AND   = 3'b111;

    always @(*) begin
        case (ALUOp)
            2'b00: 
                ALUControl = ALU_ADD; 
            2'b01: 
                ALUControl = ALU_SUB; 
            2'b10: 
                case (funct3)
                    F3_ADD_SUB: begin
                        if (funct7_5)
                            ALUControl = ALU_SUB; 
                        else
                            ALUControl = ALU_ADD; 
                    end
                    F3_SLT:
                        ALUControl = ALU_SLT;
                    F3_OR:
                        ALUControl = ALU_OR;
                    F3_AND:
                        ALUControl = ALU_AND;
                    
                endcase
            
        endcase
    end

endmodule
