# Synthesis Notes

## Overview

This project includes a Yosys synthesis flow for a synthesis-friendly flattened 4x4 matrix multiplication module.

The original simulation-oriented 4x4 RTL uses 2D unpacked array ports. This works in simulation with Icarus Verilog, but Yosys had trouble parsing those ports for synthesis.

To support synthesis, a flattened module was added:

rtl/matmul_4x4_flat.sv

This version uses packed flat input/output buses:

A_flat  
B_flat  
C_flat  

## Synthesis Command

Run:

make sure the synth directory exists, then:

yosys -s synth/matmul_4x4_flat.ys

## Generated Files

synth/matmul_4x4_flat.ys  
synth/matmul_4x4_flat_netlist.v  

## Yosys Result Summary

Top module:

matmul_4x4_flat

Statistics from Yosys:

Wires: 11163  
Wire bits: 213328  
Ports: 3  
Port bits: 544  
Cells: 51056  

Cell breakdown:

AND gates: 23888  
OR gates: 8016  
XOR gates: 19152  

## Interpretation

The synthesized combinational 4x4 matrix multiplier has a large gate count because the design computes all 16 output elements in parallel.

Each output is a 4-term dot product, so the design contains many multiply/add operations expanded into gate-level logic.

This demonstrates the hardware tradeoff:

Combinational design:
- high parallelism
- fewer cycles
- larger gate-level implementation
- longer combinational path

Sequential design:
- fewer compute resources
- more cycles
- more realistic accelerator control structure

## Key Lesson

Simulation-friendly RTL is not always synthesis-friendly RTL.

For synthesis, tool-compatible interfaces such as flattened packed buses can be easier for synthesis tools to process than unpacked multi-dimensional array ports.
