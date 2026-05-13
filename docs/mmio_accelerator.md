# Memory-Mapped 4x4 INT8 Matrix Multiply Accelerator

## Overview

`rtl/matmul_4x4_mmio.sv` wraps the sequential 4x4 INT8 matrix multiplier with a small memory-mapped register interface.

Instead of exposing full `A_flat`, `B_flat`, and `C_flat` buses directly at the top level, software or a testbench can load matrix data by writing registers, trigger computation with a control register write, and read back results from result registers.

## Interface

Inputs:

- `clk`: system clock
- `rst`: asynchronous reset
- `wr_en`: write enable for MMIO transactions
- `rd_en`: read enable for MMIO transactions
- `addr[7:0]`: byte address of the MMIO register
- `wr_data[31:0]`: write data bus

Outputs:

- `rd_data[31:0]`: read data bus
- `done`: high when the matrix multiply has finished

The interface is intentionally simple. Each register is word-spaced by 4 bytes, which matches the way many real embedded buses present control/status registers.

## Address Map

### Control Register

- `0x00`
  - write bit 0 = `1` to start a new matrix multiply
  - read bit 1 = `done`

## A Matrix Storage

Addresses `0x10` to `0x4C` store matrix `A[4][4]` in row-major order.

Each entry uses:

- one 32-bit word address
- only `wr_data[7:0]` is stored
- value is treated as signed INT8

Mapping:

- `0x10` `A[0][0]`
- `0x14` `A[0][1]`
- `0x18` `A[0][2]`
- `0x1C` `A[0][3]`
- `0x20` `A[1][0]`
- ...
- `0x4C` `A[3][3]`

## B Matrix Storage

Addresses `0x50` to `0x8C` store matrix `B[4][4]` in row-major order.

Mapping starts at:

- `0x50` `B[0][0]`

and ends at:

- `0x8C` `B[3][3]`

## C Matrix Results

Addresses `0x90` to `0xCC` expose matrix `C[4][4]` in row-major order.

Each entry is read back as a signed 32-bit result.

Examples:

- `0x90` `C[0][0]`
- `0x94` `C[0][1]`
- `0xA0` `C[1][0]`
- `0xCC` `C[3][3]`

## FSM Behavior

The accelerator uses a simple sequential finite-state machine:

1. `IDLE`
2. `COMPUTE`
3. `DONE`

### IDLE

The block waits for a write of `1` to control register bit 0. On start:

- `done` is cleared
- all `C` registers are cleared
- loop indices reset to zero
- accumulation register resets

### COMPUTE

The design performs one multiply-accumulate operation per cycle:

`acc = acc + A[row][k] * B[k][col]`

When `k` reaches the end of the inner product:

- the final accumulated value is written into `C[row][col]`
- the FSM advances to the next output column or row

For a 4x4 matrix multiply, there are:

- 16 output elements
- 4 MAC operations per output element
- 64 MAC cycles total

### DONE

When all 16 outputs are computed:

- `done` goes high
- the result registers remain available for reading

If software writes start again, the accelerator clears `done` and begins a new operation.

## Why This Is More Realistic

Exposing full matrix ports such as `A_flat`, `B_flat`, and `C_flat` is useful for learning datapath design, but it is not how most accelerators are integrated into larger systems.

A memory-mapped interface is more realistic because:

- embedded CPUs usually control accelerators through registers
- inputs are loaded over time instead of being presented as giant top-level buses
- outputs are read back from status/data registers
- a control register and `done` flag match common SoC peripheral design patterns

This makes the module a better stepping stone toward:

- AXI-Lite or APB peripherals
- FPGA soft-core integration
- ASIC accelerator blocks inside a system-on-chip
