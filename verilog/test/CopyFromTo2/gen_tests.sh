#!/bin/bash

TEST_NUMBER=20

TIMING=$( mktemp )
DATA=$( mktemp )

for t in $( seq -w 0 $(( TEST_NUMBER -1 )) )
do
  echo $t
  TESTIN=test$t.in
  TESTOUT=test$t.out

  # between 40..49 numbers in input (prog is fixed to 40 numbers)
  SIZE=$( cat /dev/urandom | tr -dc '0-9' | fold -w 2 | grep ^[4] | grep -v 00 | head -1 )

  # timing, between 01..59
  cat /dev/urandom | tr -dc '0-9' | fold -w 2 | grep -v 00 | grep ^[0-5] | head -n $SIZE > $TIMING

  # datos
  cat /dev/urandom | tr -dc '0-9a-f' | fold -w 2 | head -n $SIZE > $DATA

  paste -d " " $TIMING $DATA > $TESTIN

  head -n 40 $DATA > $TESTOUT

done
