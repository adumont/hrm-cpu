module PC (
        input clk,              // clock
        input rst,              // active high reset
        input [7:0] jmpAddr,    // jump destination Addr
        // control signals
        input branch,
        input ijump,
        input aluFlag,
        input wPC,
        // output: register value
        output reg [7:0] PC
    );

    // initial PC=0;

    always @(posedge clk) begin
        if(rst)
            PC <= 8'h00;
        else if(wPC) begin
            if( branch && ( ijump || aluFlag ) ) 
                PC <= jmpAddr;
            else 
                PC <= PC + 1;
        end
    end

endmodule
