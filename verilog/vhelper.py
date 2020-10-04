#!/usr/bin/env python3

import argparse
import contextlib
import os.path
import re
import sys
import hdlparse.verilog_parser as vlog

# Argument parsing
parser = argparse.ArgumentParser()
parser.add_argument('-f','--file', required=True, help='Verilog input file')
parser.add_argument('-i','--iceblock', action='store_true', help='Help with Icestudio code block generation')
parser.add_argument('-n','--name', help='Instance Name')
args = parser.parse_args()

vlog_ex = vlog.VerilogExtractor()
vlog_mods = vlog_ex.extract_objects(args.file)

input = lambda p: p.mode == "input"
output = lambda p: p.mode == "output"

def lpad(str,n):
  return ( str + " "*n )[0:n]

def rpad(str,n):
  return ( " "*n + str )[-n:]

def instanciate():
  for m in vlog_mods:
    w = max(len(p.name) for p in m.ports)
    w2 = max(len(re.sub("wire|reg","",p.data_type).strip()) for p in filter(input, m.ports))
    
    # Print a header
    print()
    print("`include \"%s\"" % args.file)
    print()
    print("// ---------------------------------------- //")
    print("// %s (%s)" %(args.name, m.name))
    print("//")
    print()
    # Declare wires for all ports
    for p in m.ports:
      print("wire %s %s_%s_%s;" %( rpad( re.sub("wire|reg","", p.data_type).strip(),w2), "i" if p.mode == "input" else "o", args.name, p.name ) )

    print()
    # Module instanciation
    print("%s %s (" % ( m.name, args.name ))
    n = len(m.ports)
    i = 1
    # input ports
    if filter(input, m.ports):
      print("   //---- input ports ----")
      for p in filter(input, m.ports):
        print("   .%s(i_%s_%s)%s" % ( lpad(p.name,w), args.name, lpad(p.name,w), "," if i<n else "" ))
        i+=1
    # output ports
    if filter(output, m.ports):
      print("   //---- output ports ----")
      for p in filter(output, m.ports):
        print("   .%s(o_%s_%s)%s" % ( lpad(p.name,w), args.name, lpad(p.name,w), "," if i<n else "" ))
        i+=1

    print(");")

    if m.generics : print("// Define Parameters:")
    # Module Parameters
    for p in m.generics:
      print("// defparam %s.%s = ;" % (args.name, p.name))
    # Input ports connections
    print("// Connect Inputs:")
    for p in filter(input, m.ports):
      print("assign i_%s_%s =  ;" % (args.name, lpad(p.name,w)))
    print("// ---------------------------------------- //")
    print()

def iceBlockPorts():
  for m in vlog_mods:
    print('Parameters:')
    for p in m.generics:
      print('\t{:20}{:8}{}'.format(p.name, p.mode, p.data_type))

    print('Ports:')
    for p in m.ports:
      print('\t{:20}{:8}{}'.format(p.name, p.mode, p.data_type))

  # Parameters
  print()
  print("PARAMETERS:")
  print()
  print("  %s" % (', '.join( p.name for p in m.generics )) )

  # input ports
  print()
  print("INPUT PORTS:")
  print()
  print("  ", end="")

  l=[]
  for p in filter(input, m.ports):
    width = re.sub("wire|reg|signed", "", p.data_type ).strip()
    l.append( ""+ p.name + width )
  print(', '.join( l ))

  # output ports
  print()
  print("OUTPUT PORTS:")
  print()
  print("  ", end="")
  l=[]
  for p in filter(output, m.ports):
    width = re.sub("wire|reg|signed", "", p.data_type ).strip()
    l.append( ""+ p.name + width )
  print(', '.join( l ))

  print()
  print("Add to beginning of code block:")
  print()

  for p in filter(output, m.ports):
    if "reg" in p.data_type or "signed" in p.data_type:
      if "reg" in p.data_type:
        print("%s %s;" %( p.data_type, p.name ))
      else:
        print("wire %s %s;" %( p.data_type, p.name ))


def main():
  if args.iceblock:
    iceBlockPorts()
  else:
    if args.name is None:
      print("You need to specify an Instance Name (-n/--name)")
      exit
    else:
      instanciate()

if __name__== "__main__":
  # main()
  main()
