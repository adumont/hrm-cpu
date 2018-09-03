BOARD?=alhambra

ifeq ($(BOARD), alhambra)

  PNRDEV:=1k

else ifeq ($(BOARD), ice40hx8k)

  PNRDEV:=8k

endif