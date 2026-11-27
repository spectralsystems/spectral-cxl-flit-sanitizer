"""
SPECTRAL FLIT-FILTER v1.0.0 -- Hyperscale CXL Rack, Regional Corridor & Fleet TCO Calculator
Parameterized by CXL pool fraction alpha_pool in [0.25, 1.0].
"""
import argparse


def run_tco_audit(racks: int, tb_per_rack: float, dram_cost_per_gb: float, pue: float, alpha_pool: float) -> None:
    total_pool_tb = racks * tb_per_rack
    total_pool_gb_dec = total_pool_tb * 1000.0
    total_pool_gib_bin = total_pool_tb * 1024.0

    sota_wasted_tb_dec = total_pool_tb * 0.015625
    sota_wasted_tib_bin = total_pool_gib_bin * 0.015625 / 1000.0
    sota_capex_usd = (total_pool_gib_bin * 0.015625) * dram_cost_per_gb
    sota_mw_dec = ((total_pool_gb_dec * 0.015625 * 0.45) / 1e6) * pue
    sota_mw_bin = ((total_pool_gib_bin * 0.015625 * 0.45) / 1e6) * pue

    cheri_capex_usd = (total_pool_gib_bin * 0.125) * dram_cost_per_gb
    kl_total_mw = (racks * 0.00142 / 1e6) * pue

    va_lo, va_hi = 450.0 * alpha_pool, 600.0 * alpha_pool
    us_lo, us_hi = 1.65 * alpha_pool, 2.55 * alpha_pool

    print("=" * 86)
    print(f" SPECTRAL FLIT-FILTER v1.0.0 -- RACK & CORRIDOR TCO AUDIT (alpha_pool = {alpha_pool:.2f})")
    print(f" Cluster Scale : {racks:,} Racks | {tb_per_rack:.0f} TB/Rack ({total_pool_tb:,.0f} TB Pooled HBM/DDR5)")
    print("=" * 86)
    print(f" [1] Per-Cluster DRAM Reclaimed : {sota_wasted_tb_dec:,.1f} TB ({sota_wasted_tib_bin:,.1f} TiB) [250 GB/Rack]")
    print(f" [2] Per-Cluster CapEx Saved    : ${sota_capex_usd/1e6:,.2f}M (vs. Table Firewall) | ${cheri_capex_usd/1e6:,.2f}M (vs. CHERI)")
    print(f" [3] Continuous Metadata Power  : {sota_mw_dec:,.3f}-{sota_mw_bin:,.3f} MW saved vs. {kl_total_mw:.6f} MW enclave")
    print(f" [4] Virginia Corridor Relief   : {va_lo:,.1f}-{va_hi:,.1f} MW baseload (alpha_pool = {alpha_pool:.2f})")
    print(f" [5] U.S. Fleet Sensitivity     : {us_lo:,.2f}-{us_hi:,.2f} GW baseload (alpha_pool = {alpha_pool:.2f})")
    print("=" * 86)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--racks", type=int, default=10000)
    parser.add_argument("--tb-per-rack", type=float, default=16.0)
    parser.add_argument("--dram-cost", type=float, default=15.0)
    parser.add_argument("--pue", type=float, default=1.25)
    parser.add_argument("--alpha-pool", type=float, default=1.0)
    args = parser.parse_args()
    run_tco_audit(args.racks, args.tb_per_rack, args.dram_cost, args.pue, args.alpha_pool)
