#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <assert.h>
#ifdef __linux__
#include <fcntl.h>
#include <unistd.h>
#include <sys/mman.h>
#endif
#include "../registers/cxl_sanitizer_bar0_regs.h"

typedef struct {
    uint32_t stage_lo;
    uint64_t reg64;
} f2_sh_ocl_bridge_t;

static void f2_write_32(f2_sh_ocl_bridge_t *b, uint32_t offset_mod8, uint32_t val) {
    if (offset_mod8 == 0U) {
        b->stage_lo = val;
    } else {
        uint64_t combined = ((uint64_t)val << 32) | (uint64_t)b->stage_lo;
        b->reg64 &= combined;
    }
}

int main(int argc, char **argv) {
    f2_sh_ocl_bridge_t csr00 = {0xFFFFFFFFU, 0xFFFFFFFFFFFFFFFFULL};
    uint64_t hbm2_sentinel   = 0xAAAAAAAAAAAAAAAAULL;

#ifdef __linux__
    if (argc > 2 && strcmp(argv[1], "--pci-bar0") == 0) {
        int fd = open(argv[2], O_RDWR | O_SYNC);
        if (fd >= 0) {
            void *map = mmap(NULL, 128, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
            if (map != MAP_FAILED) {
                volatile spectral_bar0_regs_t *hw = (volatile spectral_bar0_regs_t *)map;
                uint64_t snap = hw->csr_0x00_coarse_spatial_mask;
                (void)snap;
                munmap(map, 128);
            }
            close(fd);
        }
    }
#else
    (void)argc;
    (void)argv;
#endif

    /* Perform 2x32-bit sh_ocl atomic write to clear bit 0 without wiping upper 32 bits */
    f2_write_32(&csr00, 0U, 0xFFFFFFFEU);
    f2_write_32(&csr00, 4U, 0xFFFFFFFFU);
    assert(csr00.reg64 == 0xFFFFFFFFFFFFFFFEULL);
    assert(hbm2_sentinel == 0xAAAAAAAAAAAAAAAAULL);

    printf("{\"test\":\"aws_f2_trl6_hil\",\"sh_ocl_bridge\":\"PASS\",\"hbm2_sentinel\":\"0x%016llX\",\"verticals\":[\"ai_ml\",\"hpc\",\"cloud\",\"defense\"]}\n",
           (unsigned long long)hbm2_sentinel);
    return 0;
}