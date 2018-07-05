# call with make MODULE=moduleName sim|svg|upload

TOP:=top

MODULE?=$(TOP)

DEPS_MEMORY:=\
  ram.v

DEPS_HRMCPU:=\
  ufifo.v \
  ALU.v \
  MEMORY.v \
  $(DEPS_MEMORY) \
  register.v \
  IR.v \
  program.v \
  PC.v \
  ControlUnit.v

DEPS_TOP:=\
  hrmcpu.v \
  $(DEPS_HRMCPU) \
  debouncer.v \
  rxuartlite.v \
  txuartlite.v

ifeq ($(MODULE), $(TOP))
  DEPS:=$(DEPS_TOP)


else ifeq ($(MODULE), MEMORY)

  DEPS:=$(DEPS_MEMORY)

else ifeq ($(MODULE), hrmcpu)

  DEPS:=$(DEPS_HRMCPU)

endif

IVERILOG_MACRO=

ifdef $(PROGRAM)
  IVERILOG_MACRO:=$(IVERILOG_MACRO) -DPROGRAM=\"$(PROGRAM)\"
endif

ifdef $(ROMFILE)
  IVERILOG_MACRO:=$(IVERILOG_MACRO) -DROMFILE=$(ROMFILE)\"
endif

# YOSYSOPT:=-retime -abc2

ifndef $(MEMORY)
	MEMORY="1k"
endif

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

$(MODULE).bin: $(MODULE).pcf $(MODULE).v $(DEPS)
	
	yosys -p "synth_ice40 -top $(MODULE) -blif $(MODULE).blif $(YOSYSOPT)" \
              -l $(MODULE).log -q $(MODULE).v $(DEPS)  
	
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

clean:

	rm -f *.bin *.pnr *.blif *.out *.vcd *~

.PHONY: all clean json svg sim dot
