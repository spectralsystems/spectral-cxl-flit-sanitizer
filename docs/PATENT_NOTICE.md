# Intellectual Property, USPTO Priority & 35 U.S.C. § 287(a) Virtual Marking Ledger

- **Assignee & Applicant:** Spectral Systems LLC (Virginia Beach, Virginia, USA)
- **Principal Investigator:** Eric C. Murphy (`eric@spectralsystems.org`) — Sole Human Inventor (37 C.F.R. § 1.41; compliant with 89 FR 10043)
- **Academic Collaborator / Co-PI (Computational Mathematics & Multilevel Splitting):** Dr. Yuesheng Xu (Department of Mathematics, Old Dominion University)
- **Patent Portfolio Status:** **17 U.S. Provisional Patent Applications Pending (PPAs 1–17; Latest: App No. 64/187,145, filed Oct 29, 2026)** under 35 U.S.C. § 111(b) (Standard-Essential CXL / PCIe / UCIe / HBM Interconnect & Memory Enclave Portfolio)
- **Latest Priority Filings:**
  * **PPA-14:** U.S. Provisional Patent Application (Docket No. PPA-14; unpublished serial number withheld in confidence under 35 U.S.C. § 122), filed October 24, 2026 (Official USPTO Specification SHA-512 Cryptographic Anchor: `40D805FF33C54B74B8382832069D5B09A16104AA4021ACE09816DD79C64600AF484FBB3838BB4F2ECD462FE7C6D2632AEB4E896849BDF15277F35B20E6933BCC`)
  * **PPA-15:** U.S. Provisional Patent Application (Docket No. PPA-15), filed October 26, 2026, titled *"Orthogonal Cellular Sheaf Flit Sanitization, Per-Slot Cycle-1 NOP Nullification, Synthetic Credit Reconciliation, Monotonic CSR Ratcheting, Hamming-Isometric Shadow Cosets, and Physical Silicon Realizations for High-Speed Interconnects and Pooled Memory Enclaves"*
    * **PPA-16:** U.S. Provisional Patent Application (Docket No. PPA-16), filed October 28, 2026;
  * **PPA-17:** U.S. Provisional Patent Application Serial No. **64/187,145** (Confirmation No. **2351**; Patent Center ID: **83912534**), filed **October 29, 2026 at 4:08:08 PM EDT** (Official USPTO Specification SHA-512 Anchor: 240DC56E439F09DD337FD34AF2D4C86B0669844B4CDAE8FE83003CCBD02CCE3FD20991F311F8E280054202201482E2B72B514F68326D1E3FD944A9C07618AE72), titled *"COLD-RESET-ISOLATED MONOTONIC ACCESS RATCHETING, TRANSLATION-VALIDATED DUAL-RAIL MORPHIC CAPABILITY SIEVES, ANTI-ROWHAMMER SELF-APERTURE READ PROJECTION, SHIFTED-INVOLUTION AND 264-KEY FEISTEL-CHI COSET BIJECTIONS, FOLDED MODULO-3 REED-SOLOMON SUPERCODE TAGGING, ZERO-TOPOLOGY-DISCLOSURE KLEENE-KRON GATEWAY FEDERATION, CREDIT-COUPLED 1-BIT IDE FILTRATION, OUT-OF-ORDER 64-CACHELINE DMA RATCHETING, BIRTH-PRESENCE DAG PROOF AUDITING, AND BOCKSTEIN COLLECTIVE PLAQUETTE VERIFICATION FOR HIGH-SPEED INTERCONNECTS AND MEMORY ENCLAVES"*

---

## 1. 35 U.S.C. § 112(f) Physical Structure & Netlist Primitive Traceability
To preempt any ambiguity under **35 U.S.C. § 112(a)/(b)/(f)**, all architectural components disclosed in this verification ledger correspond to specific, deterministic digital logic structures verified in `reports_public/vivado_xcvu47p_core_utilization.rpt` and `vivado_xcvu47p_core_timing_summary.rpt`:

