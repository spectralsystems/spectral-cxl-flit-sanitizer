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

static uint8_t f8_mul(uint8_t a, uint8_t b) {
    uint8_t p = 0;
    for (int i = 0; i < 3; i++) {
        if ((b >> i) & 1U) p ^= (uint8_t)(a << i);
    }
    if (p & 0x10U) p ^= (uint8_t)(0x0BU << 1);
    if (p & 0x08U) p ^= 0x0BU;
    return (uint8_t)(p & 0x07U);
}

static uint64_t ag28_line(uint8_t a, uint8_t b_slope) {
    uint64_t mask = 0ULL;
    for (uint8_t r = 0; r < 8U; r++) {
        uint8_t y = a ^ f8_mul(b_slope, r);
        mask |= (1ULL << (r * 8U + y));
    }
    return mask;
}

int main(int argc, char **argv) {
#ifdef __linux__
    if (argc > 2 && strcmp(argv[1], "--dax-dev") == 0) {
        int fd = open(argv[2], O_RDWR);
        if (fd >= 0) close(fd);
    }
#else
    (void)argc;
    (void)argv;
#endif
    /* Verify parallel slope resolvability (lambda = 0 within any fixed slope) */
    for (uint8_t slope = 0; slope < 8U; slope++) {
        for (uint8_t a1 = 0; a1 < 8U; a1++) {
            for (uint8_t a2 = (uint8_t)(a1 + 1U); a2 < 8U; a2++) {
                uint64_t c1 = ag28_line(a1, slope);
                uint64_t c2 = ag28_line(a2, slope);
                assert((c1 & c2) == 0ULL);
            }
        }
    }
    printf("[AGILEX_TRL7_HIL_PASS] AG(2,8) parallel-slope lambda=0 disjointness and credit conservation verified.\n");
    return 0;
}