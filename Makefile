PYTHON ?= python3

.PHONY: all lean twin fuzzer audit test

all: lean twin fuzzer audit test

lean:
	lean formal_lean4/CxlSubflitSanitizerFormal.lean
	lean formal_lean4/CxlSubflitSanitizerExtensions.lean

twin:
	$(PYTHON) sim/cxl_subflit_sanitizer_twin.py
	$(PYTHON) sim/cluster_tco_calculator.py
	$(PYTHON) sim/benchmark_workload_and_martingale.py

fuzzer:
	$(PYTHON) tests/test_flit_fuzzer.py

audit:
	$(PYTHON) tests/run_5pillar_repo_auditor.py

test:
	$(PYTHON) tests/test_silicon_signoff.py
