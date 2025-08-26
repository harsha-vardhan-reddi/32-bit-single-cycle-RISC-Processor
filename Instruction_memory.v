module instruction_mem (
    input  [31:0] a,    // Address input (from PC)
    output [31:0] rd    // Instruction output
);

    
    reg [31:0] ram[1023:0];
    initial begin
        ram[0] = 32'h00500093; // addi x1, x0, 5
        ram[1] = 32'h00A00113; // addi x2, x0, 10
        ram[2] = 32'h002081B3; // add x3, x1, x2
        ram[3] = 32'h00302023; // sw x3, 0(x0)
        ram[4] = 32'h00002203; // lw x4, 0(x0)
        ram[5] = 32'h00108463; 
        ram[6] = 32'h0000006F; // jal x0, 0
        ram[7] = 32'h401102B3; // sub x5, x2, x1
        
    end
    assign rd = ram[a[11:2]];

endmodule
