SOURCES:=hrmcpu.v ufifo.v ALU.v MEMORY.v register.v IR.v program.v PC.v ControlUnit.v ram.v test/tester.v

AUXFILE:=program ram

.DEFAULT_GOAL := all

MAKEFLAGS += -j 8

# Add ../ to list of dependency files:
SRCFILEPATH:=$(addprefix ../../, $(SOURCES))

LEVEL_DIR := $(strip $(notdir $(patsubst %/,%,$(CURDIR))))

help:
	@printf "%b" "$(COM_COLOR)$(COM_STRING) $(OBJ_COLOR)$(@)$(NO_COLOR)\n";

# Regular Colors
Black=\033[30m        # Black
Red=\033[31m          # Red
Green="\033[0;32m"        # Green
Yellow=\033[33m       # Yellow
Blue=\033[34m         # Blue
Purple=\033[35m       # Purple
Cyan=\033[36m         # Cyan
White=\033[37m        # White
# Reset
Color_Off=\033[0m       # Text Reset

# COM_COLOR   = \033[0;34m
# OBJ_COLOR   = \033[0;36m
RED         = \033[0;31m
GREEN       = \033[0;32m
YELLOW      = \033[0;33m
NO_COLOR    = \033[m
BLUE        = \033[0;34m

all-tests := $(addsuffix .check, $(basename $(wildcard *.in)))

.PHONY : test all #%.test_out %.ivl %.check

test : $(all-tests)

# Do not remove these files at the end
#.PRECIOUS: %.ivl %.test 

%.ivl : $(SRCFILEPATH) $(AUXFILE)
	iverilog $(SRCFILEPATH) -DPROGRAM=\"program\" -DROMFILE=\"ram\" -DINBFILE=\"$*.in\" -o $*.ivl

%.test_out : %.in %.ivl
	./$*.ivl > $@

%.check : %.test_out %.out
	grep OUTPUT: $*.test_out | awk '{ print $$3 }' | diff -q $*.out - >/dev/null && \
	( touch $*.check; printf "%b" "$(GREEN)$(LEVEL_DIR): Test [$*] OK$(NO_COLOR)\n" ) || \
	( printf "%b" "$(RED)$(LEVEL_DIR): Test [$*] FAILED$(NO_COLOR)\n" ; false )

all : test 
	@printf "%b" "$(GREEN)$(LEVEL_DIR): Success, all tests passed$(NO_COLOR)\n"

clean :
	rm *.ivl *.test *.check || true