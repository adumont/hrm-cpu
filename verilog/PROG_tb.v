`default_nettype none

module PROG_tb();

	reg [7:0] Addr;

	wire [7:0] Data;

	localparam SIZE=10;

	// Instanciate DUT
	PROG program0 (.Addr(Addr), .clk(clk), .Data(Data));
	defparam program0.PROGRAM = "program.rom";
	defparam program0.SIZE = SIZE;

	// Simulate clock
	reg clk  = 0;
    always #1 clk = ~clk;

	// start simulation
	initial begin
		$dumpfile("program_tb.vcd");
		$dumpvars(0, PROG_tb);

		#2;

        for (Addr=0; Addr<SIZE-1; Addr=Addr+1)
        begin
            #2;
        end

		# 10
		$finish;

	end

endmodule
