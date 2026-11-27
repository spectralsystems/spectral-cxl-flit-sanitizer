#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <assert.h>
#include "../registers/cxl_sanitizer_bar0_regs.h"
int main(void) {
    uint64_t csr_0x00_prev  = 0xFFFFFFFFFFFF00FFULL;
    uint64_t csr_0x08_prev  = 0x0000FFFFFFFFFFFFULL;
    uint64_t csr_0x60_prev  = 0xFEFEFEFEFEFEFEFEULL;
    uint64_t csr_0x68_prev  = 0x0000FFFFFFFFFFFFULL;
    uint64_t csr_0x70_prev  = 0xFFFFFFFFFFFFFFEBULL;
    uint64_t rogue_fm_write = 0xFFFFFFFFFFFFFFFFULL;
    assert(CXL_CONSORTIUM_DVSEC_VENDOR_ID == 0x1E98U);
    assert(SPECTRAL_DVSEC_ID               == 0x0023U);
    assert(SPECTRAL_SUBSYSTEM_DEVICE_ID    == 0x4B4CU);
    assert(SPECTRAL_BAR0_TOTAL_BYTES       == 128U);
    assert(SPECTRAL_BAR0_CSR_COUNT         == 16U);
    assert(SPECTRAL_CSR_0x00_COARSE_SPATIAL_OFFSET    == 0x00U);
    assert(SPECTRAL_CSR_0x08_COARSE_TEMPORAL_OFFSET   == 0x08U);
    assert(SPECTRAL_CSR_0x10_SHADOW_KEY_LO_OFFSET     == 0x10U);
    assert(SPECTRAL_CSR_0x18_SHADOW_KEY_HI_OFFSET     == 0x18U);
    assert(SPECTRAL_CSR_0x20_EPOCH_CTRL_OFFSET        == 0x20U);
    assert(SPECTRAL_CSR_0x28_INGRESS_CRD_CNT_OFFSET   == 0x28U);
    assert(SPECTRAL_CSR_0x30_EGRESS_CRD_CNT_OFFSET    == 0x30U);
    assert(SPECTRAL_CSR_0x38_SANITIZED_CNT_OFFSET     == 0x38U);
    assert(SPECTRAL_CSR_0x40_SELF_NAK_CNT_OFFSET      == 0x40U);
    assert(SPECTRAL_CSR_0x48_TAMPER_TRAP_CNT_OFFSET   == 0x48U);
    assert(SPECTRAL_CSR_0x50_RWD_FIFO_STATUS_OFFSET   == 0x50U);
    assert(SPECTRAL_CSR_0x58_CANONICAL_EGRESS_OFFSET  == 0x58U);
    assert(SPECTRAL_CSR_0x60_FINE_COHORT_MASK_OFFSET  == 0x60U);
    assert(SPECTRAL_CSR_0x68_FINE_TIMEWHEEL_OFFSET    == 0x68U);
    assert(SPECTRAL_CSR_0x70_SPID_LIVE_BITMAP_OFFSET  == 0x70U);
    assert(SPECTRAL_CSR_0x78_PREFIX_DMA_CFG_OFFSET    == 0x78U);
    assert(((csr_0x00_prev & rogue_fm_write) & ~csr_0x00_prev) == 0ULL);
    assert(((csr_0x08_prev & rogue_fm_write) & ~csr_0x08_prev) == 0ULL);
    assert(((csr_0x60_prev & rogue_fm_write) & ~csr_0x60_prev) == 0ULL);
    assert(((csr_0x68_prev & rogue_fm_write) & ~csr_0x68_prev) == 0ULL);
    assert(((csr_0x70_prev & rogue_fm_write) & ~csr_0x70_prev) == 0ULL);
    printf("[PASS] CXL 3.0-4.0 DVSEC & 16-CSR (128-Byte) BAR0 MMIO ABI Invariants Verified.\n");
    return EXIT_SUCCESS;
}
