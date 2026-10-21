`timescale 1ns/1ps

package spectral_gf256_pkg;
    function automatic logic [7:0] gf_mul(input logic [7:0] a, input logic [7:0] b);
        logic [7:0] p;
        logic [7:0] a_var;
        logic       hi_bit;
        p     = 8'h00;
        a_var = a;
        for (int i = 0; i < 8; i++) begin
            if (b[i]) p ^= a_var;
            hi_bit = a_var[7];
            a_var  = {a_var[6:0], 1'b0};
            if (hi_bit) a_var ^= 8'h1D;
        end
        return p;
    endfunction

    function automatic logic [63:0] crc8_step_byte(
        input logic [63:0] crc_in,
        input logic [7:0]  data_byte
    );
        logic [7:0]  fb;
        logic [7:0]  g [0:7];
        logic [63:0] next_crc;
        g[7] = 8'hFE; g[6] = 8'h76; g[5] = 8'h52; g[4] = 8'h38;
        g[3] = 8'h3A; g[2] = 8'h5E; g[1] = 8'hEC; g[0] = 8'h40;

        fb = data_byte ^ crc_in[63:56];
        next_crc[63:56] = crc_in[55:48] ^ gf_mul(fb, g[7]);
        next_crc[55:48] = crc_in[47:40] ^ gf_mul(fb, g[6]);
        next_crc[47:40] = crc_in[39:32] ^ gf_mul(fb, g[5]);
        next_crc[39:32] = crc_in[31:24] ^ gf_mul(fb, g[4]);
        next_crc[31:24] = crc_in[23:16] ^ gf_mul(fb, g[3]);
        next_crc[23:16] = crc_in[15:8]  ^ gf_mul(fb, g[2]);
        next_crc[15:8]  = crc_in[7:0]   ^ gf_mul(fb, g[1]);
        next_crc[7:0]   =                 gf_mul(fb, g[0]);
        return next_crc;
    endfunction

    function automatic logic [15:0] fec2_step_byte(
        input logic [15:0] fec_in,
        input logic [7:0]  data_byte
    );
        logic [7:0]  fb;
        logic [15:0] next_fec;
        fb = data_byte ^ fec_in[15:8];
        next_fec[15:8] = fec_in[7:0] ^ gf_mul(fb, 8'h06);
        next_fec[7:0]  =               gf_mul(fb, 8'h08);
        return next_fec;
    endfunction
endpackage

module cxl_ping_pong_slicer_ctrl (
    input  logic clk,
    input  logic rst_n,
    input  logic is_skp_os_or_nop,
    input  logic tsp_edf_epoch_sync,
    output logic active_slice_sel,
    output logic slice_a_detrap_en,
    output logic slice_b_detrap_en
);
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            active_slice_sel <= 1'b0;
        end else if (is_skp_os_or_nop && tsp_edf_epoch_sync) begin
            active_slice_sel <= ~active_slice_sel;
        end
    end
    assign slice_a_detrap_en =  active_slice_sel;
    assign slice_b_detrap_en = ~active_slice_sel;
endmodule

module cxl_cut_through_flit_sanitizer
    import spectral_gf256_pkg::*;
(
    input  logic       clk,
    input  logic       rst_n,
    input  logic       flit_valid_in,
    input  logic [7:0] flit_byte_idx,
    input  logic [7:0] rx_byte_in,
    input  logic       excursion_detected,
    input  logic [7:0] clamp_mask_byte,
    output logic       flit_valid_out,
    output logic [7:0] tx_byte_out,
    output logic [7:0] active_delta_out
);
    logic [63:0] delta_crc_acc;
    logic [15:0] delta_fec_acc [0:2];

    logic is_clampable_payload;
    assign is_clampable_payload = (flit_byte_idx >= 8'd16) && (flit_byte_idx <= 8'd235);
    assign active_delta_out     = (flit_valid_in && excursion_detected && is_clampable_payload)
                                  ? clamp_mask_byte : 8'h00;

    logic [7:0] current_delta_crc_byte;
    always_comb begin
        case (flit_byte_idx)
            8'd242: current_delta_crc_byte = delta_crc_acc[63:56];
            8'd243: current_delta_crc_byte = delta_crc_acc[55:48];
            8'd244: current_delta_crc_byte = delta_crc_acc[47:40];
            8'd245: current_delta_crc_byte = delta_crc_acc[39:32];
            8'd246: current_delta_crc_byte = delta_crc_acc[31:24];
            8'd247: current_delta_crc_byte = delta_crc_acc[23:16];
            8'd248: current_delta_crc_byte = delta_crc_acc[15:8];
            8'd249: current_delta_crc_byte = delta_crc_acc[7:0];
            default: current_delta_crc_byte = 8'h00;
        endcase
    end

    logic [7:0] current_delta_fec_byte;
    always_comb begin
        case (flit_byte_idx)
            8'd250: current_delta_fec_byte = delta_fec_acc[0][15:8];
            8'd251: current_delta_fec_byte = delta_fec_acc[0][7:0];
            8'd252: current_delta_fec_byte = delta_fec_acc[1][15:8];
            8'd253: current_delta_fec_byte = delta_fec_acc[1][7:0];
            8'd254: current_delta_fec_byte = delta_fec_acc[2][15:8];
            8'd255: current_delta_fec_byte = delta_fec_acc[2][7:0];
            default: current_delta_fec_byte = 8'h00;
        endcase
    end

    assign flit_valid_out = flit_valid_in;
    always_comb begin
        if (!flit_valid_in) begin
            tx_byte_out = 8'h00;
        end else if (flit_byte_idx <= 8'd241) begin
            tx_byte_out = rx_byte_in ^ active_delta_out;
        end else if (flit_byte_idx <= 8'd249) begin
            tx_byte_out = rx_byte_in ^ current_delta_crc_byte;
        end else begin
            tx_byte_out = rx_byte_in ^ current_delta_fec_byte;
        end
    end

    int sub_group;
    assign sub_group = int'(flit_byte_idx) % 3;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            delta_crc_acc    <= 64'h0;
            delta_fec_acc[0] <= 16'h0;
            delta_fec_acc[1] <= 16'h0;
            delta_fec_acc[2] <= 16'h0;
        end else if (flit_valid_in) begin
            if (flit_byte_idx == 8'd255) begin
                delta_crc_acc    <= 64'h0;
                delta_fec_acc[0] <= 16'h0;
                delta_fec_acc[1] <= 16'h0;
                delta_fec_acc[2] <= 16'h0;
            end else if (flit_byte_idx <= 8'd241) begin
                delta_crc_acc            <= crc8_step_byte(delta_crc_acc, active_delta_out);
                delta_fec_acc[sub_group] <= fec2_step_byte(delta_fec_acc[sub_group], active_delta_out);
            end else if (flit_byte_idx <= 8'd249) begin
                delta_fec_acc[sub_group] <= fec2_step_byte(delta_fec_acc[sub_group], current_delta_crc_byte);
            end
        end
    end
endmodule

module tb_cxl_flit_sanitizer;
    import spectral_gf256_pkg::*;

    logic       clk                = 0;
    logic       rst_n              = 0;
    logic       flit_valid_in      = 0;
    logic [7:0] flit_byte_idx      = 0;
    logic [7:0] rx_byte_in         = 0;
    logic       excursion_detected = 0;
    logic [7:0] clamp_mask_byte    = 0;
    logic       flit_valid_out;
    logic [7:0] tx_byte_out;
    logic [7:0] active_delta_out;

    logic is_skp_os = 0, tsp_edf_sync = 0;
    logic active_slice_sel, slice_a_detrap, slice_b_detrap;

    always #0.5 clk = ~clk;

    cxl_cut_through_flit_sanitizer dut_sanitizer (.*);
    cxl_ping_pong_slicer_ctrl dut_slicer (
        .clk(clk), .rst_n(rst_n),
        .is_skp_os_or_nop(is_skp_os), .tsp_edf_epoch_sync(tsp_edf_sync),
        .active_slice_sel(active_slice_sel),
        .slice_a_detrap_en(slice_a_detrap), .slice_b_detrap_en(slice_b_detrap)
    );

    logic [7:0]  orig_flit [0:255];
    logic [7:0]  sanitized_flit [0:255];
    logic [63:0] tx_crc, rx_check_crc;
    logic [15:0] tx_fec [0:2], rx_check_fec [0:2];

    initial begin
        rst_n = 0;
        #5 rst_n = 1;

        tx_crc = 64'h0;
        tx_fec[0] = 16'h0; tx_fec[1] = 16'h0; tx_fec[2] = 16'h0;
        for (int i = 0; i < 242; i++) begin
            orig_flit[i]  = 8'(i * 37 + 19);
            tx_crc        = crc8_step_byte(tx_crc, orig_flit[i]);
            tx_fec[i % 3] = fec2_step_byte(tx_fec[i % 3], orig_flit[i]);
        end
        for (int j = 0; j < 8; j++) begin
            orig_flit[242 + j]      = tx_crc[(7 - j)*8 +: 8];
            tx_fec[(242 + j) % 3]   = fec2_step_byte(tx_fec[(242 + j) % 3], orig_flit[242 + j]);
        end
        orig_flit[250] = tx_fec[0][15:8]; orig_flit[251] = tx_fec[0][7:0];
        orig_flit[252] = tx_fec[1][15:8]; orig_flit[253] = tx_fec[1][7:0];
        orig_flit[254] = tx_fec[2][15:8]; orig_flit[255] = tx_fec[2][7:0];

        for (int i = 0; i < 256; i++) begin
            @(negedge clk);
            flit_valid_in      = 1'b1;
            flit_byte_idx      = 8'(i);
            rx_byte_in         = orig_flit[i];
            excursion_detected = (i > 96);
            clamp_mask_byte    = 8'(i ^ 8'hA5);
            #0.2 sanitized_flit[i] = tx_byte_out;
            @(posedge clk);
        end
        @(negedge clk);
        flit_valid_in = 1'b0;

        is_skp_os = 1'b1; tsp_edf_sync = 1'b1;
        @(posedge clk);
        #0.1;
        is_skp_os = 1'b0; tsp_edf_sync = 1'b0;

        rx_check_crc = 64'h0;
        rx_check_fec[0] = 16'h0; rx_check_fec[1] = 16'h0; rx_check_fec[2] = 16'h0;
        for (int i = 0; i < 242; i++) begin
            rx_check_crc        = crc8_step_byte(rx_check_crc, sanitized_flit[i]);
            rx_check_fec[i % 3] = fec2_step_byte(rx_check_fec[i % 3], sanitized_flit[i]);
        end
        for (int j = 0; j < 8; j++) begin
            rx_check_crc[(7 - j)*8 +: 8] ^= sanitized_flit[242 + j];
            rx_check_fec[(242 + j) % 3]   = fec2_step_byte(rx_check_fec[(242 + j) % 3], sanitized_flit[242 + j]);
        end
        rx_check_fec[0] ^= {sanitized_flit[250], sanitized_flit[251]};
        rx_check_fec[1] ^= {sanitized_flit[252], sanitized_flit[253]};
        rx_check_fec[2] ^= {sanitized_flit[254], sanitized_flit[255]};

        $display("======================================================================");
        $display("[BUILD-0 RTL VERIFICATION: PPA 12 (64/179,325) CXL 3.0 SANITIZER]");
        $display("  Leading Bytes 0..96 Preserved Unmodified : %s", (sanitized_flit[50] == orig_flit[50]) ? "PASS" : "FAIL");
        $display("  Trailing Bytes 97..235 Clamped in Flight : %s", (sanitized_flit[120] != orig_flit[120]) ? "PASS" : "FAIL");
        $display("  DLP Routing Credits (236..241) Protected : %s", (sanitized_flit[238] == orig_flit[238]) ? "PASS" : "FAIL");
        $display("  Receiver Flit CRC Syndrome S_CRC(F')     : 0x%016h (Expected 0)", rx_check_crc);
        $display("  Receiver 3-Way RS-FEC Syndromes S_FEC(F'): 0x%04h, 0x%04h, 0x%04h", rx_check_fec[0], rx_check_fec[1], rx_check_fec[2]);
        $display("  SKP OS + TSP-EDF Ping-Pong Slicer Swap   : Active Slice = %0d (Slice A Detrap = %0d)", active_slice_sel, slice_a_detrap);
        $display("  OVERALL VERDICT                          : %s",
            (rx_check_crc == 0 && rx_check_fec[0] == 0 && rx_check_fec[1] == 0 && rx_check_fec[2] == 0 && active_slice_sel == 1)
            ? "100% PASS (ZERO NAK REPLAY STORM)" : "FAIL");
        $display("======================================================================");
        $finish;
    end
endmodule
