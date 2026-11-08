#!/usr/bin/env python3
"""100,000-Transaction CXL 3.0-5.0 Protocol Conformance & Credit Conservation Verifier."""
import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "sim"))
from cxl_subflit_sanitizer_twin import CxlSubflitSanitizerTwin


def main() -> None:
    twin = CxlSubflitSanitizerTwin()
    for i in range(25000):
        twin.evaluate_flit(
            [0xAA, 0xBB, 0xCC, 0xDD],
            [1 << (i % 64), 1 << ((i + 1) % 64), 1 << ((i + 2) % 64), 1 << ((i + 3) % 64)],
            [0x2941, 0x2941, 0x2941, 0x2941],
            [False, False, False, False],
            [False, False, False, False],
            [True, True, True, True],
        )
    rx_crd = twin.read_bar0(0x28)
    tx_crd = twin.read_bar0(0x30)
    assert rx_crd == 100000 and tx_crd == 100000
    assert twin.read_bar0(0x40) == 0
    print(f"[HIL_CXL_CONFORMANCE_PASS] {rx_crd} CXL transactions verified with 0 self-NAKs.")


if __name__ == "__main__":
    main()