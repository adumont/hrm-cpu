test: 
	$(MAKE) -C verilog test
	$(MAKE) -C verilog/test BOARD=alhambra  hwbin
	$(MAKE) -C verilog/test BOARD=ice40hx8k hwbin

clean:
	$(MAKE) -C verilog clean
	$(MAKE) -C verilog/test BOARD=alhambra  clean
	$(MAKE) -C verilog/test BOARD=ice40hx8k clean

PREFIX:=~/toolchain

GIT_ICEST:=https://github.com/cliffordwolf/icestorm.git
GIT_YOSYS:=https://github.com/cliffordwolf/yosys.git
GIT_ARACH:=https://github.com/cseed/arachne-pnr.git

VER_ICEST:=$(PREFIX)/icestorm.ver
VER_YOSYS:=$(PREFIX)/yosys.ver
VER_ARACH:=$(PREFIX)/arachne-pnr.ver

check_latest:
	[ -e $(VER_ICEST) ] && ( git ls-remote --heads $(GIT_ICEST) refs/heads/master | cut -f1 | cmp $(VER_ICEST) - || rm -f $(VER_ICEST) ) || true
	[ -e $(VER_YOSYS) ] && ( git ls-remote --heads $(GIT_YOSYS) refs/heads/master | cut -f1 | cmp $(VER_YOSYS) - || rm -f $(VER_YOSYS) ) || true
	[ -e $(VER_ARACH) ] && ( git ls-remote --heads $(GIT_ARACH) refs/heads/master | cut -f1 | cmp $(VER_ARACH) - || rm -f $(VER_ARACH) ) || true

ci-deps: $(VER_ICEST) $(VER_YOSYS) $(VER_ARACH)

$(VER_ICEST):
	cd && \
	rm -rf icestorm && \
	git clone $(GIT_ICEST) && \
	cd icestorm && \
	git log -1 && \
	nice make DESTDIR=~/toolchain PREFIX= install && \
	git rev-parse HEAD > $(VER_ICEST) && \
	cd .. && \
	rm -rf icestorm

$(VER_YOSYS):
	cd && \
	rm -rf yosys && \
	git clone $(GIT_YOSYS) && \
	cd yosys && \
	git log -1 && \
	nice make PREFIX=$(PREFIX) install && \
	git rev-parse HEAD > $(VER_YOSYS) && \
	cd .. && \
	rm -rf yosys

$(VER_ARACH):
	cd && \
	rm -rf arachne-pnr && \
	git clone $(GIT_ARACH) && \
	cd arachne-pnr && \
	git log -1 && \
	nice make PREFIX=~/toolchain install && \
	git rev-parse HEAD > $(VER_ARACH) && \
	cd .. && \
	rm -rf arachne-pnr

.PHONY: test clean ci-deps check_latest