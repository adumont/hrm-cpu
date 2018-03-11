module inbox (
        input clk,      // clock
        input rstn,     // reset active low
        input wire rIn, // pop value to R
        // Output: Control signals
        output reg signed [11:0] data,
        output reg empty
    );

    parameter LENGTH=4; // number of item in the INBOX

    // items in the INBOX loaded from file
    parameter INBOX = "inbox.rom";
    initial begin
        if (INBOX) $readmemb(INBOX, inbox);
        p=0;
        empty=0;
    end

    // INBOX: a list of LENGTH elements, 12 bit each
    reg [$clog2(LENGTH)-1:0] p = 0; // cursor
    reg signed [11: 0] inbox [0:LENGTH];

    always @(posedge clk) begin
        // by default, keep value
        p<=p;
        if(!rstn) begin
            p <=0;
            empty  <= 0;
        end
        else if( rIn && !empty ) begin
            if( p == LENGTH-1 )
                empty  <= 1; // keep here or move below to combinational block?
            else
                p <= p+1;
        end
    end

    // combinational logic
    always @(p) begin
        data <= inbox[p];
    end

endmodule
