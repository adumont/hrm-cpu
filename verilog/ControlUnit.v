module ControlUnit (
    // input signals
    input  wire [7:0] INSTR,
    input  wire       inEmpty,
    input  wire       outFull,
    input  wire       debug,
    input  wire       nxtInstr,
    // output signals
    output reg        wIR,
    output reg  [1:0] muxR,
    output reg        wR,
    output reg        srcA,
    output reg        wM,
    output reg        wAR,
    output reg  [2:0] aluCtl,
    output reg        wPC,
    output reg        rIn,
    output reg        wO,
    output reg        ijump,
    output reg        branch,
    output reg        rst,
    output reg        halt,
    // generic signals
    input wire clk,
    input wire i_rst
);

    // States
    localparam
    S_ADD         = 5'b 01111,
    S_BUMPN       = 5'b 10101,
    S_BUMPP       = 5'b 10100,
    S_COPYFROM    = 5'b 01000,
    S_COPYTO      = 5'b 01011,
    S_DECODE      = 5'b 01001,
    S_FETCH_I     = 5'b 00010,
    S_FETCH_O     = 5'b 01110,
    S_HALT        = 5'b 01010,
    S_INBOX       = 5'b 00011,
    S_Inc_PC      = 5'b 00001,
    S_INCPC2      = 5'b 00110,
    S_JUMP        = 5'b 01100,
    S_JUMPN       = 5'b 10011,
    S_JUMPZ       = 5'b 10010,
    S_LOAD_AR     = 5'b 10111,
    S_LOAD_AR2    = 5'b 11000,
    S_LOAD_IR     = 5'b 01101,
    S_OUTBOX      = 5'b 00101,
    S_READMEM     = 5'b 00111,
    S_READMEM2    = 5'b 11001,
    S_RESET       = 5'b 00000,
    S_SUB         = 5'b 10000,
    S_WAIT_INBOX  = 5'b 10001,
    S_WAIT_KEY    = 5'b 11010,
    S_WAIT_OUTBOX = 5'b 10110;

    wire [3:0] opcode = INSTR[7:4];
    wire indirect = INSTR[3];

    localparam
    o_INBOX    = 4'b 0000,
    o_OUTBOX   = 4'b 0001,
    o_COPYFROM = 4'b 0010,
    o_COPYTO   = 4'b 0011,
    o_ADD      = 4'b 0100,
    o_SUB      = 4'b 0101,
    o_BUMPP    = 4'b 0110,
    o_BUMPN    = 4'b 0111,
    o_JUMP     = 4'b 1000,
    o_JUMPZ    = 4'b 1001,
    o_JUMPN    = 4'b 1010,
    // o_NOP1     = 4'b 1011,
    // o_NOP2     = 4'b 1100,
    // o_NOP3     = 4'b 1101,
    // o_SET      = 4'b 1110,
    o_HALT     = 4'b 1111;

    reg [4:0] state, nextstate;

    initial begin
      state = S_RESET; // 5'b 00000; // only value we can initialize correctly
    end
    
    // comb always block
    // NEXT STATE LOGIC (depends on currState and INPUTS)
    always @* begin
      // defaulting to implied_loopback to avoid latches being inferred 
      nextstate = state;
      case (state)
        S_RESET       : nextstate = S_FETCH_I;
        S_Inc_PC      : nextstate = S_FETCH_I;
        S_FETCH_I     : if (debug)  nextstate = S_WAIT_KEY;
                        else        nextstate = S_LOAD_IR;
        S_INBOX       : nextstate = S_Inc_PC;
        S_OUTBOX      : nextstate = S_Inc_PC;
        S_INCPC2      : nextstate = S_FETCH_O;
        S_READMEM     : case (opcode)
                          o_BUMPP    : nextstate = S_BUMPP;
                          o_BUMPN    : nextstate = S_BUMPN;
                          o_COPYFROM : nextstate = S_COPYFROM;
                          o_ADD      : nextstate = S_ADD;
                          o_SUB      : nextstate = S_SUB;
                          default    : nextstate = S_HALT;
                        endcase
        S_COPYFROM    : nextstate = S_Inc_PC;
        S_DECODE      : case (opcode)
                          o_INBOX  : if( inEmpty ) nextstate = S_WAIT_INBOX;
                                     else          nextstate = S_INBOX;
                          o_OUTBOX : if( outFull ) nextstate = S_WAIT_OUTBOX;
                                     else          nextstate = S_OUTBOX;
                          o_HALT   : nextstate = S_HALT;
                          default  : nextstate = S_INCPC2;
                        endcase
        S_COPYTO      : nextstate = S_Inc_PC;
        S_JUMP        : nextstate = S_FETCH_I;
        S_LOAD_IR     : nextstate = S_DECODE;
        S_FETCH_O     : case (opcode)
                          o_JUMP  : nextstate = S_JUMP;
                          o_JUMPZ : nextstate = S_JUMPZ;
                          o_JUMPN : nextstate = S_JUMPN;
                          default : nextstate = S_LOAD_AR;
                        endcase
        S_ADD         : nextstate = S_Inc_PC;
        S_SUB         : nextstate = S_Inc_PC;
        S_WAIT_INBOX  : if( ~inEmpty ) nextstate = S_INBOX;
        S_JUMPZ       : nextstate = S_FETCH_I;
        S_JUMPN       : nextstate = S_FETCH_I;
        S_BUMPP       : nextstate = S_COPYTO;
        S_BUMPN       : nextstate = S_COPYTO;
        S_WAIT_OUTBOX : if( ~outFull ) nextstate = S_OUTBOX;
        S_HALT        : nextstate = S_HALT;
        S_LOAD_AR     : if      ( ~indirect && opcode == o_COPYTO ) nextstate = S_COPYTO;
                        else if (  indirect )                       nextstate = S_READMEM2;
                        else                                        nextstate = S_READMEM;
        S_LOAD_AR2    : if( opcode == o_COPYTO ) nextstate = S_COPYTO;
                        else nextstate = S_READMEM;
        S_READMEM2    : nextstate = S_LOAD_AR2;
        S_WAIT_KEY    : if (nxtInstr) nextstate = S_LOAD_IR;
      endcase
    end

    // sequential always block
    always @(posedge clk or posedge i_rst) begin
      if (i_rst)
        state <= S_RESET;
      else
        state <= nextstate;
    end

    // OUTPUT LOGIC (Combinational)
    always @ (state)
    begin
      // avoid latches, preset all regs here to a default value. eventually change them later in the case() 
      wIR    = 1'b0;
      muxR   = 2'b00;
      wR     = 1'b0;
      srcA   = 1'b0;
      wM     = 1'b0;
      wAR    = 1'b0;
      aluCtl = 3'b000;
      wPC    = 1'b0;
      rIn    = 1'b0;
      wO     = 1'b0;
      ijump  = 1'b0;
      branch = 1'b0;
      rst    = 1'b0;
      halt   = 1'b0;

      case (state)
        S_ADD        : begin
          muxR   = 2'b  11;
          aluCtl = 3'b 000;
          wR     = 1'b   1;
        end
        S_BUMPN      : begin
          muxR   = 2'b  11;
          aluCtl = 3'b 011;
          wR     = 1'b   1;
        end
        S_BUMPP      : begin
          muxR   = 2'b  11;
          aluCtl = 3'b 010;
          wR     = 1'b   1;
        end
        S_COPYFROM   : begin
          muxR   = 2'b  01;
          wR     = 1'b   1;
        end
        S_COPYTO     : wM = 1'b 1;
        S_HALT       : halt = 1'b 1;
        S_INBOX      : begin
          rIn    = 1'b   1;
          muxR   = 2'b  00;
          wR     = 1'b   1;
        end
        S_Inc_PC     : wPC  = 1'b 1;
        S_INCPC2     : wPC  = 1'b 1;
        S_JUMP       : begin
          branch = 1'b 1;
          ijump  = 1'b 1;
          wPC    = 1'b 1;
        end
        S_JUMPN      : begin
          branch = 1'b 1;
          ijump  = 1'b 0;
          aluCtl = 3'b 100;
          wPC    = 1'b 1;
        end
        S_JUMPZ      : begin
          branch = 1'b 1;
          ijump  = 1'b 0;
          aluCtl = 3'b 000;
          wPC    = 1'b 1;
        end
        S_LOAD_AR    : wAR  = 1'b 1;
        S_LOAD_AR2   : begin
          srcA   = 1'b 1;
          wAR    = 1'b 1;
        end
        S_LOAD_IR    : wIR  = 1'b 1;
        S_OUTBOX     : wO   = 1'b 1;
        S_RESET      : rst  = 1'b1;
        S_SUB        : begin
          muxR   = 2'b  11;
          aluCtl = 3'b 001;
          wR     = 1'b   1;
        end
        // S_DECODE     : ;
        // S_FETCH_I    : ;
        // S_FETCH_O    : ;
        // S_READMEM    : ;
        // S_READMEM2   : ;
        // S_WAIT_INBOX : ;
        // S_WAIT_KEY   : ;
        // S_WAIT_OUTBOX: ;
        default: ;
      endcase
    end

    // This code allows you to see state names in simulation
    `ifndef SYNTHESIS
    reg [79:0] statename;
    reg [79:0] instrname;
    always @* begin
      // decode state name
      case (state)
        S_ADD         : statename = "ADD";
        S_BUMPN       : statename = "BUMPN";
        S_BUMPP       : statename = "BUMPP";
        S_COPYFROM    : statename = "COPYFROM";
        S_COPYTO      : statename = "COPYTO";
        S_DECODE      : statename = "DECODE";
        S_FETCH_I     : statename = "FETCH_I";
        S_FETCH_O     : statename = "FETCH_O";
        S_HALT        : statename = "HALT";
        S_INBOX       : statename = "INBOX";
        S_Inc_PC      : statename = "Inc_PC";
        S_INCPC2      : statename = "INCPC2";
        S_JUMP        : statename = "JUMP";
        S_JUMPN       : statename = "JUMPN";
        S_JUMPZ       : statename = "JUMPZ";
        S_LOAD_AR     : statename = "LOAD_AR";
        S_LOAD_AR2    : statename = "LOAD_AR2";
        S_LOAD_IR     : statename = "LOAD_IR";
        S_OUTBOX      : statename = "OUTBOX";
        S_READMEM     : statename = "READMEM";
        S_READMEM2    : statename = "READMEM2";
        S_RESET       : statename = "RESET";
        S_SUB         : statename = "SUB";
        S_WAIT_INBOX  : statename = "WAIT_INBOX";
        S_WAIT_KEY    : statename = "WAIT_KEY";
        S_WAIT_OUTBOX : statename = "WAIT_OUTBOX";
        default       : statename = "XXXXXXXXXX";
      endcase

      // decode instrname name
      case (opcode)
        o_INBOX    : instrname = "INBOX";
        o_OUTBOX   : instrname = "OUTBOX";
        o_COPYFROM : instrname = "COPYFROM";
        o_COPYTO   : instrname = "COPYTO";
        o_ADD      : instrname = "ADD";
        o_SUB      : instrname = "SUB";
        o_BUMPP    : instrname = "BUMPP";
        o_BUMPN    : instrname = "BUMPN";
        o_JUMP     : instrname = "JUMP";
        o_JUMPZ    : instrname = "JUMPZ";
        o_JUMPN    : instrname = "JUMPN";
        o_HALT     : instrname = "HALT";
        default    : instrname = "XXXXXXXXXX";
      endcase

      $display("%t - opcode: %10s (%1b) - State: %12s", $time, instrname, indirect, statename);
    end
    `endif

endmodule
