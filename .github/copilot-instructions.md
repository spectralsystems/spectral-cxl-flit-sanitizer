# SPECTRAL SYSTEMS LLC -- AUTONOMOUS AGENT CONSTITUTION (`v1.0.0`)

## 1. Two-Zone Air-Gap & Sovereign IP Rules (`DFARS 252.227-7018` / `DEAR 952.227-14`)
- **Workspace Root:** `C:\Spectral_Systems` (Zone 0 Author Manuscript, Zone 2 Public GitHub Repo Staging, Zone 3 Clean Agency Briefings, `scripts_local`).
- **Air-Gapped Vault:** `C:\Spectral_Vault_DFARS` (Zone 1 Private synthesizable `.sv` RTL, encrypted `.edf`/`.dcp`, USPTO PPA files, `.pem` keys, AWS F2 run archives).
- **STRICT PROHIBITION:** Never copy `.sv`, `.vhd`, `.edf`, `.dcp`, `.bit`, `.xsa`, `.pem`, or `.clixml` files into `C:\Spectral_Systems\02_GitHub_Repo_Staging`.
- **PUBLIC OPSEC:** Never write private patent application serials, confirmation numbers (`#7627`, `#2351`), internal docket tags (`SPEC-PPA-`), USPTO Customer Numbers (`246935`), or local Windows user paths (`C:\Users\`) into public Website HTML, GitHub Wiki, or public README surfaces. Always use **`All Patents Pending`**.

## 2. Canonical Release `v1.0.0` Hardware, Formal & Control-Plane Telemetry (Zero Drift)
- **Entity Identifiers:** Spectral Systems LLC / Sole Inventor: Eric C. Murphy (`37 C.F.R. 1.41`, `90 FR 54636`) / CAGE: `268E1` / SAM.gov UEI: `VTP2JPCJU3D9` / Domain: `https://spectralsystems.org`
- **Active Artifact Digests:** `preprint_Murphy_v1_0_0.tex` (`b576d886ee3f8605bfe39cd938aebd20170d342536eb0f5951321b901e9b6d4e`) / `preprint_Murphy_v1_0_0.pdf` (`7cdc29d8e064967bdf916ab796781a1ef1402bfe721606f0639205b24182605c`)
- **Formal Verification:** `30` zero-axiom `Init.Prelude` Lean 4 theorem groups (`thm00`--`thm29`, `33` verified groups / `41` definitions in extended suite), `0` `sorry`, `0` `axiom`, `0` `propext`, `0` `by`-tactics, `100%` pure term-mode (`Bool.rec` / `Nat.rec` / `rfl`).
- **16nm FPGA Sign-Off (`xcvu47p-fsvh2892-2L-e`, Vivado `v2025.2`):** `1,585` Core CLB LUTs (`0.12%`, `321` CLBs), `1,157` FFs (`341` Scrub Shim LUTs, `2,555` Cycle-0 LUTs, `5,459` 4-Stage Wrapper LUTs / `3,461` FFs), `0` BRAM, `0` URAM, `0` LUTRAM, `0` DSP, `+1.048 ns` WNS (`338.8 MHz`), `35.0 mW`, `0` DRC.
- **7nm FinFET CMOS Sign-Off (`ASAP7` `asap7sc7p5t`, OpenROAD + OpenRCX + OpenSTA):** `9,678` core cells (`11,420` NAND2 GE, `0.00224 mm^2`); `27,877` placed-and-routed enclave cells (`3,335.45 um^2` / `0.003335 mm^2`), `0` SRAM, `0` DRC, `+2,556.41 ps` WNS, `1,443.59 ps` critical path (`693 MHz` = `2.77x` overdrive), `3.728 mW`.
- **Live AWS EC2 `f2.6xlarge` Dual-AFI Receipts:**
  1. **Track B.1 BIST & TVLA:** `agfi-03b742e2a9cd2c0f2` (`afi-07282de69eecfd279`), `+1.842 ns` WNS @ `250.0 MHz` (`128.0 Gbps`), `800,000` sub-flit slots (`400,000` rogue scrubbed), `WSTRB = 0x0000FFFF0000FFFF`, post-warm-FLR `CSR[0x70] = 0xFFFFFFFFFFFFFFEB`, `19,990`-trace Welch TVLA `max |t| = 0.0 < 4.5`.
  2. **Track B.2 16 GB HBM2 DMA:** `agfi-08becf3b40b169674` (`afi-0f2ddd7dc87d81193`), `+0.512 ns` WNS, BDF `0000:34:00.0`, `16 GB` HBM2 (`0x0300 = 0x00000006`) @ `PF0-BAR4` `0x1000000000`, `25,000` bursts (`50,128` flits, `100,000` inline slots), allied `0x5555555555555555`, sentinel `0xAAAAAAAAAAAAAAAA` (`100%` intact), BF16 `0x3F8E3F8E -> 0x3F803F80`, `0` Completion Timeouts (`CmpltTO == 0`).
- **Track C Kubernetes Control Plane (`k3s` + `spectralc v1.0.0`):** `16-CSR` (`128 B`) `BAR0` ABI (`0x00`--`0x78`), FIPS-204 `ML-DSA-87` attestation, `1.36 ms` HTTP `403 Forbidden` admission block on rogue `0 -> 1` bit-widening.
- **Exascale 10,000-Rack TCO & Link Goodput:** `99.20%` surgical sub-flit goodput (vs. `48.90%` under tail-CRC poisoning), `8.0 ns` Sparse-MoE P99.99 tail latency (vs. `184.2 ns` on LBNL *Space-Control* and `34.8 ns` on CHERI), reclaiming `2,500.0 TB` (`250 GB/rack`) HBM/DDR5 (`$37.50M--$38.40M` CapEx) and saving `8.01--39.44 MW` (`1.44 MW` passive refresh + `6.60--38.00 MW` active wait-state power).

## 3. Mandatory Deterministic Verification Gate After Any Edit
After editing any file in `C:\Spectral_Systems`, always run:
`python C:\Spectral_Systems\02_GitHub_Repo_Staging\tests\run_5pillar_repo_auditor.py`
and verify `0` errors before committing.