| Claimed Architectural Element | Physical Silicon Primitive (`xcvu47p` Post-Route Netlist) | Verified Metric / Resource |
| :--- | :--- | :--- |
| **Combinational Sheaf Coboundary Projector & Sheaf-MMU** | `674` logical LUT primitives (`523 LUT2`, `144 LUT6`, `4 LUT1`, `3 LUT4`) packed via `260` shared `O5+O6` dual-LUT (`LUT6_2`) pairs into **`414 Physical CLB LUTs`** (`0` BRAM) | `1.019 ns` routed datapath (`899.3 MHz` $F_{\max}$), Theorems 1–17 |
| **1-Cycle Stateless 4-KB Cohort Revocation & 0-BRAM DAG Verifier** | Combinational revocation mask gate (`p & ~revoked`) + `FDCE` streaming cochain accumulator (`0` Block RAM / `0` TLB shootdown IPIs) | $\Delta t_{\text{CRD}} \equiv 0$ (1 clock cycle), Theorems 18–20 |
| **Per-Slot Defect Latch & Egress Sanitizer** | `FDCE` D-Flip-Flop registers (`s1_defect_vec_reg[3:0]`, `s1_flit_reg_reg[511:0]`, `flit_data_out_reg[511:0]`) | `1,041 CLB Registers` (`+2.888 ns` WNS, `+0.036 ns` WHS) |
| **Surgical Sub-Flit `CXL_NOP` & `S2M_DRS` Zeroing Mux** | 2-to-1 `LUT2` bit-level zeroing multiplexer (`flit_data_out[*]_i_1`) + `m_hbm_wstrb_o[63:0]` byte-mask gate | `0` self-inflicted link `NAK`s, `CTO = 0`, `#MC = 0`, Theorems 21–25 |
| **Monotonic `AND`-Ratchet Registers (`CSR 0x00/0x08`)** | Feedback `AND2` gate (`reg <= reg & wdata`) cleared exclusively by cold power-on reset (`rst_n`), paired with software-non-resettable trap counter (`CSR 0x48`) | Verified by `bitvec64_monotonic_csr_ratchet_no_escalation` |
| **Galois Policy Compiler & $\beta\eta$-Canonical Egress Gate** | Stalk synthesis $(\alpha, \gamma) \to$ `CSR 0x00/0x08` & canonicalizer $\mathcal{N}(\Sigma, \pi)$ (`CSR 0x58`) | Proven in `SheafCosetIsometry.lean` Theorems 14–16 ($I = 0\text{ bits}$) |

---

## 2. Unilateral Apparatus Boundary (*Akamai* Single-Entity Infringement Notice)
All data-plane sanitization, 1-cycle stateless 4-KB cohort revocation, 0-BRAM streaming DAG cochain verification, bidirectional `S2M_DRS` read-payload zeroing, credit-refund pulse generation (`m_pcie_crd_pulse_o[3:0]`), write-strobe gating (`m_hbm_wstrb_o[63:0]`), and monotonic BAR0 ratcheting execute **entirely within a single unitary hardware apparatus boundary** without requiring modifications to external host CPUs or upstream switch firmware.

## 3. 35 U.S.C. § 287(a) Virtual Patent Marking & SEP RAND Notice
This page serves as notice under **35 U.S.C. § 287(a)** that the **SPECTRAL FLIT-FILTER** architecture and associated software/hardware artifacts are covered by **17 Pending U.S. Provisional Patent Applications (PPAs 1–17)** owned by Spectral Systems LLC. Spectral Systems LLC is committed to licensing Standard-Essential Patent (SEP) claims reading on CXL Consortium, PCI-SIG, UCIe Consortium, and JEDEC interconnect specifications on Reasonable and Non-Discriminatory (RAND) terms, subject to **DFARS 252.227-7018** data-rights reservations for U.S. Government contracts.
