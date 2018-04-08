module controlUnit_tb();

	reg [3: 0] opcode;

	wire [1:0] muxR;
	wire wR;
	wire muxM;
	wire wM;
	wire [2:0] aluCtl;
	wire branch;
	wire ijump;
	wire rIn;
	wire wO;

	// Instanciate DUT
	controlUnit controlUnit0 (opcode, muxR, wR, muxM, wM, aluCtl, branch, ijump, rIn, wO);

	// start simulation
	initial begin
		$dumpfile("controlUnit_tb.vcd");
		$dumpvars(0, controlUnit_tb);

		#5

        for (opcode=0; opcode<=14; opcode=opcode+1)
        begin
            #5
            $display("opcode: %b (%2d), %b", opcode, opcode, muxR);
        end

		# 10
		$finish;

	end

endmodule

