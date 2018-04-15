// Instruction Register
module IR (
        input clk,              // clock
        input [7:0] nIR,
        // control signals
        input wIR,                // enable signal
        // output: register value
        output reg [7:0] rIR
    );

    always @(posedge clk) begin
        if(wIR) begin
          rIR <= nIR;
        end 
    end

endmodule
