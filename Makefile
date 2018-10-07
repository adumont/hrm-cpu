test: 
	$(MAKE) -C verilog test
	$(MAKE) -C verilog/test BOARD=alhambra  hwbin
	$(MAKE) -C verilog/test BOARD=ice40hx8k hwbin

clean:
	$(MAKE) -C verilog clean
	$(MAKE) -C verilog/test BOARD=alhambra  clean
	$(MAKE) -C verilog/test BOARD=ice40hx8k clean

PREFIX:=~/toolchain

ci-deps: icestorm yosys arachne-pnr

icestorm: $(PREFIX)/icestorm.ok

$(PREFIX)/icestorm.ok:
	cd && \
	rm -rf icestorm && \
	git clone https://github.com/cliffordwolf/icestorm.git icestorm && \
	cd icestorm && \
	nice make -j$(nproc) DESTDIR=~/toolchain PREFIX= install && \
	touch $(PREFIX)/icestorm.ok && \
	cd .. && \
	rm -rf icestorm

yosys: $(PREFIX)/yosys.ok

$(PREFIX)/yosys.ok:
	cd && \
	rm -rf yosys && \
	git clone https://github.com/cliffordwolf/yosys.git yosys && \
	cd yosys && \
	nice make -j$(nproc) PREFIX=$(PREFIX) install && touch $(PREFIX)/yosys.ok && \
	cd .. && \
	rm -rf yosys

arachne-pnr: $(PREFIX)/arachne-pnr.ok

$(PREFIX)/arachne-pnr.ok:
	cd && \
	rm -rf arachne-pnr && \
	git clone https://github.com/cseed/arachne-pnr.git arachne-pnr && \
	cd arachne-pnr && \
	nice make -j$(nproc) PREFIX=~/toolchain install && \
	touch $(PREFIX)/arachne-pnr.ok && \
	cd .. && \
	rm -rf arachne-pnr

.PHONY: test clean ci-deps icestorm yosys arachne-pnr
