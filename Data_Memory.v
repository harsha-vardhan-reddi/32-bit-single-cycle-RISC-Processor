module data_mem (
    input         clk,    
    input         we,     // Write enable
    input  [31:0] a,      // Address
    input  [31:0] wd,     // Write data
    output [31:0] rd      // Read data
);

    reg [31:0] ram[1023:0]; //DATA mEMORY
    assign rd = ram[a[11:2]];


    always @(posedge clk) begin
        if (we) begin
            ram[a[11:2]] <= wd;
        end
    end
    integer i;
    initial begin
        for (i = 0; i < 1024; i = i + 1) begin
            ram[i] = 32'b0;
        end
    end

endmodule
