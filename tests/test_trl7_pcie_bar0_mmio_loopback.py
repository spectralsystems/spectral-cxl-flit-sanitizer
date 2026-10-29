"""
TRL-7 Host OS BAR0 MMIO 4-KB Virtual Aperture & LUT6_2 Gate-Level Loopback Suite
Streams 25,000 512-bit CXL 3.0/4.0 flits (100,000 sub-flit slots) and 1,000 Fabric Manager
privilege-escalation writes across an anonymous 4-KB mmap BAR0 register aperture.
"""
import mmap
import os
import struct
import sys
import unittest

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))
from sim.kron_landauer_twin import KronLandauerBehavioralTwin, CXL_NOP_SLOT_128B


class TestTRL7PCIeBAR0MMIOLoopback(unittest.TestCase):

    def test_trl7_100k_slot_mmap_bar0_loopback(self) -> None:
        twin = KronLandauerBehavioralTwin(initial_spatial_mask=0xFFFFFFFFFFFF00FF)
        bar0_map = mmap.mmap(-1, 4096)
        try:
            # 1. Inject 1,000 compromised Fabric Manager privilege-escalation attacks
            for _ in range(1000):
                allowed = twin.write_csr_0x00_monotonic_ratchet(0xFFFFFFFFFFFFFFFF)
                self.assertFalse(allowed)
            self.assertEqual(twin.csrs.csr_0x48_fm_escalation_traps, 1000)

            # 2. Stream 25,000 512-bit flits (100,000 128-bit slots) through LUT6_2 bi-sim model
            slots = [0xDEADDEAD_CAFEBABE, 0x11111111, 0x22222222, 0x33333333]
            stalks = [0x00000100, 0x00000001, 0x00000002, 0x00000004]
            for _ in range(25000):
                egress, wstrb4, crd = twin.step_512b_flit(slots, stalks, ide_k_set_go=1, target_hbm_row=0)
                self.assertEqual(egress[0], CXL_NOP_SLOT_128B)
                self.assertEqual(wstrb4, 0b1110)
                self.assertEqual(crd, 1)

            c1, c2 = twin.canonical_proof_carrying_egress_64b(0x20261027, 0xAAAA, 0x5555, valid=True)
            self.assertEqual(c1, c2)

            # 3. Sync 12-CSR BAR0 telemetry into 4-KB mmap aperture and verify binary offsets
            bar0_map[0x00:0x08] = struct.pack("<Q", twin.csrs.csr_0x00_spatial_stalk_mask)
            bar0_map[0x08:0x10] = struct.pack("<Q", twin.csrs.csr_0x08_temporal_stalk_mask)
            bar0_map[0x28:0x30] = struct.pack("<Q", twin.csrs.csr_0x28_slots_sanitized)
            bar0_map[0x30:0x38] = struct.pack("<Q", twin.csrs.csr_0x30_credits_refunded)
            bar0_map[0x40:0x48] = struct.pack("<Q", twin.csrs.csr_0x40_self_inflicted_naks)
            bar0_map[0x48:0x50] = struct.pack("<Q", twin.csrs.csr_0x48_fm_escalation_traps)
            bar0_map[0x58:0x60] = struct.pack("<Q", twin.csrs.csr_0x58_egress_canon_digest)

            self.assertEqual(struct.unpack("<Q", bar0_map[0x28:0x30])[0], 25000)
            self.assertEqual(struct.unpack("<Q", bar0_map[0x30:0x38])[0], 25000)
            self.assertEqual(struct.unpack("<Q", bar0_map[0x40:0x48])[0], 0)
            self.assertEqual(struct.unpack("<Q", bar0_map[0x48:0x50])[0], 1000)
            self.assertEqual(twin.hbm2_rows[0][0], 0xAAAAAAAA)
        finally:
            bar0_map.close()


if __name__ == "__main__":
    unittest.main(verbosity=2)
