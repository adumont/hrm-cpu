`default_nettype none

module hrmcpu (
    // input signals
    input  wire       cpu_debug,
    input  wire       cpu_nxtInstr,
    input  wire [7:0] cpu_in_data,
    input  wire       cpu_in_wr, // write to CPU's INBOX
    input  wire       cpu_out_rd,// read from CPU's OUTBOX
    input  wire [4:0] cpu_fifo_dmp_pos,
    input  wire       cpu_fifo_sel, // select a FIFO for dumping values: 0 INBOX, 1 OUTBOX

    // output signals
    output reg        cpu_in_full,
    output reg        cpu_out_empty,
    output reg  [7:0] cpu_out_data,
    output reg  [7:0] cpu_fifo_dmp_data,  // data in selected FIFO @ position "cpu_fifo_dmp_pos"
    output reg        cpu_fifo_dmp_valid, // whether cpu_fifo_dmp_pos is a valid position

    // generic signals
    input wire clk,
    input wire i_rst
);

    parameter PROGRAM = "dummy_prg.hex";
    parameter ROMFILE = "dummy_ram.hex";

    // ---------------------------------------- //
    // ControlUnit (FSM)
    //
    wire [7:0] cu_INSTR;
    wire       cu_inEmpty;
    wire       cu_outFull;
    wire       cu_debug;
    wire       cu_nxtInstr;
    // output signals
    wire       cu_wIR;
    wire [1:0] cu_muxR;
    wire       cu_wR;
    wire       cu_srcA;
    wire       cu_wM;
    wire       cu_wAR;
    wire [2:0] cu_aluCtl;
    wire       cu_wPC;
    wire       cu_rIn;
    wire       cu_wO;
    wire       cu_ijump;
    wire       cu_branch;
    wire       cu_rst;
    wire       cu_halt;

    ControlUnit ControlUnit0 (
        // input ports
        .INSTR(cu_INSTR),
        .inEmpty(cu_inEmpty),
        .outFull(cu_outFull),
        .debug(cu_debug),
        .nxtInstr(cu_nxtInstr),
        // output ports
        .wIR(cu_wIR),
        .muxR(cu_muxR),
        .wR(cu_wR),
        .srcA(cu_srcA),
        .wM(cu_wM),
        .wAR(cu_wAR),
        .aluCtl(cu_aluCtl),
        .wPC(cu_wPC),
        .rIn(cu_rIn),
        .wO(cu_wO),
        .ijump(cu_ijump),
        .branch(cu_branch),
        .rst(cu_rst),
        .halt(cu_halt),
        // clk, rst
        .clk(clk),
        .i_rst(i_rst)
    );

    // Connect inputs
    assign cu_INSTR = IR0_rIR;
    assign cu_inEmpty = ~ INBOX_empty_n;
    assign cu_outFull = OUTB_full;
    assign cu_debug = cpu_debug;
    assign cu_nxtInstr = cpu_nxtInstr;
    // ---------------------------------------- //

    // ---------------------------------------- //
    // PC
    //
    wire       PC0_rst;
    wire       PC0_branch;
    wire       PC0_ijump;
    wire       PC0_aluFlag;
    wire       PC0_wPC;

    wire [7:0] PC0_jmpAddr;
    wire [7:0] PC0_PC;

    PC PC0 (
        // input ports
        .jmpAddr(PC0_jmpAddr),
        .branch(PC0_branch),
        .ijump(PC0_ijump),
        .aluFlag(PC0_aluFlag),
        .wPC(PC0_wPC),
        // output ports
        .PC(PC0_PC),
        // clk, rst
        .clk(clk),
        .rst(PC0_rst)
    );

    // Connect inputs
    assign PC0_rst = cu_rst;
    assign PC0_branch = cu_branch;
    assign PC0_ijump = cu_ijump;
    assign PC0_jmpAddr = program0_Data;
    assign PC0_aluFlag = alu_flag;
    assign PC0_wPC = cu_wPC;
    // ---------------------------------------- //

    // ---------------------------------------- //
    // PROG
    //
	wire [7:0] program0_Addr;
	wire [7:0] program0_Data;

	PROG program0 (
        // input ports
        .Addr(program0_Addr),
        // output ports
        .Data(program0_Data),
        // clk, rst
        .clk(clk)
    );
	defparam program0.PROGRAM = PROGRAM;
    // Connect inputs
    assign program0_Addr = PC0_PC;
    // ---------------------------------------- //

    // ---------------------------------------- //
    // IR
    //
    wire [7:0] IR0_nIR; // next Instruction
    wire       IR0_wIR; // store next Instruction to current Instruction
    wire [7:0] IR0_rIR; // current Instruction

    IR IR0 (
        // input ports
        .wIR(IR0_wIR),
        .nIR(IR0_nIR), // input, next Instruction
        // output ports
        .rIR(IR0_rIR), // output, current Instruction
        // clk, rst
        .clk(clk)
    );
    // Connect inputs
    assign IR0_nIR = program0_Data;
    assign IR0_wIR = cu_wIR;
    // ---------------------------------------- //

    // ---------------------------------------- //
    // Register R
    //
    wire signed [7:0] R_iInbox;
    wire signed [7:0] R_iAlu;
    wire signed [7:0] R_iMem;
    wire        [1:0] R_muxR;
    wire              R_wR;

    wire signed [7:0] R_value;

    register register0 (
        // input ports
        .iInbox(R_iInbox),
        .iAlu(R_iAlu),
        .iMem(R_iMem),
        .muxR(R_muxR),
        .wR(R_wR),
        // output ports
        .R(R_value),
        // clk
        .clk(clk)
    );    
    // Connect inputs
    assign R_iInbox = INBOX_o_data;
    assign R_iAlu = alu_Out;
    assign R_iMem = mem_M;
    assign R_muxR = cu_muxR;
    assign R_wR = cu_wR;
    // ---------------------------------------- //

    // ---------------------------------------- //
    // MEMORY
    //
    wire        [7:0] mem_ADDR;
    wire        [7:0] mem_R;
    wire              mem_srcA;
    wire              mem_wM;
    wire              mem_wAR;
    wire signed [7:0] mem_M;

    // Instanciate UUT
    MEMORY MEMORY0 (
        // input ports
        .ADDR(mem_ADDR),
        .R(mem_R),
        .srcA(mem_srcA),
        .wM(mem_wM),
        .wAR(mem_wAR),
        // output ports
        .M(mem_M),
        // clk
        .clk(clk)
    );
    defparam MEMORY0.ROMFILE = ROMFILE;

    // Connect inputs
    assign mem_ADDR = program0_Data;
    assign mem_R = R_value;
    assign mem_srcA = cu_srcA;
    assign mem_wM = cu_wM;
    assign mem_wAR = cu_wAR;
    // ---------------------------------------- //

    // ---------------------------------------- //
    // ALU
    //
    wire        [2:0] alu_Ctl;
    wire signed [7:0] alu_inR;
    wire signed [7:0] alu_inM;
    wire signed [7:0] alu_Out;
    wire              alu_flag;

    ALU alu0 (
        // input ports
        .aluCtl( alu_Ctl ),
        .inR( alu_inR ),
        .inM( alu_inM ),
        // output ports
        .aluOut( alu_Out ),
        .flag( alu_flag )
    );    
    // Connect inputs
    assign alu_Ctl = cu_aluCtl;
    assign alu_inR = R_value;
    assign alu_inM = mem_M;
    // ---------------------------------------- //

    // ---------------------------------------- //
    // INBOX (FIFO)
    //
    wire              INBOX_i_wr;
    wire signed [7:0] INBOX_i_data;
    wire              INBOX_i_rd;
    wire signed [7:0] INBOX_o_data;
    wire              INBOX_empty_n;
    wire              INBOX_full;
    wire              INBOX_i_rst;
    // dump ports
    wire        [4:0] INBOX_i_dmp_pos;
    wire        [7:0] INBOX_o_dmp_data; 
    wire              INBOX_o_dmp_valid; 

    /* verilator lint_off PINMISSING */
    ufifo #(.LGFLEN(4'd5)) INBOX (
        // write port (push)
        .i_wr(INBOX_i_wr),
        .i_data(INBOX_i_data),
        // read port (pop)
        .i_rd(INBOX_i_rd),
        .o_data(INBOX_o_data),
        // flags
        .o_empty_n( INBOX_empty_n ), // not empty
        .o_err( INBOX_full ), // overflow aka full, CPU output pin
        // .o_status(),
        // dump ports
        .i_dmp_pos(INBOX_i_dmp_pos),     // dump position in queue
        .o_dmp_data(INBOX_o_dmp_data),   // value at dump position
        .o_dmp_valid(INBOX_o_dmp_valid), // i_dmp_pos is valid 
        // clk, rst
        .i_rst(INBOX_i_rst),
        .i_clk(clk)
    );
    /* verilator lint_on PINMISSING */
    defparam INBOX.RXFIFO=1'b1;
    // Connect inputs
    assign INBOX_i_data = cpu_in_data;
    assign INBOX_i_wr = cpu_in_wr;
    assign INBOX_i_rd = cu_rIn;
    assign INBOX_i_rst = cu_rst;
    assign INBOX_i_dmp_pos = cpu_fifo_dmp_pos;
    // ---------------------------------------- //

    // ---------------------------------------- //
    // OUTBOX (FIFO)
    //
    wire              OUTB_i_wr;
    wire signed [7:0] OUTB_i_data;
    wire              OUTB_i_rd;
    wire signed [7:0] OUTB_o_data;
    wire              OUTB_empty_n;
    wire              OUTB_full;
    wire              OUTB_i_rst;

    /* verilator lint_off PINMISSING */
    ufifo #(.LGFLEN(4'd5)) OUTB (
        // write port (push)
        .i_wr(OUTB_i_wr),
        .i_data(OUTB_i_data),
        // read port (pop)
        .i_rd(OUTB_i_rd),
        .o_data(OUTB_o_data),
        // flags
        .o_empty_n( OUTB_empty_n ), // not empty, CPU output pin
        .o_err( OUTB_full ), // overflow aka full
        // .o_status(),
        // clk, rst
        .i_rst(OUTB_i_rst),
        .i_clk(clk)
    );
    /* verilator lint_on PINMISSING */
    defparam OUTB.RXFIFO=1'b1;
    // Connect inputs
    assign OUTB_i_data = R_value;
    assign OUTB_i_wr = cu_wO;
    assign OUTB_i_rd = cpu_out_rd;
    assign OUTB_i_rst = cu_rst;
    // ---------------------------------------- //


    // ---------------------------------------- //
    // CPU OUTPUT
    always @(*)
    begin
        cpu_out_data = OUTB_o_data;
        cpu_out_empty = ~ OUTB_empty_n;
        cpu_in_full = INBOX_full;
        if( cpu_fifo_sel == 0 ) // INBOX dump values
        begin
            cpu_fifo_dmp_data = INBOX_o_dmp_data;
            cpu_fifo_dmp_valid = INBOX_o_dmp_valid;
        end
        else // OUTBOX dump values
        begin
            cpu_fifo_dmp_data = INBOX_o_dmp_data;  // TODO: change to OUTBOX
            cpu_fifo_dmp_valid = INBOX_o_dmp_valid;// TODO: change to OUTBOX
        end
    end
    // ---------------------------------------- //

endmodule
