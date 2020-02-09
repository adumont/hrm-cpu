#!/usr/bin/env python3
import serial
import argparse
import contextlib
import os.path
import re
import sys
import logging
from time import sleep



# Argument parsing
parser = argparse.ArgumentParser()
parser.add_argument('-i','--input' , required=True, help='input file')
parser.add_argument('-o','--output', required=True, help='expected output file')
parser.add_argument('-d','--debug' , action='store_true', help='print debug messages')
parser.add_argument('-p','--port'  , help='serial port')
args = parser.parse_args()

@contextlib.contextmanager
def smart_open(filename=None, mode="w"):
  if filename and filename != '-':
    fh = open(filename, mode)
  else:
    if mode == "r":
      fh = os.fdopen(sys.stdin.fileno(), mode, closefd=False)
    else:
      fh = os.fdopen(sys.stdout.fileno(), mode, closefd=False)
  try:
    yield fh
  finally:
    if filename and filename != '-':
      fh.close()

def str2int(str):
  b=16 if str.startswith("0X") else 10
  return int(str, b)

expected = []
received = []

i=0

def receive():
   global i
   while(ser.in_waiting>0):
      out = ser.read()
      d = out[0]
      print("RECV %03d: 0x%02X (%d)" %(i, d, d ))
      received.append( d )
      if i+1 > len(expected):
         print("ERROR: Received more bytes (%d) than expected (%d)"%(i+1,len(expected)))
         exit(2)
      else:
         if expected[i] != received[i]:
            print("ERROR: byte %d received (%2X) is not what was expected (%2X)" %(i, received[i], expected[i]))
            exit(1)
         # else:
         #    print("OK")
      i += 1

# MAIN()
if __name__== "__main__":

   if args.port is None:
      port = "/dev/ttyUSB1"
   else:
      port = args.port

   ser=serial.Serial(port, 115200)

   with smart_open(args.output, 'r') as handle:
      for line in handle:
         data, _ = re.split("\s",line)
         # print( int(data, 16) )
         expected.append( int(data, 16) )

   # print("EXPECTED:", expected)

   j=0
   with smart_open(args.input, 'r') as handle:
      for line in handle:
         wait, data, _ = re.split("\s",line)
         sleep(int(wait) * 0.001)
         # print("SEND:", bytes( [ int(data, 16) ] ))
         d=int(data, 16)
         print("SEND %03d: 0x%02X (%d)" %(j, d, d ))
         j += 1
         ser.write( bytes( [ d ] ) )
         sleep(0.001)
         receive()

   sleep(1)
   receive()

   if i<len(expected):
      print("ERROR: Received less bytes (%d) than expected (%d)"%(i,len(expected)))
      exit(3)

   # print()
   # print("EXPECTED:", expected)
   # print("RECEIVED:", received)
   print("OK")
   exit(0) # OK