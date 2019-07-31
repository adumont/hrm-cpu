`default_nettype none

module mem_wrapper #(
        parameter data_width = 8,
        parameter addr_width=8
    ) (
        input  wire                  clk,
        input  wire [addr_width-1:0] addr,
        input  wire [data_width-1:0] din,
        input  wire                  write_en,
        input  wire                  mmio,
        output reg  [data_width-1:0] dout,
        output reg  [7:0]            o_leds
    );

    wire cs_RAM0 = ~mmio;
    wire cs_XALU =  mmio & ( addr[7:4] == 4'h0 );
    wire cs_LEDS =  mmio & ( addr == 8'h10 );
    wire cs_RAND =  mmio & ( addr == 8'h11 );

    // ---------------------------------------- //
    // RAM
    //
    parameter ROMFILE = "";

    wire [data_width-1:0] ram0_dout;
    ram #( .ram_size( 256 ), .data_width( 8 ) ) ram0 (
    // read port
        .rclk( clk ),
        .raddr( addr ),
        .dout( ram0_dout ),
    // write port
        .wclk( clk ),
        .write_en( write_en & cs_RAM0 ),
        .waddr( addr ),
        .din( din )
    );
    defparam ram0.ROMFILE = ROMFILE;
    // ---------------------------------------- //

    // ---------------------------------------- //
    // XALU - Extended ALU
    //
    wire [data_width-1:0] xalu_dout;
    XALU #( .BASE_ADDR( 8'h00 ), .data_width( 8 ) ) xalu0 (
        .clk( clk ),
        .addr( addr ),
        .dout( xalu_dout ),
        .write_en( write_en & cs_XALU ),
        .din( din ),
        .rst( 0 )
    );
    // ---------------------------------------- //

    // ---------------------------------------- //
    // LEDS (convenience module to have consistent 
    // modules topology)
    //
    wire [data_width-1:0] leds_dout;
    LEDS #( .BASE_ADDR( 8'h10 ), .data_width( 8 ) ) leds0 (
        .clk( clk ),
        .addr( addr ),
        .dout( leds_dout ),
        .write_en( write_en & cs_LEDS ),
        .din( din ),
        .rst( 0 )
    );
    // ---------------------------------------- //

    // ---------------------------------------- //
    // RANDOM 
    //
    wire [data_width-1:0] rand_dout;
    RAND rand0 (
        .clk( clk ),
        .addr( addr ),
        .dout( rand_dout ),
        .write_en( write_en & cs_RAND ),
        .din( din ),
        .rst( 0 )
    );
    // ---------------------------------------- //

    // ---------------------------------------- //
    // MUX mem_wrapper output
    always @*
    begin
        case (1'b1)
            cs_RAM0: dout = ram0_dout;
            cs_XALU: dout = xalu_dout;
            cs_LEDS: dout = leds_dout;
            cs_RAND: dout = rand_dout;

            default: dout = {(data_width){1'b 0}};
        endcase

        o_leds = leds_dout;
    end
    // ---------------------------------------- //

endmodule
