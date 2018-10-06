ci-deps: apio icestorm

apio: ~/.local/bin/apio
icestorm: ~/.apio/packages/toolchain-icestorm/bin

~/.apio/packages/toolchain-icestorm/bin:
	~/.local/bin/apio install icestorm
	
~/.local/bin/apio:
	pip3 install --user -U apio

test: 
	$(MAKE) -C verilog/test BOARD=alhambra  hwbin
	$(MAKE) -C verilog test
	$(MAKE) -C verilog/test BOARD=ice40hx8k hwbin

clean:
	$(MAKE) -C verilog clean
	$(MAKE) -C verilog/test BOARD=alhambra  clean
	$(MAKE) -C verilog/test BOARD=ice40hx8k clean

.PHONY: test deps
