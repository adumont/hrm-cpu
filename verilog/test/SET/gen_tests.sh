#!/bin/bash

TEST_NUMBER=80

> PROG
> test00.in
> test00.out

for t in $( seq 0 255 )
do
  echo $( cat /dev/urandom | tr -dc '0-9a-f' | fold -w 3 | head -n 1 ) $t
done | sort | cut -d" " -f 2 | head -n $TEST_NUMBER | while read t
do 

  echo "SET $t" >> PROG
  echo "OUTBOX" >> PROG

  printf "%02x\n" $t >> test00.out
  
done
