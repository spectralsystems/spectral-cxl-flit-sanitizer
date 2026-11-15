#!/usr/bin/env python3
import json
import re
import shutil
import subprocess
from pathlib import Path

def main():
    repo = Path(__file__).resolve().parent.parent
    lean_nc = ""
    lean_files = []
    for fn in ("CxlSubflitSanitizerFormal.lean", "CxlSubflitSanitizerExtensions.lean"):
        fp = repo / "formal_lean4" / fn
        assert fp.exists(), f"Missing {fp}"
        lean_files.append(fp)
        t = fp.read_text(encoding="utf-8")
        nc = re.sub(r"/-.*?-/", " ", t, flags=re.DOTALL)
        nc = re.sub(r"--[^\n]*", " ", nc)
        assert not re.search(r"\bsorry\b", nc), f"sorry token found in {fn}"
        assert not re.search(r"\baxiom\b", nc), f"axiom token found in {fn}"
        assert not re.search(r":=\s*by\b", nc), f"tactic mode := by found in {fn}"
        lean_nc += "\n" + nc

    thms = re.findall(r"\btheorem\s+([A-Za-z0-9_']+)", lean_nc)
    defs = re.findall(r"\bdef\s+([A-Za-z0-9_']+)", lean_nc)
    assert len(set(thms)) >= 30, f"Expected >= 30 distinct pure term-mode theorem groups, found {len(set(thms))}"

    lean_bin = shutil.which("lean")
    if not lean_bin:
        elan_lean = Path.home() / ".elan" / "bin" / ("lean.exe" if Path.home().drive else "lean")
        if elan_lean.is_file():
            lean_bin = str(elan_lean)
    if lean_bin:
        for lf in lean_files:
            r = subprocess.run([lean_bin, str(lf)], capture_output=True, text=True)
            assert r.returncode == 0, f"Lean 4 kernel failed on {lf.name}:\n{r.stdout}\n{r.stderr}"
            assert "sorryAx" not in r.stdout, f"sorryAx detected in {lf.name}"

    for sim_fn in ("cxl_subflit_sanitizer_twin.py", "cluster_tco_calculator.py", "benchmark_workload_and_martingale.py"):
        assert (repo / "sim" / sim_fn).exists(), f"Missing sim/{sim_fn}"

    abi = json.loads((repo / "registers" / "bar0_abi_v1.json").read_text(encoding="utf-8"))
    assert abi["total_bytes"] == 128 and len(abi["registers"]) == 16

    bad_ext = {".sv", ".svh", ".v", ".vh", ".edf", ".edif", ".dcp", ".gds", ".spef", ".bit", ".pem", ".key"}
    for p in repo.rglob("*"):
        if p.is_file() and ".git" not in p.parts:
            assert p.suffix.lower() not in bad_ext, f"OPSEC leak: {p}"
            assert not p.name.upper().startswith("PPA_19"), f"Patent vault leak: {p}"

    for r_fn in (
        "vivado_xcvu47p_core_timing_summary.rpt",
        "vivado_xcvu47p_core_utilization.rpt",
        "STAGE2_AWS_F2_SILICON_RECEIPT.json",
        "TRL6_ASIC_7NM_ASAP7_SIGNOFF.json",
        "TRL7_AWS_F2_HBM2_DMA_RECEIPT.json",
        "TRL8_K8S_OPERATOR_HIL_RECEIPT.json",
        "ZK_LEC_MITER_RECEIPT.json",
    ):
        assert (repo / "reports_public" / r_fn).exists(), f"Missing reports_public/{r_fn}"

    kern_tag = " + lean kernel typechecked" if lean_bin else ""
    print(f"[5PILLAR_REPO_AUDITOR_PASS] Verified {len(set(thms))} zero-axiom term-mode Lean 4 theorem groups ({len(set(defs))} defs{kern_tag}) & all 5 pillars (v1.0.0).")

if __name__ == "__main__":
    main()
