`default_nettype none

module PROG (
        // Input: Addr

        input wire [7:0] Addr,
        input clk,

        // Output: Data, 8 bit: Instruction or Operand

        output wire [7:0] Data
        // output wire signed [11:0] Data   # do we need to have "signed" here?
    );

    // signals are coded into the microcode.rom file
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
