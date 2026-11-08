#!/usr/bin/env python3
import random, sys, unittest
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "sim"))
from cxl_subflit_sanitizer_twin import CxlSubflitSanitizerTwin, MASK64, phi_f8_expand_10b

class TestCxlSubflitFuzzer(unittest.TestCase):
    def test_ag28_and_mds_pairwise_overlap(self) -> None:
        ag28 = [phi_f8_expand_10b(c) for c in range(64)] + [phi_f8_expand_10b(c) for c in range(512, 520)]
        self.assertEqual(len(ag28), 72)
        for i in range(72):
            self.assertEqual(ag28[i].bit_count(), 8)
            for j in range(i + 1, 72):
                self.assertLessEqual((ag28[i] & ag28[j]).bit_count(), 1)
    def test_10000_flits_40000_slots(self) -> None:
        rng = random.Random(20261107)
        twin = CxlSubflitSanitizerTwin()
        twin.write_bar0(0x00, 0xFFFFFFFFFFFFFEFF)
        sentinel = 0xAAAAAAAAAAAAAAAA
        for step in range(10000):
            if step % 250 == 0:
                prev = twin.read_bar0(0x00)
                twin.write_bar0(0x00, rng.getrandbits(64) | 0xFF)
                self.assertEqual(twin.read_bar0(0x00) & (~prev & MASK64), 0)
            out, viols, wstrb = twin.evaluate_flit(
                [0xDEADDEAD, 0x11111111, 0x22222222, 0x33333333],
                [0x0100, 0x0001, 0x0002, 0x0004],
                [0x2941, 0x2941, 0x2941, 0x2941],
                [False, False, False, False],
                [False, False, False, False],
                [True, True, True, True],
            )
            self.assertTrue(viols[0])
            self.assertEqual(out[0], 0)
            self.assertEqual(wstrb & 0xFFFF, 0)
            self.assertEqual(sentinel, 0xAAAAAAAAAAAAAAAA)
        self.assertEqual(twin.read_bar0(0x28), 40000)
        self.assertEqual(twin.read_bar0(0x30), 40000)
        self.assertEqual(twin.read_bar0(0x40), 0)

if __name__ == "__main__":
    unittest.main(verbosity=2)
