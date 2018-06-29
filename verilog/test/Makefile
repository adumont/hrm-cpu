#.SILENT:

.DEFAULT_GOAL := all

# find all subdirectories with any tests to run
SUBDIRS = $(sort $(dir $(wildcard */*.in)))

test clean all: $(SUBDIRS)

$(SUBDIRS):
	$(MAKE) -C $@ -f ../tester.mk $(MAKECMDGOALS)

.PHONY : test clean all $(SUBDIRS)
