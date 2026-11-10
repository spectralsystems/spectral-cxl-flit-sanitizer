/* ============================================================================
 * File: registers/cxl_sanitizer_bar0_regs.h
 * 16-CSR (128-Byte) BAR0 Register ABI for Spectral Flit-Filter (v1.0.0)
 * Author: Eric C. Murphy (Spectral Systems LLC | CAGE: 268E1 | UEI: VTP2JPCJU3D9)
 * ============================================================================ */
#ifndef CXL_SANITIZER_BAR0_REGS_H
#define CXL_SANITIZER_BAR0_REGS_H

#include <stdint.h>
#include <stddef.h>

#define CXL_CONSORTIUM_DVSEC_VENDOR_ID  0x1E98U
#define SPECTRAL_DVSEC_ID               0x0023U
#define SPECTRAL_SUBSYSTEM_DEVICE_ID    0x4B4CU
#define SPECTRAL_BAR0_TOTAL_BYTES       128U
#define SPECTRAL_BAR0_CSR_COUNT         16U

#define SPECTRAL_CSR_0x00_COARSE_SPATIAL_OFFSET   0x00U
#define SPECTRAL_CSR_0x08_COARSE_TEMPORAL_OFFSET  0x08U
#define SPECTRAL_CSR_0x10_SHADOW_KEY_LO_OFFSET    0x10U
#define SPECTRAL_CSR_0x18_SHADOW_KEY_HI_OFFSET    0x18U
#define SPECTRAL_CSR_0x20_EPOCH_CTRL_OFFSET       0x20U
#define SPECTRAL_CSR_0x28_INGRESS_CRD_CNT_OFFSET  0x28U
#define SPECTRAL_CSR_0x30_EGRESS_CRD_CNT_OFFSET   0x30U
#define SPECTRAL_CSR_0x38_SANITIZED_CNT_OFFSET    0x38U
#define SPECTRAL_CSR_0x40_SELF_NAK_CNT_OFFSET     0x40U
#define SPECTRAL_CSR_0x48_TAMPER_TRAP_CNT_OFFSET  0x48U
#define SPECTRAL_CSR_0x50_RWD_FIFO_STATUS_OFFSET  0x50U
#define SPECTRAL_CSR_0x58_CANONICAL_EGRESS_OFFSET 0x58U
#define SPECTRAL_CSR_0x60_FINE_COHORT_MASK_OFFSET 0x60U
#define SPECTRAL_CSR_0x68_FINE_TIMEWHEEL_OFFSET   0x68U
#define SPECTRAL_CSR_0x70_SPID_LIVE_BITMAP_OFFSET 0x70U
#define SPECTRAL_CSR_0x78_PREFIX_DMA_CFG_OFFSET   0x78U

typedef struct spectral_bar0_regs {
    volatile uint64_t csr_0x00_coarse_spatial_mask;
    volatile uint64_t csr_0x08_coarse_temporal_mask;
    volatile uint64_t csr_0x10_shadow_key_lo;
    volatile uint64_t csr_0x18_shadow_key_hi;
    volatile uint64_t csr_0x20_epoch_ctrl_status;
    volatile uint64_t csr_0x28_ingress_crd_cnt;
    volatile uint64_t csr_0x30_egress_crd_cnt;
    volatile uint64_t csr_0x38_sanitized_slot_cnt;
    volatile uint64_t csr_0x40_self_nak_cnt;
    volatile uint64_t csr_0x48_tamper_trap_cnt;
    volatile uint64_t csr_0x50_rwd_fifo_status;
    volatile uint64_t csr_0x58_canonical_egress;
    volatile uint64_t csr_0x60_fine_cohort_mask;
    volatile uint64_t csr_0x68_fine_timewheel_mask;
    volatile uint64_t csr_0x70_spid_live_bitmap;
    volatile uint64_t csr_0x78_prefix_submode_dma;
} spectral_bar0_regs_t;

_Static_assert(sizeof(spectral_bar0_regs_t) == 128U, "spectral_bar0_regs_t must be exactly 128 bytes");
_Static_assert(offsetof(spectral_bar0_regs_t, csr_0x00_coarse_spatial_mask) == 0x00U, "CSR 0x00 offset");
_Static_assert(offsetof(spectral_bar0_regs_t, csr_0x08_coarse_temporal_mask)== 0x08U, "CSR 0x08 offset");
_Static_assert(offsetof(spectral_bar0_regs_t, csr_0x10_shadow_key_lo)       == 0x10U, "CSR 0x10 offset");
_Static_assert(offsetof(spectral_bar0_regs_t, csr_0x18_shadow_key_hi)       == 0x18U, "CSR 0x18 offset");
_Static_assert(offsetof(spectral_bar0_regs_t, csr_0x20_epoch_ctrl_status)   == 0x20U, "CSR 0x20 offset");
_Static_assert(offsetof(spectral_bar0_regs_t, csr_0x28_ingress_crd_cnt)     == 0x28U, "CSR 0x28 offset");
_Static_assert(offsetof(spectral_bar0_regs_t, csr_0x30_egress_crd_cnt)      == 0x30U, "CSR 0x30 offset");
_Static_assert(offsetof(spectral_bar0_regs_t, csr_0x38_sanitized_slot_cnt)  == 0x38U, "CSR 0x38 offset");
_Static_assert(offsetof(spectral_bar0_regs_t, csr_0x40_self_nak_cnt)        == 0x40U, "CSR 0x40 offset");
_Static_assert(offsetof(spectral_bar0_regs_t, csr_0x48_tamper_trap_cnt)     == 0x48U, "CSR 0x48 offset");
_Static_assert(offsetof(spectral_bar0_regs_t, csr_0x50_rwd_fifo_status)     == 0x50U, "CSR 0x50 offset");
_Static_assert(offsetof(spectral_bar0_regs_t, csr_0x58_canonical_egress)    == 0x58U, "CSR 0x58 offset");
_Static_assert(offsetof(spectral_bar0_regs_t, csr_0x60_fine_cohort_mask)    == 0x60U, "CSR 0x60 offset");
_Static_assert(offsetof(spectral_bar0_regs_t, csr_0x68_fine_timewheel_mask) == 0x68U, "CSR 0x68 offset");
_Static_assert(offsetof(spectral_bar0_regs_t, csr_0x70_spid_live_bitmap)    == 0x70U, "CSR 0x70 offset");
_Static_assert(offsetof(spectral_bar0_regs_t, csr_0x78_prefix_submode_dma)  == 0x78U, "CSR 0x78 offset");

#endif /* CXL_SANITIZER_BAR0_REGS_H */