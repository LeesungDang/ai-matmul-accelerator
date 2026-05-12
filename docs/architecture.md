# Architecture Notes

## Project Overview

This project implements a small SystemVerilog matrix multiplication accelerator flow. It starts with a dot-product unit and builds up to 2x2 and 4x4 matrix multiplication modules, including both combinational and sequential designs.

The project uses Python/NumPy golden models and randomized test-vector generation to verify RTL correctness.

## Dot Product Unit

The dot-product unit computes:

result = a0*b0 + a1*b1 + a2*b2 + a3*b3

This is the core operation behind matrix multiplication and many AI inference workloads.

## 2x2 Matrix Multiply

The 2x2 matrix multiplier computes:

C = A x B

Each output element is a dot product between one row of A and one column of B.

Example:

c00 = a00*b00 + a01*b10  
c01 = a00*b01 + a01*b11  
c10 = a10*b00 + a11*b10  
c11 = a10*b01 + a11*b11  

## 4x4 Combinational Matrix Multiply

The combinational 4x4 module computes all 16 output elements using nested loops.

For each output:

C[i][j] = sum over k of A[i][k] * B[k][j]

This design has high parallelism and low cycle latency, but it implies more hardware resources and a longer combinational path.

## 4x4 Sequential Matrix Multiply

The sequential 4x4 module uses:

- clk
- rst
- start
- done
- FSM control
- signed accumulator

Instead of computing everything at once, it computes one multiply-accumulate step per cycle.

The FSM states are:

- IDLE: waits for start
- COMPUTE: performs multiply-accumulate operations
- DONE: raises done after the full matrix multiplication is complete

This design uses fewer compute resources than a fully parallel design, but it takes more cycles.

## Signed INT8 Arithmetic

Inputs are signed INT8 values. Accumulation must use a wider signed type because matrix multiplication results can exceed the INT8 range.

This project follows the common AI hardware pattern:

INT8 inputs  
wider signed accumulation  

A bug appeared during randomized testing when negative inputs were introduced. The fix was to explicitly use wider signed accumulation in the 4x4 RTL.

## Verification Flow

The verification flow includes:

1. Hand-written SystemVerilog testbenches
2. Python/NumPy golden models
3. Randomized INT8 test-vector generation
4. RTL testbench comparison against expected outputs

The randomized tests are important because fixed positive-only tests can miss signed arithmetic bugs.

## Design Tradeoff

Combinational 4x4 design:

- Computes outputs immediately
- More parallel hardware
- Lower cycle latency
- Longer combinational path

Sequential 4x4 design:

- Computes over multiple cycles
- Uses an FSM
- Fewer compute resources
- Higher cycle latency
- More realistic accelerator control structure

## Key Learning Outcomes

This project demonstrates:

- SystemVerilog RTL design
- Testbench development
- Signed arithmetic handling
- Matrix multiplication datapaths
- Python golden-model verification
- Randomized RTL testing
- FSM-based sequential hardware design
- Hardware tradeoffs between area, latency, and throughput
