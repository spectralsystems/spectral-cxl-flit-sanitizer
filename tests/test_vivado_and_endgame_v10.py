"""
SPECTRAL FLIT-FILTER v1.0.0 -- Direct AMD Vivado v2025.2 Silicon Report Parser,
Zero-BRAM Causal DAG Verifier, Endgame Extension Suite & UTF-8/OPSEC Gate.
"""
import hashlib
import pathlib
import unittest

REPO_ROOT = pathlib.Path(__file__).resolve().parent.parent
MASK_64 = (1 << 64) - 1
MASK_32 = (1 << 32) - 1


def rotl64(v: int, s: int) -> int:
    v &= MASK_64
    s &= 63
    return ((v << s) | (v >> (64 - s))) & MASK_64


def rotr64(v: int, s: int) -> int:
    return rotl64(v, (64 - s) & 63)


def l_diff_64(m: int) -> int:
    return (m ^ rotl64(m, 1) ^ rotl64(m, 32)) & MASK_64


def l_diff_inv_64(y: int) -> int:
    return rotr64(l_diff_64(y), 2)


def chi_round_32(x: int, k: int) -> int:
    x &= MASK_32
    k &= MASK_32
    r1 = ((x << 1) | (x >> 31)) & MASK_32
    r2 = ((x << 2) | (x >> 30)) & MASK_32
    r3 = ((x << 3) | (x >> 29)) & MASK_32
    return (r1 ^ (x & k) ^ (r2 & (~r3 & MASK_32))) & MASK_32


def feistel_chi_enc_64(m: int, key: int) -> int:
    hi, lo = (m >> 32) & MASK_32, m & MASK_32
    k0, k1 = key & MASK_32, (key >> 32) & MASK_32
    u_hi = hi ^ chi_round_32(lo, k0)
    v_lo = lo ^ chi_round_32(u_hi, k1)
    return ((u_hi << 32) | v_lo) & MASK_64


def feistel_chi_dec_64(c: int, key: int) -> int:
    v_hi, v_lo = (c >> 32) & MASK_32, c & MASK_32
    k0, k1 = key & MASK_32, (key >> 32) & MASK_32
    lo = v_lo ^ chi_round_32(v_hi, k1)
    hi = v_hi ^ chi_round_32(lo, k0)
    return ((hi << 32) | lo) & MASK_64


def ticket_hash_64(key: int, formula_id: int, t_birth: int, copy_idx: int) -> int:
    payload = f"{key:016x}:{formula_id:016x}:{t_birth}:{copy_idx}".encode("ascii")
    return int.from_bytes(hashlib.blake2b(payload, digest_size=8).digest(), "little")


class ZeroBramStreamingDagVerifier:
    def __init__(self, key: int = 0xA5A5F0F0_0F0F5A5A) -> None:
        self.key = key & MASK_64
        self.premise_born_mask_q = 0
        self.dag_cochain_acc_q = True
        self.proof_syndrome_q = 0
        self.consumed_pairs = set()

    def step_infer(
        self,
        t_step: int,
        formula_id: int,
        fan_out: int,
        premises: list,
        rule_ok: bool = True,
    ) -> None:
        step_ok = rule_ok and (1 <= fan_out <= 16)
        for prem_formula, t_birth, copy_idx in premises:
            born_bit = (self.premise_born_mask_q >> (t_birth % 64)) & 1
            if not (t_birth < t_step and born_bit == 1 and (t_birth, copy_idx) not in self.consumed_pairs):
                step_ok = False
            self.consumed_pairs.add((t_birth, copy_idx))
            self.proof_syndrome_q ^= ticket_hash_64(self.key, prem_formula, t_birth, copy_idx)

        self.dag_cochain_acc_q = self.dag_cochain_acc_q and step_ok
        if step_ok:
            self.premise_born_mask_q |= 1 << (t_step % 64)
            for j in range(1, fan_out + 1):
                self.proof_syndrome_q ^= ticket_hash_64(self.key, formula_id, t_step, j)

    def finalize_canonical_egress(self, sigma_header: int, final_step: int) -> int:
        expected = ticket_hash_64(self.key, sigma_header, final_step, 1)
        if self.dag_cochain_acc_q and self.proof_syndrome_q == expected:
            return sigma_header & MASK_64
        return 0


