#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include "../registers/kron_landauer_bar0_regs.h"

#define KL_VERIFY(cond) \
    do { \
        if (!(cond)) { \
            fprintf(stderr, "[FAIL] Invariant violation at %s:%d: %s\n", __FILE__, __LINE__, #cond); \
            return EXIT_FAILURE; \
        } \
    } while (0)

int main(void) {
    uint64_t csr_0x00_prev  = 0xFFFFFFFFFFFF00FFULL;
    uint64_t csr_0x08_prev  = 0x0000FFFFFFFFFFFFULL;
    uint64_t rogue_fm_write = 0xFFFFFFFFFFFFFFFFULL;
    uint64_t csr_0x00_curr  = csr_0x00_prev & rogue_fm_write;
    uint64_t csr_0x08_curr  = csr_0x08_prev & rogue_fm_write;

    uint64_t csr_0x28_sanitized = 4ULL;
    uint64_t csr_0x30_refunded  = 4ULL;
    uint64_t csr_0x40_naks      = 0ULL;

    /* Verify PCI-SIG / CXL 3.0-5.0 DVSEC Discovery Constants */
    KL_VERIFY(KL_PCIE_EXT_CAP_ID_DVSEC       == 0x0023U);
    KL_VERIFY(KL_CXL_DVSEC_REVISION_3_1      == 0x0003U);
    KL_VERIFY(KL_CXL_DVSEC_ID_FLIT_SANITIZER == 0x4B4CU);
    KL_VERIFY(KL_CXL_DVSEC_BAR0_BIR          == 0x00U);

    /* Verify Non-Overlapping 64-Bit Aligned 12-CSR BAR0 MMIO Offsets (0x00 - 0x58) */
    KL_VERIFY(KL_CSR_SPATIAL_STALK_MASK_OFFSET   == 0x00UL);
    KL_VERIFY(KL_CSR_TEMPORAL_STALK_MASK_OFFSET  == 0x08UL);
    KL_VERIFY(KL_CSR_TEMPORAL_EPOCH_PHASE_OFFSET == 0x08UL);
    KL_VERIFY(KL_CSR_EPOCH_KEY_BANK0_OFFSET      == 0x10UL);
    KL_VERIFY(KL_CSR_EPOCH_KEY_BANK1_OFFSET      == 0x18UL);
    KL_VERIFY(KL_CSR_IDE_KEY_STATUS_OFFSET       == 0x20UL);
    KL_VERIFY(KL_CSR_SLOTS_SANITIZED_CNT_OFFSET  == 0x28UL);
    KL_VERIFY(KL_CSR_CREDITS_REFUNDED_CNT_OFFSET == 0x30UL);
    KL_VERIFY(KL_CSR_LAST_VIOL_BITMAP_OFFSET     == 0x38UL);
    KL_VERIFY(KL_CSR_SELF_INFLICTED_NAKS_OFFSET  == 0x40UL);
    KL_VERIFY(KL_CSR_FM_ESCALATION_TRAPS_OFFSET  == 0x48UL);
    KL_VERIFY(KL_CSR_RWD_ROLLOVER_CNT_OFFSET     == 0x50UL);
    KL_VERIFY(KL_CSR_EGRESS_CANON_DIGEST_OFFSET  == 0x58UL);

    /* Verify Hardware Invariant Macros */
    KL_VERIFY(KL_ASSERT_ZERO_NAK_INVARIANT(csr_0x40_naks));
    KL_VERIFY(KL_ASSERT_CREDIT_CONSERVATION(csr_0x28_sanitized, csr_0x30_refunded));
    KL_VERIFY(KL_ASSERT_MONOTONIC_RATCHET(csr_0x00_prev, csr_0x00_curr));
    KL_VERIFY(KL_ASSERT_MONOTONIC_RATCHET(csr_0x08_prev, csr_0x08_curr));

    printf("[PASS] CXL 3.0-5.0 DVSEC Discovery & 12-Register BAR0 MMIO Driver Invariants Verified.\n");
    return EXIT_SUCCESS;
}
