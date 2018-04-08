module program (
        // Input: PC
        input  wire [11:0] PC,
        // Output: Instruction, split in OP-DATA
        output wire        [ 3:0] OP,
        output wire signed [11:0] DATA
    );

    // signals are coded into the microcode.rom file
    parameter PROGRAM = "program.rom";
    parameter SIZE = 6;

    initial begin
        $readmemb(PROGRAM, rom);
    end

    // SIZE instructions, 16 bit each
    reg [15: 0] rom [0: SIZE-1 ];

    reg [15:0] instr;

    always @(PC) begin
        instr <= rom[PC];
    end

    assign OP   = instr[15:12];
    assign DATA = instr[11:0];

endmodule
