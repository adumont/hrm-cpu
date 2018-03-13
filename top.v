
module top (
    input wire clk,
    input wire sw1,
    input wire sw2,
    output wire [7:0] leds
);

    wire sw1_d, sw2_d; // pulse when sw pressed
    wire sw1_u, sw2_u; // pulse when sw released
    wire sw1_s, sw2_s;

    debouncer db_sw1 (.clk(clk), .PB(sw1), .PB_down(sw1_d), .PB_up(sw1_u), .PB_state(sw1_s));
    debouncer db_sw2 (.clk(clk), .PB(sw2), .PB_down(sw2_d), .PB_up(sw2_u), .PB_state(sw2_s));

    reg [11:0] counter = 0;

    always @(posedge clk)
    begin
        if( sw1_d ) counter <= counter + 1;
        if( sw2_d ) counter <= counter << 1;
        if( ~sw1_s && ~sw2_s ) counter <= 0;
        if(counter==6) counter <= 0;
    end

    program PROG (
        .PC(counter),
        .OP(leds[3:0])
    );

endmodule

