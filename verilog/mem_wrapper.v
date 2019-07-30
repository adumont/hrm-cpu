`default_nettype none

module mem_wrapper #(
        parameter data_width = 8,
        parameter addr_width=8
    ) (
        input wire clk,
        input wire [addr_width-1:0] addr,
        input wire [data_width-1:0] din,
        input wire write_en,
        input wire mmio,
        output reg [data_width-1:0] dout
    );

    parameter ROMFILE = "";

    wire [data_width-1:0] ram0_dout;
    ram #( .ram_size( 256 ), .data_width( 8 ) ) ram0 (
    // read port
        .rclk( clk ),
        .raddr( addr ),
        .dout( ram0_dout ),
    // write port
        .wclk( clk ),
        .write_en( write_en  ),
        .waddr( addr ),
        .din( din )
    );
    defparam ram0.ROMFILE = ROMFILE;

    // ---------------------------------------- //
    // MUX Dump Output
    always @*
    begin
        if( mmio ) begin
            // Memory Mapped IO
            dout = {(data_width){1'b 0}};

            // if( addr == 1 ) dout = 8'h EE ;
            // else dout = 8'h FF;

        end else begin
            // RAM
            dout = ram0_dout;
        end
    end
    // ---------------------------------------- //

endmodule
