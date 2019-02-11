PROJECT:=hrmcpu

RTL_DIR:=../verilog
GUI_DIR:=.

-include $(RTL_DIR)/Design.mk

RTL_DEPS := $(addprefix $(RTL_DIR)/, $(DEPS))

.DEFAULT_GOAL := $(PROJECT)

VOBJS := $(RTL_DIR)/obj_dir/verilated.o  $(RTL_DIR)/obj_dir/V$(PROJECT)__ALLcls.o  $(RTL_DIR)/obj_dir/V$(PROJECT)__ALLsup.o

$(PROJECT): $(PROJECT).mk $(VOBJS) .FORCE
	cd $(GUI_DIR) && make -f $(PROJECT).mk

$(VOBJS): $(RTL_DIR)/$(PROJECT).v $(RTL_DEPS)
	cd $(RTL_DIR) && verilator --public -cc $(PROJECT).v
	make -C $(RTL_DIR)/obj_dir/ -f V$(PROJECT).mk V$(PROJECT)__ALL.a verilated.o

$(PROJECT).mk: $(PROJECT).pro
	qmake $(PROJECT).pro -r -spec linux-g++-64 -o $(PROJECT).mk

vclean:
	cd $(RTL_DIR) && rm -rf obj_dir/

qtclean:
	cd $(GUI_DIR) && rm -f hrmcpu.mk hrmcpu *.o moc_*.cpp moc_*.h qrc_*.cpp ui_*.h

clean: vclean qtclean

.PHONY: clean .FORCE qtclean vclean

