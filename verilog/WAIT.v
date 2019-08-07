`default_nettype none

module WAIT (
	// input signals
	input  wire [7:0] din,
	input  wire       start,
	// output signals
	output wire       busy,
	// generic signals
	input wire        clk,
	input wire        rst
);
	parameter MAXC = 5 ; // FSM will keep busy=1 for MAXC clocks
	localparam BITS = $clog2( MAXC );

    // States
    localparam
    S_IDLE     = 2'b 00,
    S_START    = 2'b 01,
    S_WAIT     = 2'b 10,
    S_NEXT     = 2'b 11;

    // state registers
    reg [1:0] state;
    reg [1:0] nextstate;

    // initial begin
    //   state = S_IDLE; // 5'b 00000; // only value we can initialize correctly
    // end
    
    // internal registers
    reg [7:0] t;
    reg [BITS-1:0] c;

    // comb always block
    // NEXT STATE LOGIC (depends on currState and INPUTS)
    always @* begin
      // defaulting to implied_loopback to avoid latches being inferred 
      nextstate = state;
      case (state)
        S_IDLE        : if (start && din != 8'b0 ) nextstate = S_START;
                        else        			   nextstate = S_IDLE;

        S_START       : nextstate = S_WAIT;

		S_WAIT		  : if ( c != MAXC - 	1 )     nextstate = S_WAIT;
						else begin
							if ( t == 8'b1 ) nextstate = S_IDLE;
							else			 nextstate = S_NEXT;
						end

        S_NEXT        : nextstate = S_WAIT;
        default: nextstate = S_IDLE;
      endcase
    end

    // sequential always block
    always @(posedge clk) begin
      if (rst)
        state <= S_IDLE;
      else
        state <= nextstate;
    end

    // output signal
    assign busy = ( t != 0 );

	always @( posedge clk )
	case( state )
		S_IDLE  : begin
					c <= 0;
					t <= 0;
		end
		S_WAIT  : c <= c + 1 ;
		S_NEXT  : begin
					c <=  0 ;
					t <= t - 1 ;
		end
		S_START : begin
					// c <= c + 1 ;
					t <= din ;
		end
		default : begin
					c <= c;
					t <= t;
		end
	endcase

// This code allows you to see state names in simulation
`ifndef SYNTHESIS

    reg [87:0] statename;
    reg [79:0] instrname;

    always @* begin
		// decode state name
		case (state)
			S_IDLE        : statename = "IDLE";
			S_START       : statename = "START";
			S_WAIT        : statename = "WAIT";
			S_NEXT        : statename = "NEXT";
			default       : statename = "INVALID";
		endcase
		//$display("%t - opcode: %10s (%1b) - State: %12s", $time, instrname, indirect, statename);
    end
`endif

`ifdef FORMAL

  reg	f_past_valid;
  initial	f_past_valid = 1'b0;
  always @(posedge clk)
    f_past_valid <= 1'b1;

  always @(*) assert( statename != "XXXXXXXXXX" ); // asserts MUST stay true

  always @(posedge clk)
  if (f_past_valid)
  begin
    if( $past( i_rst ) ) assert( state == S_RESET );

  end

`endif

endmodule