
# GYMS-16 RISC-V Pipelined Processor

Overview

The GYMS-16 project is a 16-bit RISC-V pipelined processor designed and implemented as part of a mini project at IIIT Dharwad. The processor features a simplified instruction set architecture (ISA), pipelined datapath, custom assembler, and is verified through simulation and synthesis.

Features

- RISC Architecture: Implements Reduced Instruction Set Computer (RISC) principles for efficiency and simplicity.
- 16-bit Data Path: Operates on 16-bit instructions and data.
- Custom ISA: Supports 13 arithmetic, logical, shift, and data movement instructions.
- Pipelining: Five-stage pipeline (IF, ID, EX, MEM, WB) for increased throughput.
- Harvard Architecture: Separate instruction and data memories (each 0.5kB).
- Register File: 32-byte general-purpose register file.
- Assembler: Python-based assembler to convert assembly code to binary/hex.
- Simulation & Synthesis: Verified using Icarus Verilog/GTKWave and synthesized with Quartus Prime Lite.

Instruction Set

- Arithmetic: ADD, SUB, DIV
- Logical: AND, OR, NOT, XOR
- Shift: SHL, SHR (logical and arithmetic)
- Memory: LDM (load), STM (store)
- Register Ops: LDR (load immediate), MOV (move register)
- NOP: No operation

Pipeline Stages

1. IF (Instruction Fetch)
2. ID (Instruction Decode)
3. EX (Execute)
4. MEM (Memory Access)
5. WB (Write Back)

Hazards & Solutions

- Structural Hazards: Managed by design.
- Data Hazards: Forwarding, stalling, interlocks.
- Control Hazards: Branch prediction, speculative execution.

Assembler

- Converts human-readable assembly to machine code.
- Handles lexical/syntax analysis and instruction encoding.

Simulation & Synthesis

- Simulated using Icarus Verilog and GTKWave.
- Synthesized using Quartus Prime Lite for FPGA deployment.

Authors

- More Prasad (21BEC025)
- R S Gokul Varun (21BEC034)
- Sai Sathvik G B (21BEC042)
- Yash Kumar (21BEC059)

Supervisor: Dr. Jagadish D N

References

- FPGA4Student: Verilog code for 16-bit RISC processor
  Smruti Ranjan Sarangi, Computer Organisation and Architecture, McGraw Hill Education

License

This project is released under the MIT License.
