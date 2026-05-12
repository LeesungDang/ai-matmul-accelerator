# AI Matrix Multiply Accelerator

A SystemVerilog hardware design project for building and verifying a matrix multiplication accelerator, starting from a dot-product compute unit and expanding toward a pipelined INT8 accelerator for AI inference-style workloads.

## Current Milestone

Implemented and simulated a 4-element signed dot-product module:

result = a0*b0 + a1*b1 + a2*b2 + a3*b3

Test case:

A = [1, 2, 3, 4]
B = [5, 6, 7, 8]

Expected result = 70
Simulation result = 70
TEST PASSED

## Project Goals

- Design reusable SystemVerilog RTL modules
- Build a dot-product compute unit
- Expand to 2x2 and 4x4 matrix multiplication
- Add Python/NumPy golden-model verification
- Add randomized test generation
- Add pipelining and cycle-count benchmarking
- Document latency, throughput, and hardware tradeoffs

## Repo Structure

rtl/          SystemVerilog hardware modules
tb/           SystemVerilog testbenches
python/       Python golden models and test generation
docs/         Architecture and timing notes
waveforms/    Simulation waveform outputs
scripts/      Helper scripts
build/        Simulation build outputs

## How to Run Current Simulation

From the project root:

iverilog -g2012 -o build/dot_product_tb tb/tb_dot_product.sv rtl/dot_product.sv
vvp build/dot_product_tb

Expected output:

VCD info: dumpfile waveforms/dot_product.vcd opened for output.
Dot product result = 70
TEST PASSED

## Tools Used

- SystemVerilog
- Icarus Verilog
- GTKWave
- Python / NumPy
- Git / GitHub

## Learning Focus

This project develops skills relevant to:

- FPGA engineering
- ASIC / RTL design
- AI hardware acceleration
- Computer architecture
- Digital design verification
- Hardware/software co-design
