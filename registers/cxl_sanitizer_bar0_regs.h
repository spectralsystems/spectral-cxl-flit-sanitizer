/* Licensed under Apache-2.0 for software compilation, simulation, and formal verification only.
 * Pursuant to PATENTS.md and DFARS 252.227-7018 / DEAR 952.227-14, no patent license is granted
 * to synthesize, place-and-route, program onto an FPGA bitstream, or fabricate in ASIC silicon
 * (All Patents Pending, Spectral Systems LLC, CAGE: 268E1). */
#ifndef CXL_SANITIZER_BAR0_REGS_H
#define CXL_SANITIZER_BAR0_REGS_H
#include <stdint.h>
#include <stddef.h>
#ifdef __cplusplus
extern "C" {
#endif
#define SPECTRAL_DVSEC_VENDOR_ID       0x1E98U
#define SPECTRAL_DVSEC_DEVICE_ID       0x4B4CU
#define SPECTRAL_DVSEC_CAP_ID          0x0023U
#define SPECTRAL_BAR0_SIZE_BYTES       128U
#define SPECTRAL_SBUNDLE_SIZE_BYTES    256U
#define SPECTRAL_SBUNDLE_MAGIC_U64     0x4C444E4243455053ULL
#define SPECTRAL_SBUNDLE_MAGIC_STR     "SPECBNDL"
#define SPECTRAL_VIETA_MAX_DEGREE      8U
#define SPECTRAL_BBP_SUBTRACTIVE_WALL  21845ULL
#define SPECTRAL_BBP_Q_MAX_DEFAULT     10000ULL
#define SPECTRAL_POR_SPID_REVOKED_MASK 0xFFFFFFFFFFFFFFEBULL
#define SPECTRAL_HBM2_SENTINEL_U64     0xAAAAAAAAAAAAAAAAULL
#define CSR_SPATIAL_COARSE_OFF         0x00U
#define CSR_TEMPORAL_COARSE_OFF        0x08U
#define CSR_KEY_PORTAL_LO_OFF          0x10U
#define CSR_KEY_PORTAL_HI_OFF          0x18U
#define CSR_EPOCH_CTRL_OFF             0x20U
#define CSR_INGRESS_CRD_OFF            0x28U
#define CSR_EGRESS_CRD_OFF             0x30U
#define CSR_SCRUB_BBP_CNT_OFF          0x38U
#define CSR_SELF_NAK_CNT_OFF           0x40U
#define CSR_TAMPER_TRAP_CNT_OFF        0x48U
#define CSR_RWD_FIFO_STAT_OFF          0x50U
#define CSR_CANON_EGRESS_OFF           0x58U
#define CSR_FINE_COHORT_BK_OFF         0x60U
#define CSR_TIME_WHEEL_64_OFF          0x68U
#define CSR_SPID_LIVE_MAP_OFF          0x70U
#define CSR_PORT_CFG_DMA_OFF           0x78U
typedef struct {
    uint64_t csr_spatial_coarse, csr_temporal_coarse, csr_key_portal_lo, csr_key_portal_hi;
    uint64_t csr_epoch_ctrl, csr_ingress_crd, csr_egress_crd, csr_scrub_bbp_cnt;
    uint64_t csr_self_nak_cnt, csr_tamper_trap_cnt, csr_rwd_fifo_stat, csr_canon_egress;
    uint64_t csr_fine_cohort_bk, csr_time_wheel_64, csr_spid_live_map, csr_port_cfg_dma;
} spectral_bar0_regs_t;
typedef struct {
    spectral_bar0_regs_t regs;
    uint8_t magic[8]; uint32_t version; uint32_t dvsec_id;
    uint8_t sha256[32]; uint8_t mldsa87[80];
} spectral_sbundle_t;
#if defined(__cplusplus)
static_assert(sizeof(spectral_bar0_regs_t) == 128, "BAR0 ABI must be 128 bytes");
static_assert(sizeof(spectral_sbundle_t) == 256, "sbundle capsule must be 256 bytes");
#else
_Static_assert(sizeof(spectral_bar0_regs_t) == 128, "BAR0 ABI must be 128 bytes");
_Static_assert(sizeof(spectral_sbundle_t) == 256, "sbundle capsule must be 256 bytes");
_Static_assert(offsetof(spectral_bar0_regs_t, csr_spatial_coarse)  == 0x00, "CSR 0x00");
_Static_assert(offsetof(spectral_bar0_regs_t, csr_epoch_ctrl)      == 0x20, "CSR 0x20");
_Static_assert(offsetof(spectral_bar0_regs_t, csr_tamper_trap_cnt) == 0x48, "CSR 0x48");
_Static_assert(offsetof(spectral_bar0_regs_t, csr_fine_cohort_bk)  == 0x60, "CSR 0x60");
_Static_assert(offsetof(spectral_bar0_regs_t, csr_spid_live_map)   == 0x70, "CSR 0x70");
_Static_assert(offsetof(spectral_bar0_regs_t, csr_port_cfg_dma)    == 0x78, "CSR 0x78");
#endif
static inline uint8_t spectral_gf256_mul(uint8_t a, uint8_t b) {
    uint8_t p = 0U;
    for (int i = 0; i < 8; ++i) { if ((b & 1U) != 0U) p ^= a; a = (uint8_t)((a << 1) ^ ((a & 0x80U) ? 0x1BU : 0U)); b >>= 1; }
    return p;
}
static inline void spectral_bar0_write64_ordered(volatile uint64_t *reg_addr, uint64_t val) {
    volatile uint32_t *lo = (volatile uint32_t *)reg_addr;
    lo[0] = (uint32_t)(val & 0xFFFFFFFFULL); lo[1] = (uint32_t)((val >> 32) & 0xFFFFFFFFULL);
}
static inline void spectral_bar0_write64(volatile void *bar0_base, uint32_t off, uint64_t val) {
    spectral_bar0_write64_ordered((volatile uint64_t *)((volatile uint8_t *)bar0_base + (off & 0x78U)), val);
}
static inline uint64_t spectral_bar0_read64(const volatile void *bar0_base, uint32_t off) {
    const volatile uint32_t *lo = (const volatile uint32_t *)((const volatile uint8_t *)bar0_base + (off & 0x78U));
    return (uint64_t)lo[0] | ((uint64_t)lo[1] << 32);
}
static inline uint64_t spectral_bar0_ratchet_spid_killswitch(volatile void *bar0_base, uint64_t kill_mask) {
    volatile uint64_t *csr70 = (volatile uint64_t *)((volatile uint8_t *)bar0_base + CSR_SPID_LIVE_MAP_OFF);
    spectral_bar0_write64_ordered(csr70, (*csr70) & kill_mask); return *csr70;
}
static inline void spectral_bar0_atomic_shadow_swap(volatile void *bar0_base, uint64_t sigma, uint8_t d_rev, uint8_t bank) {
    spectral_bar0_write64(bar0_base, CSR_FINE_COHORT_BK_OFF, sigma);
    spectral_bar0_write64(bar0_base, CSR_EPOCH_CTRL_OFF, ((uint64_t)(d_rev & 0x0FU) << 8) | (uint64_t)(bank & 0x03U));
}
static inline int spectral_bar0_vieta_revoke_byte(volatile spectral_bar0_regs_t *bar0, uint8_t alpha) {
    if (alpha == 0U) return 0;
    uint64_t sig = bar0->csr_fine_cohort_bk, d_rev = (bar0->csr_epoch_ctrl >> 8) & 0x0FULL;
    uint8_t s[9]; s[0] = 1U;
    for (int k = 1; k <= 8; ++k) s[k] = (uint8_t)((sig >> ((k - 1) * 8)) & 0xFFU);
    uint8_t eval = 0U;
    for (int k = 0; k <= 8; ++k) eval = spectral_gf256_mul(eval, alpha) ^ s[k];
    if (eval == 0U) return 0;
    if (d_rev >= 8ULL) { bar0->csr_epoch_ctrl |= (1ULL << 12); return -4; }
    for (int k = 8; k >= 1; --k) s[k] ^= spectral_gf256_mul(alpha, s[k - 1]);
    uint64_t next_sig = 0ULL;
    for (int k = 1; k <= 8; ++k) next_sig |= ((uint64_t)s[k] << ((k - 1) * 8));
    bar0->csr_fine_cohort_bk = next_sig;
    bar0->csr_epoch_ctrl = (bar0->csr_epoch_ctrl & ~0x0F00ULL) | ((d_rev + 1ULL) << 8);
    return 1;
}
static inline int spectral_bar0_apply_sbundle(volatile void *bar0_base, const uint8_t sbundle[256]) {
    const char *mref = SPECTRAL_SBUNDLE_MAGIC_STR;
    if (!bar0_base || !sbundle) return -1;
    for (int m = 0; m < 8; ++m) if (sbundle[128 + m] != (uint8_t)mref[m]) return -2;
    volatile uint64_t *bw = (volatile uint64_t *)bar0_base;
    const uint64_t *w = (const uint64_t *)(const void *)sbundle;
    if ((w[4] & 0x03ULL) == 0ULL) { bw[9] += 1ULL; return -5; }
    if (((w[4] >> 8) & 0x0FULL) > 8ULL || ((w[4] >> 12) & 1ULL) != 0ULL) { bw[9] += 1ULL; return -4; }
    if ((bw[15] & 0xFFULL) != 0ULL && (w[15] & 0xFFULL) != (bw[15] & 0xFFULL)) { bw[9] += 1ULL; return -6; }
    if (w[7] > SPECTRAL_BBP_SUBTRACTIVE_WALL) { bw[9] += 1ULL; return -7; }
    const int r_idx[4] = {0, 1, 13, 14};
    for (int k = 0; k < 4; ++k) { int idx = r_idx[k]; if ((w[idx] & ~bw[idx]) != 0ULL) { bw[9] += 1ULL; return -3; } }
    for (int i = 0; i < 16; ++i) { if (i == 5 || i == 6 || i == 8 || i == 9 || i == 10) continue; spectral_bar0_write64_ordered(&bw[i], w[i]); }
    return 0;
}
#ifdef __cplusplus
}
#endif
#endif
