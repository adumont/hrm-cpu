ci-deps: apio icestorm

apio: ~/.local/bin/apio
icestorm: ~/.apio/packages/toolchain-icestorm/bin

~/.apio/packages/toolchain-icestorm/bin:
	~/.local/bin/apio install icestorm
	
~/.local/bin/apio:
	pip3 install --user -U apio

test: 
	$(MAKE) -C verilog $@

.PHONY: test deps
