# call with make MODULE=moduleName sim|svg|upload

include Design.mk

BUILDDIR?=builddir/

all: bin svg dot sim

bin: $(BUILDDIR)$(MODULE).bin
vcd: $(MODULE)_tb.vcd
sim: vcd gtkwave
json: $(BUILDDIR)$(MODULE).json
svg: assets/$(MODULE).svg
dot: assets/$(MODULE)_dot.svg

# @echo '@: $@' # file name of the target
# @echo '%: $%' # name of the archive member
# @echo '<: $<' # name of the first prerequisite
# @echo '?: $?' # names of all prerequisites newer than the target
# @echo '^: $^' # names of all prerequisites
# @echo '|: $|' # names of all the order-only prerequisites
# @echo '*: $*' # stem with which an implicit rule matches
# @echo $(word 2, $?) 2nd word names of all prerequisites 

$(MODULE)_tb.vcd: $(MODULE).v $(DEPS) $(MODULE)_tb.v

	iverilog $^ $(IVERILOG_MACRO) -o $(MODULE)_tb.out
	./$(MODULE)_tb.out

gtkwave: $(MODULE).v $(DEPS) $(MODULE)_tb.v $(MODULE)_tb.vcd

	gtkwave $(MODULE)_tb.vcd $(MODULE)_tb.gtkw &

$(BUILDDIR)$(MODULE).bin: $(MODULE).pcf $(MODULE).v $(DEPS) $(AUXFILES) $(BUILDDIR)build.config
	
	yosys -p "synth_ice40 -top $(MODULE) -blif $(BUILDDIR)$(MODULE).blif $(YOSYSOPT)" \
              -l $(BUILDDIR)$(MODULE).log -q $(DEPS) $(MODULE).v
	
	arachne-pnr -d $(MEMORY) -p $(MODULE).pcf $(BUILDDIR)$(MODULE).blif -o $(BUILDDIR)$(MODULE).pnr
	
	icepack $(BUILDDIR)$(MODULE).pnr $(BUILDDIR)$(MODULE).bin

$(BUILDDIR)$(MODULE).json: $(MODULE).v $(DEPS)

	yosys -p "prep -top $(MODULE); write_json $(MODULE).json" $(MODULE).v $(DEPS)

assets/$(MODULE).svg: $(BUILDDIR)$(MODULE).json

	netlistsvg $(MODULE).json -o assets/$(MODULE).svg && rm $(MODULE).json

assets/$(MODULE)_dot.svg: $(MODULE).v $(DEPS)

	yosys -p "read_verilog $(MODULE).v $(DEPS); hierarchy -check; proc; opt; fsm; opt; memory; opt; clean; stat; show -colors 1 -format svg -stretch -prefix $(MODULE)_dot $(MODULE);"
	mv $(MODULE)_dot.svg assets/
	[ -f $(MODULE)_dot.dot ] && rm $(MODULE)_dot.dot

upload: $(BUILDDIR)$(MODULE).bin
	iceprog $(BUILDDIR)$(MODULE).bin

# We save AUXFILES names to build.config. Force a rebuild if they have changed
$(BUILDDIR)build.config: $(AUXFILES) $(BUILDDIR) .force
	@echo '$(AUXFILES)' | cmp -s - $@ || echo '$(AUXFILES)' > $@

$(BUILDDIR):
	mkdir -p $(BUILDDIR)

$(BUILDDIR)top_wrapper.v: top_wrapper.m4 $(BUILDDIR)build.config
	m4 $(M4_OPTIONS) top_wrapper.m4 > $(BUILDDIR)top_wrapper.v

clean:

	rm -f $(BUILDDIR)$(MODULE).bin
	rm -f $(BUILDDIR)$(MODULE).pnr
	rm -f $(BUILDDIR)$(MODULE).blif
	rm -f $(BUILDDIR)top_wrapper.v
	rm -f $(BUILDDIR)$(MODULE).log
	rm -f $(BUILDDIR)build.config
	rmdir $(BUILDDIR) 2>/dev/null || true
	rm -f *.out *.vcd

.PHONY: all clean json svg bin sim dot .force
 
