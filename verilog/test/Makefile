#.SILENT:

.DEFAULT_GOAL := all

# find all subdirectories with any tests to run
SUBDIRS = $(sort $(dir $(wildcard */*.in)))

test clean all: $(SUBDIRS)
clean: hwclean

hwtest:
	$(MAKE) -f hwtests.mk

hwclean:
	$(MAKE) -f hwtests.mk clean

$(SUBDIRS):
	$(MAKE) -C $@ -f ../tester.mk $(MAKECMDGOALS)

.PHONY : test clean all $(SUBDIRS)
