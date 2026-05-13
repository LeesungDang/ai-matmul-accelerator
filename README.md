# AI Matrix Multiply Accelerator

A SystemVerilog RTL project that builds from a dot-product unit to 2x2 and 4x4 matrix multiplication accelerators, with Python/NumPy golden-model verification and randomized RTL testing.

This project practices skills relevant to FPGA engineering, ASIC/RTL design, AI hardware acceleration, computer architecture, and digital verification.

## Current Features

- 4-element signed dot-product module
- 2x2 matrix multiplication module
- Array-based 2x2 matrix multiplication module
- 4x4 combinational matrix multiplication module
- 4x4 sequential FSM-based matrix multiplication accelerator
- Python/NumPy golden models
- Randomized INT8 test-vector generation
- Randomized RTL verification against expected outputs
- Makefile-based simulation workflow

## Repo Structure

rtl/          SystemVerilog RTL modules  
tb/           SystemVerilog testbenches  
python/       Python golden models and test-vector generators  
docs/         Architecture and design notes  
scripts/      Helper scripts  
build/        Generated simulation builds, ignored by Git  
waveforms/    Generated waveform files, ignored by Git  

## Main Modules

### Dot Product

Computes:

result = a0*b0 + a1*b1 + a2*b2 + a3*b3

This is the core operation behind matrix multiplication and AI inference workloads.

### 4x4 Combinational Matrix Multiply

Computes all 16 output values of:

C = A x B

using nested loop logic.

### 4x4 Sequential Matrix Multiply

A clocked FSM-based design with:

clk, rst, start, done

It computes one multiply-accumulate step per cycle, showing the tradeoff between hardware resource usage and cycle latency.

## Verification

The project uses:

1. Fixed SystemVerilog testbenches
2. Python/NumPy golden models
3. Randomized INT8 test-vector generation
4. RTL comparison against expected outputs

Randomized testing caught signed-arithmetic issues that fixed positive-only tests missed.

## How to Run

Run the full test suite:

make all

Run individual tests:

make dot  
make matmul2  
make matmul2array  
make matmul4  
make matmul4seq  
make matmul4random  
make golden  

Clean generated files:

make clean

## Example Passing Output

Dot product result = 70  
TEST PASSED  

C =  
[250 260 270 280]  
[618 644 670 696]  
[986 1028 1070 1112]  
[1354 1412 1470 1528]  
TEST PASSED  

RANDOMIZED 4x4 MATMUL TESTS PASSED

## Tools Used

- SystemVerilog
- Icarus Verilog
- Python
- NumPy
- Make
- Git/GitHub

## Key Concepts Demonstrated

- RTL design
- Testbench development
- Signed INT8 arithmetic
- Wider signed accumulation
- Matrix multiplication datapaths
- FSM-based sequential hardware
- Python golden-model verification
- Randomized RTL testing
- Area vs latency vs throughput tradeoffs

## Documentation

See docs/architecture.md for design notes and architecture explanation.

## Synthesis Results

Both flattened 4x4 matrix multiply designs were synthesized with Yosys.

| Design | Style | Yosys Cell Count | Main Tradeoff |
|---|---:|---:|---|
| matmul_4x4_flat | Combinational | 51,056 cells | High parallelism, larger gate count |
| matmul_4x4_seq_flat | Sequential FSM | 5,134 cells | Lower gate count, more cycles |

The sequential design uses about 10x fewer cells than the fully combinational design, demonstrating the hardware tradeoff between area and latency.


## Project Summary

A recruiter-facing summary with resume bullets and interview talking points is available here:

docs/project_summary.md


## OpenLane Physical Design

The sequential flat accelerator was run through the OpenLane SKY130 RTL-to-GDS flow.

See:

docs/openlane.md

Committed reports:

openlane/matmul_4x4_seq_flat/


## OpenLane Physical Design

The sequential flat accelerator was run through the OpenLane SKY130 RTL-to-GDS flow.

See:

docs/openlane.md

Committed reports:

openlane/matmul_4x4_seq_flat/

