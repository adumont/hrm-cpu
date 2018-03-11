module controlUnit (
        // Input: Instruction
        input  wire [3: 0] instr,
        // Output: Control signals
        output wire [1:0] muxR,
        output wire wR,
        output wire muxM,
        output wire wM,
        output wire [2:0] aluCtl,
        output wire branch,
        output wire ijump,
        output wire rIn,
        output wire wO
    );

    // signals are coded into the microcode.rom file
    parameter MICROCODE = "microcode.rom";

    initial begin
        $readmemb(MICROCODE, rom);
    end

    // 15 instructions, 12 bit signals each
    reg [11: 0] rom [0:15];

    reg [11:0] signals;

    always @(instr) begin
        signals <= rom[instr];
    end

    assign muxR = signals[11:10];
    assign wR = signals[9];
    assign muxM = signals[8];
    assign wM = signals[7];
    assign aluCtl = signals[6:4];
    assign branch = signals[3];
    assign ijump = signals[2];
    assign rIn = signals[1];
    assign wO = signals[0];

endmodule
