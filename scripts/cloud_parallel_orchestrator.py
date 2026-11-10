#!/usr/bin/env python3
"""
6-Way Parallel Verification Orchestrator (scripts/cloud_parallel_orchestrator.py).
Executes the 6 verification lanes concurrently across CPU cores (in /dev/shm on Linux
or locally on Windows) and aggregates deterministic telemetry.
"""

import concurrent.futures
import json
import os
import subprocess
import sys
import time
from pathlib import Path


def run_cmd(label: str, cmd: list, cwd: Path) -> dict:
    t0 = time.time()
    proc = subprocess.run(cmd, cwd=str(cwd), capture_output=True, text=True)
    dt = round(time.time() - t0, 3)
    return {
        "lane": label,
        "cmd": " ".join(cmd),
        "returncode": proc.returncode,
        "elapsed_sec": dt,
        "stdout": proc.stdout.strip()[-400:],
        "stderr": proc.stderr.strip()[-400:],
    }


def main() -> None:
    repo_root = Path(__file__).resolve().parent.parent
    py = sys.executable

    lanes = [
        ("Lane1_DigitalTwin", [py, "sim/cxl_subflit_sanitizer_twin.py"]),
        ("Lane2_FlitFuzzer_40k", [py, "tests/test_flit_fuzzer.py"]),
        ("Lane3_Stage0_BAR0_100k", [py, "tests/test_stage0_pcie_bar0_mmio_loopback.py"]),
        ("Lane4_HIL_CXL_100k", [py, "hil_conformance/test_hil_cxl_traffic.py"]),
        ("Lane5_Cluster_TCO_Martingale", [py, "sim/cluster_tco_calculator.py"]),
        ("Lane6_SPDM_ZK_LEC_Endgame", [py, "cloud_trl8_aws_f2/spdm_attestation/spdm_measure.py"]),
    ]

    results = []
    with concurrent.futures.ThreadPoolExecutor(max_workers=6) as pool:
        futs = {pool.submit(run_cmd, name, cmd, repo_root): name for name, cmd in lanes}
        for f in concurrent.futures.as_completed(futs):
            res = f.result()
            results.append(res)
            if res["returncode"] != 0:
                raise RuntimeError(f"Lane {res['lane']} failed: {res['stderr']}\n{res['stdout']}")

    # Run Endgame & 5-Pillar Auditor sequentially after lanes complete
    for post_name, post_cmd in [
        ("Post_Endgame_Audit", [py, "tests/test_silicon_signoff.py"]),
        ("Post_5Pillar_Audit", [py, "tests/run_5pillar_repo_auditor.py"]),
    ]:
        r = run_cmd(post_name, post_cmd, repo_root)
        results.append(r)
        if r["returncode"] != 0:
            raise RuntimeError(f"{post_name} failed: {r['stderr']}\n{r['stdout']}")

    rpt = repo_root / "reports_public" / "PARALLEL_ORCHESTRATOR_RECEIPT.json"
    rpt.write_text(json.dumps({"lanes": results, "status": "ALL_6_LANES_PASS"}, indent=2) + "\n", encoding="utf-8")
    print("[PARALLEL_6WAY_ORCHESTRATOR_PASS] All 6 parallel verification lanes completed.")


if __name__ == "__main__":
    main()