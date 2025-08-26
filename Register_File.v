module register_file (
    input         clk,      
    input         we3,      
    input  [4:0]  a1,       
    input  [4:0]  a2,       
    input  [4:0]  a3,       
    input  [31:0] wd3,     
    output [31:0] rd1,      
    output [31:0] rd2       
);
    reg [31:0] rf[31:0];
    assign rd1 = (a1 == 5'b0) ? 32'b0 : rf[a1];
    assign rd2 = (a2 == 5'b0) ? 32'b0 : rf[a2];
    always @(posedge clk) begin
        if (we3 && (a3 != 5'b0)) begin
            rf[a3] <= wd3;
        end
    end
    integer i;
    initial begin
        for (i = 0; i < 32; i = i + 1) begin
            rf[i] = 32'b0;
        end
    end

endmodule
