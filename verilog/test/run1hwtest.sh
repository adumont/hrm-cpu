#!/bin/bash

PORT=$1
TEST=$2

sleep 1

kill -9 $( ps -ef | grep "cat /dev/ttyUSB1" | grep -v grep | awk '{ print $2 }' ) 2>/dev/null
stty -F ${PORT} 115200 cs8 -cstopb -parenb

cat ${PORT} > ${TEST}.hwtest_out &
PID=$!

cat ${TEST}.in | while read T C; do sleep $( echo "0.001 * $T" | bc ); echo "Sending $C"; echo -en "\x$C" > ${PORT}; done 

sleep 1
exec 2>/dev/null
kill ${PID}

echo "Output received:"
xxd -g1 ${TEST}.hwtest_out | cut -c11-58 | sed -e "s/ /\n/g" | grep -v "^$"

xxd -g1 ${TEST}.hwtest_out | cut -c11-58 | sed -e "s/ /\n/g" | grep -v "^$"| diff -q ${TEST}.out - >/dev/null
