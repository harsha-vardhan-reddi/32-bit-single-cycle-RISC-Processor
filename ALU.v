module ALU (
    input  [31:0] a,          
    input  [31:0] b,         
    input  [2:0]  ALUControl, 
    output reg [31:0] ALUResult,  
    output zero   // zero flag
    
);
    parameter ALU_ADD  = 3'b000;
    parameter ALU_SUB  = 3'b001;
    parameter ALU_AND  = 3'b010;
    parameter ALU_OR   = 3'b011;
    always @(*) begin
        case (ALUControl)
            ALU_ADD: ALUResult = a + b;
            ALU_SUB: ALUResult = a - b;
            ALU_AND: ALUResult = a & b;
            ALU_OR:  ALUResult = a | b;
        endcase
    end
    if (ALUResult == 32'b0)
        assign zero = 32'b0;

endmodule
