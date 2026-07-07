# Pipelined RISC-V Processor

A 5-stage pipelined RISC-V processor implemented in Verilog, supporting a core subset of the RV64I instruction set with full data-hazard forwarding, load-use stalling, and control-hazard flushing.

Built as a course project (Spring 2026, ECE, IIIT Hyderabad) by **Naga Rama Hari Kumar**, **Chandini Gayathri**, and **Veekshita Sai**.

## Overview

The processor implements the classic five-stage RISC pipeline:

```
IF  →  ID  →  EX  →  MEM  →  WB
```

| Stage | Description |
|-------|-------------|
| **IF** (Instruction Fetch) | Fetches the instruction at the current PC and computes PC+4 |
| **ID** (Instruction Decode) | Decodes the instruction, reads the register file, sign-extends immediates, and generates control signals |
| **EX** (Execute) | Performs the ALU operation, resolves forwarded operands, and computes the branch target |
| **MEM** (Memory Access) | Reads or writes data memory for loads/stores |
| **WB** (Write Back) | Writes the ALU result or loaded data back to the register file |

Four pipeline registers (`IF/ID`, `ID/EX`, `EX/MEM`, `MEM/WB`) carry data and control signals between stages every clock cycle.

## Features

- **64-bit datapath** (RV64I-style) with a 32-bit instruction word
- **Gate-level ALU** built from ripple-carry full adders (`add`, `sub`, `and`, `or`), with a zero flag for branch evaluation
- **Full data-hazard forwarding** — EX/MEM → EX and MEM/WB → EX paths, so back-to-back dependent instructions don't stall unnecessarily
- **Load-use hazard detection** — inserts a single-cycle stall/bubble when an instruction immediately depends on a preceding load
- **Control-hazard handling** — static "branch not taken" prediction with pipeline flushing (`IF/ID` and `ID/EX` bubbles) on a taken branch
- **Self-checking testbench** that runs until it fetches an all-zero (halt) instruction and dumps final register state to a file

## Supported Instructions

| Type | Instructions | Opcode |
|------|-------------|--------|
| R-type | `ADD`, `SUB`, `AND`, `OR` | `0110011` |
| I-type (ALU) | `ADDI` | `0010011` |
| Load | `LD` | `0000011` |
| Store | `SD` | `0100011` |
| Branch | `BEQ` | `1100011` |

## Project Structure

```
├── processor.v          # Top-level module wiring all pipeline stages together
├── pc.v                 # Program counter with stall support
├── instruction_mem.v    # Instruction memory (loaded from instructions.txt)
├── data_memory.v        # Byte-addressable data memory
├── register_file.v      # 32×64-bit register file, dual read / single write
├── immediate_gen.v      # Sign-extended immediate generation (I/S/B formats)
├── control_unit.v       # Main decoder — generates control signals from opcode
├── alu_control.v        # Refines ALU operation from ALUOp + funct3/funct7
├── alu.v                # Gate-level ALU (ripple-carry adder/subtractor, AND, OR)
├── forwarding_unit.v    # EX-stage operand forwarding logic
├── hazard_detection.v   # Load-use stall/flush detection
├── pipeline_regs.v      # IF/ID, ID/EX, EX/MEM, MEM/WB pipeline registers
├── pipe_tb.v             # Top-level testbench / simulation driver
├── instructions.txt     # Hex machine code loaded into instruction memory
└── Pipeline_Processor_report.pdf  # Full design report
```

## How It Works

### Data Hazards
When an instruction needs a value that a prior instruction hasn't written back yet (e.g. `add x2, x1, x3` followed by `sub x4, x2, x5`), the **forwarding unit** routes the result directly from the `EX/MEM` or `MEM/WB` register into the ALU inputs, avoiding a stall in most cases.

### Load-Use Hazards
Forwarding can't help when a load is immediately followed by a dependent instruction (e.g. `ld x5, 0(x1)` then `add x6, x5, x2`), since the loaded value isn't available until after the MEM stage. The **hazard detection unit** stalls the PC and `IF/ID` register for one cycle and injects a bubble into `ID/EX` so the value is ready to forward on the next cycle.

### Control Hazards
Branch outcomes aren't known until the end of EX, by which point later instructions have already been fetched. The processor assumes branches are **not taken** and fetches sequentially; if a branch turns out to be taken, the `IF/ID` and `ID/EX` registers are flushed (bubbles inserted) and the PC is redirected to the branch target.

## Running the Simulation

This project uses plain Verilog and can be run with [Icarus Verilog](http://iverilog.icarus.com/).

```bash
# Compile
iverilog -o sim.out pipe_tb.v

# Run
vvp sim.out
```

The testbench runs until instruction fetch reads an all-zero word (treated as a halt), or times out after 100,000 cycles. On completion, it writes the final contents of all 32 registers (plus total cycle count) to `register_file.txt`.

### Program Input

The program to execute is provided as a stream of hex bytes in `instructions.txt`, which is loaded into instruction memory via `$readmemh`. Replace this file with your own hex-encoded RV64I program to run different code.

## Design Report

A detailed writeup covering the datapath, each pipeline stage, control signal generation, and hazard-handling strategy is available in [`Pipeline_Processor_report.pdf`](./Pipeline_Processor_report.pdf).
