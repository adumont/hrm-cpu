#!/bin/bash

cd verilog

ls *.v |
  grep -v _tb.v |
  while read M
  do
    symbolator -i $M -f svg -o assets/blocks/ --title -t
  done

cd -
