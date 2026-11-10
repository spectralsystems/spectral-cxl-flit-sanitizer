#!/usr/bin/env python3
"""DOE SST (Structural Simulation Toolkit) CXL 3.0 Sub-Flit Interposer Adapter."""
import json
from cxl_subflit_sanitizer_twin import CxlSubflitSanitizerTwin

if __name__ == "__main__":
    twin = CxlSubflitSanitizerTwin()
    print(json.dumps({"sst_adapter": "READY", "csr_0x00": hex(twin.read_bar0(0x00))}))