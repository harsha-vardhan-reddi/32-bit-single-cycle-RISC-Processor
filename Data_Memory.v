/******************************************************************
*
* Module: data_mem.v
* Description: A 32-bit data memory (RAM).
* - Used for load and store operations.
* - Reads are combinational (asynchronous).
* - Writes are synchronous on the positive clock edge.
*
******************************************************************/

module data_mem (
    input         clk,    // Clock
    input         we,     // Write enable
    input  [31:0] a,      // Address
    input  [31:0] wd,     // Write data
    output [31:0] rd      // Read data
);

    // Declare memory: 1024 entries, 32 bits each.
    reg [31:0] ram[1023:0];

    // Combinational read logic
    // Address is word-aligned, so we use a[11:2] as the index.
    assign rd = ram[a[11:2]];

    // Synchronous write logic
    always @(posedge clk) begin
        if (we) begin
            // If write enable is high, write the data to the specified address.
            ram[a[11:2]] <= wd;
        end
    end

    // Optional: Initialize memory to 0 at the start of simulation
    integer i;
    initial begin
        for (i = 0; i < 1024; i = i + 1) begin
            ram[i] = 32'b0;
        end
    end

endmodule
