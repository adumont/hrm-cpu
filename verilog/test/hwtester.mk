include ../../Design.mk

SERIAL?=/dev/ttyUSB1

#SOURCES:=hrmcpu.v ufifo.v ALU.v MEMORY.v register.v IR.v program.v PC.v ControlUnit.v ram.v test/tester.v
SOURCES:= $(DEPS_HRMCPU) hrmcpu.v test/tester.v

AUXFILE:=

.DEFAULT_GOAL := all

#.SILENT:

# only run 1 test at a time on HW
#.NOTPARALLEL
MAKEFLAGS += -j 1

# Add ../ to list of dependency files:
SRCFILEPATH:=$(addprefix ../../, $(SOURCES))

# Directory name we are in now...
LEVEL_DIR := $(strip $(notdir $(patsubst %/,%,$(CURDIR))))

-include $(LEVEL_DIR).mk

RED      = \033[0;31m
GREEN    = \033[0;32m
YELLOW   = \033[0;33m
BLUE     = \033[0;34m
NO_COLOR = \033[m

all-tests := $(addsuffix .hwcheck, $(basename $(wildcard *.in)))

.PHONY : test all

test : $(all-tests)

# Do not remove these files at the end
#.PRECIOUS: %.ivl %.hwtest_out 

%.hwcheck : %.out %.in $(AUXFILE) $(SRCFILEPATH)
	@printf "\n%b\n" "$(BLUE)Programming FPGA with $(LEVEL_DIR)$(NO_COLOR)\n"
	$(MAKE) -C ../../ LEVEL=$(LEVEL_DIR) upload
	@printf "\n%b\n" "$(BLUE)Running test $(LEVEL_DIR)/$*$(NO_COLOR)\n"
	../run1hwtest.py -p $(SERIAL) -i $*.in -o $*.out && \
	( touch $*.hwcheck; printf "\n%b\n" "$(GREEN)$(LEVEL_DIR): HW Test [$*] OK$(NO_COLOR)\n" ) || \
	( printf "\n%b\n" "$(RED)$(LEVEL_DIR): HW Test [$*] FAILED$(NO_COLOR)\n" ; false )

all : test 
	@printf "\n%b\n" "$(GREEN)$(LEVEL_DIR): Success, all HW tests passed$(NO_COLOR)\n"

clean :
	-rm -f *.hwcheck *.hwtest_out
