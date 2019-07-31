`default_nettype none

/* PRNG Pseudo Random Number Generator
 * This module will output a pseudo random
 * number at each clk tick. 
 * It's base on a Cellular Automaton
 * with Wolfram Rule 30.
 * The seed can be adjusted by writing to the module via COPYTO /17
 * Author: Alexandre Dumont <adumont@gmail.com>
 * License: GPL 3.0
 */ 


module RAND (
        input wire clk,
        input wire [7:0] addr,
        input wire write_en,
        input wire rst,
        input wire [7:0] din,
        output wire [7:0] dout
    );

    localparam
        //SEED = 16'b 100_0010_1001,
        SEED = {8'h01, 8'h77},
        RULE = 8'd 30,
        WIDTH = 16;

    reg ini = 0;
    always @(posedge(clk))
        ini <= 1;

    wire [WIDTH-1:0] in; 
    wire [WIDTH-1:0] out;

    genvar i;
    generate
        for (i=0; i<WIDTH; i=i+1)
        begin : automaton_cell
            CA_cell ca_cell( { in[ (i==0) ? WIDTH-1 : (i-1) ], in[i], in[ ( i == (WIDTH-1) ) ? 0 : i+1 ] }, RULE, out[i] );
        end 
    endgenerate

    reg [WIDTH-1:0] q = 0;

    always @(posedge(clk))
        if( ini == 0 ) q <= SEED;
        else if( write_en ) q <= {8'h01,din};
        else q <= out;

    assign in = q;
    assign dout = out[9:2];

endmodule

module CA_cell(in, rule, out);
    input wire[2:0] in;
    input wire[7:0] rule;

    output wire out;

    assign out = rule[in];
endmodule