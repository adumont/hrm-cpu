module program_tb();

	reg [11:0] PC;

	wire [ 3:0] OP;
	wire signed [11:0] DATA;

	localparam SIZE=6;

	// Instanciate DUT
	program program0 (.PC(PC), .OP(OP), .DATA(DATA));
	defparam program0.PROGRAM = "program.rom";
	defparam program0.SIZE = SIZE;

	// start simulation
	initial begin
		$dumpfile("program_tb.vcd");
		$dumpvars(0, program_tb);

		#1;

        for (PC=0; PC<=SIZE-1; PC=PC+1)
        begin
            #1;
        end

		# 10
		$finish;

	end

endmodule

