# Human Resource Machine CPU (Verilog)

- [Human Resource Machine CPU (Verilog)](#human-resource-machine-cpu-verilog)
- [Introduction](#introduction)
- [Disclaimer](#disclaimer)
- [CPU Elements](#cpu-elements)
- [Instruction set](#instruction-set)
- [Microarchitecture](#microarchitecture)
    - [Top module](#top-module)
    - [Control Unit](#control-unit)
    - [Inbox](#inbox)
    - [Outbox](#outbox)
    - [Register](#register)
    - [Memory](#memory)
    - [PC (Program Counter)](#pc-program-counter)
    - [IR (Instruction Register)](#ir-instruction-register)
    - [ALU](#alu)
- [Simulations in Logisim](#simulations-in-logisim)
    - [Example of COPYTO/COPYFROM](#example-of-copytocopyfrom)
    - [Example of JUMP](#example-of-jump)
- [Tools used](#tools-used)

# Introduction

This personal project aims at designing a soft core CPU in Verilog (synthetizable in FPGA) that works like the game [Human Resource Machine](https://tomorrowcorporation.com/humanresourcemachine) (HRM).

The HRM game features a worker, an inbox queue, an outbox queue, and tiles on the floor. The worker executes a sequence of orders (developped by the player) using a very limited set of instructions and picks items from the inbox, can eventually deposit the items on a tile, do some arithmetical operations, and outputs items in the Outbox queue.

# Disclaimer

- I'm not an CS engineer, nor a hardware engineer. I'm a complete n00b in electronics, although I enjoy learning from books, youtube videos and tutorials online.
- This is a personal project, with entertaining and educational objectives exlusively.
- I'm happy if it gets to work somehow. It's not optimized in any way. Don't judge the quality.
- It's a work in progress. It's highly incomplete (and may never be complete).
- Documentation is also incomplete (and may never be complete).

# CPU Elements

We can see how the game actually represents a CPU and it's internals.

Here are some elements of the analogie:

| HRM  element | CPU element  |
| ------------ | ------------ |
| Worker       | Register     |
| Inbox/Outbox | I/O          |
| Tiles        | Memory (RAM) |
| Instructions | Program      |

# Instruction set

For now, the latest version of the instruction set is described in this [Google Spreadsheet](https://docs.google.com/spreadsheets/d/1WEB_RK878GqC6Xb1BZOdD-QtXDiJCOBEF22lt2ebCDg/edit?usp=sharing).

![](assets/instruction-set.png)

Current implementation status is represented by the color in the first column (Green: implemented, white: pending).

I have added a couple of instructions that were not in the HRM game: SET, and HALT.

I've coded the instruction with 8 bits. The optional operand is coded with another 8 bits.

# Microarchitecture

The microarchitecture is very loosely inspired from MIPS architecture. The CPU is a multi-cycle CPU.

![](assets/HRM-CPU-3.png)

Sections below detail each module individually:

## Top module

![](logisim/diagram/top.png)

## Control Unit

The **Control Unit** is a Finite State Machine. It takes as input the instruction, and some external signals, and generate control signals that will orchestrate the data flow along the data path.

The following chart shows the control signals for some of the instruction:

Control Signals:
![](assets/control-signals-1.png)

Below is the corresponding FSM:

![](assets/control-unit-FSM.png)

Note:
- Logisim FSM addon tool doesn't seem to allow transition to the same state, so I have defined two HALT states in a loop. I'll remove it when I implement it in Verilog.

## Inbox

![](logisim/diagram/inbox.png)

## Outbox

![](logisim/diagram/outbox.png)

## Register

![](logisim/diagram/R.png)

## Memory

-  0x00-0x1f: 32 x 1 byte, general purpose ram (*Tiles* in HRM)
-  0x20-... program space. (PC starts at 0x20 upon reset)

![](logisim/diagram/memory.png)

## PC (Program Counter)

- starts at 0x20 upon reset, increment by 1 (1byte)
- can be set to allow branching (JUMPs instructions)

![](logisim/diagram/pc.png)

## IR (Instruction Register)

![](logisim/diagram/IR.png)

## ALU

![]()

# Simulations in Logisim

## Example of COPYTO/COPYFROM

Let's consider this simple program, which takes two items from Input, and outputs them in reverse order:

```
    20  INBOX       00
    21  COPYTO 0    30 00
    23  INBOX       00
    24  OUTBOX      10
    25  COPYFROM 0  20 00
    27  OUTBOX      10
    28  HALT        F0
```

TODO: add video, screenshots of Input/Ouput before/after

## Example of JUMP

```
    20  INBOX       00
    21  OUTBOX      10
    22  JUMP 20     80 20
```

TODO: add video, screenshots of Input/Ouput before/after

# Tools used

Pending to add reference/links.

- Logisim Evolution with FSM Addon
- Visual Studio Code
- Fizzim
- Opensource FPGA toolchain
- SchemeIt