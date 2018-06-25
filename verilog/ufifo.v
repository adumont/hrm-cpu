////////////////////////////////////////////////////////////////////////////////
//
// Filename: 	ufifo.v
//
// Project:	wbuart32, a full featured UART with simulator
//
// Purpose:	A synchronous data FIFO, designed for supporting the Wishbone
//		UART.  Particular features include the ability to read and
//	write on the same clock, while maintaining the correct output FIFO
//	parameters.  Two versions of the FIFO exist within this file, separated
//	by the RXFIFO parameter's value.  One, where RXFIFO = 1, produces status
//	values appropriate for reading and checking a read FIFO from logic,
//	whereas the RXFIFO = 0 applies to writing to the FIFO from bus logic
//	and reading it automatically any time the transmit UART is idle.
//
// Creator:	Dan Gisselquist, Ph.D.
//		Gisselquist Technology, LLC
//
////////////////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2015-2017, Gisselquist Technology, LLC
//
// This program is free software (firmware): you can redistribute it and/or
// modify it under the terms of  the GNU General Public License as published
// by the Free Software Foundation, either version 3 of the License, or (at
// your option) any later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTIBILITY or
// FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
// for more details.
//
// You should have received a copy of the GNU General Public License along
// with this program.  (It's in the $(ROOT)/doc directory.  Run make with no
// target there if the PDF file isn't present.)  If not, see
// <http://www.gnu.org/licenses/> for a copy.
//
// License:	GPL, v3, as defined and found on www.gnu.org,
//		http://www.gnu.org/licenses/gpl.html
//
//
////////////////////////////////////////////////////////////////////////////////
//
//
`default_nettype	none
//
module ufifo(i_clk, i_rst, i_wr, i_data, o_empty_n, i_rd, o_data, o_status, o_err);
	parameter	BW=8;	// Byte/data width
	parameter [3:0]	LGFLEN=4;
	parameter 	RXFIFO=1'b0;
	input	wire		i_clk, i_rst;
	input	wire		i_wr;
	input	wire [(BW-1):0]	i_data;
	output	wire		o_empty_n;	// True if something is in FIFO
	input	wire		i_rd;
	output	wire [(BW-1):0]	o_data;
	output	wire	[15:0]	o_status;
	output	wire		o_err;

	localparam	FLEN=(1<<LGFLEN);

	reg	[(BW-1):0]	fifo[0:(FLEN-1)];
	reg	[(LGFLEN-1):0]	r_first, r_last, r_next;

	wire	[(LGFLEN-1):0]	w_first_plus_one, w_first_plus_two,
				w_last_plus_one;
	assign	w_first_plus_two = r_first + {{(LGFLEN-2){1'b0}},2'b10};
	assign	w_first_plus_one = r_first + {{(LGFLEN-1){1'b0}},1'b1};
	assign	w_last_plus_one  = r_next; // r_last  + 1'b1;

	reg	will_overflow;
	initial	will_overflow = 1'b0;
	always @(posedge i_clk)
		if (i_rst)
			will_overflow <= 1'b0;
		else if (i_rd)
			will_overflow <= (will_overflow)&&(i_wr);
		else if (i_wr)
			will_overflow <= (will_overflow)||(w_first_plus_two == r_last);
		else if (w_first_plus_one == r_last)
			will_overflow <= 1'b1;

	// Write
	reg	r_ovfl;
	initial	r_first = 0;
	initial	r_ovfl  = 0;
	always @(posedge i_clk)
		if (i_rst)
		begin
			r_ovfl <= 1'b0;
			r_first <= { (LGFLEN){1'b0} };
		end else if (i_wr)
		begin // Cowardly refuse to overflow
			if ((i_rd)||(!will_overflow)) // (r_first+1 != r_last)
				r_first <= w_first_plus_one;
			else
				r_ovfl <= 1'b1;
		end
	always @(posedge i_clk)
		if (i_wr) // Write our new value regardless--on overflow or not
			fifo[r_first] <= i_data;

	// Reads
	//	Following a read, the next sample will be available on the
	//	next clock
	//	Clock	ReadCMD	ReadAddr	Output
	//	0	0	0		fifo[0]
	//	1	1	0		fifo[0]
	//	2	0	1		fifo[1]
	//	3	0	1		fifo[1]
	//	4	1	1		fifo[1]
	//	5	1	2		fifo[2]
	//	6	0	3		fifo[3]
	//	7	0	3		fifo[3]
	reg	will_underflow;
	initial	will_underflow = 1'b1;
	always @(posedge i_clk)
		if (i_rst)
			will_underflow <= 1'b1;
		else if (i_wr)
			will_underflow <= 1'b0;
		else if (i_rd)
			will_underflow <= (will_underflow)||(w_last_plus_one == r_first);
		else
			will_underflow <= (r_last == r_first);

	//
	// Don't report FIFO underflow errors.  These'll be caught elsewhere
	// in the system, and the logic below makes it hard to reset them.
	// We'll still report FIFO overflow, however.
	//
	// reg		r_unfl;
	// initial	r_unfl = 1'b0;
	initial	r_last = 0;
	initial	r_next = { {(LGFLEN-1){1'b0}}, 1'b1 };
	always @(posedge i_clk)
		if (i_rst)
		begin
			r_last <= 0;
			r_next <= { {(LGFLEN-1){1'b0}}, 1'b1 };
			// r_unfl <= 1'b0;
		end else if (i_rd)
		begin
			if (!will_underflow) // (r_first != r_last)
			begin
				r_last <= r_next;
				r_next <= r_last +{{(LGFLEN-2){1'b0}},2'b10};
				// Last chases first
				// Need to be prepared for a possible two
				// reads in quick succession
				// o_data <= fifo[r_last+1];
			end
			// else r_unfl <= 1'b1;
		end

	reg	[(BW-1):0]	fifo_here, fifo_next, r_data;
	always @(posedge i_clk)
		fifo_here <= fifo[r_last];
	always @(posedge i_clk)
		fifo_next <= fifo[r_next];
	always @(posedge i_clk)
		r_data <= i_data;

	reg	[1:0]	osrc;
	always @(posedge i_clk)
		if (will_underflow)
			// o_data <= i_data;
			osrc <= 2'b00;
		else if ((i_rd)&&(r_first == w_last_plus_one))
			osrc <= 2'b01;
		else if (i_rd)
			osrc <= 2'b11;
		else
			osrc <= 2'b10;
	assign o_data = (osrc[1]) ? ((osrc[0])?fifo_next:fifo_here) : r_data;

	// wire	[(LGFLEN-1):0]	current_fill;
	// assign	current_fill = (r_first-r_last);

	reg	r_empty_n;
	initial	r_empty_n = 1'b0;
	always @(posedge i_clk)
		if (i_rst)
			r_empty_n <= 1'b0;
		else casez({i_wr, i_rd, will_underflow})
			3'b00?: r_empty_n <= (r_first != r_last);
			3'b010: r_empty_n <= (r_first != w_last_plus_one);
			3'b10?: r_empty_n <= 1'b1;
			3'b110: r_empty_n <= (r_first != r_last);
			3'b111: r_empty_n <= 1'b1;
			default: begin end
		endcase

	wire	w_full_n;
	assign	w_full_n = will_overflow;

	//
	// If this is a receive FIFO, the FIFO count that matters is the number
	// of values yet to be read.  If instead this is a transmit FIFO, then 
	// the FIFO count that matters is the number of empty positions that
	// can still be filled before the FIFO is full.
	//
	// Adjust for these differences here.
	reg	[(LGFLEN-1):0]	r_fill;
	generate
	if (RXFIFO != 0)
		initial	r_fill = 0;
	else
		initial	r_fill = -1;
	endgenerate

	always @(posedge i_clk)
		if (RXFIFO!=0) begin
			// Calculate the number of elements in our FIFO
			//
			// Although used for receive, this is actually the more
			// generic answer--should you wish to use the FIFO in
			// another context.
			if (i_rst)
				r_fill <= 0;
			else casez({(i_wr), (!will_overflow), (i_rd)&&(!will_underflow)})
			3'b0?1:   r_fill <= r_first - r_next;
			3'b110:   r_fill <= r_first - r_last + 1'b1;
			3'b1?1:   r_fill <= r_first - r_last;
			default: r_fill <= r_first - r_last;
			endcase
		end else begin
			// Calculate the number of elements that are empty and
			// can be filled within our FIFO.  Hence, this is really
			// not the fill, but (SIZE-1)-fill.
			if (i_rst)
				r_fill <= { (LGFLEN){1'b1} };
			else casez({i_wr, (!will_overflow), (i_rd)&&(!will_underflow)})
			3'b0?1:   r_fill <= r_fill + 1'b1;
			3'b110:   r_fill <= r_fill - 1'b1;
			default: r_fill  <= r_fill;
			endcase
		end

	// We don't report underflow errors.  These
	assign o_err = (r_ovfl); //  || (r_unfl);

	wire	[3:0]	lglen;
	assign lglen = LGFLEN;

	wire	w_half_full;
	wire	[9:0]	w_fill;
	assign	w_fill[(LGFLEN-1):0] = r_fill;
	generate if (LGFLEN < 10)
		assign w_fill[9:(LGFLEN)] = 0;
	endgenerate

	assign	w_half_full = r_fill[(LGFLEN-1)];

	assign	o_status = {
		// Our status includes a 4'bit nibble telling anyone reading
		// this the size of our FIFO.  The size is then given by
		// 2^(this value).  Hence a 4'h4 in this position means that the
		// FIFO has 2^4 or 16 values within it.
		lglen,
		// The FIFO fill--for a receive FIFO the number of elements
		// left to be read, and for a transmit FIFO the number of
		// empty elements within the FIFO that can yet be filled.
		w_fill,
		// A '1' here means a half FIFO length can be read (receive
		// FIFO) or written to (not a receive FIFO).
		// receive FIFO), or be written to (if it isn't).
		(RXFIFO!=0)?w_half_full:w_half_full,
		// A '1' here means the FIFO can be read from (if it is a
		// receive FIFO), or be written to (if it isn't).
		(RXFIFO!=0)?r_empty_n:w_full_n
	};

	assign	o_empty_n = r_empty_n;

//
//
//
// FORMAL METHODS
//
//
//
`ifdef	FORMAL

