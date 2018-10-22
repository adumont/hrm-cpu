#.SILENT:

include ../Boards.mk

RED      = \033[0;31m
GREEN    = \033[0;32m
YELLOW   = \033[0;33m
BLUE     = \033[0;34m
NO_COLOR = \033[m

.DEFAULT_GOAL := all

# find all subdirectories with any tests to run
SUBDIRS = $(sort $(dir $(wildcard */*.in)))

test clean all: $(SUBDIRS)
clean: hwclean

# build bitstream for board, for all levels
LEVELS := $(patsubst %/,%, $(sort $(dir $(wildcard */*.in))))

LEVELS_HWBIN := $(addsuffix .hwbin, $(LEVELS))

hwbin: $(LEVELS_HWBIN)

%.hwbin:
	@printf "\n%b\n" "$(BLUE)Synthesizing bitstream for BOARD=$(YELLOW)$(BOARD)$(BLUE) LEVEL=$(YELLOW)$*$(NO_COLOR)\n"
	$(MAKE) -C ../ BOARD=$(BOARD) LEVEL=$* bin

###
hwtest:
	$(MAKE) BOARD=$(BOARD) -f hwtests.mk test

hwclean: $(addsuffix .hwclean, $(LEVELS))

%.hwclean:
	$(MAKE) -C ../ BOARD=$(BOARD) LEVEL=$* clean
	rm -f $*/*.hwcheck $*/*.hwtest_out

$(SUBDIRS):
	$(MAKE) BOARD=$(BOARD) -C $@ -f ../tester.mk $(MAKECMDGOALS)

.PHONY : test clean all $(SUBDIRS) %.hwtest .force %.clean
