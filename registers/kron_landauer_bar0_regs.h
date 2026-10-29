/**
 * @file kron_landauer_bar0_regs.h
 * @brief ANSI-C Bare-Metal / Kernel Driver MMIO & CXL 3.0-5.0 DVSEC Register Map (v1.0.0)
 * @note  Public Software/Hardware Interface Specification (Zero Synthesizable RTL).
 *        Protected under 16 Pending U.S. Provisional Patent Applications.
 */
#ifndef KRON_LANDAUER_BAR0_REGS_H
#define KRON_LANDAUER_BAR0_REGS_H

#include <stdint.h>

/* PCIe Extended Config Space: CXL 3.0-5.0 Designated Vendor-Specific (DVSEC) Discovery */
#define KL_PCIE_EXT_CAP_ID_DVSEC           0x0023U /* PCI-SIG Designated Vendor-Specific Cap ID */
#define KL_CXL_DVSEC_REVISION_3_1          0x0003U /* CXL 3.0/3.1/4.0 Enclave Capability Rev    */
#define KL_CXL_DVSEC_ID_FLIT_SANITIZER     0x4B4CU /* 'KL' Enclave Telemetry & Ratchet DVSEC ID */
#define KL_CXL_DVSEC_BAR0_BIR              0x00U   /* Base Address Register Indicator (BAR0)    */

/* PCIe / CXL.io BAR0 Base Offsets (Non-Overlapping 64-Bit Aligned 12-CSR MMIO Map) */
#define KL_CSR_SPATIAL_STALK_MASK_OFFSET   0x00UL /* R/W* (*Monotonic AND-Ratchet: reg <= reg & wdata) */
#define KL_CSR_TEMPORAL_STALK_MASK_OFFSET  0x08UL /* R/W* (*Monotonic AND-Ratchet: reg <= reg & wdata) */
#define KL_CSR_TEMPORAL_EPOCH_PHASE_OFFSET 0x08UL /* Alias for backward ABI compatibility              */
#define KL_CSR_EPOCH_KEY_BANK0_OFFSET      0x10UL /* R/W  64-Bit Shadow-Sheaf Coset Key Bank 0         */
#define KL_CSR_EPOCH_KEY_BANK1_OFFSET      0x18UL /* R/W  64-Bit Shadow-Sheaf Coset Key Bank 1         */
#define KL_CSR_IDE_KEY_STATUS_OFFSET       0x20UL /* RO   Native IDE Key_Set_Select Phase & Flit Count */
#define KL_CSR_SLOTS_SANITIZED_CNT_OFFSET  0x28UL /* RO   Cumulative Violating 128b Slots Nullified    */
#define KL_CSR_CREDITS_REFUNDED_CNT_OFFSET 0x30UL /* RO   Cumulative Synthetic +CRD Pulses Returned    */
#define KL_CSR_LAST_VIOL_BITMAP_OFFSET     0x38UL /* RO   Most Recent 4-Bit Per-Slot Violation Bitmap  */
#define KL_CSR_SELF_INFLICTED_NAKS_OFFSET  0x40UL /* RO   Link Replay Storms Induced (Invariant == 0)  */
#define KL_CSR_FM_ESCALATION_TRAPS_OFFSET  0x48UL /* RO   Software-Non-Resettable FM Escalation Traps  */
#define KL_CSR_RWD_ROLLOVER_CNT_OFFSET     0x50UL /* RO   Cumulative 64B M2S_RwD Rollover Bursts       */
#define KL_CSR_EGRESS_CANON_DIGEST_OFFSET  0x58UL /* RO   Beta-Eta Canonical Proof-Carrying Egress Tag */

/* Invariant Verification Macros for Host Attestation Daemons */
#define KL_ASSERT_ZERO_NAK_INVARIANT(naks)         ((naks) == 0ULL)
#define KL_ASSERT_CREDIT_CONSERVATION(san, crd)    ((san)  == (crd))
#define KL_ASSERT_MONOTONIC_RATCHET(prev, curr)    (((curr) & ~(prev)) == 0ULL)

#endif /* KRON_LANDAUER_BAR0_REGS_H */
