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

# shortcut to the test cases in test/,
# call with LEVEL=<levelname> (aka Dir name)
# Will load default program and ram files
ifdef LEVEL
  BUILDDIR:=buildir/$(LEVEL)/
  PROGRAM:=test/$(LEVEL)/program
  ROMFILE:=test/$(LEVEL)/ram
endif

M4_OPTIONS=
AUXFILES=

ifdef PROGRAM
  M4_OPTIONS += -D_PROGRAM_=$(PROGRAM)
  DEPS := $(BUILDDIR)top_wrapper.v $(filter-out top_wrapper.v,$(DEPS)) 
  AUXFILES += $(PROGRAM)
endif

ifdef ROMFILE
  M4_OPTIONS += -D_ROMFILE_=$(ROMFILE)
  DEPS := $(BUILDDIR)top_wrapper.v $(filter-out top_wrapper.v,$(DEPS)) 
  AUXFILES += $(ROMFILE)
endif

IVERILOG_MACRO=
ifdef PROGRAM
  IVERILOG_MACRO:=$(IVERILOG_MACRO) -DPROGRAM=\"$(PROGRAM)\"
endif

ifdef ROMFILE
  IVERILOG_MACRO:=$(IVERILOG_MACRO) -DROMFILE=$(ROMFILE)\"
endif

# YOSYSOPT:=-retime -abc2

ifndef MEMORY
	MEMORY="1k"
endif
