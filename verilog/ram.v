`default_nettype none

module ram #(
        parameter data_width =  8,
        parameter ram_size =  2,
        parameter addr_width =  $clog2(ram_size)
    ) (
        input wire rclk,
        input wire [addr_width-1:0] raddr,
        output reg [data_width-1:0] dout,
        input wire wclk,
        input wire write_en,
        input wire [addr_width-1:0] waddr,
        input wire [data_width-1:0] din
    );

    reg [data_width-1:0] mem [ram_size-1:0];

    parameter ROMFILE = "";
    initial begin
        if(ROMFILE) $readmemh(ROMFILE, mem);
        dout=0;
    end

    always @(posedge rclk) // Read memory
    begin
        if (write_en)
            dout <= din;
        else
            dout <= mem[raddr];
    end

    always @(posedge wclk) // Write memory.
    begin
        if (write_en) mem[waddr] <= din; // Using write address bus.
    end

endmodule
