# Sub-Flit Interposer Pinout and 16-CSR `BAR0` Integration Specification

Empirical and architectural evidence suggests that clean interface boundaries simplify integration between a CXL 3.0–5.0 / UCIe link controller and a downstream HBM2e/HBM3/HBM4 AXI4 memory controller.

**The goal of the integration boundary: expose a deterministic 512-bit cut-through flit pipeline and a 128-byte (16 x 64-bit) PCIe `BAR0` register file (`0x00..0x78`) with cold-reset-isolated monotonic ratchets.**

## 16-CSR `BAR0` Register Map (`128 Bytes`, Vendor `0x1E98`, Device `0x4B4C`)
| Offset | Register Name | Access Policy | Reset Value | Functional Summary |
| :--- | :--- | :--- | :--- | :--- |
| `0x00` | `CSR_0x00_COARSE_SPATIAL_MASK` | `RW_AND_RATCHET` | `0xFFFFFFFFFFFFFFFF` | Coarse 512-MB arena spatial mask (cold-POR isolated) |
| `0x08` | `CSR_0x08_COARSE_TEMPORAL_MASK` | `RW_AND_RATCHET` | `0xFFFFFFFFFFFFFFFF` | Coarse 512-MB arena temporal mask (cold-POR isolated) |
| `0x10` | `CSR_0x10_SHADOW_KEY_LO` | `RW_SHADOW_BANK` | `0x0123456789ABCDEF` | Inactive-bank lower 64-bit key staging portal |
| `0x18` | `CSR_0x18_SHADOW_KEY_HI` | `RW_SHADOW_BANK` | `0xFEDCBA9876543210` | Inactive-bank upper 64-bit key staging portal |
| `0x20` | `CSR_0x20_EPOCH_CTRL_STATUS` | `RW` | `0x0000000000000001` | Dual-bank epoch control, `bank_valid[1:0]`, Vieta degree |
| `0x28` | `CSR_0x28_INGRESS_CRD_CNT` | `RO` | `0x0000000000000000` | Cumulative RX credit request counter |
| `0x30` | `CSR_0x30_EGRESS_CRD_CNT` | `RO` | `0x0000000000000000` | Cumulative Stage-4 equalized TX credit refund counter |
| `0x38` | `CSR_0x38_SANITIZED_SLOT_CNT` | `RO` | `0x0000000000000000` | Unauthorized 128-bit slots clamped to `CXL_NOP` |
| `0x40` | `CSR_0x40_SELF_NAK_CNT` | `RO` | `0x0000000000000000` | Self-inflicted link CRC NAK counter (`== 0`) |
| `0x48` | `CSR_0x48_TAMPER_TRAP_CNT` | `RO_COLD_POR` | `0x0000000000000000` | `0->1` escalation, DMA replay, and dual-rail fault counter |
| `0x50` | `CSR_0x50_RWD_FIFO_STATUS` | `RO` | `0x0000000000000000` | 32-slot `M2S_RwD` rollover shift FIFO status |
| `0x58` | `CSR_0x58_CANONICAL_EGRESS` | `RW_LOCKOUT` | `0x0000000000000000` | Canonical egress digest with sticky invalid-witness lockout |
| `0x60` | `CSR_0x60_FINE_COHORT_MASK` | `RW_AND_RATCHET` | `0xFFFFFFFFFFFFFFFF` | Fine 4-KB cohort spatial mask / Vieta coefficients |
| `0x68` | `CSR_0x68_FINE_TIMEWHEEL_MASK` | `RW_AND_RATCHET` | `0xFFFFFFFFFFFFFFFF` | 64-bucket lease time-wheel / fine temporal mask |
| `0x70` | `CSR_0x70_SPID_LIVE_BITMAP` | `RW_AND_RATCHET` | `0xFFFFFFFFFFFFFFFF` | Prefix-guarded 64-tenant live SPID bitmap |
| `0x78` | `CSR_0x78_PREFIX_SUBMODE_DMA` | `RW_WONCE_PFX` | `0x00000000000000A5` | Write-once port SPID prefix `[7:0]` & 4-ch OOO DMA portal |

*Remarks:* It is important to note that on AWS EC2 F2 (`sh_ocl` 32-bit MMIO bus), writes to 64-bit monotonic AND-ratchets must be staged through the atomic `2x32-bit` bridge (`cl_spectral_aws_f2_shell.sv`) so that writing the lower 32-bit word never zero-wipes the upper 32 bits.