# call with make MODULE=moduleName sim|svg|upload

include Design.mk

all: bin svg dot sim

bin: $(MODULE).bin
vcd: $(MODULE)_tb.vcd
sim: vcd gtkwave
json: $(MODULE).json
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

$(MODULE).bin: $(MODULE).pcf $(MODULE).v $(DEPS) $(AUXFILES) build.config
	
	yosys -p "synth_ice40 -top $(MODULE) -blif $(MODULE).blif $(YOSYSOPT)" \
              -l $(MODULE).log -q $(DEPS) $(MODULE).v
	
	arachne-pnr -d $(MEMORY) -p $(MODULE).pcf $(MODULE).blif -o $(MODULE).pnr
	
	icepack $(MODULE).pnr $(MODULE).bin

$(MODULE).json: $(MODULE).v $(DEPS)

	yosys -p "prep -top $(MODULE); write_json $(MODULE).json" $(MODULE).v $(DEPS)

assets/$(MODULE).svg: $(MODULE).json

	netlistsvg $(MODULE).json -o assets/$(MODULE).svg && rm $(MODULE).json

assets/$(MODULE)_dot.svg: $(MODULE).v $(DEPS)

	yosys -p "read_verilog $(MODULE).v $(DEPS); hierarchy -check; proc; opt; fsm; opt; memory; opt; clean; stat; show -colors 1 -format svg -stretch -prefix $(MODULE)_dot $(MODULE);"
	mv $(MODULE)_dot.svg assets/
	[ -f $(MODULE)_dot.dot ] && rm $(MODULE)_dot.dot

upload: $(MODULE).bin
	iceprog $(MODULE).bin

# We save AUXFILES names to build.config. Force a rebuild if they have changed
build.config: $(AUXFILES) .force
	@echo '$(AUXFILES)' | cmp -s - $@ || echo '$(AUXFILES)' > $@

top_wrapper.v: top_wrapper.m4 build.config
	m4 $(M4_OPTIONS) top_wrapper.m4 > top_wrapper.v

clean:

	rm -f *.bin *.pnr *.blif *.out *.vcd *~ top_wrapper.v build.config

.PHONY: all clean json svg bin sim dot .force
 