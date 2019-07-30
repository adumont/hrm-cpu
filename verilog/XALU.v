`default_nettype none

// Extended ALU
// Other operations that were not present in the original HRM-CPU

module XALU #(
        parameter BASE_ADDR = 8'b 0000_1111,
        data_width = 8
    ) (
        input wire clk,
        input wire [7:0] addr,
        input wire write_en,
        input wire rst,
        input wire [7:0] din,
        output reg [7:0] dout
    );

    reg [data_width-1:0] a0, a1;

    // a0 register
    always @(posedge clk)
    begin
        if( rst ) a0 <= 8'b 0;
        else if( write_en && addr == BASE_ADDR + 8'd0 ) a0 <= din;
        else a0 <= a0;
    end

    // a1 register
    always @(posedge clk)
    begin
        if( rst ) a1 <= 8'b 0;
        else if( write_en && addr == BASE_ADDR + 8'd1 ) a1 <= din;
        else a1 <= a1;
    end

    // combination logic for outputs
    always @(*) 
    begin
        case(addr)
            BASE_ADDR + 8'd0: dout = a0;
            BASE_ADDR + 8'd1: dout = a1;
            BASE_ADDR + 8'd2: dout = a0 >> 1;      // A0 >> 1
            BASE_ADDR + 8'd3: dout = a0 << 1;      // A0 << 1
            BASE_ADDR + 8'd4: dout = a0 & a1;      // AND
            BASE_ADDR + 8'd5: dout = ~( a0 & a1);  // NAND
            BASE_ADDR + 8'd6: dout = a0 | a1;      // OR
            BASE_ADDR + 8'd7: dout = ~( a0 | a1);  // NOR
            BASE_ADDR + 8'd8: dout = a0 ^ a1;      // XOR
            BASE_ADDR + 8'd9: dout = ~a0 ;         // NOT(A0)
            default: dout = 8'b 0;
        endcase
    end

endmodule