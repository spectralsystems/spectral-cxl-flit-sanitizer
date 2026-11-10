# Virtual Patent Marking & Tactical Apache-2.0 License Scope (35 U.S.C. § 287(a) — Release v1.0.0)

- **Assignee & Commercial Entity:** Spectral Systems LLC (`https://spectralsystems.org` • CAGE: `268E1` • SAM.gov UEI: `VTP2JPCJU3D9`)
- **Sole Human Inventor:** Eric C. Murphy (`eric@spectralsystems.org`), compliant with `37 C.F.R. § 1.41` and **USPTO Revised Inventorship Guidance for AI-Assisted Inventions, 90 FR 54636 (Nov. 28, 2025)**.
- **Sovereign Funding Provenance:** Developed 100% at private expense (`DFARS 252.227-7018` / `DEAR 952.227-14`).
- **Patent Portfolio Status:** Protected by **19 U.S. Provisional Patent Applications (`All Patents Pending`)**.
- **Export Control Compliance:** Public open-source cryptographic/verification notification filed with BIS and the NSA ENC Encryption Request Coordinator pursuant to `15 C.F.R. § 742.15(b)`.

## Three-Tier Tactical License & Patent Boundary

| Repository Surface | Applicable License | Patent & Commercial Scope |
| :--- | :--- | :--- |
| **Tier 1: Open-Source Verification & Control Plane** (`formal_lean4/`, `spectralc/`, `sim/`, `helm/`, `tests/`) | **Apache License 2.0 (`SPDX: Apache-2.0`)** | Full open-source copyright and Apache-2.0 Section 3 patent grant **strictly scoped to software execution, compilation, and formal mathematical verification** of the 30 zero-axiom `Init.Prelude` Lean 4 theorem groups (`thm00`–`thm29`), `spectralc v1.0.0`, Python reference twins, and `k3s` admission webhook. |
| **Tier 2: Air-Gapped Silicon & Physical Hardware** (`.sv`, `.vhd`, `.edf`, `.dcp`, `16nm` `xcvu47p` AFIs `agfi-03b742e2a9cd2c0f2` & `agfi-08becf3b40b169674`, `7nm` `ASAP7` GDSII/DEF) | **Proprietary Commercial / Government COTS License (`DFARS 252.227-7018`)** | **Excluded from the Apache-2.0 "Work".** No license (express, implied, or under Apache-2.0 Section 3) is granted to synthesize, place-and-route, program onto FPGA/ASIC silicon, or commercially deploy physical CXL 3.0–5.0 or UCIe sub-flit capability sanitization hardware. |
| **Tier 3: Preprint Monograph, Register ABI & Silicon Receipts** (`preprint_Murphy_v1_0_0.pdf`/`.tex`, `registers/bar0_abi_v1.json`, `reports_public/*.json`, `docs/`, `website_public/`) | **Verbatim Attribution & Evaluation Scope (`35 U.S.C. § 287(a)`)** | Published for academic peer review, reproducibility auditing, and grant/procurement inspection. Publication of register ABIs (`16-CSR` `128 B` `BAR0` `0x00`–`0x78`) and sign-off telemetry conveys no license to fabricate physical hardware covered by the 19 pending provisional patent applications. |
