#!/usr/bin/env python3
import json
from pathlib import Path

def test_v1_silicon_and_cots_signoff():
    repo = Path(__file__).resolve().parent.parent
    rpt = repo / "reports_public"
    viv = json.loads((rpt / "AWS_VIVADO_SIGNOFF_SUMMARY.json").read_text(encoding="utf-8"))
    s2 = json.loads((rpt / "STAGE2_AWS_F2_SILICON_RECEIPT.json").read_text(encoding="utf-8"))
    asap = json.loads((rpt / "TRL6_ASIC_7NM_ASAP7_SIGNOFF.json").read_text(encoding="utf-8"))
    hbm = json.loads((rpt / "TRL7_AWS_F2_HBM2_DMA_RECEIPT.json").read_text(encoding="utf-8"))
    k8s = json.loads((rpt / "TRL8_K8S_OPERATOR_HIL_RECEIPT.json").read_text(encoding="utf-8"))

    assert viv["core_luts"] == 1585 and viv["core_ffs"] == 1157 and viv["bram"] == 0
    assert s2["agfi_id"] == "agfi-03b742e2a9cd2c0f2" and s2["total_subflit_slots_tested"] == 800000
    assert asap["routed_standard_cells"] == 27877 and asap["sram_macros"] == 0 and asap["tritonroute_drc_violations"] == 0
    assert hbm["agfi_id"] == "agfi-08becf3b40b169674" and hbm["rogue_hbm2_sentinels_intact"] is True
    assert k8s["rogue_widening_kubectl_rejected"] is True

if __name__ == "__main__":
    test_v1_silicon_and_cots_signoff()
    print("[SILICON_SIGNOFF_TEST_PASS] All v1.0.0 silicon, 7nm ASAP7, 16GB HBM2 DMA, and k3s HIL assertions passed.")
