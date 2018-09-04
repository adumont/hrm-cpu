changequote([,])dnl
`define PROGRAM "_PROGRAM_"
`define ROMFILE "_ROMFILE_"
ifdef([_BOARD_HAVE_BUTTONS_], `define BOARD_HAVE_BUTTONS
)dnl
`include "top.v"
