/******************************************************************
*
* Module: register_file.v
* Description: A 32-entry, 32-bit register file.
* - Two asynchronous read ports (RD1, RD2).
* - One synchronous write port (WD3).
* - Register x0 is hardwired to zero.
*
******************************************************************/

module register_file (
    input         clk,      // Clock
    input         we3,      // Write enable for port 3
    input  [4:0]  a1,       // Read address for port 1
    input  [4:0]  a2,       // Read address for port 2
    input  [4:0]  a3,       // Write address for port 3
    input  [31:0] wd3,      // Write data for port 3
    output [31:0] rd1,      // Read data from port 1
    output [31:0] rd2       // Read data from port 2
);

    // Declare the register file as an array of 32 registers, each 32 bits wide.
    reg [31:0] rf[31:0];

    // Three-port design:
    // Port 1: Combinational read
    // If read address is 0, output 0. Otherwise, output the register value.
    assign rd1 = (a1 == 5'b0) ? 32'b0 : rf[a1];

    // Port 2: Combinational read
    // If read address is 0, output 0. Otherwise, output the register value.
    assign rd2 = (a2 == 5'b0) ? 32'b0 : rf[a2];

    // Port 3: Synchronous write on the positive edge of the clock
    always @(posedge clk) begin
        if (we3 && (a3 != 5'b0)) begin
            // Only write if write enable is high and the destination is not x0
            rf[a3] <= wd3;
        end
    end

    // Optional: Initialize all registers to 0 at the start of simulation
    integer i;
    initial begin
        for (i = 0; i < 32; i = i + 1) begin
            rf[i] = 32'b0;
        end
    end

endmodule
