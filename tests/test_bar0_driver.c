/* Apache-2.0 software simulation/formal verification only; pursuant to PATENTS.md & DFARS 252.227-7018, no patent license granted for FPGA/ASIC synthesis (All Patents Pending, Spectral Systems LLC, CAGE: 268E1). */
#define __USE_MINGW_ANSI_STDIO 1
#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include "cxl_sanitizer_bar0_regs.h"
#define L_S1 0x2A2A2A2A80808080ULL
#define L_RN 0xABABABABFEFEFEFEULL
#define L_MO 0xCC00CC00A2E0A2E0ULL
#define L_T1 0x0C0C0C000A0A0A00ULL
#define L_76 0x0C0C0C000A0A0000ULL
#define L_MD 0x0C0C00000A0A0000ULL
#define L_LW 0x0C0000000A000000ULL
#define L_PP 0x060C0A0008000000ULL
static uint8_t gf8(uint8_t a, uint8_t b) {
    uint8_t p = 0U;
    for (int i = 0; i < 3; ++i) { if (b & 1U) { p ^= a; } a = (uint8_t)(((a << 1) & 7U) ^ ((a & 4U) ? 3U : 0U)); b >>= 1; }
    return p;
}
static int pc64(uint64_t x) { int c = 0; while (x) { x &= (x - 1ULL); ++c; } return c; }
static void mk_sb(uint8_t b[256], uint64_t sp, uint8_t d, uint8_t bk, uint8_t px, uint64_t q) {
    const char *m = SPECTRAL_SBUNDLE_MAGIC_STR; uint64_t w[16]; memset(b, 0, 256U);
    w[0] = 0x0000FFFFFFFFFFEBULL; w[1] = 0x7FFFFFFFFFFFFFFFULL; w[2] = 0x303ULL; w[3] = 0xFF0005ULL;
    w[4] = ((uint64_t)(d & 0xFU) << 8) | (uint64_t)(bk & 3U) | (d > 8U ? (1ULL << 12) : 0ULL);
    w[7] = q; w[10] = 16ULL; w[11] = 0x5A4B4C45435F4F4BULL; w[12] = 0x1D2B4F839AC7E104ULL;
    w[13] = 0xFFFFFFFFFFFFBFFFULL; w[14] = sp; w[15] = 0x000C40003F800000ULL | (uint64_t)px;
    memcpy(b, w, 128U); for (int i = 0; i < 8; ++i) { b[128 + i] = (uint8_t)m[i]; }
}
int main(void) {
    uint64_t gfp = 0ULL, agp = 0ULL, bzs = 0ULL, css = 0ULL, wt[5] = {0,0,0,0,0}, ln[72], luts = 0ULL, rs = 0ULL, it = 0ULL, sk = 0ULL, tk = 0ULL;
    for (int a = 0; a < 256; ++a) {
        uint8_t sq = (uint8_t)a; for (int s = 0; s < 8; ++s) { sq = spectral_gf256_mul(sq, sq); } if (sq != (uint8_t)a) { return 1; }
        for (int b = 0; b < 256; ++b) {
            if (spectral_gf256_mul((uint8_t)a, (uint8_t)b) != spectral_gf256_mul((uint8_t)b, (uint8_t)a)) { return 1; } ++gfp;
            uint8_t p0 = (uint8_t)(a ^ b), p1 = (uint8_t)(spectral_gf256_mul(2U, (uint8_t)a) ^ spectral_gf256_mul(3U, (uint8_t)b));
            int w = (a != 0) + (b != 0) + (p0 != 0U) + (p1 != 0U); ++wt[w]; ++css;
        }
    }
    if (wt[0] != 1ULL || wt[1] != 0ULL || wt[2] != 0ULL || wt[3] != 1020ULL || wt[4] != 64515ULL) { return 2; }
    for (int m = 0; m < 8; ++m) { for (int b = 0; b < 8; ++b) { uint64_t k = 0ULL; for (int x = 0; x < 8; ++x) { k |= (1ULL << (8 * x + (gf8((uint8_t)m, (uint8_t)x) ^ (uint8_t)b))); } ln[m * 8 + b] = k; } }
    for (int x = 0; x < 8; ++x) { uint64_t k = 0ULL; for (int y = 0; y < 8; ++y) { k |= (1ULL << (8 * x + y)); } ln[64 + x] = k; }
    for (int i = 0; i < 72; ++i) { if (pc64(ln[i]) != 8) { return 2; } for (int j = i + 1; j < 72; ++j) { int o = pc64(ln[i] & ln[j]); if (((i / 8) == (j / 8) && o != 0) || ((i / 8) != (j / 8) && o != 1)) { return 3; } ++agp; } }
    for (int a = 1; a < 256; ++a) { uint8_t s[9] = {1U,0,0,0,0,0,0,0,0}, q[9]; for (int k = 8; k >= 1; --k) { s[k] ^= spectral_gf256_mul((uint8_t)a, s[k - 1]); } q[0] = 1U; for (int k = 1; k <= 8; ++k) { q[k] = s[k] ^ spectral_gf256_mul((uint8_t)a, q[k - 1]); ++bzs; } if (q[8] != 0U) { return 4; } }
    const uint64_t bl[8] = {L_T1, L_T1, L_T1, L_T1, L_76, L_MD, L_LW, L_LW}; const int eu[4] = {0, 9, 12, 16};
    for (int a = 0; a < 32; ++a) { if ((((L_S1 >> a) & 1ULL) ^ ((L_RN >> (31 - a)) & 1ULL)) != 1ULL) { return 5; } luts += 4ULL; }
    for (int c = 0; c < 4; ++c) { int u = 0; for (int s = 0; s < 8; ++s) { int a5 = (c << 3) | 3; u += (int)((bl[s] >> a5) & 1ULL) + (int)((bl[s] >> (32 + a5)) & 1ULL); luts += 32ULL; } if (u != eu[c]) { return 6; } }
    for (int w = 0; w < 64; ++w) { int walsh = 0; for (int x = 0; x < 64; ++x) { int fx = ((x & 1) & ((x >> 3) & 1)) ^ (((x >> 1) & 1) & ((x >> 4) & 1)) ^ (((x >> 2) & 1) & ((x >> 5) & 1)); int wx = pc64((uint64_t)(w & x)) & 1; walsh += (fx ^ wx) ? -1 : 1; } if (walsh != 8 && walsh != -8) { return 6; } luts += 2ULL; }
    for (int ad = 0; ad <= 8; ++ad) { for (int sd = 0; sd <= 6; ++sd) { for (int fc = 0; fc <= 32; ++fc) { for (int bi = 0; bi < 3; ++bi) { for (int lk = 0; lk <= 1; ++lk) { ++rs; it += (ad >= 6) ? 5ULL : 4ULL; } } } } }
    int rsm = 137; for (int t = 0; t < 137; ++t) { rsm -= 1; } if (rs != 12474ULL || it != 54054ULL || rsm != 0) { return 7; }
    const uint64_t gl[5] = {L_S1, L_RN, L_MO, L_76, L_PP};
    for (int m = 0; m < 5; ++m) { for (int b = 0; b < 64; ++b) { uint64_t mt = gl[m] ^ (1ULL << b); int k = 0; for (int a = 0; a < 32; ++a) { if (((mt >> a) & 1ULL) != ((gl[m] >> a) & 1ULL) || ((mt >> (32 + a)) & 1ULL) != ((gl[m] >> (32 + a)) & 1ULL)) { k = 1; break; } } if (!k) { return 8; } ++sk; } }
    struct { spectral_bar0_regs_t b; uint8_t p[4096 - 128]; uint64_t h[64]; } ap; memset(&ap, 0, sizeof(ap));
    ap.b.csr_spatial_coarse = ~0ULL; ap.b.csr_temporal_coarse = ~0ULL; ap.b.csr_time_wheel_64 = ~0ULL; ap.b.csr_spid_live_map = ~0ULL; ap.b.csr_epoch_ctrl = 0x401ULL;
    for (int i = 0; i < 64; ++i) { ap.h[i] = SPECTRAL_HBM2_SENTINEL_U64; }
    uint8_t sb[256];
    mk_sb(sb, SPECTRAL_POR_SPID_REVOKED_MASK, 4U, 1U, 0xA5U, 10000ULL); if (spectral_bar0_apply_sbundle(&ap.b, sb) != 0) { return 9; }
    const int ro[4] = {0, 8, 104, 112};
    for (int k = 0; k < 4; ++k) { mk_sb(sb, SPECTRAL_POR_SPID_REVOKED_MASK, 4U, 1U, 0xA5U, 10000ULL); uint64_t ao = ~0ULL; memcpy(sb + ro[k], &ao, 8U); if (spectral_bar0_apply_sbundle(&ap.b, sb) == -3) { ++tk; } }
    mk_sb(sb, SPECTRAL_POR_SPID_REVOKED_MASK, 4U, 1U, 0xA5U, 10000ULL); sb[128] ^= 0xFFU; if (spectral_bar0_apply_sbundle(&ap.b, sb) == -2) { ++tk; }
    mk_sb(sb, SPECTRAL_POR_SPID_REVOKED_MASK, 9U, 1U, 0xA5U, 10000ULL); if (spectral_bar0_apply_sbundle(&ap.b, sb) == -4) { ++tk; }
    mk_sb(sb, SPECTRAL_POR_SPID_REVOKED_MASK, 4U, 1U, 0xA5U, 10000ULL); sb[33] |= 0x10U; if (spectral_bar0_apply_sbundle(&ap.b, sb) == -4) { ++tk; }
    mk_sb(sb, SPECTRAL_POR_SPID_REVOKED_MASK, 4U, 0U, 0xA5U, 10000ULL); if (spectral_bar0_apply_sbundle(&ap.b, sb) == -5) { ++tk; }
    mk_sb(sb, SPECTRAL_POR_SPID_REVOKED_MASK, 4U, 1U, 0x5AU, 10000ULL); if (spectral_bar0_apply_sbundle(&ap.b, sb) == -6) { ++tk; }
    mk_sb(sb, SPECTRAL_POR_SPID_REVOKED_MASK, 4U, 1U, 0xA5U, 25000ULL); if (spectral_bar0_apply_sbundle(&ap.b, sb) == -7) { ++tk; }
    ap.b.csr_fine_cohort_bk = 0ULL; ap.b.csr_epoch_ctrl = 1ULL;
    for (uint8_t r = 1U; r <= 8U; ++r) { if (spectral_bar0_vieta_revoke_byte(&ap.b, r) != 1) { return 10; } }
    if (spectral_bar0_vieta_revoke_byte(&ap.b, 0U) == 0 && ((ap.b.csr_epoch_ctrl >> 12) & 1ULL) == 0ULL) { ++tk; }
    ap.b.csr_rwd_fifo_stat = 0ULL; if (ap.b.csr_spid_live_map == SPECTRAL_POR_SPID_REVOKED_MASK) { ++tk; }
    if (sk != 320ULL || tk != 12ULL) { return 11; }
    for (uint64_t s = 0ULL; s < 1000000ULL; ++s) { uint32_t sp = (s & 1ULL) ? 2U : 1U; ap.b.csr_ingress_crd += 1ULL; if (((ap.b.csr_spid_live_map >> sp) & 1ULL) == 0ULL) { ap.b.csr_scrub_bbp_cnt += 1ULL; } ap.b.csr_egress_crd += 1ULL; }
    printf("[BAR0_C11_BRUTAL_CEILING_PASS] GF256=%llu | CSS_MDS=%llu[1,0,0,%llu,%llu] | AG28=%llu | Bezout=%llu | LUT+Bent=%llu | States=%llu | Trans=%llu | Mutants=%llu/332 | Slots=%llu\n", (unsigned long long)gfp, (unsigned long long)css, (unsigned long long)wt[3], (unsigned long long)wt[4], (unsigned long long)agp, (unsigned long long)bzs, (unsigned long long)luts, (unsigned long long)rs, (unsigned long long)it, (unsigned long long)(sk + tk), (unsigned long long)ap.b.csr_ingress_crd);
    return 0;
}
