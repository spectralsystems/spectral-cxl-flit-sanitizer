# Export Control, CUI, and DFARS 252.227-7018 Boundary Attestation

## 1. Zero Export-Controlled or CUI Content in Public Repository
Spectral Systems LLC attests that this public GitHub repository (`spectral-cxl-flit-sanitizer`) contains **zero** Controlled Unclassified Information (CUI), **zero** ITAR-controlled technical data (22 C.F.R. Parts 120–130), and **zero** EAR-restricted physical technology files.

All files hosted in this public repository consist strictly of:
1. Published mathematical logic theorems in Microsoft Lean 4 (`formal_lean4/CxlSubflitSanitizerFormal.lean`), qualifying as fundamental mathematical research and published patent subject matter under **15 C.F.R. § 734.3(b)(3)** and **19 Pending U.S. Provisional Patent Applications**.
2. Non-reconstructible post-route utilization, timing summary, and DRC sign-off reports (`reports_public/vivado_xcvu47p_*.rpt`) and one-way cryptographic SHA-256 digests (`tests/test_silicon_signoff.py`).
3. High-level register offset maps (`registers/cxl_sanitizer_bar0_regs.h`) and untimed behavioral models (`sim/`).

## 2. Air-Gapped SBIR Data Rights Vault (DFARS 252.227-7018)
All synthesizable SystemVerilog RTL (`cxl_subflit_slot_sanitizer_core.sv`, `cxl_subflit_sanitizer_enclave_top.sv`), 7nm FinFET standard-cell Liberty models (`*.lib`), and placed-and-routed FPGA checkpoints (`*.dcp`) were developed exclusively at private expense and are maintained in an offline vault in United States. They are transmitted solely to authorized U.S. Government evaluators and cleared Defense Prime partners under **DFARS 252.227-7018** restrictive legends.
