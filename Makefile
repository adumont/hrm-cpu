TARGETDIR:=~/toolchain
SOURCEDIR:=~/src

test: 
	grep . $(TARGETDIR)/*.ver
	$(MAKE) -C verilog test
	$(MAKE) -C verilog/test BOARD=alhambra  hwbin
	$(MAKE) -C verilog/test BOARD=ice40hx8k hwbin

clean:
	$(MAKE) -C verilog clean
	$(MAKE) -C verilog/test BOARD=alhambra  clean
	$(MAKE) -C verilog/test BOARD=ice40hx8k clean

GIT_ICEST:=https://github.com/cliffordwolf/icestorm.git
GIT_YOSYS:=https://github.com/cliffordwolf/yosys.git
GIT_ARACH:=https://github.com/cseed/arachne-pnr.git

VER_ICEST:=$(TARGETDIR)/icestorm.ver
VER_YOSYS:=$(TARGETDIR)/yosys.ver
VER_ARACH:=$(TARGETDIR)/arachne-pnr.ver

check_latest:
	[ -e $(VER_ICEST) ] && ( git ls-remote --heads $(GIT_ICEST) refs/heads/master | cut -f1 | cmp $(VER_ICEST) - || rm -f $(VER_ICEST) ) || true
	[ -e $(VER_YOSYS) ] && ( git ls-remote --heads $(GIT_YOSYS) refs/heads/master | cut -f1 | cmp $(VER_YOSYS) - || rm -f $(VER_YOSYS) ) || true
	[ -e $(VER_ARACH) ] && ( git ls-remote --heads $(GIT_ARACH) refs/heads/master | cut -f1 | cmp $(VER_ARACH) - || rm -f $(VER_ARACH) ) || true

ci-deps: $(VER_ICEST) $(VER_YOSYS) $(VER_ARACH)

$(VER_ICEST):
	mkdir -p $(SOURCEDIR); cd $(SOURCEDIR) && \
	( [ -e icestorm ] || git clone $(GIT_ICEST) ) && \
	cd icestorm && \
	git pull && \
	git log -1 && \
	nice make DESTDIR=$(TARGETDIR) PREFIX= install && \
	git rev-parse HEAD > $(VER_ICEST)

$(VER_YOSYS):
	mkdir -p $(SOURCEDIR); cd $(SOURCEDIR) && \
	( [ -e yosys ] || git clone $(GIT_YOSYS) ) && \
	cd yosys && \
	git pull && \
	git log -1 && \
	nice make PREFIX=$(TARGETDIR) install && \
	git rev-parse HEAD > $(VER_YOSYS)

$(VER_ARACH):
	mkdir -p $(SOURCEDIR); cd $(SOURCEDIR) && \
	( [ -e arachne-pnr ] || git clone $(GIT_ARACH) ) && \
	cd arachne-pnr && \
	git pull && \
	git log -1 && \
	nice make PREFIX=$(TARGETDIR) install && \
	git rev-parse HEAD > $(VER_ARACH)

.PHONY: test clean ci-deps check_latest
