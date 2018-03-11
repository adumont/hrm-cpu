module controlUnit_tb();

	reg [3: 0] instr;

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
	controlUnit controlUnit0 (instr, muxR, wR, muxM, wM, aluCtl, branch, ijump, rIn, wO);

	// start simulation
	initial begin
		$dumpfile("controlUnit_tb.vcd");
		$dumpvars(0, controlUnit_tb);

		#5

        for (instr=0; instr<=14; instr=instr+1)
        begin
            #5
            $display("instr: %b (%2d), %b", instr, instr, muxR);
        end

		# 10
		$finish;

	end

endmodule

