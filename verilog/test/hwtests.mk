#.SILENT:

.DEFAULT_GOAL := all

MAKEFLAGS += -j 1

# find all subdirectories with any tests to run
LEVELS := $(patsubst %/,%, $(sort $(dir $(wildcard */*.in))))

LEVELS_HWTEST := $(addsuffix .hwtest, $(LEVELS))

test all: $(LEVELS_HWTEST)

clean: $(addsuffix .clean, $(LEVELS))

RED      = \033[0;31m
GREEN    = \033[0;32m
YELLOW   = \033[0;33m
BLUE     = \033[0;34m
NO_COLOR = \033[m

%.hwtest: ../builddir/%/.top.bin
	@printf "\n%b\n" "$(BLUE)Running tests from Level $* $(NO_COLOR)\n"
	$(MAKE) -C $* -f ../hwtester.mk all

%.clean:
	$(MAKE) -C $* -f ../hwtester.mk clean

# with .force we force a rebuild (we'll launche theç
# $(MAKE), that will decide if it needs to build anything or not)
../builddir/%/.top.bin:
	@printf "\n%b\n" "$(BLUE)Synthesizing bitstream for $* $(NO_COLOR)\n"
	$(MAKE) -C .. LEVEL=$* bin && touch ../builddir/$*/.top.bin

.PHONY : test clean all $(LEVELS) %.hwtest .force %.clean