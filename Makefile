# Spectral Systems LLC - Deterministic Local Verification Makefile (v1.0.0 / v1.1.0)
# CAGE: 268E1 | SAM.gov UEI: VTP2JPCJU3D9 | DOI: 10.5281/zenodo.24047902
export PATH := $(HOME)/.elan/bin:$(USERPROFILE)/.elan/bin:$(PATH)
export PYTHONDONTWRITEBYTECODE := 1

PYTHON ?= $(shell command -v python3 2>/dev/null || command -v python 2>/dev/null || echo python)
CC     ?= gcc
CFLAGS ?= -std=c11 -Werror -O2 -I. -Iregisters -Iinclude -Isw -Idriver -Itests

.PHONY: all verify audit sim tco lean cdriver test

all: verify

audit:
	$(PYTHON) tests/run_5pillar_repo_auditor.py

sim:
	$(PYTHON) sim/cxl_subflit_sanitizer_twin.py

tco:
	$(PYTHON) sim/cluster_tco_calculator.py

lean:
	PATH='$$HOME/.elan/bin:$$USERPROFILE/.elan/bin:$$PATH' lean formal_lean4/CxlSubflitSanitizerFormal.lean
	PATH='$$HOME/.elan/bin:$$USERPROFILE/.elan/bin:$$PATH' lean formal_lean4/CxlSubflitSanitizerExtensions.lean
	PATH='$$HOME/.elan/bin:$$USERPROFILE/.elan/bin:$$PATH' lean formal_lean4/CxlSubflitSanitizerV110Expansion.lean

cdriver:
	$(CC) $(CFLAGS) tests/test_bar0_driver.c -o build_test_bar0_driver && ./build_test_bar0_driver && rm -f build_test_bar0_driver build_test_bar0_driver.exe

test:
	$(PYTHON) -m pytest -q -p no:cacheprovider || $(PYTHON) -m unittest discover -s tests

verify: audit sim tco lean cdriver test
	@echo '[OK] All Spectral Systems local verification gates passed.'
