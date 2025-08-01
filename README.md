[![Join the HRMCPU chat at https://gitter.im/hrm-cpu/Lobby](https://badges.gitter.im/hrm-cpu/Lobby.svg)](https://gitter.im/hrm-cpu/Lobby?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
[![Build Status](https://travis-ci.com/adumont/hrm-cpu.svg?branch=master)](https://travis-ci.com/adumont/hrm-cpu)
[![Gitpod Ready-to-Code](https://img.shields.io/badge/Gitpod-ready--to--code-blue?logo=gitpod)](https://gitpod.io/#https://github.com/adumont/hrm-cpu)

# Human Resource Machine CPU (Verilog)

- [Human Resource Machine CPU (Verilog)](#human-resource-machine-cpu-verilog)
- [Introduction](#introduction)
  - [CPU Architecture components](#cpu-architecture-components)
  - [Project status](#project-status)
  - [Disclaimer](#disclaimer)
- [Functional Description](#functional-description)
  - [HRM CPU Instruction Set](#hrm-cpu-instruction-set)
  - [Addressing Modes](#addressing-modes)
  - [Memory Mapped I/O mapping](#memory-mapped-io-mapping)
  - [Timer (WAIT)](#timer-wait)
  - [Assembler](#assembler)
- [Architecture](#architecture)
  - [Top module](#top-module)
  - [Control Unit](#control-unit)
  - [Inbox](#inbox)
  - [Outbox](#outbox)
  - [Register](#register)
  - [Memory](#memory)
  - [PC (Program Counter)](#pc-program-counter)
  - [PROG (Program ROM)](#prog-program-rom)
  - [IR (Instruction Register)](#ir-instruction-register)
  - [ALU](#alu)
- [Simulations in Logisim](#simulations-in-logisim)
  - [Year 4](#year-4)
  - [Year 32](#year-32)
- [Automated test (simulations)](#automated-test-simulations)
  - [Generating new tests](#generating-new-tests)
- [Synthesis to FPGA](#synthesis-to-fpga)
  - [Top module design](#top-module-design)
  - [How to build and flash in the FPGA](#how-to-build-and-flash-in-the-fpga)
- [Hardware tests](#hardware-tests)
- [Graphical User Interface (GUI)](#graphical-user-interface-gui)
  - [GUI Screenshots](#gui-screenshots)
  - [GUI Features](#gui-features)
  - [How to build the GUI (Linux)](#how-to-build-the-gui-linux)
- [Continuous Integration (CI)](#continuous-integration-ci)
- [Makefiles features](#makefiles-features)
- [Tools used in this project:](#tools-used-in-this-project)
- [External files](#external-files)

# Introduction

HRM CPU is a personal project aimed at designing a soft core microprocessor in Verilog, **synthetizable in an FPGA** that behaves like the gameplay of [Human Resource Machine](https://tomorrowcorporation.com/humanresourcemachine) by Tomorrow Corp.

Here's an extract of an article on HRM, posted on [IEEE's Spectrum site](https://spectrum.ieee.org/geek-life/reviews/three-computer-games-that-make-assembly-language-fun):
>In this game the player takes on the role of an office worker who must handle numbers and letters arriving on an “in” conveyor belt and put the desired results on an “out” conveyor belt.
>
>[...]Those in the know will recognize the office worker as a register, the temporary workspace on the office floor as random access memory, and many of the challenges as classic introductory computer science problems.[...]

The *HRM CPU* is an **8-bit multi-cycle RISC microprocessor** based on the **Harvard architecture** with **variable length instructions** and one register (accumulator).

**TL;DR**: For the impatients, you can jump to these demos (with videos) at the end:
- [HRM Year 4 in Logisim](#year-4)
- [HRM Year 32 in Logisim](#year-32)
- [Demo of 3 programs running on HRMCPU in the Icezum Alhambra FPGA](https://www.youtube.com/watch?v=BREuXfzeU0w)
- [*Twitter moment* with most of the related tweets](https://twitter.com/i/moments/1017515777610649601)
- Want to see the [GUI](#graphical-user-interface-gui) and play with the HRMCPU (no FPGA?)

## CPU Architecture components

We can see how the game actually represents a CPU and its internal components:

| HRM  components |   #   | CPU components         |
| --------------- | :---: | ---------------------- |
| Office Worker   |   1   | Register (Accumulator) |
| In/Out belts    | 2, 3  | Input/Ouput (I/O)      |
| Floor Tiles     |   4   | Memory (RAM)           |
| Program         |   5   | Program Memory         |
|                 |   6   | Program Counter        |
|                 |   7   | Instruction Register   |

![](assets/hrm_04-labels.png)

## Project status

![](assets/status.png)

## Disclaimer

- I'm a passionate hobbist with a recent interest in digital electronics, meaning I'm not a Computer Science Engineer, nor a hardware engineer. I enjoy learning from books, youtube videos and tutorials online. This project is about practicing and learning.
- This is a strictly personal project, with entertaining and educational objectives exlusively, not commercial nor industrial.
- This design is original and based only on my understanding of the game and it's behaviour as a black box. I haven't done any reverse engineering of the game in any form.
- The design is not optimized in any way. I'm happy it works: **It work, in Logisim, Verilog simulation, and synthesized in the Icezum Alhambra FPGA.**
- It's a work in progress, so it's incomplete (and may never be complete).
- Although I try to be thorough, this documentation is also incomplete (and may never be complete).

# Functional Description

## HRM CPU Instruction Set

The instruction set is (almost) the same as in the HRM game, I have respected the limited original 11 instructions set, to which I have added three convinient instructions: SET, WAIT and HALT.



The latest version of the instruction set is described in this [Google Spreadsheet](https://docs.google.com/spreadsheets/d/1WEB_RK878GqC6Xb1BZOdD-QtXDiJCOBEF22lt2ebCDg/edit?usp=sharing).

The following picture shows the instruction set format, and corresponding machine language:

![](assets/instruction-set.png)

The current implementation status is represented by the color in the first column (Green: implemented in Logisim, white: pending).

I have added a couple of instructions that were not in the HRM game: WAIT, SET, and HALT. 

I have also added support for some memory mapped IO, allowing to access additional modules via the memory commands, by setting the mmio bit in the opcode lower nibble.

The opcodes are encoded with 1 word (8 bit) or two nibbles. Some instructions have one operand which is also encoded with 8 bits. So the length of instructions is variable: some are 1 word wide, others are two words wide.

## Addressing Modes

The HRM CPU is capable of addressing 256 bytes of block-ram, or 256 bytes of memory-mapped IO.

| Addressing Mode  | Example Instruction | Description                                                                                                                               |
| :--------------- | :------------------ | :---------------------------------------------------------------------------------------------------------------------------------------- |
| Direct Mode      | COPYTO A            | The operand A represents the address in Ram the instruction will operate on                                                               |
| Indirect Mode    | COPYTO [A]          | The value stored in Ram at the address A will be used as the address in Ram the instruction will operate on                               |
| Memory Mapped IO | COPYTO /A           | Address A represents a memory mapped module and possibly a function (depending of the module). See [Memory Mapped I/O](#memory-mapped-io) |

## Memory Mapped I/O mapping

HRM CPU support a limited set of Memory Mapped modules detailled below.

Access to memory mapped modules is achieved by asserting the "mmio bit" (lsb) in the opcode of the instruction. In assembler language, we prefix the ADDR with "/":

| Action                                                | Instruction format | Example        |
| :---------------------------------------------------- | :----------------- | :------------- |
| Write from R to memory mapped device at address ADDR  | COPYTO /ADDR       | COPYTO /LEDS   |
| Read from memory mapped device at address ADDR into R | COPYFROM /ADDR     | COPYFROM /RAND |

Currently, there are 3 modules available via Memory Mapped IO:

- XALU: An extended ALU, which provides some additional operations (logical operator).
- LEDS: Allows to set the fisical LEDS of the board, by using `COPYTO /16`. There's also a macro so we can use `COPYTO /LEDS`.
- RAND: A Pseudo Random Number Generator.

The table below details the modules, the addresses and the corresponding function, when written or read:

![](assets/mmio-modules.png)

### Examples

- Do some logic-operations with XALU

| Instruction | Meaning                        |
| :---------- | :----------------------------- |
| COPYTO /A0  | Copy R to register A0 in XALU  |
| COPYTO /A1  | Copy R to register A1 in XALU  |
| COPYFROM /4 | Place A0 AND A1 (bitwise) in R |

- Get a pseudo-random number

| Instruction    | Meaning                                      |
| :------------- | :------------------------------------------- |
| COPYFROM /RAND | Get a pseudo-random number and place it in R |

- Change the pseudo random generator's Seed:

| Instruction  | Meaning                    |
| :----------- | :------------------------- |
| COPYTO /RAND | Use R as new seed for RAND |

- Power on/off the board's leds

| Instruction  | Meaning                                            |
| :----------- | :------------------------------------------------- |
| COPYTO /LEDS | Power on/off the leds according to the 8 bits of R |

## Timer (WAIT)

I have added a new instruction, WAIT: It takes one operand N, and will pause the execution for N x 50ms.

| Instruction | Meaning                          |
| :---------- | :------------------------------- |
| WAIT n      | Pause the execution for n x 50ms |

## Assembler

The purpose of the `hrmasm` assembler is to translates an HRM program (the *assembly* language) to the corresponding *machine code* so it can then be loaded into the [Program ROM (PROG)](#prog-program-rom) and drive the CPU accordingly.

The assembler resides in `/hrmasm` folder.

```
usage: hrmasm [-h] [-s SOURCE] [-o OUTPUT] [-p PRETTY] [-b BIN] [-l] [-d]
              [-r RAM]

optional arguments:
  -h, --help            show this help message and exit
  -s SOURCE, --source SOURCE
                        source file
  -o OUTPUT, --output OUTPUT
                        output rom file (for FPGA)
  -p PRETTY, --pretty PRETTY
                        output pretty printed file
  -b BIN, --bin BIN, --binary BIN
                        output in binary format file
  -l, --logisim         binary rom/ram file in logisim format
  -d, --debug           print debug messages
  -r RAM, --ram RAM     output initial ram file (for FPGA)
```

If you provide a source file using the `-s` flag, you can generate the corresponding machine code in any of these formats:

- A Rom file suitable to be loaded into a Verilog model (`-o` flag). It's an ascii file, with each byte written in hexadecimal, separated by spaces. Padded to 256 bytes. If the `-l` flag is specified, a header is added so the output file is compatible with Logisim Rom/Ram format.
- A Binary file (`-b` flag): raw bytes written in binary format, padded to 256 bytes.
- A text file with a pretty printed representation of the program, addresses and machine code. Suitable to be feed back into hrmasm as input file if modified (in that case, the addresses and machine code part are ignored)

Notes:
- "-" specified as a filename will mean stdin/stdout
- If several output formats are specified, they will all be generated sequentially.
- The padding used is 0x00.
- Used alone, the `-r` flag can be used to generate a 256 ram file (filled with 0x00). If the `-l` flag is also specified, a header is added so the output file is compatible with Logisim Rom/Ram format.

### Using the hrmasm assembler

Todo

# Architecture

The HRM CPU architecture is loosely inspired from MIPS architecture. This CPU is a multi-cycle CPU with a Harvard architecture (program is held in a different memory as general memory).

The following internal Architecture simplified block diagram shows all the [CPU components](#cpu-architecture-components), the Data Path and Control Path (in red dashed line):

![](assets/HRM-CPU-Harvard.png)

This is the corresponding RTL Block Diagram generated by Yosys from the Verilog HDL code I have written:

![](verilog/assets/hrmcpu.svg)

The sections below detail each module individually.

## Top module

The top module shows all the inner modules, the Data Path and Control Path:

![](logisim/diagram/TOP.png)

TODO:
- Document hrmcpu testbench & waveform screenshots

## Control Unit

The **Control Unit** is a Finite State Machine. It takes as input the instruction, and some external signals, and generate control signals that will orchestrate the data flow along the data path.

![](verilog/assets/blocks/ControlUnit-ControlUnit.svg)

The following chart shows all the steps (clock-cycles) and control signals involved in each instruction:

![](assets/control-signals-1.png)
![](assets/control-signals-2.png)

Below is the corresponding FSM:

[![](assets/control-unit-FSM.png)](assets/control-unit-FSM.png)

Note:
- Logisim FSM addon tool doesn't seem to allow transition to the same state, that is why the HALT state doesn't have any transition out of it. It should loop on itself. Anyway in Logisim's simulation it behaves as expected.

### Debug Mode

I have added a *debug mode*  (which can be enabled by asserting the *cpu_debug* signal). When in *debug mode*, the FSM will pause right before loading the next instruction into the Instruction Register (IR). It will then resume execution when the user press the "nxtInstr" button. This allows the user to run the program in an *Instruction by Instruction* fashion, and inspect the state of all the components after an instruction has run, and before we run the next.

### Hold Mode

The CPU have a *Hold mode* which can be triggered by asserting the *cpu_hold* signal. This will gate the clock input of the FSM, so the FSM (Control Unit) will be paused ("on hold"). All the other components of the CPU (fifos, memory, registers) will still receive the clock signal, allowing to dump their values for example to a VGA screen.

## Inbox

We load the Inbox with some elements. The first element of the inbox is expected to be the length of the inbox (that is the number of elements).

### Logisim circuit

In an initial design, the length of the inbox was fixed (see the 04 at the input of the comparator?).

![](logisim/diagram/INBOX.png)

Then I designed a small FSM inside the Inbox module that reads the first element, and sets the length of the queue. It then position the cursor on the actual first element of the Inbox, ready for the program to consume it.

This is the resulting design:

![](logisim/diagram/INBOX-2.png)

The INBOX FSM is very simple. (for some reason, I was unable to create it in Logisim with 2-bit states encoding, that's probaby a bug. That's why it has 3 bit state encoding.)

![](logisim/diagram/INBOX-2-FSM.png)

Notes:
- When all the elements have been read (popped out of the IN belt), the empty signal is asserted. Once empty = 1, any INBOX instruction will wait until a new element is loaded in INBOX. At this time, the elements in INBOX si fixed, so that's equivalent to ending the program. Whenever I'll add a UART-RX at this end, it will allow the CPU to process items endlessly.

[Update] The Verilog implementation is based on a FIFO queue, and doesn't require anymore to indicate the number of elements as first element.

## Outbox

![](verilog/assets/blocks/ufifo-ufifo.svg)

### Logisim circuit

![](logisim/diagram/OUTBOX.png)

## Register

![](verilog/assets/blocks/REG-REG.svg)

### Logisim circuit

![](logisim/diagram/R.png)

### RTL Block Diagram

![](verilog/assets/register.svg)

### Testbench simulation

![](verilog/assets/register_sim.png)

## Memory

![](verilog/assets/blocks/MEMORY-MEMORY.svg)

### Logisim circuit

![](logisim/diagram/MEMORY.png)

NOTE: the Logisim model doesn't support Memory Mapped IO.

### RTL Block Diagram

![](verilog/assets/MEMORY.svg)

In place of the "ram" module that was in the MEMORY module, we now have a memory wrapper that will handle the IO Memory Mapping:

![](verilog/assets/mem_wrapper.svg)


## PC (Program Counter)

- Reinitialized to 0x00 upon reset
- Increments by 1 (1byte) when wPC=1
- Branch signals:
    - Inconditional jump (JUMP) when *( branch && ijump )*
    - Conditional jumps (JUMPZ/N) only when *( branch && aluFlag )*

![](verilog/assets/blocks/PC-PC.svg)

### Logisim circuit

![](logisim/diagram/PC.png)

### RTL Block Diagram

![](verilog/assets/PC.svg)

### Testbench simulation

![](verilog/assets/PC_sim.png)


## PROG (Program ROM)

![](verilog/assets/blocks/PROG-PROG.svg)

### Logisim circuit

![](logisim/diagram/PROG.png)

### RTL Block Diagram

![](verilog/assets/program.svg)

### Testbench simulation

![](verilog/assets/program_sim.png)


## IR (Instruction Register)

![](verilog/assets/blocks/IR-IR.svg)

### Logisim circuit

![](logisim/diagram/IR.png)

### RTL Block Diagram

![](verilog/assets/IR.svg)

### Testbench simulation

![](verilog/assets/IR_sim.png)


## ALU

The ALU can perform 6 different operations selectable via aluCtl[2:0]:

- 4 Arithmetic operations, selectable via aluCtl[1:0]:

| aluCtl[1:0] | Operation | Output |
| :---------: | :-------: | :----: |
|     00      |   R + M   | aluOut |
|     01      |   R - M   | aluOut |
|     10      |   M + 1   | aluOut |
|     11      |   M - 1   | aluOut |

- 2 comparison operations, which will be used in JUMPZ/JUMPN, selectable via aluCtl[2]:

| aluCtl[2] | Operation | Output |
| :-------: | :-------: | :----: |
|     0     |  R = 0 ?  |  flag  |
|     1     |  R < 0 ?  |  flag  |

![](verilog/assets/blocks/ALU-ALU.svg)

### Logisim circuit

![](logisim/diagram/ALU.png)

### RTL Block Diagram

![](verilog/assets/ALU.svg)

### Testbench simulation

![](verilog/assets/ALU_sim.png)


# Simulations in Logisim

## Year 4

This is a simple example of the game, level 4: in this level, the worker has to take each pair of elements from Inbox, and put them on the Outbox in reverse order.

First let see the level in the game:

[![](logisim/prog/Year-04/assets/hrm_youtube_preview.png)](https://www.youtube.com/watch?v=JiQOIyq1n_M)

Now, we'll load the same program in our PROG memory, load the INBOX, clear the OUTBOX, and run the simulation in Logisim.

Program:

    init:
      00: 00    ; INBOX 
      01: 30 2  ; COPYTO 2
      03: 00    ; INBOX 
      04: 10    ; OUTBOX 
      05: 20 2  ; COPYFROM 2
      07: 10    ; OUTBOX 
      08: 80 00 ; JUMP init

(This is the output of my [Assembler](#assembler))

The corresponding Logisim memory dump (machine language) is:

    v2.0 raw
    00 30 2 00 10 20 2 10 80 00 

We load the PROG in Logisim:

![](logisim/prog/Year-04/assets/PROG.png)

Inbox:

The first element of the INBOX memory is the length (number of elements) of the INBOX.

| INBOX |
| :---: |
| 0x06  |
| 0x03  |
| 0x09  |
| 0x5a  |
| 0x48  |
| 0x02  |
| 0x07  |

In Logisim that is:

    v2.0 raw
    06 03 09 5a 48 02 07

We load the INBOX in Logisim:

![](logisim/prog/Year-04/assets/INBOX.png)

We clear the OUTBOX:

![](logisim/prog/Year-04/assets/OUTBOX-start.png)

And we run the simulation:

[![](logisim/prog/Year-04/assets/logisim_youtube_preview.png)](https://www.youtube.com/watch?v=S10Yhqw98eg)

Once the CPU halts (after trying to run INBOX instruction on an empty INBOX), we can see the resulting OUTBOX memory:

![](logisim/prog/Year-04/assets/OUTPUT-end.png)

Indeed, we can verify that the elements have been inverted two by two:

| OUTBOX |
| :----: |
| 0x09   |
| 0x03   |
| 0x48   |
| 0x5a   |
| 0x07   |
| 0x02   |

## Year 32

This level is more complex. In level 32 there are 14 letters on the tiles, plus a 0. For each letters that comes into the Inbox, you have to compute how many tiles have the same letter, and send the total count to the Outbox.

This is how I did it in the real game:

[![](logisim/prog/Year-32/assets/hrm-year32-thumbnail.png)](https://www.youtube.com/watch?v=O4R98aO1frI)

Now let see how my HRM CPU behaves with the same program. First let's have a look at the program itself:

Here's my solution for Level 32. It involves direct (`COPYFROM 14`) and indirect adressing mode (`COPYFROM [19]`).

    init:
        00: 20 0e ; COPYFROM 14
        02: 30 13 ; COPYTO 19
        04: 30 10 ; COPYTO 16
        06: 00 00 ; INBOX 
        07: 30 0f ; COPYTO 15
    nexttile:
        09: 28 13 ; COPYFROM [19]
        0b: 90 19 ; JUMPZ outputcount
        0d: 50 0f ; SUB 15
        0f: 90 15 ; JUMPZ inccount
    inctileaddr:
        11: 60 13 ; BUMP+ 19
        13: 80 09 ; JUMP nexttile
    inccount:
        15: 60 10 ; BUMP+ 16
        17: 80 11 ; JUMP inctileaddr
    outputcount:
        19: 20 10 ; COPYFROM 16
        1b: 10 00 ; OUTBOX 
        1c: 80 00 ; JUMP init

(This is the output of my [Assembler](#assembler))

The corresponding Logisim memory dump (machine languag, ready for loading into Logisim) is:

    v2.0 raw
    20 0e 30 13 30 10 00 30 0f 28 13 90 19 50 0f 90 15 60 13 80 09 60 10 80 11 20 10 10 80 00 

Below we can see it is loaded into the program memory (PROG) of the CPU:

![](logisim/prog/Year-32/assets/PROG.png)

Now let's see the Inbox:

We'll load 5 elements: `1`, `2`, `5`, `3` and `4` into the INBOX. As we have to load first the number of elements, it is in total 6 items:

| INBOX |
| :---: |
| 0x05  |
| 0x01  |
| 0x02  |
| 0x05  |
| 0x03  |
| 0x04  |

In Logisim format that is:

    v2.0 raw
    05 01 02 05 03 04

We load the INBOX in Logisim:

![](logisim/prog/Year-32/assets/INBOX.png)

In this level, we also have to pre-load the tiles in MEMORY. Here's the file:

    v2.0 raw
    02 01 04 02 03 04 01 02 01 04 03 02 01 02 00

Let's pause and count mentally how many of each item we have in the Tiles:

| Item  | Count |
| :---: | :---: |
| 0x01  |   4   |
| 0x02  |   5   |
| 0x03  |   2   |
| 0x04  |   3   |
| 0x05  |   0   |

(That is what we expect to get in the OUTBOX)

Before running the program, let's clear the OUTBOX:

![](logisim/prog/Year-32/assets/OUTBOX-start.png)

And finally we run the program:

[![](logisim/prog/Year-32/assets/hrm-cpu-logisim-year32-thumbnail.png)](https://www.youtube.com/watch?v=9MmbXoqh_AE)

The program will finish when the last item in the inbox is processed. Let's see the result we get in OUTBOX:

![](logisim/prog/Year-32/assets/OUTBOX-end.png)

| OUTBOX |
| :----: |
| 0x05   |
| 0x04   |
| 0x00   |
| 0x02   |
| 0x03   |

Indeed, we can verify that this is the total count of each item (from the INBOX) in the tiles: 4 x 0x01, 5 x 0x02, 0 x 0x05, 2 x 0x03 and 3 x 0x04.

**So it works!!!**

# Automated test (simulations)

[TODO]

- show hrmcpu module testbench
- explain folders structure
- explain regression test suite structure and how it works
    - Makefile, tester.v, tester.mk,
    - Icarus Verilog MACRO injection from Makefile
    - If the any source file, or program or ram file has changed, the necesarry tests (depending on the modified files) will be rerun (that's the power of using Makefile!)
    - Generic testbench + tests folders (one per game level)
        - program and initial ram file
        - as many pairs of input and expected output files as tests we want to do
        - Makefile finds all levels and run all tests within a level (until a test would fail)
    - show sample tests
    - how to run tests

From `verilog/test`

Run all tests:

```
$ make -s 
BUMP+: Success, all tests passed
Echo: Test [test01] OK
Echo: Success, all tests passed
Year-01: Success, all tests passed
Year-03: Success, all tests passed
Year-04: Success, all tests passed
Year-32: Success, all tests passed
```

Run all tests of 1 level:

```
$ cd Year-04
$ make -s -f ../tester.mk
Year-04: Test [test02] OK
Year-04: Test [test01] OK
Year-04: Success, all tests passed
```

Run only 1 test of a particular level

```
$ cd Year-04
$ make -s -f ../tester.mk test02.check
Year-04: Test [test02] OK
```

Inspect a particular tests and traces: for that we need to run the test manually, so it will generate the trace for Gtkwave:

```
$ cd Year-32-NOP
$ make -f ../tester.mk clean
$ make -f ../tester.mk test01.test.out
```

In addition to test01.test_out (output of the simulation), this will generate the test01.lxt (interLaced eXtensible Trace file), suitable for Gtkwave inspection:

```
$ gtkwave test01.lxt
```

Clean all test files
```
$ make -s clean
```

## Generating new tests

Some levels have a test generator, so it's easy to generate new random tests (random input and the corresponding expected output). Inside the `gen_test.sh` script you can see information about size of input, number of tests to run.

Generally, each test will feature:
- a random input length
- random input values
- random timing for when to input each value

Check in `verilog/test/*/` for the `gen_test.sh` script. Simply run the script in the corresponding level test folder.

Some tests also have a `gen_prog.sh` script that allows to generate new random programs (usually it randomizes the memory addresses used in the program).

# Synthesis to FPGA

## Top module design

The top modules is the one that will connect the IO pins, the UART-RX to the CPU's Inbox, the CPU's Outbox to the UART-TX. I have also added a small *controller* that to only pop data out of the Outbox when it's not empty AND UART-TX is not busy.

![](verilog/assets/top.svg)

![](verilog/assets/top_dot.svg)

## How to build and flash in the FPGA

From `verilog` directory:

```
make LEVEL=Echo upload
```
From a clean folder, it will generate the bitstream and program it to the FPGA connected via USB.


The Makefile offers several handy targets to do different actions, per module:

If no module is specified with `MODULE=<module>`, it will default to `MODULE=top`.

| Target | What it does                                                                                                         | Comments                                                           |
| :----: | :------------------------------------------------------------------------------------------------------------------- | :----------------------------------------------------------------- |
|  bin   | Generates bitstream                                                                                                  | Makes sense for top module                                         |
| upload | Upload bitstream to FPGA                                                                                             | Makes sense for top module                                         |
|  svg   | Generates a netlistsvg output in asset/ folder                                                                       |                                                                    |
|  dot   | Generates a GraphViz DOT output in asset/ folder                                                                     |                                                                    |
|  sim   | Runs a testbench simulation of a specific module, generates Variables dumps and open Gtkwave to inspect the waveform | Use with `MODULE=<module>`. Testbench must be called <module>_tb.v |

Additionally:
- a board can be specified: `BOARD=<board>`, it will default to `MODULE=alhambra` (board must be defined first in Board.mk)
- a game level should be specified: `LEVEL=<level>`. Level files must exist in /test/. See examples.

[TODO]: add more detail

- Write (or choose a program) and eventually initial ram file.
    - For example: use `make PROGRAM=test/Year-32/program ROMFILE=test/Year-32/ram upload`
- Convert it to machine language, so it can be read by Verilog $readmemh().
- Sinthesize the bitstream
- Program the FPGA

# Hardware tests

I have implemented a mechanism to run the tests against the FPGA.

To run the tests, from the `verilog/test` directory:

```
make BOARD=alhambra hwtest
```

It will synthesize the bitstream for each test directory under `verilog/test`, and then for each test inside it, it will program the FPGA, send the input (testXX.in) and check that the generated output is the same as the expected output (testXX.out).

NOTE:
- If all hardware tests (or many) randomly fail, check if there are some processes "cat /dev/ttyUSB1" hanging and kill them (or run "killall cat").

# Graphical User Interface (GUI)

This GUI sub-project is about showing the internal state of all the components of the HRMCPU.

The GUI is made in QT, and designed using QT Creator. Internally, it relies on the [Verilator](https://www.veripool.org/wiki/verilator) model which is directly derived from the HRMCPU Verilog design.

In other words:
* the GUI is a *facade* on top of the *verilated* HRMCPU's Verilog design
  * it handles the user interaction: shows the state of registers, memories and signals
  * it handles and feed the clock signal to the  design
  * it allows the user to interact with the CPU with the Inbox and Outbox FIFOs (using the buttons in the UI)
* the *verilated* HRMCPU model handles the heavy work (digital logic) as designed in Verilog (that is the HRMCPU)

Please note that while the HRMCPU project is about creating a synthesizable CPU, this GUI doesn't interact with the real hardware (synthesized in FPGA) but with the *verilated* Verilog design (which runs in software).

I made it for (my own) recreational purpose, but it could serve educational purpose, or as a base to create other GUIs for other verilator models (CPUs or anything else).

## GUI Screenshots

![](assets/hrmcpu_gui_1.png)

The UI layout is self explanatory: it shows the main elements of the HRMCPU and their internal states in real time.

See this [video](https://youtu.be/b5eFUFYJFLQ) for a demo.

## GUI Features

These are some of the features the GUI brings at the moment:

* Select and Load a program from file (machine language) into PROG memory (make tests to create all the test programs from assembler)
* Three running modes:
  * F3: Run manually (tick by tick) or in automatic mode, with adjustable clock period
  * F4: Step to next instruction (stops on next DECODE state or HALT instruction)
  * F5: Run continuously
* Show values of registers and signals
* Show content MEMORY ram, PROG memory, as well as INBOX and OUTBOX FIFOs (doesn't allow to directly edit values, as least not for now)
* Shows current instruction name and current ControlUnit (FSM) name
I/O:
* Input field to manually push new values to INBOX
* Manual pop out of OUTBOX
* Generates a VCD file to allow for further inspection of internal states with Gtkwave for example (includes all arrays/ram content)
* Button to reset the CPU (it won't reset clock)

TODO:
* Show FSM flags
* Save/Restore internal state and time (verilated_save)
* ALU isn't represented yet

## How to build the GUI (Linux)

At the moment, the GUI can only be built on Linux.

```
$ cd gui
$ make
```

Make will make the Verilator model, and the QT gui and link both, to generate the `hrmcpu` binary in gui/.

From gui/ folder, run it with no argument:

```
$ ./hrmcpu
```

Or you can also rebuild and run in one make command:

```
$ make run
```



# Continuous Integration (CI)

Tests: cd /verilog/, make test

Latest Travis CI build status: [![Build Status](https://travis-ci.org/adumont/hrm-cpu.svg?branch=harvard)](https://travis-ci.org/adumont/hrm-cpu) (click to get all details)

[TODO] *Document this part*

# Makefiles features

There's a lot of effort put into progressively crafting the Makefiles in this project in order to acomplish several features:

`verilog/Makefile` features:
- Multi board support (each board with different Arachne-pnr Device parameter) and it's own PCF file
- [Parameterized verilog](https://maker.itnerd.space/define-verilog-parameters-at-synthesis-time-yosys/) from Makefile using m4 wrapper (injected into verilog before sinthesis with yosys)
- Build (rebuild) only what is needed. Every step is a Makefile target:
	- Synthesis (yosys) verilog sources -> blif file
	- Place and Route (arachne-pnr) blif -> pnr file
	- Generate bitstream (icepack) pnr -> .bin file
- Don't rebuild bitstream if only bram initialization files have chenged (use icebram instead)
	- pnr -> pnr (with updated bram blocks)
- Upload: Flash/program FPGA
	- Only flash if bitstream has changed (keep md5 of last bitstream flashed)
- For a specific module:
	- svg: Generates a netlistsvg diagram
	- dot: Generates a GraphViz diagram
	- sim: Runs the testbench simulation of the specific module, generates variables dumps and opend gtkwave to inspect the waveform

`verilog/test/Makefile`:
- Discover all tests
- Runs all tests (sends input and checks ouput for every level)
- Syntesize all tests for a board (multi-board support)
- Runs all test (sends input and checks ouput for every level) against an FPGA board connected via serial port. See [Hardware tests](#hardware-tests)

root's `Makefile` features:
- Update toolchain if upstream sources have been updated
    - Incremental source update (git pull)
    - Incremental rebuild (only rebuild what's changed)
- Run testbenches (iverilog) and synthesize every level for every defined board (hw test aren't run as we can't test hardware from Travis CI... yet?)
- Called from Travis, see [Continuous Integration (CI)](#continuous-integration-ci)

# Tools used in this project:

- [Logisim Evolution, fork with FSM Addon](https://github.com/sderrien/logisim-evolution): this version has an FSM editor, which is regat to design and test FSMs. Unfortunately, it's not based on the latest Logisim Evolution version, nor is it compatible with.
- [Visual Studio Code](https://code.visualstudio.com/) as code editor
    - [Verilog HDL 0.3.5](https://github.com/mshr-h/vscode-verilog-hdl-support) extension
- Opensource FPGA toolchain ([installer](https://github.com/dcuartielles/open-fpga-install))
    - Synthesizer: [Yosys](http://www.clifford.at/yosys/) ([github](https://github.com/cliffordwolf/yosys))
    - Place & Route (PnR): [Arachne-pnr](https://github.com/cseed/arachne-pnr) (on github) 
    - Utilities and FPGA programmer: [IceStorm Project](http://www.clifford.at/icestorm/)
    - Verilog Simulator: [Icarus Verilog](http://iverilog.icarus.com/) 
    - Waveform Viewer: [Gtkwave](http://gtkwave.sourceforge.net/)
- [Verilator](https://www.veripool.org/wiki/verilator): the fastest free Verilog HDL simulator
- Diagram editor: [SchemeIt](https://www.digikey.com/schemeit)
- [Symbolator](https://kevinpt.github.io/symbolator/)
- [QtCreator](https://en.wikipedia.org/wiki/Qt_Creator) and [Qt](https://en.wikipedia.org/wiki/Qt_(software))
- [Travis CI](https://travis-ci.org/adumont/hrm-cpu) for continuous integration
    - Thanks to [stevehoover](https://github.com/stevehoover/warp-v)

# External files

I have re-used some files from external sources:

- UART and uFIFO by Dan Gisselquist, from https://github.com/ZipCPU/wbuart32 (GPL)
