`default_nettype none

module MEMORY (
        input  wire [7:0] ADDR,
        input  wire       clk,
        input  wire [7:0] R,
        input  wire       srcA,
        input  wire       wM,
        input  wire       wAR,
        output wire [7:0] M
    );

    wire [7:0] AR_d;

    parameter ROMFILE = "";

    // MUX: select what goes into AR
    assign AR_d = ( srcA == 0 ) ? ADDR : M ;

    // AR: Address Register
    reg [7:0] AR_q;

    always @(posedge clk)
    begin
        if( wAR )
            AR_q <= AR_d;
        else
            AR_q <= AR_q;
    end

    ram #( .ram_size( 256 ), .data_width( 8 ) ) ram0 (
    // read port
        .rclk( clk ),
        .raddr( AR_q ),
        .dout( M ),
    // write port
        .wclk( clk ),
        .write_en( wM ),
        .waddr( AR_q ),
        .din( R )
    );
    defparam ram0.ROMFILE = ROMFILE;

`ifndef SYNTHESIS
    always @(R)
       $display("%t DEBUG AR_q=%h", $time, AR_q);
    always @(M)
       $display("%t DEBUG M=%h", $time, M);
`endif

endmodule
