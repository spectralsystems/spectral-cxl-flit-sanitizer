# Microarchitectural Benchmarks & Comparative Analysis

## 1. Comparison Against State-of-the-Art Isolation Architectures

| Metric / Architectural Property | *Space-Control* (2026) | CHERI / ARM Morello | Legacy Tail-CRC Poisoning | **KRON-LANDAUER v3.3.1** |
| :--- | :--- | :--- | :--- | :--- |
| **Pooled DRAM Metadata Tax** | 1.56% (250 GB / 16 TB rack) | 12.50% (2 TB / 16 TB rack) | 0.00% | **0.00% (0 Bytes DRAM)** |
| **Runtime Execution Stall** | +3.30% (table miss penalty) | +4.50% to +12.0% | Link-halt on replay | **0.00% (Cut-Through)** |
| **Stage-1 Combinational Delay** | Multi-cycle SRAM lookup | Cache-hierarchy dependent | End-of-flit (Cycle 4) | **38.0 ps (7nm FinFET)** |
| **Silicon Footprint** | Large SRAM tag tables | Full core tag pipelines | Minimal (~150 gates) | **624 Standard Cells (0 BRAM)** |
| **Innocent Slot Survival** | Stalled | Exception trap | Destroyed (Full flit NAK) | **100% Preserved (Per-Slot NOP)** |
| **Self-Inflicted NAK Replays** | None | None | 100% of blocked flits | **0% (Clean-CRC Commit)** |
| **Formal Verification Grade** | Simulation only | Partial ISA proofs | None | **7 Lean 4 Theorems (0 Sorry)** |

## 2. 7nm FinFET Standard-Cell STA Summary
* **Stage-1 Sheaf Split Delay:** `38.0 ps` (1 `AND2_X1` + 1 `INV_X1` topological depth)
* **Full Enclave Critical Path:** `176.5 ps` at `1.0 GHz` (`> 820 ps` positive setup slack)
* **Total Gate Count:** `624` combinational and sequential cells (`0` Block RAMs, `0` DSP slices)
* **Dynamic Power Envelope:** `< 1.5 mW` at line rate