module inbox_tb;

    reg clk  = 0;
    reg rstn = 1; // not active
    reg rIn  = 0;
    wire[7:0] DIN;
    wire empty;

    // Instanciate DUT
    inbox inbox0 (
        .clk(clk),
        .rstn(rstn),
        .rIn(rIn),
        .DIN(DIN),
        .empty(empty)
    );

    // Simulate clock
    //always #1 clk = ~clk;

    // Start simulation
    initial begin

        $dumpfile("inbox_tb.vcd");
        $dumpvars(0, inbox_tb);

        // Reset
        #1  rstn = 0;
        #1  clk  = 1; // posedge clk
        #1  rstn = 1;
        #1  clk  = 0; 

        // Read In
        #1  rIn = 1;
        #1  clk  = 1; // posedge clk
        #1  rIn = 0;
        #1  clk  = 0; 

        // Read In
        #1  rIn = 1;
        #1  clk  = 1; // posedge clk
        #1  rIn = 0;
        #1  clk  = 0; 

        // Read In
        #1  rIn = 1;
        #1  clk  = 1; // posedge clk
        #1  rIn = 0;
        #1  clk  = 0; 

        // Reset
        #1  rstn = 0;
        #1  clk  = 1; // posedge clk
        #1  rstn = 1;
        #1  clk  = 0; 

        // Read In
        #1  rIn = 1;
        #1  clk  = 1; // posedge clk
        #1  rIn = 0;
        #1  clk  = 0; 

        // Read In
        #1  rIn = 1;
        #1  clk  = 1; // posedge clk
        #1  rIn = 0;
        #1  clk  = 0; 

        // Read In
        #1  rIn = 1;
        #1  clk  = 1; // posedge clk
        #1  rIn = 0;
        #1  clk  = 0; 

        // Read In
        #1  rIn = 1;
        #1  clk  = 1; // posedge clk
        #1  rIn = 0;
        #1  clk  = 0; 

        #10 $finish;
    end


endmodule
