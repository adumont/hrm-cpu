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
  BUILDDIR:=builddir/$(BOARD)/$(LEVEL)/
  PROGRAM:=test/$(LEVEL)/program
  ROMFILE:=test/$(LEVEL)/ram
endif

AUXFILES=

PROGRAM?=test/Echo/program
M4_OPTIONS += -D_PROGRAM_=$(PROGRAM)
AUXFILES += $(PROGRAM)

ROMFILE?=
M4_OPTIONS += -D_ROMFILE_=$(ROMFILE)
AUXFILES += $(ROMFILE)

IVERILOG_MACRO=
ifdef PROGRAM
  IVERILOG_MACRO:=$(IVERILOG_MACRO) -DPROGRAM=\"$(PROGRAM)\"
endif

ifdef ROMFILE
  IVERILOG_MACRO:=$(IVERILOG_MACRO) -DROMFILE=$(ROMFILE)\"
endif

# YOSYSOPT:=-retime -abc2