# DARPA, DoD & Peer-Reviewer 5-Minute Verification Guide (`v0.0.0`)

This repository (`spectralsystems/spectral-cxl-flit-sanitizer`) is structured so any technical evaluator can verify all five formal, algebraic, gate-level, and control-plane verification pillars on a standard laptop in **under 60 seconds** without a $50,000 AMD Vivado license or an AWS EC2 `f2.6xlarge` account.

---

## 1. One-Command Full-Stack Verification (Local or GitHub Codespaces)

```bash
# 1. Verify Zero-Axiom Lean 4 Formal Proofs (Init.Prelude, 0 sorry, 0 axiom)
lean formal_lean4/CxlSubflitSanitizerFormal.lean
lean formal_lean4/CxlSubflitSanitizerExtensions.lean

# 2. Run Standalone Tseitin CNF Miter + Verified LRAT RUP Kernel + 1-Step ZK-IC3 & zkPi Attestor
python3 tests/verify_zk_ic3_lrat_miter.py

# 3. Run Adversarial Fault-Injection & Mutation Kill-Matrix (320 LUT6_2 Bit-Flips + 4 Protocol Attacks)
python3 tests/test_adversarial_mutation_kill_matrix.py

# 4. Run Infinite-Precision Exact-Rational (fractions.Fraction) Leiden-Standard Oracle Prover
python3 tests/verify_leiden_rational_oracles.py

# 5. Run Sandia SST (CXL-ClusterSim) Trace Co-Simulator, 5-Pillar Auditor & SHA-256 Manifest Check
python3 sim/sst_cxl_clustersim_adapter.py
python3 tests/run_5pillar_repo_auditor.py
sha256sum -c SHA256SUMS.txt
```

---

## 2. How the Two-Zone DFARS 252.227-7018 Air-Gap Is Bridged Mathematically

| Boundary Layer | Public Zone 2 (`Apache-2.0` Verification Corpus) | Air-Gapped Zone 1 (`DFARS 252.227-7018` Private Vault) |
| :--- | :--- | :--- |
| **Gate-Level Equivalence** | `tests/verify_zk_ic3_lrat_miter.py` + `reports_public/ZK_LEC_MITER_RECEIPT.json` prove Tseitin CNF/LRAT RUP `UNSAT` across all `320` placed `LUT6_2` states & 1-step inductive `ZK-IC3` consecution. | Retains synthesizable SystemVerilog (`*.sv`), post-route `*.edf` netlists, and `*.dcp` checkpoints developed 100% at private expense. |
| **Non-Vacuity Guarantee** | `tests/test_adversarial_mutation_kill_matrix.py` injects `320` single-bit `LUT6_2` mutations + 4 Trojan/protocol faults and verifies a **100% kill-rate** (`UNSAT -> SAT`). | Prevents tautological or vacuous specification passes without exposing structural wire coordinates. |
| **Live Silicon Execution** | Post-route 16nm `xcvu47p` (`1,585` Core LUTs, `0` BRAM, `+1.048 ns` WNS), 7nm `ASAP7` (`27,877` cells, `693 MHz`), and Dual-AFI AWS F2 receipts (`agfi-03b742e2a9cd2c0f2` & `agfi-08becf3b40b169674`). | AWS F2 AFI `loadPermission` remains account-locked until entitled for government or commercial evaluation. |

---

## 3. Protocol for Under-NDA / CRADA Zone-1 Vault Inspection & Live AWS F2 AFI Entitlement

Government contracting officers (DARPA, CDAO, DOE/NNSA, NSA) and semiconductor prime evaluators may request:
1. **Live AWS EC2 `f2.6xlarge` AFI Execution Entitlement:** Provide your 12-digit AWS Account ID to `eric@spectralsystems.org` to receive `loadPermission` on `agfi-03b742e2a9cd2c0f2` (800k-slot BIST & 19,990-trace TVLA) and `agfi-08becf3b40b169674` (16 GB HBM2 DMA).
2. **Zone-1 RTL / Netlist Inspection:** Available under mutual NDA or Federal CRADA (`Spectral Systems LLC`, `CAGE: 268E1`, `SAM.gov UEI: VTP2JPCJU3D9`).
