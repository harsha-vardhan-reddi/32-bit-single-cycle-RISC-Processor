module datapath (
    input clk,
    input reset
);
    wire [31:0] pc, next_pc, pc_plus_4, pc_target;
    wire [31:0] instruction;
    wire [31:0] imm_ext;
    wire [31:0] alu_result, alu_b;
    wire [31:0] read_data_1, read_data_2, write_data_3;
    wire [31:0] mem_read_data;
    wire [31:0] result;
    wire zero;
    wire RegWrite, MemWrite, ALUSrc, ResultSrc;
    wire [1:0]  ALUOp, ImmSrc;
    wire [2:0]  ALUControl; 
    wire PCSrc_and, PCSrc_or;

    always @(posedge clk or posedge reset) begin
        if (reset)
            pc <= 32'b0;
        else
            pc <= next_pc;      //UPdating the program counter
    end

    
    assign pc_plus_4 = pc + 32'd4;
    instruction_mem imem (.a(pc), .rd(instruction));          //Instruction fetching

   
    register_file rf (
        .clk(clk), .we3(RegWrite), .a1(instruction[19:15]),
        .a2(instruction[24:20]), .a3(instruction[11:7]),             //decoding the Registers
        .wd3(result), .rd1(read_data_1), .rd2(read_data_2)
    );

    
    control_logic ctrl (
        .opcode(instruction[6:0]), .RegWrite(RegWrite), .MemWrite(MemWrite),
        .ALUSrc(ALUSrc), .ResultSrc(ResultSrc), .PCSrc(PCSrc_or),                            //calling the control logic module
        .ALUOp(ALUOp), .ImmSrc(ImmSrc)
    );

    always @(*) begin
        case (ImmSrc)
            2'b00: // I-type
                imm_ext = {{20{instruction[31]}}, instruction[31:20]};
            2'b01: // S-type
                imm_ext = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
            2'b10: // B-type
                imm_ext = {{20{instruction[31]}}, instruction[7], instruction[30:25], instruction[11:8], 1'b0};           //immediate generation based on the instruction type
            2'b11: // J-type
                imm_ext = {{12{instruction[31]}}, instruction[19:12], instruction[20], instruction[30:21], 1'b0};
            default:
                imm_ext = 32'hxxxxxxxx;
        endcase
    end

    
    ALU_Control_unit alu_ctrl (
        .ALUOp(ALUOp), .funct3(instruction[14:12]),
        .funct7_5(instruction[30]), .ALUControl(ALUControl)               //ALU
    );
    assign alu_b = ALUSrc ? imm_ext : read_data_2;
    ALU alu (
        .a(read_data_1), .b(alu_b), .ALUControl(ALUControl),
        .ALUResult(alu_result), .zero(zero)
    );

   
    data_mem dmem (
        .clk(clk), .we(MemWrite), .a(alu_result),                   //Data mem access
        .wd(read_data_2), .rd(mem_read_data)
    );

    assign result = ResultSrc ? mem_read_data : alu_result;

    assign pc_target = pc + imm_ext;                              //update the PC
    assign PCSrc_and = PCSrc_or & zero;
    assign next_pc = PCSrc_and ? pc_target : pc_plus_4;

endmodule
