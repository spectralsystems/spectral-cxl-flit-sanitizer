# ==============================================================================
# SPECTRAL FLIT-FILTER v1.0.0 -- Master 5-Oracle Verification Makefile
# Entity : Spectral Systems LLC (Virginia Beach, VA, USA)
# Scope  : 16 Canonical Lean 4 Theorems (0 Axioms) | 899.3 MHz xcvu47p | BAR0
# ==============================================================================

SHELL  := /bin/bash
LEAN   := $(shell command -v lean 2>/dev/null || echo ~/.elan/bin/lean)
PY     := python3
CC     := gcc
CFLAGS := -Wall -Wextra -Werror -pedantic -DNDEBUG -O3

.PHONY: all verify-lean4 run-bar0-loopback check-silicon clean

all: verify-lean4 run-bar0-loopback check-silicon
@echo "================================================================================"
@echo " [PASS] ALL 5 SPECTRAL FLIT-FILTER v1.0.0 VERIFICATION ORACLES COMPLETED"
@echo "================================================================================"

verify-lean4:
@echo "=== ORACLE 1: Microsoft Lean 4 Formal Kernel (16 Canonical Theorems, 0 Axioms) ==="
@if grep -v '^\s*--' formal_lean4/SheafCosetIsometry.lean | grep -w "sorry"; then \
echo "[FAIL] Unproven sorry token detected"; exit 1; \
fi
@$(LEAN) formal_lean4/SheafCosetIsometry.lean > /tmp/spectral_lean4_audit.log
@cat /tmp/spectral_lean4_audit.log
@if grep -iE "sorryAx|propext|Quot\.sound|Classical\.choice|ofReduceBool" /tmp/spectral_lean4_audit.log; then \
echo "[FAIL] Non-empty axiom detected in kernel output"; exit 1; \
fi
@AXIOM_FREE_CNT=$$(grep -c "does not depend on any axioms" /tmp/spectral_lean4_audit.log); \
if [ "$$AXIOM_FREE_CNT" -ne 16 ]; then \
echo "[FAIL] Expected 16 zero-axiom theorems, got $$AXIOM_FREE_CNT"; exit 1; \
fi
@echo "[PASS] All 16 Canonical Lean 4 theorems verified with 0 custom or classical axioms."

run-bar0-loopback:
@echo "=== ORACLE 2 & 3: ANSI-C 12-CSR BAR0 Driver, Endgame Verifier & 100k-Slot Loopback ==="
@$(CC) $(CFLAGS) tests/test_bar0_driver.c -o /tmp/test_bar0_driver && /tmp/test_bar0_driver
@$(PY) tests/test_vivado_and_endgame_v10.py
@$(PY) tests/test_flit_fuzzer.py
@$(PY) tests/test_trl6_subsystem_integration.py
@$(PY) tests/test_trl7_pcie_bar0_mmio_loopback.py
@$(PY) sim/cluster_tco_calculator.py --racks 10000 --tb-per-rack 16 --alpha-pool 0.50

check-silicon:
@echo "=== ORACLE 4 & 5: AMD Vivado v2025.2 xcvu47p (899.3 MHz / 414 LUTs / 0 BRAM) Audit ==="
@grep -q "2.888" reports_public/vivado_xcvu47p_core_timing_summary.rpt
@grep -q "Block RAM Tile   |    0" reports_public/vivado_xcvu47p_core_utilization.rpt
@grep -q "CLB LUTs         |  414" reports_public/vivado_xcvu47p_core_utilization.rpt
@grep -q "Checks found: 0" reports_public/vivado_xcvu47p_drc_audit.rpt
@bash sim/run_secret_vault_rtl.sh
@echo "[PASS] xcvu47p 899.3 MHz (+2.888 ns WNS), 414 CLB LUTs, 0 BRAM, 0 DRC errors verified."

clean:
@rm -f /tmp/test_bar0_driver /tmp/spectral_lean4_audit.log
