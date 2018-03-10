# Human Resource Machine CPU (Verilog)

## Introduction

This personal project aims at designing a soft core CPU in Verilog (synthetizable in FPGA) that works like the [Human Resource Machine](https://tomorrowcorporation.com/humanresourcemachine).

The game features a worker, an inbox queue, an outbox queue, and tiles on the floor. The worker executes a sequence of orders (developped by the player) using a very limited set of instructions and picks items from the inbox, can eventually deposit the items on a tile, do some arithmetical operations, and outputs items in the Outbox queue.

## CPU Elements

We can see how the game actually represents a CPU and how it's working internally.

Here are all the elements of the analogy:

| HRM  element | CPU element  |
| ------------ | ------------ |
| Worker       | Register     |
| Inbox/Outbox | I/O          |
| Tiles        | Memory (RAM) |
| Instructions | Program      |

## Instruction set

## Microarchitecture

The microarchitecture is inspired from MIPS architecture. The CPU is single-cycle.