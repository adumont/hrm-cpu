TOP:=top

AUXFILES=

MODULE?=$(TOP)

DEPS_MEM_WRAPPER:=\
  XALU.v\
  LEDS.v\
  ram.v

DEPS_MEMORY:=\
  $(DEPS_MEM_WRAPPER)\
  mem_wrapper.v

DEPS_HRMCPU:=\
  ufifo.v \
  ALU.v \
  MEMORY.v \
  $(DEPS_MEMORY) \
  REG.v \
  IR.v \
  PROG.v \
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

else ifeq ($(MODULE), mem_wrapper)

  DEPS:=$(DEPS_MEM_WRAPPER)

else ifeq ($(MODULE), hrmcpu)

  DEPS:=$(DEPS_HRMCPU)

else ifeq ($(MODULE), ufifo)
  # TODO: should move above (in TOP?)
  # just here temporarily to simulate ufifo_tb.v
  DEPS:=font.v
  AUXFILES += font256x8x8.rom

endif

BOARD_BUILDDIR:=builddir/$(BOARD)
BUILDDIR:=$(BOARD_BUILDDIR)

LEVEL?=Echo

# shortcut to the test cases in test/,
# call with LEVEL=<levelname> (aka Dir name)
# Will load default program and ram files
ifdef LEVEL
  BUILDDIR:=$(BOARD_BUILDDIR)/$(LEVEL)
  ifneq ($(MODULE), none)
    PROGRAM:=test/$(LEVEL)/program
    ROMFILE:=test/$(LEVEL)/ram
  endif
endif

AUXFILES=

PROGRAM?=dummy_prg.hex
#M4_OPTIONS += -D_PROGRAM_=$(PROGRAM)
#AUXFILES += $(PROGRAM)

ROMFILE?=dummy_ram.hex
#M4_OPTIONS += -D_ROMFILE_=$(ROMFILE)
#AUXFILES += $(ROMFILE)

IVERILOG_MACRO=
ifdef PROGRAM
  IVERILOG_MACRO:=$(IVERILOG_MACRO) -DPROGRAM=\"$(PROGRAM)\"
endif

ifdef ROMFILE
  IVERILOG_MACRO:=$(IVERILOG_MACRO) -DROMFILE=\"$(ROMFILE)\"
endif

# YOSYSOPT:=-retime -abc2
