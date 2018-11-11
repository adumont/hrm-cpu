`default_nettype none

module register (
        input clk,              // clock
        input [7:0] iInbox,
        input [7:0] iAlu,
        input [7:0] iMem,
        // control signals
        input wire [1:0] muxR,   // source mux select
        input wR,                // enable signal
        // output: register value
        output reg signed [7:0] R
    );

    always @(posedge clk) begin
        if(wR) begin
            case (muxR)
              2'b00: R <= iInbox;
              2'b01: R <= iMem;
              2'b11: R <= iAlu;
              default: R <= 8'bx;
            endcase
        end
    end

`ifndef SYNTHESIS
    always @(R)
       $display("%t DEBUG R=%h", $time, R);
`endif

endmodule
