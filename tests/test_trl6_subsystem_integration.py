#!/usr/bin/env python3
import sys, unittest
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "sim"))
from cxl_subflit_sanitizer_twin import CxlSubflitSanitizerTwin, BAR0_OFFSETS

class TestSubsystemIntegrationV1(unittest.TestCase):
    def test_16_csr_bar0_ratchet_and_warm_flr(self) -> None:
        twin = CxlSubflitSanitizerTwin()
        self.assertEqual(len(BAR0_OFFSETS), 16)
        twin.write_bar0(0x70, 0xFFFFFFFFFFFFFFEB)
        self.assertEqual(twin.read_bar0(0x70), 0xFFFFFFFFFFFFFFEB)
        twin.write_bar0(0x70, 0xFFFFFFFFFFFFFFFF)
        self.assertEqual(twin.read_bar0(0x70), 0xFFFFFFFFFFFFFFEB)
        self.assertEqual(twin.read_bar0(0x48), 1)
        twin.warm_flr_reset()
        self.assertEqual(twin.read_bar0(0x70), 0xFFFFFFFFFFFFFFEB)
    def test_bi_rsp_snoop_progress_and_ooo_dma_replay(self) -> None:
        twin = CxlSubflitSanitizerTwin()
        twin.write_bar0(0x00, 0x0)
        out, viols, wstrb = twin.evaluate_flit(
            [0xB1B1B1B1, 0xDEAD, 0xDEAD, 0xDEAD],
            [0x1, 0x1, 0x1, 0x1],
            [0x2941, 0x2941, 0x2941, 0x2941],
            [False, False, False, False],
            [True, False, False, False],
            [True, True, True, True],
        )
        self.assertEqual(viols, [False, True, True, True])
        self.assertEqual(out[0], 0xB1B1B1B1)
        self.assertEqual(wstrb, 0x000000000000FFFF)
        twin.write_bar0(0x78, (1 << 63) | (0x12345 << 10) | (0 << 8) | 0xA5)
        self.assertTrue(twin.check_dma_beat(0, 0x12345, 7))
        self.assertFalse(twin.check_dma_beat(0, 0x12345, 7))

if __name__ == "__main__":
    unittest.main(verbosity=2)
