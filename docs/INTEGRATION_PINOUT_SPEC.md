# Black-Box ASIC / FPGA Drop-In Integration, Pinout & IEEE 1800-2017 / P3164 SVA Specification

## 1. Top-Level Hard Macro Boundary Pinout

| Signal Name | Direction | Width | Clock Domain | Functional Description |
| :--- | :-: | :-: | :--- | :--- |
| `clk` | Input | 1 | `1.0 GHz` CPI | Primary cut-through pipeline clock (`1000 ps` ASIC / `4.000 ns` `xcvu47p` constraint, `899.3 MHz` $F_{\max}$). |
| `rst_n` | Input | 1 | Async Low | Cold-boot power-on reset (sole reset path for monotonic `CSR 0x00/0x08` ratchets and `CSR 0x48` trap counter). |
| `s_flit_payload_i` | Input | 512 | `clk` | Ingress CXL 3.0–5.0 / UCIe 2.0 512-bit flit (`4 x 128-bit` co-packed protocol slots). |
| `s_slot_stalk_i` | Input | 256 | `clk` | Per-slot capability stalks (`4 x 64-bit` source/destination security credentials). |
| `ide_k_set_go_i` | Input | 1 | `clk` | Native CXL IDE `Key_Set_Select` (`K_Set_Go`) epoch wire (`0` extra DLP header bits). |
| `m_flit_payload_o` | Output | 512 | `clk` (+4 cyc) | Sanitized egress flit (rogue write slots replaced with `CXL_NOP`; rogue `S2M_DRS` read data zeroed with `Tag_ID` preserved). |
| `m_hbm_wstrb_o` | Output | 64 | `clk` (+4 cyc) | JEDEC HBM2/3/4 AXI4 byte-enable write strobe (`16B x 4` slots); forced to `16'h0000` per violating slot. |
| `m_pcie_crd_pulse_o` | Output | 4 | `clk` (+1 cyc) | Per-slot synthetic `+CRD` flow-control credit return pulse to upstream switch port (`CSR 0x28 == CSR 0x30`). |
| `bar0_mmio_bus` | In/Out | 64 | `clk` | PCIe/CXL.io `BAR0` 12-CSR MMIO interface (`0x00`/`0x08` Ratchets, `0x10`–`0x58` Telemetry & Canonical Egress). |

## 2. Public Black-Box IEEE 1800-2017 SystemVerilog Assertion (SVA) & IEEE P3164 Contract

~~~systemverilog
// Property 1 (Lean Theorems 7 & 10): Spatial BAR0 CSR 0x00 Monotonic AND-Ratchet Lockdown
property p_monotonic_csr_ratchet_no_escalation;
  @(posedge clk) disable iff (!rst_n)
  (bar0_we && (bar0_addr == 8'h00)) |=> ((csr_0x00_mask & ~$past(csr_0x00_mask)) == 64'h0);
endproperty
assert property (p_monotonic_csr_ratchet_no_escalation);

// Property 2 (Lean Theorems 4, 10 & 11): Temporal BAR0 CSR 0x08 Monotonic AND-Ratchet Lockdown
property p_temporal_csr_0x08_ratchet_no_escalation;
  @(posedge clk) disable iff (!rst_n)
  (bar0_we && (bar0_addr == 8'h08)) |=> ((csr_0x08_mask & ~$past(csr_0x08_mask)) == 64'h0);
endproperty
assert property (p_temporal_csr_0x08_ratchet_no_escalation);

// Property 3 (Lean Theorems 2, 6, 9, 13, 16, 24 & 25): Surgical CXL_NOP, +1 CRD Refund & HBM WSTRB Gate
property p_surgical_nop_and_credit_conservation;
  @(posedge clk) disable iff (!rst_n)
  (slot0_sheaf_defect != 64'h0 && slot_is_cmd_hdr[0] && !slot_is_bi_rsp[0])
  |-> (m_pcie_crd_pulse_o[0] == 1'b1) ##3 (m_hbm_wstrb_o[15:0] == 16'h0000);
endproperty
assert property (p_surgical_nop_and_credit_conservation);

// Property 4 (Lean Theorem 23 — CXL 3.0-5.0 Coherency Invariant): Unconditional M2S_BIRsp Snoop Cut-Through
property p_bi_channel_forward_progress_no_deadlock;
  @(posedge clk) disable iff (!rst_n)
  (slot_is_bi_rsp[0] == 1'b1) |-> (s1_defect_vec[0] == 1'b0);
endproperty
assert property (p_bi_channel_forward_progress_no_deadlock);

// Property 5 (Lean Theorem 15): Zero-Leakage Beta-Eta Canonical Proof-Carrying Egress (CSR 0x58)
property p_canonical_egress_zero_leakage;
  @(posedge clk) disable iff (!rst_n)
  (!egress_proof_valid) |-> (csr_0x58_canon_digest == 64'h0);
endproperty
assert property (p_canonical_egress_zero_leakage);

// Property 6 (Lean Theorem 18 / PPA-16 Claim 1): 1-Cycle Stateless 4-KB Cohort Revocation (Delta t_CRD == 0)
property p_stateless_4kb_cohort_revocation_1cycle;
  @(posedge clk) disable iff (!rst_n)
  ((s_slot_stalk_i[63:0] & cohort_revoked_mask_64b) != 64'h0 && slot_is_cmd_hdr[0] && !slot_is_bi_rsp[0])
  |-> (s1_defect_vec[0] == 1'b1);
endproperty
assert property (p_stateless_4kb_cohort_revocation_1cycle);

// Property 7 (Lean Theorem 19 / PPA-16 Claim 2): 0-BRAM Streaming DAG Proof-Cochain Monotonic Accumulator
property p_streaming_dag_cochain_0bram_monotonic;
  @(posedge clk) disable iff (!rst_n)
  (dag_step_valid) |=> ((dag_cochain_acc_q & ~$past(dag_cochain_acc_q)) == 64'h0);
endproperty
assert property (p_streaming_dag_cochain_0bram_monotonic);
~~~
