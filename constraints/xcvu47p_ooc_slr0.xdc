# =============================================================================
# SPECTRAL FLIT-FILTER v1.0.0 -- AMD Virtex UltraScale+ HBM (xcvu47p-fsvh2892-2L-e)
# Out-of-Context (OOC) Soft-IP Timing & Contained SLR0 Floorplan Constraints
# =============================================================================
create_clock -period 4.000 -name clk_f2_250mhz [get_ports clk]
set_property HD.CLK_SRC BUFGCTRL_X0Y0 [get_ports clk]

create_pblock pblock_spectral_slr0
add_cells_to_pblock [get_pblocks pblock_spectral_slr0] -top
resize_pblock [get_pblocks pblock_spectral_slr0] -add {SLR0}
set_property IS_SOFT FALSE [get_pblocks pblock_spectral_slr0]
set_property CONTAIN_ROUTING 1 [get_pblocks pblock_spectral_slr0]
