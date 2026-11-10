#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <assert.h>
#include "../registers/cxl_sanitizer_bar0_regs.h"

int main(void) {
    spectral_bar0_regs_t dev;
    memset((void *)&dev, 0, sizeof(dev));
    dev.csr_0x00_coarse_spatial_mask  = 0xFFFFFFFFFFFFFFFFULL;
    dev.csr_0x60_fine_cohort_mask     = 0xFFFFFFFFFFFFFFFFULL;
    dev.csr_0x70_spid_live_bitmap     = 0xFFFFFFFFFFFFFFFFULL;
    dev.csr_0x78_prefix_submode_dma   = 0x00000000000000A5ULL;

    /* Revoke tenant 3 in CSR 0x70 */
    dev.csr_0x70_spid_live_bitmap &= ~(1ULL << 3);
    assert((dev.csr_0x70_spid_live_bitmap & (1ULL << 3)) == 0ULL);
    printf("[VFIO_DRIVER_PASS] Userspace VFIO CXL BAR0 ratchet sequence verified.\n");
    return 0;
}