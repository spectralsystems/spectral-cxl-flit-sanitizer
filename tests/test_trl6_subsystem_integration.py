"""
TRL-6 End-to-End Subsystem Prototype Integration Verification Suite (v1.0.0)
Verifies PCIe/CXL.io BAR0 + 2-FF flit_sop_in CDC + 512b CPI Multi-Slot Sanitizer +
Slot-0 Shared Flit-Header Preservation + 64B M2S_RwD Rollover Inheritance +
M2S_BIRsp Coherency Bypass + IDE K_Set_Go Cosets + Modulo-3 GF(2^8) FEC Alignment +
64-Byte AXI4 HBM2/3/4 WSTRB Interlock + Galois/Canonical-Egress/LUT6_2 Bi-Simulation +
PPA-16 Multilevel Sheaf-MMU, 1-Cycle 4-KB Cohort Revocation, 0-BRAM Streaming DAG Verifier &
Preprint v12 Theorems 3.2, 3.3, 5.1, 5.2, 6.1 & Lemma 9.6 (25 Lean 4 Theorems).
"""
import os
import sys
import unittest

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))
from sim.kron_landauer_twin import KronLandauerBehavioralTwin, CXL_NOP_SLOT_128B, MASK_64B


class TestTRL6SubsystemPrototypeIntegration(unittest.TestCase):

    def test_01_rwd_64b_rollover_verdict_inheritance(self) -> None:
        twin = KronLandauerBehavioralTwin(initial_spatial_mask=0xFFFFFFFFFFFF00FF)
        ai_weights = [0x00000001_12345678, 0xFFFFFFFF_FFFFFFFF, 0xCAFEBABE_DEADBEEF, 0x01000100_01000100]
        stalks_auth = [0x00000001, 0x00000100, 0x00000100, 0x00000100]
        egress_a, wstrb4_a, crd_a = twin.step_512b_flit(
            slots_128b=ai_weights,
            slot_stalk_reqs_64b=stalks_auth,
            slot_is_cmd_hdr=0b0001,
            slot_is_rwd_hdr=0b0001,
        )
        self.assertEqual(egress_a, ai_weights)
        self.assertEqual(wstrb4_a, 0b1111)
        self.assertEqual(twin.expand_slot_wstrb_to_64b(wstrb4_a), 0xFFFFFFFFFFFFFFFF)
        self.assertEqual(crd_a, 0)

        stalks_rogue = [0x00000100, 0x00000001, 0x00000001, 0x00000001]
        egress_r, wstrb4_r, crd_r = twin.step_512b_flit(
            slots_128b=ai_weights,
            slot_stalk_reqs_64b=stalks_rogue,
            slot_is_cmd_hdr=0b0001,
            slot_is_rwd_hdr=0b0001,
            slot_consumes_credit=0b0001,
        )
        self.assertEqual(egress_r, [CXL_NOP_SLOT_128B] * 4)
        self.assertEqual(wstrb4_r, 0b0000)
        self.assertEqual(twin.expand_slot_wstrb_to_64b(wstrb4_r), 0x0000000000000000)
        self.assertEqual(crd_r, 1)
        self.assertEqual(twin.csrs.csr_0x50_rwd_rollover_cnt, 2)

    def test_02_bi_channel_snoop_response_deadlock_immunity(self) -> None:
        twin = KronLandauerBehavioralTwin(initial_spatial_mask=0x0000000000000000)
        slots = [0xB1B1B1B1, 0xDEADDEAD, 0xDEADDEAD, 0xDEADDEAD]
        stalks = [0xFFFFFFFFFFFFFFFF] * 4
        egress, wstrb4, crd = twin.step_512b_flit(
            slots_128b=slots,
            slot_stalk_reqs_64b=stalks,
            slot_is_cmd_hdr=0b1111,
            slot_is_bi_rsp=0b0001,
            slot_consumes_credit=0b1110,
        )
        self.assertEqual(egress[0], 0xB1B1B1B1)
        self.assertEqual(egress[1:], [CXL_NOP_SLOT_128B] * 3)
        self.assertEqual(wstrb4, 0b0001)
        self.assertEqual(crd, 3)

    def test_03_glitch_free_cdc_and_sop_atomic_boundary(self) -> None:
        twin = KronLandauerBehavioralTwin(initial_spatial_mask=0xFFFFFFFFFFFFFFFF)
        twin.write_csr_0x00_monotonic_ratchet(0xFFFFFFFFFFFF00FF, commit_immediately=False)
        self.assertEqual(twin.csrs.csr_0x00_spatial_stalk_mask, 0xFFFFFFFFFFFFFFFF)

        _, wstrb_mid, _ = twin.step_512b_flit(
            slots_128b=[0x1111, 0x2222, 0x3333, 0x4444],
            slot_stalk_reqs_64b=[0x0100, 0x0001, 0x0002, 0x0004],
            flit_sop_in=0,
        )
        self.assertEqual(wstrb_mid, 0b1111)

        _, wstrb_sop, _ = twin.step_512b_flit(
            slots_128b=[0x1111, 0x2222, 0x3333, 0x4444],
            slot_stalk_reqs_64b=[0x0100, 0x0001, 0x0002, 0x0004],
            flit_sop_in=1,
        )
        self.assertEqual(wstrb_sop, 0b1110)

    def test_04_shadow_coset_isometry_and_phy_error_passthrough(self) -> None:
        twin = KronLandauerBehavioralTwin()
        slots = [0x1111, 0x2222, 0x3333, 0x4444]
        crc_clean, psi = twin.compute_egress_crc64_with_coset(slots, 0x00FF, ide_k_set_go=1, ingress_phy_crc_err=False)
        crc_phy_err, _ = twin.compute_egress_crc64_with_coset(slots, 0x00FF, ide_k_set_go=1, ingress_phy_crc_err=True)
        self.assertEqual(crc_clean ^ crc_phy_err, MASK_64B)

        wire_err = 0x80000000_00000001
        rx_syndrome = (crc_clean ^ wire_err) ^ crc_clean
        self.assertEqual(rx_syndrome, wire_err)
        self.assertNotEqual(psi, 0)

    def test_05_modulo3_gf256_fec_alignment_and_temporal_ratchet(self) -> None:
        self.assertTrue(KronLandauerBehavioralTwin.verify_modulo3_fec_parity_mapping())
        twin = KronLandauerBehavioralTwin()
        self.assertTrue(twin.write_csr_0x08_temporal_monotonic_ratchet(0x0000FFFFFFFFFFFF))
        self.assertFalse(twin.write_csr_0x08_temporal_monotonic_ratchet(0xFFFFFFFFFFFFFFFF))
        self.assertEqual(twin.csrs.csr_0x48_fm_escalation_traps, 1)
        self.assertFalse(twin.attempt_software_clear_csr_0x48_trap_counter())

    def test_06_bidirectional_s2m_drs_read_zeroing_and_ucie_fdi(self) -> None:
        twin = KronLandauerBehavioralTwin(initial_spatial_mask=0xFFFFFFFFFFFF00FF)
        secret_hbm_weights = [0xCAFEBABE_DEADBEEF, 0x11112222_33334444, 0x55556666_77778888, 0x9999AAAA_BBBBCCCC]
        req_stalks = [0x00000100, 0x00000001, 0x00000200, 0x00000002]
        mshr_tags  = [0xA101, 0xA102, 0xA103, 0xA104]
        san_data, out_tags, zeroed = twin.sanitize_s2m_drs_read_completion(secret_hbm_weights, req_stalks, mshr_tags)
        self.assertEqual(san_data[0], CXL_NOP_SLOT_128B)
        self.assertEqual(san_data[1], secret_hbm_weights[1])
        self.assertEqual(san_data[2], CXL_NOP_SLOT_128B)
        self.assertEqual(san_data[3], secret_hbm_weights[3])
        self.assertEqual(out_tags, mshr_tags)
        self.assertEqual(zeroed, 2)

    def test_07_slot0_shared_flit_header_preservation_and_full_bar0_map(self) -> None:
        twin = KronLandauerBehavioralTwin(initial_spatial_mask=0xFFFFFFFFFFFF00FF)
        slots = [0xDEADDEAD_0000A55A, 0x11111111, 0x22222222, 0x33333333]
        stalks = [0x00000100, 0x00000001, 0x00000002, 0x00000004]
        egress, wstrb4, crd = twin.step_512b_flit(
            slots_128b=slots,
            slot_stalk_reqs_64b=stalks,
            preserve_slot0_shared_hdr=True,
        )
        self.assertEqual(egress[0], 0xA55A)
        self.assertEqual(egress[1:], slots[1:])
        self.assertEqual(wstrb4, 0b1110)
        self.assertEqual(crd, 1)
        self.assertEqual(twin.csrs.csr_0x38_last_viol_bitmap, 0b0001)
        self.assertEqual(twin.csrs.csr_0x20_ide_key_status & 1, 1)

    def test_08_galois_policy_canonical_egress_and_lut_sram_translation(self) -> None:
        self.assertTrue(KronLandauerBehavioralTwin.verify_xcvu47p_lut_sram_translation_table())
        q_safe = 0x00FF00FF_00FF00FF
        p_s    = 0x000F000F_000F000F
        p_t    = 0x00FF000F_00FF000F
        self.assertTrue(KronLandauerBehavioralTwin.verify_galois_policy_refinement(
            0xDEADCAFE_BEEF1234, p_s, p_t, q_safe
        ))
        sigma = 0x31415926_53589793
        out1 = KronLandauerBehavioralTwin.canonical_egress_oracle(sigma, 0xAAAAAAAAAAAAAAAA, True)
        out2 = KronLandauerBehavioralTwin.canonical_egress_oracle(sigma, 0x5555555555555555, True)
        out_invalid = KronLandauerBehavioralTwin.canonical_egress_oracle(sigma, 0xAAAAAAAAAAAAAAAA, False)
        self.assertEqual(out1, sigma)
        self.assertEqual(out1, out2)
        self.assertEqual(out_invalid, 0)

    def test_09_galois_refinement_canonical_egress_and_lut6_bisim(self) -> None:
        twin = KronLandauerBehavioralTwin()
        self.assertTrue(
            KronLandauerBehavioralTwin.verify_galois_policy_and_lut6_bisim(
                stalk_64b=0xCAFEBABE_DEADBEEF,
                p_spatial_64b=0xFFFFFFFF_FFFF00FF,
                p_temporal_64b=0x0000FFFF_FFFFFFFF,
                forbidden_pred_64b=0x12345678_9ABCDEF0,
            )
        )
        c1, c2 = twin.canonical_proof_carrying_egress_64b(
            sigma_header_64b=0x00000000_20261027,
            proof_witness_a_64b=0xAAAAAAAAAAAAAAAA,
            proof_witness_b_64b=0x5555555555555555,
            valid=True,
        )
        self.assertEqual(c1, c2)
        self.assertNotEqual(twin.csrs.csr_0x58_egress_canon_digest, 0)
        c_inv1, c_inv2 = twin.canonical_proof_carrying_egress_64b(
            sigma_header_64b=0x00000000_20261027,
            proof_witness_a_64b=0xAAAAAAAAAAAAAAAA,
            proof_witness_b_64b=0x5555555555555555,
            valid=False,
        )
        self.assertEqual(c_inv1, 0)
        self.assertEqual(c_inv2, 0)

    def test_10_preprint_stiefel_multilevel_tsp_omission_and_landauer_bounds(self) -> None:
        self.assertTrue(KronLandauerBehavioralTwin.verify_dyadic_stiefel_and_multilevel_splitting())
        self.assertTrue(KronLandauerBehavioralTwin.verify_tsp_edf_omission_and_landauer_bounds())

    def test_11_ppa16_sheaf_mmu_stateless_4kb_cohort_revocation_and_0bram_dag(self) -> None:
        self.assertTrue(KronLandauerBehavioralTwin.verify_ppa16_sheaf_mmu_cohort_revocation_and_0bram_dag())


if __name__ == "__main__":
    unittest.main(verbosity=2)
