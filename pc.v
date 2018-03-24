module pc (
        input clk,              // clock
        input rst,              // active high reset
        input [7:0] jmpAddr,    // jump Addr read from Mem
        // control signals
        input branch,
        input ijump,
        input aluFlag,
        input wPC,
        // output: register value
        output reg [7:0] PC
    );

    always @(posedge clk) begin
        if(rst)
            PC <= 8'b0010_0000; // start of PROG in RAM
        else if(wPC) begin
            if( branch && ( ijump || aluFlag ) ) 
                PC <= jmpAddr;
            else 
                PC <= PC + 1;
        end
    end

endmodule
