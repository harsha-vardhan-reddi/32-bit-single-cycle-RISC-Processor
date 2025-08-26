module datapath (
    input clk,
    input reset
);

    // Internal wires for connecting components
    wire [31:0] pc, next_pc, pc_plus_4, pc_target;
    wire [31:0] instruction;
    wire [31:0] imm_ext;
    wire [31:0] alu_result, alu_b;
    wire [31:0] read_data_1, read_data_2, write_data_3;
    wire [31:0] mem_read_data;
    wire [31:0] result;
    wire zero;

    // Control signals
    wire        RegWrite, MemWrite, ALUSrc, ResultSrc;
    wire [1:0]  ALUOp;
    wire [3:0]  ALUControl;
    wire        PCSrc_and, PCSrc_or; // Wires for PC source logic

    // --- Program Counter (PC) ---
    // A register that holds the address of the current instruction.
    // It updates on the positive edge of the clock.
    always @(posedge clk or posedge reset) begin
        if (reset)
            pc <= 32'b0;
        else
            pc <= next_pc;
    end

    // --- Instruction Fetch ---
    // Adder to calculate PC + 4
    assign pc_plus_4 = pc + 32'd4;

    // Instruction Memory
    instruction_mem imem (
        .a(pc),
        .rd(instruction)
    );

    register_file rf (
        .clk(clk),
        .we3(RegWrite),
        .a1(instruction[19:15]), // rs1
        .a2(instruction[24:20]), // rs2
        .a3(instruction[11:7]),  // rd
        .wd3(result),
        .rd1(read_data_1),
        .rd2(read_data_2)
    );

    // Immediate Generator (Sign Extension)
    // This logic needs to be expanded for all immediate types in a full processor.
    // For this diagram, we'll model the I, S, and B types shown.
    assign imm_ext = {{20{instruction[31]}}, instruction[31:20]}; // I-type
    // A more complete immediate generator would be needed for a full implementation.


    // --- Control Logic ---
    control_logic ctrl (
        .opcode(instruction[6:0]),
        .RegWrite(RegWrite),
        .MemWrite(MemWrite),
        .ALUSrc(ALUSrc),
        .ResultSrc(ResultSrc),
        .PCSrc(PCSrc_or), // Connect to the OR gate for PC source
        .ALUOp(ALUOp)
    );

    // --- Execute (ALU) ---
    // ALU Control Unit
    ALU_Control_unit alu_ctrl (
        .ALUOp(ALUOp),
        .funct3(instruction[14:12]),
        .funct7_5(instruction[30]),
        .ALUControl(ALUControl)
    );

    // Mux for ALU's second operand
    assign alu_b = ALUSrc ? imm_ext : read_data_2;

    // The ALU itself
    ALU alu (
        .a(read_data_1),
        .b(alu_b),
        .ALUControl(ALUControl),
        .ALUResult(alu_result),
        .zero(zero)
    );

    // --- Memory Access ---
    // Data Memory
    data_mem dmem (
        .clk(clk),
        .we(MemWrite),
        .a(alu_result),      // Address comes from ALU result
        .wd(read_data_2),    // Data to write comes from rs2
        .rd(mem_read_data)
    );

    // --- Write Back ---
    // Mux to select the data to be written back to the register file
    assign result = ResultSrc ? mem_read_data : alu_result;


    // --- Next PC Logic ---
    // Adder for branch target address calculation
    assign pc_target = pc + imm_ext; // Simplified for this diagram

    // Logic for PCSrc
    // PCSrc_and is true if it's a branch instruction (PCSrc_or=1) AND the zero flag is high.
    assign PCSrc_and = PCSrc_or & zero;

    
    assign next_pc = PCSrc_and ? pc_target : pc_plus_4;

endmodule
