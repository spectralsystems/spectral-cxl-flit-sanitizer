"""
CONSTRAINED-RANDOM-VERIFIER — Automated 10,000-Flit (40,000-Slot) CXL 3.0-5.0 Verification Suite
"""
import os
import sys
import random
import unittest

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))
from sim.kron_landauer_twin import KronLandauerBehavioralTwin, CXL_NOP_SLOT_128B


class TestKronLandauerConstrainedRandomVerifier(unittest.TestCase):

    def test_canonical_hil_canary_preservation(self) -> None:
        twin = KronLandauerBehavioralTwin(initial_spatial_mask=0xFFFFFFFFFFFFFFFF)
        twin.write_csr_0x00_monotonic_ratchet(0xFFFFFFFFFFFF00FF)
        self.assertEqual(twin.csrs.csr_0x00_spatial_stalk_mask, 0xFFFFFFFFFFFF00FF)

        allowed = twin.write_csr_0x00_monotonic_ratchet(0xFFFFFFFFFFFFFFFF)
        self.assertFalse(allowed)
        self.assertEqual(twin.csrs.csr_0x00_spatial_stalk_mask, 0xFFFFFFFFFFFF00FF)
        self.assertEqual(twin.csrs.csr_0x48_fm_escalation_traps, 1)

        egress0, wstrb0, crd0 = twin.step_512b_flit(
            slots_128b=[0xDEADDEAD, 0x11111111, 0x22222222, 0x33333333],
            slot_stalk_reqs_64b=[0x00000100, 0x00000001, 0x00000002, 0x00000004],
            ide_k_set_go=1,
            target_hbm_row=0,
        )
        self.assertEqual(egress0[0], CXL_NOP_SLOT_128B)
        self.assertEqual(wstrb0, 0b1110)
        self.assertEqual(crd0, 1)
        self.assertEqual(twin.hbm2_rows[0][0], 0xAAAAAAAA)

    def test_10000_randomized_flits(self) -> None:
        rng = random.Random(20261024)
        twin = KronLandauerBehavioralTwin(initial_spatial_mask=0xFFFFFFFFFFFFFEFF)

        for step in range(10000):
            if step % 250 == 0:
                rogue_wdata = rng.getrandbits(64)
                prev_mask = twin.csrs.csr_0x00_spatial_stalk_mask
                twin.write_csr_0x00_monotonic_ratchet(rogue_wdata)
                self.assertEqual(twin.csrs.csr_0x00_spatial_stalk_mask & ~prev_mask, 0)

            slots = [rng.getrandbits(128) | 1 for _ in range(4)]
            reqs = [0x0100, rng.getrandbits(8), rng.getrandbits(8), rng.getrandbits(8)]
            egress, wstrb, _ = twin.step_512b_flit(slots, reqs, ide_k_set_go=1, target_hbm_row=0)

            self.assertEqual(egress[0], CXL_NOP_SLOT_128B)
            self.assertEqual(wstrb & 0b0001, 0)
            self.assertEqual(twin.hbm2_rows[0][0], 0xAAAAAAAA)

        self.assertEqual(twin.csrs.csr_0x28_slots_sanitized, twin.csrs.csr_0x30_credits_refunded)
        self.assertEqual(twin.csrs.csr_0x40_self_inflicted_naks, 0)
        self.assertGreaterEqual(twin.csrs.csr_0x28_slots_sanitized, 10000)


if __name__ == "__main__":
    unittest.main(verbosity=2)
