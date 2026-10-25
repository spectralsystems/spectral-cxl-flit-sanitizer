# Threat Model & Formal Invariant Mapping

## 1. Adversarial Surface in Pooled CXL 3.0/4.0 Fabrics
Modern multi-tenant AI clusters utilize Compute Express Link (CXL 3.0/4.0) Port-Based Routing (PBR) across pooled High-Bandwidth Memory (HBM2/3). When routing graphs contain topological cycles ($\beta_1 > 0$), standard point-to-point access tables fail to prevent **Confused-Deputy privilege laundering**, **Go-Back-N NAK replay storms**, and **Fabric Manager (FM) CSR escalation**.

## 2. Threat-to-Theorem Verification Matrix

| Threat Vector | Legacy Hardware Failure Mode | KRON-LANDAUER v3.3.1 Hardware Countermeasure | Machine-Checked Lean 4 Theorem |
| :--- | :--- | :--- | :--- |
| **Cyclic PBR Confused Deputy** | Multi-hop routing bypasses source ACLs | Stage-1 orthogonal sheaf projection ($\le 38\text{ ps}$) | `valid_section_zero_defect` |
| **Co-Packed Innocent Slot Collateral** | Full 512b flit drop destroys 3 innocent slots | Per-Slot Cycle-1 `CXL_NOP` surgical nullification | `sheaf_orthogonal_decomposition` |
| **Upstream Switch Credit Starvation** | Dropped flits leak link flow-control credits | Single-cycle synthetic `+CRD` return pulse | `flow_control_credit_conservation` |
| **Link-Layer NAK Replay Storm** | Tail-CRC poisoning triggersPAM-4 retransmission | Clean-CRC shadow coset isometry ($2^{-64}$ SDC) | `shadow_coset_hamming_isometry` |
| **Compromised Fabric Manager (FM)** | Malicious FM overwrites BAR0 CSR to all-1s | Hardware monotonic `AND`-ratchet (`reg <= reg & wdata`) | `monotonic_csr_ratchet_no_escalation` |
| **Key Rollover Race Condition** | DLP header bits frozen by CXL specification | Atomic binding to native IDE `Key_Set_Select` (`K_Set_Go`) | `spacetime_kunneth_monotonicity` |