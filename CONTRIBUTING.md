# Contributing & Audit Guidelines

1. **Zero Unproven Axioms**: Every theorem in `formal_lean4/` must compile cleanly under `leanprover/lean4:stable` with zero `sorry` statements.
2. **Strict Air-Gap Enforcement**: Never submit pull requests containing `.sv`, `.v`, `.vhdl`, `.lib`, `.dcp`, or `.bit` files.
3. **Cryptographic Ledger Sync**: Any modification to public verification scripts must be accompanied by an updated SHA-256 manifest in `tests/test_vivado_and_endgame_v10.py`.