`ifdef	UFIFO
`define	ASSUME	assume
`else
`define	ASSUME	assert
`endif

//
// Assumptions about our input(s)
//
//
	reg	f_past_valid, f_last_clk;

	initial restrict(i_rst);

	always @($global_clock)
	begin
		restrict(i_clk == !f_last_clk);
		f_last_clk <= i_clk;
		if (!$rose(i_clk))
		begin
			`ASSUME($stable(i_rst));
			`ASSUME($stable(i_wr));
			`ASSUME($stable(i_data));
			`ASSUME($stable(i_rd));
		end
	end

	//
	// Underflows are a very real possibility, should the user wish to
	// read from this FIFO while it is empty.  Our parent module will need
	// to deal with this.
	//
	// always @(posedge i_clk)
	//	`ASSUME((!will_underflow)||(!i_rd)||(i_rst));
//
// Assertions about our outputs
//
//

	initial	f_past_valid = 1'b0;
	always @(posedge i_clk)
		f_past_valid <= 1'b1;

	wire	[(LGFLEN-1):0]	f_fill, f_next, f_empty;
	assign	f_fill = r_first - r_last;
	assign	f_empty = {(LGFLEN){1'b1}} -f_fill;
	assign	f_next = r_last + 1'b1;
	always @(posedge i_clk)
	begin
		if (RXFIFO)
			assert(f_fill == r_fill);
		else
			assert(f_empty== r_fill);
		if (f_fill == 0)
		begin
			assert(will_underflow);
			assert(!o_empty_n);
		end else begin
			assert(!will_underflow);
			assert(o_empty_n);
		end

		if (f_fill == {(LGFLEN){1'b1}})
			assert(will_overflow);
		else
			assert(!will_overflow);

		assert(r_next == f_next);
	end

	always @(posedge i_clk)
	if (f_past_valid)
	begin
		if ($past(i_rst))
			assert(!o_err);
		else begin
			// No underflow detection in this core
			//
			// if (($past(i_rd))&&($past(r_fill == 0)))
			//	assert(o_err);
			//
			// We do, though, have overflow detection
			if (($past(i_wr))&&(!$past(i_rd))
					&&($past(will_overflow)))
				assert(o_err);
		end
	end

`endif
endmodule
