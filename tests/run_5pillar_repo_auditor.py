#!/usr/bin/env python3
"""5-Pillar Repository Auditor (Read-Only Delegate to 7-Oracle Master Suite)."""
import sys, pathlib, subprocess
REPO = pathlib.Path(__file__).resolve().parent.parent
if __name__ == "__main__":
    p = subprocess.run([sys.executable, str(REPO / "VERIFY_ALL_ONE_CLICK.py")], cwd=str(REPO))
    sys.exit(p.returncode)
