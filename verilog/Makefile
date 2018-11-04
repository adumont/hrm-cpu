# call with make MODULE=moduleName sim|svg|upload

include Boards.mk
include Design.mk

BUILDDIR?=builddir/$(BOARD)

ifeq ($(MODULE), $(TOP))
  DEPS += $(BOARD_BUILDDIR)/top_wrapper.v
endif

all: bin svg dot sim

bin: $(BUILDDIR)/$(MODULE).bin
vcd: $(MODULE)_tb.vcd
sim: vcd gtkwave
json: $(BUILDDIR)/$(MODULE).json
svg: assets/$(MODULE).svg
dot: assets/$(MODULE)_dot.svg
lint: $(BOARD_BUILDDIR)/$(MODULE).lint

# @echo '@: $@' # file name of the target
# @echo '%: $%' # name of the archive member
# @echo '<: $<' # name of the first prerequisite
# @echo '?: $?' # names of all prerequisites newer than the target
# @echo '^: $^' # names of all prerequisites
# @echo '|: $|' # names of all the order-only prerequisites
# @echo '*: $*' # stem with which an implicit rule matches
# @echo $(word 2, $?) 2nd word names of all prerequisites 

PCF:=$(MODULE)-$(BOARD).pcf

$(MODULE)_tb.vcd: $(MODULE).v $(DEPS) $(MODULE)_tb.v

	iverilog $^ $(IVERILOG_MACRO) -o $(MODULE)_tb.out
	./$(MODULE)_tb.out

$(BOARD_BUILDDIR)/$(MODULE).lint: $(MODULE).v $(DEPS)

	verilator --lint-only $(MODULE).v && > $@ || ( rm -f $@; false )

gtkwave: $(MODULE).v $(DEPS) $(MODULE)_tb.v $(MODULE)_tb.vcd

	gtkwave $(MODULE)_tb.vcd $(MODULE)_tb.gtkw &

$(BOARD_BUILDDIR)/$(MODULE).blif: $(MODULE).v $(DEPS) $(AUXFILES) $(BOARD_BUILDDIR)/build.config
	
	yosys -p "synth_ice40 -top $(MODULE) -blif $(BOARD_BUILDDIR)/$(MODULE).blif $(YOSYSOPT)" \
              -l $(BUILDDIR)/$(MODULE).log -q $(DEPS) $(MODULE).v
	
$(BOARD_BUILDDIR)/$(MODULE).pnr: $(PCF) $(BOARD_BUILDDIR)/$(MODULE).blif

	arachne-pnr -d $(PNRDEV) -p $(PCF) $(BOARD_BUILDDIR)/$(MODULE).blif -o $(BOARD_BUILDDIR)/$(MODULE).pnr

#ifdef LEVEL
$(BUILDDIR)/$(MODULE).pnr: $(BOARD_BUILDDIR)/$(MODULE).pnr $(PROGRAM) $(ROMFILE)

	icebram dummy_prg.hex $(PROGRAM) < $(BOARD_BUILDDIR)/$(MODULE).pnr > $(BUILDDIR)/$(MODULE)-tmp.pnr && \
	icebram dummy_ram.hex $(ROMFILE) < $(BUILDDIR)/$(MODULE)-tmp.pnr > $(BUILDDIR)/$(MODULE).pnr && \
	rm $(BUILDDIR)/$(MODULE)-tmp.pnr
#endif

$(BUILDDIR)/$(MODULE).bin: $(BOARD_BUILDDIR)/$(MODULE).lint $(BUILDDIR)/$(MODULE).pnr

	icepack $(BUILDDIR)/$(MODULE).pnr $(BUILDDIR)/$(MODULE).bin

upload: $(BUILDDIR)/$(MODULE).bin

	md5sum $(BUILDDIR)/$(MODULE).bin | cmp $(BOARD_BUILDDIR)/flashed.md5 && \
	( echo "INFO: FPGA $(BOARD) bitstream hasn't changed: Skipping programming and reseting board:" ; iceprog -t ) || \
	( iceprog $(BUILDDIR)/$(MODULE).bin && md5sum $(BUILDDIR)/$(MODULE).bin > $(BOARD_BUILDDIR)/flashed.md5 || rm $(BOARD_BUILDDIR)/flashed.md5 )

$(BUILDDIR)/$(MODULE).json: $(MODULE).v $(DEPS)

	yosys -p "prep -top $(MODULE); write_json $(MODULE).json" $(MODULE).v $(DEPS)

assets/$(MODULE).svg: $(BUILDDIR)/$(MODULE).json

	netlistsvg $(MODULE).json -o assets/$(MODULE).svg && rm $(MODULE).json

assets/$(MODULE)_dot.svg: $(MODULE).v $(DEPS)

	yosys -p "read_verilog $(MODULE).v $(DEPS); hierarchy -check; proc; opt; fsm; opt; memory; opt; clean; stat; show -colors 1 -format svg -stretch -prefix $(MODULE)_dot $(MODULE);"
	mv $(MODULE)_dot.svg assets/
	[ -f $(MODULE)_dot.dot ] && rm $(MODULE)_dot.dot

# We save AUXFILES names to build.config. Force a rebuild if they have changed
$(BOARD_BUILDDIR)/build.config: $(AUXFILES) $(BUILDDIR) .force
	@echo '$(AUXFILES)' | cmp -s - $@ || echo '$(AUXFILES)' > $@

$(BUILDDIR):
	mkdir -p $(BUILDDIR)

$(BOARD_BUILDDIR)/top_wrapper.v: top_wrapper.m4 $(BOARD_BUILDDIR)/build.config
	m4 $(M4_OPTIONS) top_wrapper.m4 > $(BOARD_BUILDDIR)/top_wrapper.v

test:
	$(MAKE) -C test all

clean:
	rm -rf $(BUILDDIR)

.PHONY: all clean json vcd svg bin sim dot .force test upload lint
