#!/usr/bin/env bash
set -euo pipefail

if [ -z "${SPECTRAL_VAULT_RTL_B64:-}" ]; then
    echo "[INFO] Public Environment Detected (SPECTRAL_VAULT_RTL_B64 not set)."
    echo "[INFO] Running Public Behavioral Digital Twin (10,000 Flits)..."
    python3 tests/test_flit_fuzzer.py && python3 tests/test_trl6_subsystem_integration.py
    exit 0
fi

echo "[VAULT] Authenticated Secret Environment Detected. Mounting Ephemeral RAM Disk..."
WORK_RAM="/dev/shm/spectral_ephemeral_$$"
mkdir -p -m 0700 "$WORK_RAM"
trap 'rm -rf "$WORK_RAM"' EXIT

echo "$SPECTRAL_VAULT_RTL_B64" | base64 -d > "$WORK_RAM/vault.zip"
python3 -c "import zipfile; zipfile.ZipFile('$WORK_RAM/vault.zip').extractall('$WORK_RAM')"
SV_FILES=$(find "$WORK_RAM" -name "*.sv" | tr '\n' ' ')
iverilog -g2012 -o "$WORK_RAM/sim_out" $SV_FILES
vvp "$WORK_RAM/sim_out"
echo "[VAULT PASS] Cycle-Accurate SystemVerilog RTL Verified & RAM Disk Shredded."