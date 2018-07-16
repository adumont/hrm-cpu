#.SILENT:

.DEFAULT_GOAL := all

MAKEFLAGS += -j 1

# find all subdirectories with any tests to run
LEVELS := $(patsubst %/,%, $(sort $(dir $(wildcard */*.in))))

LEVELS_HWTEST := $(addsuffix .hwtest, $(LEVELS))

test clean all: $(LEVELS_HWTEST)

%.hwtest: ../builddir/%/top.bin
	@ # seems to need something, or it will fail with "No rule to make target"
	@ # @: is "do nothing, and don't print it.. aka noop"
	@ :
	$(MAKE) -C $* -f ../hwtester.mk


# with .force we force a rebuild (we'll launche theç
# $(MAKE), that will decide if it needs to build anything or not)
../builddir/%/top.bin: .force
	$(MAKE) -C .. LEVEL=$* bin

.PHONY : test clean all $(LEVELS) %.hwtest .force