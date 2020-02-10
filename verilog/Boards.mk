BOARD?=alhambra

ifeq ($(BOARD), alhambra)

  PNRDEV:=1k
  PNRPACK:=tq144
  M4_OPTIONS += -D_BOARD_HAVE_BUTTONS_

else ifeq ($(BOARD), ice40hx8k)

  PNRDEV:=8k
  PNRPACK:=ct256

endif