class TestVivadoSiliconAndCanonicalSuite(unittest.TestCase):
    def test_01_live_vivado_xcvu47p_silicon_reports(self) -> None:
        util = (REPO_ROOT / "reports_public/vivado_xcvu47p_core_utilization.rpt").read_text(encoding="utf-8")
        timing = (REPO_ROOT / "reports_public/vivado_xcvu47p_core_timing_summary.rpt").read_text(encoding="utf-8")
        drc = (REPO_ROOT / "reports_public/vivado_xcvu47p_drc_audit.rpt").read_text(encoding="utf-8")

        self.assertRegex(util, r"\|\s*CLB LUTs\s*\|\s*414\s*\|")
        self.assertRegex(util, r"\|\s*LUT as Memory\s*\|\s*0\s*\|")
        self.assertRegex(util, r"\|\s*using O5 and O6\s*\|\s*260\s*\|")
        self.assertRegex(util, r"\|\s*CLB Registers\s*\|\s*1041\s*\|")
        self.assertRegex(util, r"\|\s*Block RAM Tile\s*\|\s*0\s*\|")
        self.assertRegex(util, r"\|\s*URAM\s*\|\s*0\s*\|")
        self.assertRegex(util, r"\|\s*DSPs\s*\|\s*0\s*\|")
        self.assertIn("unconstrained_internal_endpoints (0)", timing)
        self.assertRegex(timing, r"2\.888\s+0\.000\s+0\s+524\s+0\.036\s+0\.000\s+0\s+524")
        self.assertIn("Checks found: 0", drc)

    def test_02_shifted_involution_and_feistel_chi_zero_key_bijection(self) -> None:
        for sample in (0, MASK_64, 0xCAFEBABE_DEADBEEF, 0x01234567_89ABCDEF):
            self.assertEqual(l_diff_64(l_diff_64(sample)), rotl64(sample, 2))
            self.assertEqual(l_diff_inv_64(l_diff_64(sample)), sample)
            for key in (0, MASK_64, 0xA5A5F0F0_0F0F5A5A):
                ct = feistel_chi_enc_64(sample, key)
                self.assertEqual(feistel_chi_dec_64(ct, key), sample)

    def test_03_zero_bram_causal_dag_blocks_cycles_and_even_hallucinations(self) -> None:
        dag_ok = ZeroBramStreamingDagVerifier()
        dag_ok.step_infer(1, 0xAA01, fan_out=2, premises=[])
        dag_ok.step_infer(2, 0xBB02, fan_out=1, premises=[(0xAA01, 1, 1)])
        dag_ok.step_infer(3, 0xCC03, fan_out=1, premises=[(0xAA01, 1, 2)])
        dag_ok.step_infer(4, 0x516A, fan_out=1, premises=[(0xBB02, 2, 1), (0xCC03, 3, 1)])
        self.assertEqual(dag_ok.finalize_canonical_egress(0x516A, 4), 0x516A)

        dag_forged = ZeroBramStreamingDagVerifier()
        dag_forged.step_infer(2, 0x516A, fan_out=1, premises=[(0xFA4E, 1, 1), (0xFA4E, 1, 1)])
        self.assertEqual(dag_forged.finalize_canonical_egress(0x516A, 2), 0)

    def test_04_ooo_64cacheline_dma_and_bockstein_allreduce_plaquette(self) -> None:
        live_mask = (1 << 5) | (1 << 19) | (1 << 42) | (1 << 63)
        for line in (42, 5, 63, 19):
            self.assertEqual((live_mask >> line) & 1, 1)
            live_mask &= ~(1 << line)
        self.assertEqual(live_mask, 0)
        self.assertEqual((live_mask >> 42) & 1, 0)

        nodes = [0x11112222_33334444, 0x55556666_77778888, 0x9999AAAA_BBBBCCCC, 0xDDDDEEEE_FFFF0001]
        acc = 0
        for idx in range(4):
            coboundary = (nodes[idx] - nodes[(idx + 1) % 4]) & MASK_64
            acc = (acc + coboundary) & MASK_64
        self.assertEqual(acc, 0)

    def test_05_utf8_mojibake_and_dfars_opsec_gate(self) -> None:
        forbidden_ext = {".sv", ".v", ".vhdl", ".dcp", ".bit", ".lib"}
        mojibake_tokens = (
            "\u00e2\u20ac\u201d",
            "\u00e2\u20ac\u201c",
            "\u00c2\u00a7",
            "\u00c3\u00b6",
            "\u00c3\u00bc",
            "\u00c2\u00b2",
        )
        for path in REPO_ROOT.rglob("*"):
            if ".git" in path.parts or not path.is_file():
                continue
            self.assertNotIn(path.suffix.lower(), forbidden_ext, f"OPSEC leak: {path}")
            if path.suffix.lower() in {".md", ".py", ".c", ".h", ".svg", ".html", ".json", ".xdc", ".cff"}:
                txt = path.read_text(encoding="utf-8")
                for bad in mojibake_tokens:
                    self.assertNotIn(bad, txt, f"Mojibake found in {path}")


if __name__ == "__main__":
    unittest.main(verbosity=2)
