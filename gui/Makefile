PROJECT:=hrmcpu

RTL_DIR:=../verilog
GUI_DIR:=.

-include $(RTL_DIR)/Design.mk

RTL_DEPS := $(addprefix $(RTL_DIR)/, $(DEPS))

.DEFAULT_GOAL := $(PROJECT)

VLIBS := verilated.o verilated_save.o verilated_vcd_c.o
VOBJS := $(addprefix $(RTL_DIR)/obj_dir/, $(VLIBS) V$(PROJECT)__ALLcls.o V$(PROJECT)__ALLsup.o )

verilator: $(VOBJS)

$(PROJECT): $(PROJECT).mk $(VOBJS) .FORCE
	cd $(GUI_DIR) && make -f $(PROJECT).mk

$(VOBJS): $(RTL_DIR)/$(PROJECT).v $(RTL_DEPS)
	cd $(RTL_DIR) && verilator --savable --trace --trace-max-array 256 --public -cc $(PROJECT).v
	make -C $(RTL_DIR)/obj_dir/ -f V$(PROJECT).mk V$(PROJECT)__ALL.a $(VLIBS)

$(PROJECT).mk: $(PROJECT).pro
	cd $(GUI_DIR) && qmake $(PROJECT).pro -r -spec linux-g++-64 -o $(PROJECT).mk

vclean:
	cd $(RTL_DIR) && rm -rf obj_dir/

qtclean:
	cd $(GUI_DIR) && rm -f hrmcpu.mk hrmcpu *.o moc_*.cpp moc_*.h qrc_*.cpp ui_*.h

clean: vclean qtclean

run: $(PROJECT)
	./hrmcpu

.PHONY: clean .FORCE qtclean vclean verilator
