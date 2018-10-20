#!/bin/bash

( cat /dev/urandom | tr -dc '0-9a-f' | fold -w 2 | head -n 38; echo 00; echo ff ) | sort | while read A
do
  echo "INBOX"
  echo "COPYTO $((0x$A))"
  echo "COPYFROM $((0x$A))"
  echo "OUTBOX"
done > PROG
echo HALT >> PROG

../../../logisim/prog/assembler PROG > /dev/null

tail -1 PROG.BIN > program
> ram

rm PROG.BIN
