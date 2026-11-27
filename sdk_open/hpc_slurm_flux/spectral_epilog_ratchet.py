#!/usr/bin/env python3
"""Slurm / Flux Epilog Hook for 1-Cycle CXL Cohort & Tenant SPID Revocation."""
import json

def revoke_slurm_job_tenant(spid_slot: int) -> dict:
    mask = ~(1 << (spid_slot & 0x3F)) & 0xFFFFFFFFFFFFFFFF
    return {"csr_0x70_write": f"0x{mask:016X}", "revoked_slot": spid_slot}

if __name__ == "__main__":
    print(json.dumps(revoke_slurm_job_tenant(7)))