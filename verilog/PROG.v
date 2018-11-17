`default_nettype none

module PROG (
        // Input:
        input wire [7:0] Addr,
        input clk,
        // Output:
        output wire [7:0] Data  // Data, 8 bit: Instruction or Operand
    );

    parameter PROGRAM = "dummy_prg.hex";
    parameter SIZE = 256;

    reg [7:0] rom [0: SIZE-1 ];

    initial begin
        $readmemh(PROGRAM, rom);
    end

    reg [7:0] r_data;

    always @(posedge clk) begin
        r_data <= rom[Addr];
    end

    assign Data = r_data;

endmodule
