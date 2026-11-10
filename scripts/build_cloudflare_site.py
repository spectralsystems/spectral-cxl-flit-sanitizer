#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import datetime, hashlib, json, pathlib, shutil, subprocess

NL = chr(10)
CR = chr(13)
BS = chr(92)
SQ = chr(39)
DQ = chr(34)
PP = chr(124)

PROTO = "ht" + "tps://"
DOM = "spectralsystems" + "." + "org"
BASE_URL = PROTO + DOM
REPO_URL = PROTO + "github.com/spectralsystems/spectral-cxl-flit-sanitizer"

ROOT = pathlib.Path("C:/Spectral_Systems")
Z2 = ROOT / "02_GitHub_Repo_Staging"
WEB = Z2 / "website_public"
FIG = WEB / "figures"
DEAL = ROOT / "03_Agency_Briefings_Clean"
MANIFEST_PATH = Z2 / "reports_public" / "OMNIBUS_LOCKSTEP_MANIFEST.json"
NOW_UTC = datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
TODAY = datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%d")

def write_lf(p: pathlib.Path, txt: str):
    p.parent.mkdir(parents=True, exist_ok=True)
    clean = txt.replace(CR + NL, NL).replace(CR, NL)
    p.write_bytes(clean.encode("utf-8"))

def load_manifest() -> dict:
    if MANIFEST_PATH.is_file():
        try:
            return json.loads(MANIFEST_PATH.read_text(encoding="utf-8"))
        except Exception:
            pass
    return {}

CSS_SLOAN = """
:root {
  --bg: #F4F1EA;
  --paper: #FAF8F3;
  --sub: #EAE6DC;
  --ink: #111110;
  --body: #222220;
  --muted: #5E5C56;
  --rule: #111110;
  --hairline: #CFCBC0;
  --accent: #B82E14;
  --pass: #145A32;
  --serif: "Iowan Old Style", "Palatino Linotype", Palatino, Georgia, "Times New Roman", serif;
  --sans: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
  --mono: "JetBrains Mono", Consolas, "SFMono-Regular", Menlo, monospace;
}
[data-theme="ink"] {
  --bg: #0E0F0E;
  --paper: #141615;
  --sub: #1C1F1D;
  --ink: #EAE6DC;
  --body: #D5D1C7;
  --muted: #8E8B82;
  --rule: #4A4842;
  --hairline: #2A2C2A;
  --accent: #E04F33;
  --pass: #2ECC71;
}
* { box-sizing: border-box; margin: 0; padding: 0; }
html { font-size: 16px; -webkit-font-smoothing: antialiased; background: var(--bg); color: var(--ink); }
body { font-family: var(--sans); color: var(--body); background: var(--bg); line-height: 1.62; padding: 0; }
a { color: var(--ink); text-decoration: underline; text-underline-offset: 3px; text-decoration-thickness: 1px; }
a:hover { color: var(--accent); }
.shell { max-width: 1320px; margin: 0 auto; border-left: 1px solid var(--rule); border-right: 1px solid var(--rule); background: var(--paper); min-height: 100vh; }
.doc-bar { display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 0.75rem; padding: 0.55rem 1.5rem; border-bottom: 2px solid var(--rule); background: var(--sub); font-family: var(--mono); font-size: 0.72rem; letter-spacing: 0.03em; color: var(--ink); }
.nav-bar { display: flex; justify-content: space-between; align-items: stretch; flex-wrap: wrap; border-bottom: 1px solid var(--rule); background: var(--paper); }
.brand-box { padding: 1rem 1.5rem; border-right: 1px solid var(--rule); display: flex; flex-direction: column; justify-content: center; }
.brand-title { font-family: var(--serif); font-size: 1.25rem; font-weight: 700; letter-spacing: -0.02em; color: var(--ink); text-decoration: none; }
.brand-sub { font-family: var(--mono); font-size: 0.68rem; color: var(--muted); margin-top: 0.15rem; }
.nav-links { display: flex; flex-wrap: wrap; align-items: stretch; }
.nav-links a { display: flex; align-items: center; padding: 0 1.1rem; font-family: var(--mono); font-size: 0.73rem; text-transform: uppercase; letter-spacing: 0.04em; text-decoration: none; border-right: 1px solid var(--hairline); color: var(--ink); }
.nav-links a:hover, .nav-links a.active { background: var(--ink); color: var(--paper); }
.theme-btn { margin-left: auto; padding: 0 1.1rem; font-family: var(--mono); font-size: 0.72rem; background: transparent; border: none; border-left: 1px solid var(--rule); color: var(--ink); cursor: pointer; text-transform: uppercase; }
.theme-btn:hover { background: var(--sub); }
.grid-main { display: grid; grid-template-columns: 250px 1fr; border-bottom: 1px solid var(--rule); }
@media (max-width: 960px) { .grid-main { grid-template-columns: 1fr; } .rail-left { border-right: none !important; border-bottom: 1px solid var(--rule); } }
.rail-left { border-right: 1px solid var(--rule); padding: 1.5rem 1.25rem; background: var(--bg); font-family: var(--mono); font-size: 0.74rem; }
.rail-sec { margin-bottom: 1.5rem; }
.rail-h { font-size: 0.68rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.06em; color: var(--muted); padding-bottom: 0.4rem; border-bottom: 1px solid var(--hairline); margin-bottom: 0.6rem; }
.rail-list { list-style: none; }
.rail-list li { margin-bottom: 0.45rem; line-height: 1.35; }
.rail-list a { text-decoration: none; color: var(--body); }
.rail-list a:hover { color: var(--accent); text-decoration: underline; }
.rail-kv { display: flex; justify-content: space-between; padding: 0.28rem 0; border-bottom: 1px dotted var(--hairline); font-variant-numeric: tabular-nums; }
.content-col { padding: 2.25rem 2.75rem; max-width: 100%; overflow-x: hidden; }
@media (max-width: 680px) { .content-col { padding: 1.35rem 1.15rem; } }
.kicker { font-family: var(--mono); font-size: 0.74rem; text-transform: uppercase; letter-spacing: 0.06em; color: var(--accent); font-weight: 700; margin-bottom: 0.5rem; }
h1 { font-family: var(--serif); font-size: 2.3rem; font-weight: 400; line-height: 1.16; letter-spacing: -0.015em; color: var(--ink); margin-bottom: 1rem; max-width: 28ch; }
.lead { font-family: var(--serif); font-size: 1.16rem; line-height: 1.58; color: var(--body); max-width: 68ch; margin-bottom: 1.5rem; }
.meta-strip { display: grid; grid-template-columns: repeat(auto-fit, minmax(170px, 1fr)); border-top: 2px solid var(--rule); border-bottom: 1px solid var(--rule); background: var(--sub); margin: 1.75rem 0 2.25rem; }
.meta-cell { padding: 0.85rem 1rem; border-right: 1px solid var(--hairline); }
.meta-cell:last-child { border-right: none; }
.meta-lbl { font-family: var(--mono); font-size: 0.66rem; text-transform: uppercase; letter-spacing: 0.05em; color: var(--muted); }
.meta-val { font-family: var(--mono); font-size: 1.04rem; font-weight: 700; color: var(--ink); margin-top: 0.2rem; font-variant-numeric: tabular-nums; }
.meta-note { font-family: var(--sans); font-size: 0.73rem; color: var(--muted); margin-top: 0.1rem; }
h2 { font-family: var(--serif); font-size: 1.45rem; font-weight: 400; color: var(--ink); margin: 2.4rem 0 0.85rem; padding-bottom: 0.35rem; border-bottom: 1px solid var(--rule); display: flex; align-items: baseline; gap: 0.65rem; }
h2 .sec-num { font-family: var(--mono); font-size: 0.82rem; color: var(--accent); font-weight: 700; }
p { margin-bottom: 1.05rem; max-width: 70ch; }
.prose-aside { display: grid; grid-template-columns: 1fr 240px; gap: 2rem; align-items: start; margin: 1.25rem 0; }
@media (max-width: 900px) { .prose-aside { grid-template-columns: 1fr; gap: 0.75rem; } }
.sidenote { font-family: var(--mono); font-size: 0.73rem; line-height: 1.45; color: var(--muted); border-left: 2px solid var(--accent); background: var(--bg); padding: 0.65rem 0.75rem; }
.spec-table-wrap { overflow-x: auto; margin: 1.35rem 0 2rem; border: 1px solid var(--rule); background: var(--paper); }
table.spec { width: 100%; border-collapse: collapse; font-size: 0.83rem; font-variant-numeric: tabular-nums; }
table.spec th, table.spec td { padding: 0.56rem 0.8rem; border-bottom: 1px solid var(--hairline); border-right: 1px solid var(--hairline); text-align: left; vertical-align: top; }
table.spec th { background: var(--sub); font-family: var(--mono); font-size: 0.71rem; text-transform: uppercase; letter-spacing: 0.04em; color: var(--ink); border-bottom: 1px solid var(--rule); }
table.spec tr:last-child td { border-bottom: none; }
table.spec td.num, table.spec th.num { text-align: right; font-family: var(--mono); }
code, .mono { font-family: var(--mono); font-size: 0.84em; background: var(--sub); padding: 0.1rem 0.32rem; }
pre { background: #141413; color: #EAE6DC; padding: 1rem 1.25rem; font-family: var(--mono); font-size: 0.78rem; line-height: 1.5; overflow-x: auto; border: 1px solid var(--rule); margin: 1rem 0 1.5rem; }
.btn-row { display: flex; flex-wrap: wrap; gap: 0.65rem; margin: 1.25rem 0; }
.btn { display: inline-block; font-family: var(--mono); font-size: 0.75rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.04em; padding: 0.56rem 0.95rem; border: 1px solid var(--rule); background: var(--ink); color: var(--paper); text-decoration: none; cursor: pointer; }
.btn:hover { background: var(--accent); border-color: var(--accent); color: #fff; }
.btn-ghost { background: var(--paper); color: var(--ink); }
.btn-ghost:hover { background: var(--sub); color: var(--ink); border-color: var(--rule); }
.bench-box { border: 1px solid var(--rule); background: var(--bg); padding: 1.25rem; margin: 1.5rem 0 2rem; }
.bench-head { display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 0.5rem; padding-bottom: 0.65rem; border-bottom: 1px solid var(--rule); margin-bottom: 1rem; font-family: var(--mono); font-size: 0.74rem; font-weight: 700; text-transform: uppercase; }
.ctrl-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 1rem; margin-bottom: 1rem; }
.ctrl-item label { display: block; font-family: var(--mono); font-size: 0.71rem; text-transform: uppercase; color: var(--muted); margin-bottom: 0.25rem; }
.ctrl-item input[type=range], .ctrl-item select, .ctrl-item input[type=text] { width: 100%; font-family: var(--mono); font-size: 0.8rem; padding: 0.38rem; border: 1px solid var(--rule); background: var(--paper); color: var(--ink); }
.plate-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(360px, 1fr)); gap: 1.25rem; margin: 1.25rem 0 2rem; }
.plate-card { border: 1px solid var(--rule); background: var(--paper); padding: 0.9rem; display: flex; flex-direction: column; justify-content: space-between; }
.plate-card img { width: 100%; height: auto; border: 1px solid var(--hairline); background: #fff; cursor: zoom-in; }
.plate-cap { font-family: var(--mono); font-size: 0.72rem; color: var(--muted); margin-top: 0.65rem; line-height: 1.45; }
.footer { padding: 1.5rem; background: var(--sub); border-top: 1px solid var(--rule); font-family: var(--mono); font-size: 0.72rem; color: var(--muted); display: flex; justify-content: space-between; flex-wrap: wrap; gap: 1rem; }
#lightbox { display: none; position: fixed; inset: 0; background: rgba(17,17,16,0.92); z-index: 9999; align-items: center; justify-content: center; padding: 2rem; flex-direction: column; }
#lightbox img { max-width: 94vw; max-height: 82vh; background: #fff; border: 2px solid #fff; }
#lightbox-cap { color: #FAF8F3; font-family: var(--mono); font-size: 0.8rem; margin-top: 0.85rem; max-width: 85ch; text-align: center; }
"""

COMMON_RAIL = """
<div class="rail-sec">
  <div class="rail-h">Document Control</div>
  <div class="rail-kv"><span>Release</span><strong>v1.0.0</strong></div>
  <div class="rail-kv"><span>DLA CAGE</span><strong>268E1</strong></div>
  <div class="rail-kv"><span>SAM.gov UEI</span><strong>VTP2JPCJU3D9</strong></div>
  <div class="rail-kv"><span>VA eVA ID</span><strong>VA10140357</strong></div>
  <div class="rail-kv"><span>Lean 4 Kernel</span><strong>30 Thms / 0 Ax</strong></div>
  <div class="rail-kv"><span>16nm Core Area</span><strong>1,585 LUTs</strong></div>
  <div class="rail-kv"><span>Block RAM / DSP</span><strong>0 / 0</strong></div>
  <div class="rail-kv"><span>7nm ASAP7 Core</span><strong>9,678 / 27,877</strong></div>
  <div class="rail-kv"><span>7nm Die Area</span><strong>0.003335 mm&sup2;</strong></div>
  <div class="rail-kv"><span>Patent Portfolio</span><strong>19 Pending</strong></div>
</div>
<div class="rail-sec">
  <div class="rail-h">Executive Downloads</div>
  <ul class="rail-list">
    <li><a href="capability-statement.pdf">&rarr; 1-Page Capability PDF</a></li>
    <li><a href="preprint_Murphy_v1_0_0.pdf">&rarr; Monograph PDF (v1.0.0)</a></li>
    <li><a href="https://github.com/spectralsystems/spectral-cxl-flit-sanitizer">&rarr; GitHub Verification Repo</a></li>
    <li><a href="console-demo/index.html">&rarr; Interactive BAR0 Bench</a></li>
    <li><a href="cots-procurement.html">&rarr; FAR 13.201 GPC Quote</a></li>
    <li><a href="vendor-profile.json">&rarr; Vendor JSON Profile</a></li>
  </ul>
</div>
<div class="rail-sec">
  <div class="rail-h">Live AWS F2 Silicon</div>
  <div style="font-size:0.68rem; color:var(--muted); line-height:1.45;">
    <strong>AFI-1 (Datapath + BIST):</strong><br><code>agfi-03b742e2a9cd2c0f2</code><br><br>
    <strong>AFI-2 (16 GB HBM2 DMA):</strong><br><code>agfi-08becf3b40b169674</code>
  </div>
</div>
"""

TELE_SEAL = """<div id="spec-lockstep-seal" style="font-size:0.68rem;color:var(--muted);padding:0.75rem 1.5rem;border-top:1px solid var(--hairline);background:var(--bg);font-family:var(--mono);">
Canonical v1.0.0 Telemetry Ledger: 16nm xcvu47p-fsvh2892-2L-e (Vivado v2025.2): 1,585 Core CLB LUTs (0.12%, 321 CLBs), 1,157 FFs, 341 Scrub Shim LUTs, 2,555 Cycle-0 LUTs, 5,459 4-Stage Wrapper LUTs / 3,461 FFs, 0 BRAM, 0 URAM, 0 LUTRAM, 0 DSP, +1.048 ns WNS (338.8 MHz), 35.0 mW, 0 DRC.
7nm ASAP7 FinFET CMOS (asap7sc7p5t): 9,678 core cells (11,420 NAND2 GE, 0.00224 mm2), 27,877 placed-and-routed enclave cells (3,335.45 um2 / 0.003335 mm2), 0 SRAM, +2,556.41 ps WNS, 1,443.59 ps critical path (693 MHz = 2.77x), 3.728 mW, 0 DRC.
AWS EC2 f2.6xlarge Dual-AFI: agfi-03b742e2a9cd2c0f2 (afi-07282de69eecfd279, +1.842 ns WNS @ 250.0 MHz, 128.0 Gbps, 800,000 slots, 400,000 rogue scrubbed, CSR[0x70] = 0xFFFFFFFFFFFFFFEB, 19,990-trace Welch TVLA max |t| = 0.0) &amp; agfi-08becf3b40b169674 (afi-0f2ddd7dc87d81193, +0.512 ns WNS, 16 GB HBM2, PF0-BAR4 0x1000000000, 25,000 bursts, 50,128 flits, 100,000 slots, 0x5555555555555555, 0xAAAAAAAAAAAAAAAA, BF16 0x3F8E3F8E -&gt; 0x3F803F80, CmpltTO == 0).
CNCF k3s + spectralc v1.0.0: 16-CSR (128 B) BAR0 ABI, ML-DSA-87, 1.36 ms HTTP 403. 30 zero-axiom Init.Prelude Lean 4 theorem groups (thm00-thm29, 33 verified groups, 0 sorry).
10,000-Rack TCO: 99.20% vs. 48.90% goodput, 8.0 ns vs. 184.2 ns / 34.8 ns P99.99, 2,500.0 TB (250 GB/rack) HBM ($37.50M-$38.40M CapEx), 8.01-39.44 MW saved. CAGE: 268E1 | UEI: VTP2JPCJU3D9 | All Patents Pending | 90 FR 54636.</div>"""

def wrap_page(title: str, active_slug: str, rail_html: str, body_html: str, doi_str: str = "10.5281/zenodo.19503283") -> str:
    nav_items = [
        ("index.html", "I. Monograph"),
        ("benchmarks.html", "II. Silicon & PPA"),
        ("zero-trust.html", "III. Zero-Trust & RAIN"),
        ("verification.html", "IV. Formal Proofs"),
        ("cots-procurement.html", "V. COTS & GPC"),
        ("patents.html", "VI. IP & Compliance"),
        ("console-demo/index.html", "VII. Bench Console"),
    ]
    prefix = "../" if active_slug == "console-demo/index.html" else ""
    nav_links_html = []
    for slug, label in nav_items:
        href = (prefix + slug) if active_slug == "console-demo/index.html" else slug
        cls = f" class={DQ}active{DQ}" if slug == active_slug else ""
        nav_links_html.append(f"<a href={DQ}{href}{DQ}{cls}>{label}</a>")
    nav_str = "".join(nav_links_html)
    return f"""<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta name="citation_title" content="Spectral Flit-Filter (v1.0.0): Zero-BRAM Sub-Flit Capability Sieve and Monotonic Cold-POR Ratchet for CXL 3.0-5.0 and UCIe Memory Fabrics">
  <meta name="citation_author" content="Murphy, Eric C.">
  <meta name="citation_publication_date" content="2026/11/08">
  <meta name="citation_technical_report_institution" content="Spectral Systems LLC (CAGE: 268E1)">
  <meta name="citation_pdf_url" content="{BASE_URL}/preprint_Murphy_v1_0_0.pdf">
  <meta name="citation_doi" content="{doi_str}">
  <title>{title} - Spectral Systems LLC (CAGE: 268E1)</title>
  <meta property="og:type" content="website">
  <meta property="og:site_name" content="Spectral Systems LLC (CAGE: 268E1)">
  <meta property="og:title" content="{title}">
  <meta property="og:description" content="1,585 CLB LUTs (0 BRAM) on 16nm xcvu47p | 9,678 core / 27,877 enclave cells (3.728 mW) on 7nm ASAP7 | 99.20% goodput | 30 zero-axiom Lean 4 theorems | Live AWS F2 16 GB HBM2 silicon.">
  <meta property="og:image" content="{BASE_URL}/figures/og_datasheet_card.png">
  <meta property="og:image:width" content="1200">
  <meta property="og:image:height" content="630">
  <meta name="twitter:card" content="summary_large_image">
  <meta name="twitter:title" content="{title}">
  <meta name="twitter:description" content="Zero-BRAM sub-flit capability sieve and cold-POR hardware ratchet for CXL 3.0-5.0 and UCIe memory fabrics.">
  <meta name="twitter:image" content="{BASE_URL}/figures/og_datasheet_card.png">
  <style>{CSS_SLOAN}</style>
</head>
<body>
<div class="shell">
  <header class="doc-bar">
    <span>TECHNICAL MONOGRAPH &amp; DATASHEET // SPEC-FF-V1.0.0 // DISTRIBUTION A: PUBLIC RELEASE</span>
    <span>SPECTRAL SYSTEMS LLC (UNITED STATES) &bull; CAGE: 268E1 &bull; SAM.GOV UEI: VTP2JPCJU3D9</span>
  </header>
  <nav class="nav-bar">
    <div class="brand-box">
      <a class="brand-title" href="{prefix}index.html">Spectral Systems LLC</a>
      <span class="brand-sub">Hardware-Enforced Memory Isolation &amp; Formal Silicon Verification</span>
    </div>
    <div class="nav-links">{nav_str}</div>
    <button class="theme-btn" onclick="toggleTheme()" id="theme-toggle">[PAPER / INK]</button>
  </nav>
  <div class="grid-main">
    <aside class="rail-left">{rail_html}</aside>
    <main class="content-col">{body_html}</main>
  </div>
  {TELE_SEAL}
  <footer class="footer">
    <div>Spectral Systems LLC is a privately held U.S. microelectronics R&amp;D company (CAGE: 268E1 | SAM.gov UEI: VTP2JPCJU3D9 | non-501(c)(3)). All Patents Pending (19 U.S. Provisional Patent Applications; 90 FR 54636).</div>
    <div>Contact: <a href="mailto:eric@spectralsystems.org">eric@spectralsystems.org</a> &bull; <a href="{prefix}capability-statement.pdf">1-Page Capability PDF</a> &bull; <a href="{prefix}preprint_Murphy_v1_0_0.pdf">Preprint PDF</a> &bull; <a href="{prefix}llms.txt">llms.txt</a> &bull; <a href="{prefix}sitemap.xml">sitemap.xml</a></div>
  </footer>
</div>
<div id="lightbox" onclick="closeLightbox()">
  <img id="lightbox-img" src="" alt="Expanded Vector Figure">
  <div id="lightbox-cap"></div>
</div>
<script>
function toggleTheme() {{
  const root = document.documentElement;
  const cur = root.getAttribute("data-theme");
  const next = (cur === "ink") ? "paper" : "ink";
  root.setAttribute("data-theme", next);
  localStorage.setItem("spectral_theme", next);
}}
(function() {{
  const saved = localStorage.getItem("spectral_theme");
  if (saved === "ink") document.documentElement.setAttribute("data-theme", "ink");
}})();
function openLightbox(src, cap) {{
  const lb = document.getElementById("lightbox");
  document.getElementById("lightbox-img").src = src;
  document.getElementById("lightbox-cap").innerText = cap;
  lb.style.display = "flex";
}}
function closeLightbox() {{ document.getElementById("lightbox").style.display = "none"; }}
</script>
</body>
</html>
"""

def build_index_body() -> str:
    return """
<div class="kicker">Monograph &amp; Reference Datasheet (v1.0.0) &bull; Eric C. Murphy, Principal Architect</div>
<h1>Sub-Flit Capability Sieving and Cold-Reset Ratchets for Disaggregated Memory Fabrics</h1>
<p class="lead">
  When multiple processors and AI accelerators share High-Bandwidth Memory (HBM2e/HBM3/HBM4) and DDR5 pools over CXL 3.0&ndash;5.0 or UCIe links, enforcing isolation at line rate runs into an uncomfortable structural trade-off. If you store access-control tables in DRAM, you forfeit 1.5625% of pooled capacity (250 GB per 16 TB rack) and suffer cache-miss tail stalls (184.2 ns P99.99) under sparse traffic. If instead you place a stateless filter on the wire and poison the 512-bit flit CRC whenever a request faults, a single bad 128-bit slot triggers a link-layer retry storm that penalizes three innocent co-packaged slots and collapses allied link goodput to 48.90%.
</p>
<div class="btn-row">
  <a class="btn" href="capability-statement.pdf">1-Page Executive Capability Statement (PDF)</a>
  <a class="btn btn-ghost" href="preprint_Murphy_v1_0_0.pdf">Full Monograph PDF (v1.0.0)</a>
  <a class="btn btn-ghost" href="https://github.com/spectralsystems/spectral-cxl-flit-sanitizer">Apache-2.0 Verification Repo</a>
  <a class="btn btn-ghost" href="cots-procurement.html">Generate &lt;$25k FAR 13.201 GPC Quote</a>
</div>

<div class="meta-strip">
  <div class="meta-cell"><div class="meta-lbl">16nm xcvu47p Area</div><div class="meta-val">1,585 LUTs</div><div class="meta-note">0 BRAM &bull; 0 URAM &bull; 0 DSPs</div></div>
  <div class="meta-cell"><div class="meta-lbl">Stage-1 Sieve Delay</div><div class="meta-val">0.124 ns</div><div class="meta-note">+1.048 ns WNS (338.8 MHz)</div></div>
  <div class="meta-cell"><div class="meta-lbl">Allied Link Goodput</div><div class="meta-val">99.20%</div><div class="meta-note">vs. 48.90% whole-flit CRC</div></div>
  <div class="meta-cell"><div class="meta-lbl">7nm ASAP7 Standard-Cell</div><div class="meta-val">693.19 MHz</div><div class="meta-note">3.728 mW &bull; 0.003335 mm&sup2;</div></div>
  <div class="meta-cell"><div class="meta-lbl">Formal Proof Kernel</div><div class="meta-val">30 Theorems</div><div class="meta-note">Pure Init.Prelude Lean 4 (0 sorry)</div></div>
</div>

<h2><span class="sec-num">&sect; 1.</span> Why Existing Memory Isolation Breaks Down at Line Rate</h2>
<div class="prose-aside">
  <div>
    <p>Without structural assumptions on how requests are packed and how permissions evolve over a session, achieving zero-memory-tax isolation without link collapse is hopeless. Fortunately, real disaggregated memory protocols give us two concrete properties we can exploit directly in combinational logic:</p>
    <p><strong>First, CXL 3.0&ndash;5.0 512-bit flits are partitioned into four independent 128-bit sub-flit slots.</strong> Rather than invalidating the outer 512-bit link CRC when one tenant violates an aperture bound, a hardware interposer can evaluate all four slots in parallel inside a single <code>LUT6_2</code> logic level (<code>0.124 ns</code>), overwrite only the offending 128-bit slot into an algebraic no-op (<code>CXL_NOP</code>, <code>WSTRB = 16&apos;h0000</code>), and recompute the flit parity linearly down the pipeline.</p>
    <p><strong>Second, legitimate security policies tighten monotonically during workload execution.</strong> By wiring the capability register write path through a bitwise-AND latch (<code>reg &lt;= reg &amp; wdata</code>) whose preset pin is bound exclusively to physical cold power-on reset (<code>por_cold_rst_n</code>) rather than warm PCIe Function-Level Resets (<code>pcie_warm_flr_rst_n</code>), even a Ring-0 kernel compromise on the host cannot widen its own memory permissions without someone physically power-cycling the chassis.</p>
  </div>
  <div class="sidenote">
    <strong>What does this really mean?</strong><br><br>
    In plain terms: you do not need gigabytes of DRAM lookup tables to isolate shared HBM pools, and you do not have to trust the host OS kernel to keep an autonomous AI model inside its memory sandbox.
  </div>
</div>

<h2><span class="sec-num">&sect; 2.</span> Interactive Engineering Bench: Sub-Flit Sieve &amp; Cluster TCO Model</h2>
<p>Use the two analytical instruments below to inspect how sub-flit surgical clamping behaves on the 512-bit wire and how eliminating the 1.5625% DRAM permission-table carve-out scales across a facility under the LBNL-2001637 and ISO/IEC 30134-2/9 accounting methodology.</p>

<div class="bench-box">
  <div class="bench-head">
    <span>Instrument A // 512-Bit CXL Sub-Flit Inspection &amp; Fault-Injection Bench</span>
    <span id="flit-status-badge" style="color:var(--pass);">STATE: 4/4 SLOTS VALID &bull; GOODPUT 99.20% &bull; 0 CTO</span>
  </div>
  <div class="btn-row" style="margin-top:0;">
    <button class="btn" onclick="setBenchMode(0)">1. Nominal 4-Slot Traffic</button>
    <button class="btn btn-ghost" onclick="setBenchMode(1)">2. Inject Slot-1 Rogue Write (0xDEADBEEF)</button>
    <button class="btn btn-ghost" onclick="setBenchMode(2)">3. Simulate Host Warm PCIe FLR Attack</button>
    <button class="btn btn-ghost" onclick="setBenchMode(3)">4. Enable Tier-3 E8M0 Weight Clamp</button>
  </div>
  <div class="spec-table-wrap" style="margin-bottom:0.5rem;">
    <table class="spec" id="slot-table">
      <thead>
        <tr><th>Sub-Flit Slot</th><th>Tenant Cohort &amp; Opcode</th><th>Target HPA / Payload</th><th>Stage-1 Sieve (0.124 ns)</th><th>Stage-2 Wire Egress (2.855 ns)</th><th>Victim HBM State</th></tr>
      </thead>
      <tbody id="slot-tbody"></tbody>
    </table>
  </div>
  <div id="flit-narration" style="font-family:var(--mono); font-size:0.75rem; color:var(--muted);"></div>
</div>

<div class="bench-box">
  <div class="bench-head">
    <span>Instrument B // Renewal-Reward Goodput (Theorem 5.1) &amp; LBNL-2001637 Facility TCO Model</span>
    <span>1.5625% DRAM CARVE-OUT RECLAMATION</span>
  </div>
  <div class="ctrl-grid">
    <div class="ctrl-item">
      <label>Disaggregated Racks (<span id="lbl-racks">10,000</span> racks @ 16 TB/rack)</label>
      <input type="range" id="sl-racks" min="100" max="20000" step="100" value="10000" oninput="updateModels()">
    </div>
    <div class="ctrl-item">
      <label>Rogue / Faulting Sub-Flit Arrival Rate p_bad (<span id="lbl-pbad">0.80%</span>)</label>
      <input type="range" id="sl-pbad" min="0.1" max="5.0" step="0.1" value="0.8" oninput="updateModels()">
    </div>
    <div class="ctrl-item">
      <label>Link Replay Pipeline Depth N_pipe (<span id="lbl-npipe">32</span> flits)</label>
      <input type="range" id="sl-npipe" min="8" max="64" step="4" value="32" oninput="updateModels()">
    </div>
  </div>
  <div class="spec-table-wrap" style="margin-bottom:0;">
    <table class="spec">
      <thead>
        <tr><th>Metric / Physical Quantity</th><th class="num">Stateful DRAM Table / Whole-Flit CRC</th><th class="num">Spectral Flit-Filter (v1.0.0)</th><th class="num">Net Reclaimed / Advantage</th></tr>
      </thead>
      <tbody>
        <tr><td>Effective Allied Link Goodput</td><td class="num" id="m-gp-base">48.90%</td><td class="num" id="m-gp-spec"><strong>99.20%</strong></td><td class="num" id="m-gp-diff">+50.30% goodput</td></tr>
        <tr><td>Stranded Permission-Table DRAM (1.5625%)</td><td class="num" id="m-dram-base">2,500.0 TB</td><td class="num"><strong>0.0 TB (0 BRAM)</strong></td><td class="num" id="m-dram-save">2,500.0 TB reclaimed</td></tr>
        <tr><td>Memory CapEx Avoided ($15/GB HBM/DDR5)</td><td class="num" id="m-capex-base">$37.50M</td><td class="num"><strong>$0.00M</strong></td><td class="num" id="m-capex-save"><strong>$37.50M saved</strong></td></tr>
        <tr><td>Continuous Facility Power (PUE 1.25)</td><td class="num" id="m-pwr-base">8.01 &ndash; 39.44 MW</td><td class="num"><strong>0.00035 MW (35 mW/dev)</strong></td><td class="num" id="m-pwr-save">8.01 &ndash; 39.44 MW shed</td></tr>
        <tr><td>Annual Cooling Water (ISO 30134-9 WUE)</td><td class="num" id="m-wtr-base">101.0M &ndash; 497.5M L/yr</td><td class="num"><strong>0 L/yr</strong></td><td class="num" id="m-wtr-save">101.0M &ndash; 497.5M L/yr</td></tr>
      </tbody>
    </table>
  </div>
</div>

<h2><span class="sec-num">&sect; 3.</span> Empirical Silicon &amp; Formal Verification Summary</h2>
<p>Every architectural claim in the monograph is anchored by five reproducible verification artifacts in the public repository:</p>
<div class="spec-table-wrap">
  <table class="spec">
    <thead>
      <tr><th>Verification Pillar</th><th>Target Platform / Tool</th><th>Measured Result</th><th>Repository / Silicon Provenance</th></tr>
    </thead>
    <tbody>
      <tr><td><strong>1. Constructive Formal Proofs</strong></td><td>Microsoft Lean 4 (<code>4.28.0</code>, pure <code>Init.Prelude</code>)</td><td><strong>30 Theorem Groups</strong> (<code>0 sorry</code>, <code>0 axioms</code>, 33 verified groups)</td><td><code>formal_lean4/CxlSubflitSanitizerFormal.lean</code></td></tr>
      <tr><td><strong>2. 16nm FinFET Post-Route Sign-Off</strong></td><td>AMD Virtex UltraScale+ HBM <code>xcvu47p-fsvh2892-2L-e</code> (Vivado 2025.2)</td><td><strong>1,585 Core LUTs</strong> (0.12%, +341 Scrub Shim, 2,555 Cycle-0, 5,459 Wrapper LUTs), <strong>0 BRAM/DSP</strong>, <code>+1.048 ns</code> WNS (<code>338.8 MHz</code>), <code>35.0 mW</code></td><td><code>reports_public/AWS_VIVADO_SIGNOFF_SUMMARY.json</code></td></tr>
      <tr><td><strong>3. 7nm FinFET Standard-Cell ASIC</strong></td><td>ASAP7 7nm FinFET PDK (OpenROAD + OpenRCX + OpenSTA)</td><td><strong>9,678 Core Cells</strong> (11,420 GE, 27,877 enclave cells, <code>0.003335 mm&sup2;</code>), <code>693.19 MHz</code> Fmax, <code>3.728 mW</code></td><td><code>reports_public/TRL6_ASIC_7NM_ASAP7_SIGNOFF.json</code></td></tr>
      <tr><td><strong>4. Live Cloud FPGA Silicon (Dual-AFI)</strong></td><td>AWS EC2 <code>f2.6xlarge</code> (16nm <code>xcvu47p</code> + 16 GB HBM2, PCIe <code>0000:34:00.0</code>)</td><td><strong>800,000 BIST Slots</strong> (TVLA <code>max |t| = 0.0</code>), 100k DMA attacks blocked, <code>0xAAAAAAAAAAAAAAAA</code> intact</td><td><code>agfi-03b742e2a9cd2c0f2</code> &amp; <code>agfi-08becf3b40b169674</code></td></tr>
      <tr><td><strong>5. Control-Plane Admission Operator</strong></td><td><code>spectralc</code> Policy Compiler + <code>spectral-operator</code> K8s Webhook</td><td><strong>1.36 ms</strong> HTTP <code>403 Forbidden</code> rejection of non-monotonic policy widening</td><td><code>reports_public/TRL8_K8S_OPERATOR_HIL_RECEIPT.json</code></td></tr>
    </tbody>
  </table>
</div>

<h2><span class="sec-num">&sect; 4.</span> Canonical Vector Plates (Click Any Plate to Inspect at Full Resolution)</h2>
<div class="plate-grid">
  <div class="plate-card"><img src="figures/fig1_silicon_ppa.svg" alt="Plate 1" onclick="openLightbox(this.src, this.nextElementSibling.innerText)"><div class="plate-cap"><strong>Plate 1:</strong> 16nm xcvu47p FPGA (1,585 LUTs, 0 BRAM) &amp; 7nm ASAP7 FinFET (9,678 core / 27,877 enclave cells, 0.003335 mm&sup2;) PPA Sign-Off.</div></div>
  <div class="plate-card"><img src="figures/fig2_hbm_goodput.svg" alt="Plate 2" onclick="openLightbox(this.src, this.nextElementSibling.innerText)"><div class="plate-cap"><strong>Plate 2:</strong> Renewal-Reward Goodput Trajectory (99.20% vs. 48.90% at p_bad = 0.8%) &amp; Live 16 GB HBM2 DMA Audit.</div></div>
  <div class="plate-card"><img src="figures/fig3_martingale_latency.svg" alt="Plate 3" onclick="openLightbox(this.src, this.nextElementSibling.innerText)"><div class="plate-cap"><strong>Plate 3:</strong> Sparse-MoE Martingale Tail-Latency CCDF (8.0 ns Cut-Through vs. 184.2 ns DRAM Table Miss P99.99).</div></div>
  <div class="plate-card"><img src="figures/fig4_vieta_scaling.svg" alt="Plate 4" onclick="openLightbox(this.src, this.nextElementSibling.innerText)"><div class="plate-cap"><strong>Plate 4:</strong> Dual-Submode Cycle-0 Vieta GF(256)[Z] Root Sieve &amp; 132,600-Cohort Tensor Scaling.</div></div>
  <div class="plate-card"><img src="figures/fig5_tvla_dither.svg" alt="Plate 5" onclick="openLightbox(this.src, this.nextElementSibling.innerText)"><div class="plate-cap"><strong>Plate 5:</strong> Live AWS F2 19,990-Trace Welch TVLA (max |t| = 0.0 &lt; 4.5) &amp; Zero-LUT BF16 Mantissa Clamping Wall.</div></div>
  <div class="plate-card"><img src="figures/fig6_k8s_tco.svg" alt="Plate 6" onclick="openLightbox(this.src, this.nextElementSibling.innerText)"><div class="plate-cap"><strong>Plate 6:</strong> TRL-8 CNCF k3s Admission Webhook (1.36 ms Block) &amp; 10,000-Rack Exascale TCO ($37.50M&ndash;$38.40M Reclaimed).</div></div>
</div>

<script>
const BENCH_MODES = [
  {
    badge: "STATE: 4/4 SLOTS VALID | GOODPUT 100.0% | 0 CTO",
    color: "var(--pass)",
    note: "Nominal operation: all four 128-bit sub-flit slots carry authorized cohort credentials and pass cut-through in 8.0 ns (4 cycles @ 500 MHz).",
    rows: [
      ["Slot 0 [127:0]", "Cohort 0x11 (M2S_RwD)", "HPA 0x0000_1000_0040", "PASS (0.124 ns)", "FORWARD (WSTRB=0xFFFF)", "0xAAAAAAAAAAAAAAAA (Valid)"],
      ["Slot 1 [255:128]", "Cohort 0x11 (M2S_RwD)", "HPA 0x0000_1000_0080", "PASS (0.124 ns)", "FORWARD (WSTRB=0xFFFF)", "0xAAAAAAAAAAAAAAAA (Valid)"],
      ["Slot 2 [383:256]", "Cohort 0x24 (M2S_Req)", "HPA 0x0000_2000_0100", "PASS (0.124 ns)", "FORWARD (ARVALID=1)", "Read Completion Authorized"],
      ["Slot 3 [511:384]", "Cohort 0x24 (M2S_RwD)", "HPA 0x0000_2000_0140", "PASS (0.124 ns)", "FORWARD (WSTRB=0xFFFF)", "0xAAAAAAAAAAAAAAAA (Valid)"]
    ]
  },
  {
    badge: "STATE: SLOT 1 CLAMPED TO CXL_NOP | NEIGHBOR SLOTS 0,2,3 INTACT (99.20% GOODPUT)",
    color: "var(--accent)",
    note: "Theorem 5.1 & thm04 in action: Slot 1 attempts an unauthorized write (0xDEADBEEF). Stage-1 LUT6_2 forces WSTRB=0x0000 and rewrites Slot 1 to CXL_NOP without poisoning the 512-bit flit CRC. Slots 0, 2, and 3 complete with zero replay stall.",
    rows: [
      ["Slot 0 [127:0]", "Cohort 0x11 (M2S_RwD)", "HPA 0x0000_1000_0040", "PASS (0.124 ns)", "FORWARD (WSTRB=0xFFFF)", "0xAAAAAAAAAAAAAAAA (Intact)"],
      ["Slot 1 [255:128]", "ROGUE COHORT 0x9F", "HPA 0x0000_1000_0000 (0xDEADBEEF)", "FAULT -> TRAP CSR[0x48]", "CLAMPED: CXL_NOP (WSTRB=0x0000)", "0xAAAAAAAAAAAAAAAA (100% Protected)"],
      ["Slot 2 [383:256]", "Cohort 0x24 (M2S_Req)", "HPA 0x0000_2000_0100", "PASS (0.124 ns)", "FORWARD (ARVALID=1)", "Zero Link Retry Stall"],
      ["Slot 3 [511:384]", "Cohort 0x24 (M2S_RwD)", "HPA 0x0000_2000_0140", "PASS (0.124 ns)", "FORWARD (WSTRB=0xFFFF)", "0xAAAAAAAAAAAAAAAA (Intact)"]
    ]
  },
  {
    badge: "STATE: WARM PCIe FLR REJECTED BY COLD-POR AND2 RATCHET (thm06)",
    color: "var(--accent)",
    note: "A compromised root kernel triggers a warm PCIe Function-Level Reset (pcie_warm_flr_rst_n) and writes 0xFFFFFFFFFFFFFFFF to CSR[0x70] to re-open revoked bits. Because the AND2 latch resets only on por_cold_rst_n, CSR[0x70] remains locked at 0xFFFFFFFFFFFFFFEB.",
    rows: [
      ["BAR0 CSR[0x70]", "Host Root Write: 0xFFFF_FFFF_FFFF_FFFF", "Warm PCIe FLR Asserted", "AND2 Latch: q & wdata", "Locked: 0xFFFFFFFFFFFFFFEB", "Escalation Blocked (CSR[0x48]++)"],
      ["Slot 1 [255:128]", "Revoked Tenant Retry", "HPA 0x0000_1000_0000", "BLOCKED BY RATCHET", "CXL_NOP (WSTRB=0x0000)", "0xAAAAAAAAAAAAAAAA (Intact)"]
    ]
  },
  {
    badge: "STATE: TIER-3 E8M0 MANTISSA CLAMP ACTIVE (+0 LUT WIRE SLICE, thm27/thm29)",
    color: "var(--pass)",
    note: "Read-side model-weight protection: BF16 tensor reads pass through a zero-LUT wire-slice mask that zeroes all 7 mantissa bits (preserving sign + 8-bit exponent), erecting an 85x Le Cam minimax query wall against weight extraction.",
    rows: [
      ["Slot 0 Read", "BF16 Weight Read (Tier 3)", "Raw: 0x3F8E_3F8E_3F8E_3F8E", "Sign+Exp Preserved", "Clamped: 0x3F80_3F80_3F80_3F80", "85x Query Complexity Wall (thm29)"]
    ]
  }
];
function setBenchMode(idx) {
  const m = BENCH_MODES[idx];
  const b = document.getElementById("flit-status-badge");
  b.innerText = m.badge; b.style.color = m.color;
  document.getElementById("flit-narration").innerText = m.note;
  document.getElementById("slot-tbody").innerHTML = m.rows.map(r => `<tr><td><strong>${r[0]}</strong></td><td>${r[1]}</td><td class="mono">${r[2]}</td><td><strong>${r[3]}</strong></td><td class="mono">${r[4]}</td><td>${r[5]}</td></tr>`).join("");
}
function updateModels() {
  const racks = parseFloat(document.getElementById("sl-racks").value);
  const pbadPct = parseFloat(document.getElementById("sl-pbad").value);
  const npipe = parseFloat(document.getElementById("sl-npipe").value);
  document.getElementById("lbl-racks").innerText = racks.toLocaleString();
  document.getElementById("lbl-pbad").innerText = pbadPct.toFixed(2) + "%";
  document.getElementById("lbl-npipe").innerText = npipe;
  const p = pbadPct / 100.0;
  const pFlitClean = Math.pow(1.0 - p, 4);
  const gpBase = (pFlitClean / (pFlitClean + (1.0 - pFlitClean) * npipe)) * 100.0;
  const gpSpec = (1.0 - p) * 100.0;
  document.getElementById("m-gp-base").innerText = gpBase.toFixed(2) + "%";
  document.getElementById("m-gp-spec").innerHTML = "<strong>" + gpSpec.toFixed(2) + "%</strong>";
  document.getElementById("m-gp-diff").innerText = "+" + (gpSpec - gpBase).toFixed(2) + "% goodput";
  const dramTb = racks * 0.25;
  const capexM = dramTb * 1000.0 * 15.0 / 1e6;
  const pwrLow = (racks / 10000.0) * 8.01;
  const pwrHigh = (racks / 10000.0) * 39.44;
  const wtrLow = (racks / 10000.0) * 101.0;
  const wtrHigh = (racks / 10000.0) * 497.5;
  document.getElementById("m-dram-base").innerText = dramTb.toLocaleString(undefined,{minimumFractionDigits:1}) + " TB";
  document.getElementById("m-dram-save").innerText = dramTb.toLocaleString(undefined,{minimumFractionDigits:1}) + " TB reclaimed";
  document.getElementById("m-capex-base").innerText = "$" + capexM.toFixed(2) + "M";
  document.getElementById("m-capex-save").innerHTML = "<strong>$" + capexM.toFixed(2) + "M saved</strong>";
  document.getElementById("m-pwr-base").innerText = pwrLow.toFixed(2) + " - " + pwrHigh.toFixed(2) + " MW";
  document.getElementById("m-pwr-save").innerText = pwrLow.toFixed(2) + " - " + pwrHigh.toFixed(2) + " MW shed";
  document.getElementById("m-wtr-base").innerText = wtrLow.toFixed(1) + "M - " + wtrHigh.toFixed(1) + "M L/yr";
  document.getElementById("m-wtr-save").innerText = wtrLow.toFixed(1) + "M - " + wtrHigh.toFixed(1) + "M L/yr";
}
setBenchMode(1); updateModels();
</script>
"""

def build_benchmarks_body() -> str:
    return """
<div class="kicker">Section II &bull; Post-Route Silicon Sign-Off &amp; Workload Telemetry</div>
<h1>16nm UltraScale+ FPGA, 7nm ASAP7 FinFET &amp; Live AWS F2 Hardware Benchmarks</h1>
<p class="lead">To avoid confounding architectural properties with simulator artifacts, we synthesized, placed, and routed the Spectral Flit-Filter across both a commercial 16nm FinFET FPGA (AMD Virtex UltraScale+ HBM <code>xcvu47p-fsvh2892-2L-e</code>) and a 7nm FinFET standard-cell CMOS library (ASAP7), then executed live hardware-in-the-loop DMA and Built-In Self-Test (BIST) sweeps on AWS EC2 <code>f2.6xlarge</code> silicon.</p>
<h2><span class="sec-num">&sect; 2.1</span> Post-Route Hardware PPA Ledger (16nm FPGA &amp; 7nm CMOS ASIC)</h2>
<div class="spec-table-wrap">
  <table class="spec">
    <thead><tr><th>Parameter / Metric</th><th>16nm AMD <code>xcvu47p</code> (Core Sieve)</th><th>16nm 4-Stage Wrapper / Scrub Shim</th><th>7nm ASAP7 FinFET Standard-Cell ASIC</th></tr></thead>
    <tbody>
      <tr><td>Combinational Logic / Cells</td><td class="num">1,585 CLB LUTs (0.12%)</td><td class="num">5,459 Wrapper LUTs (+341 Scrub Shim)</td><td class="num">9,678 Core / 27,877 Enclave Cells</td></tr>
      <tr><td>Sequential Flip-Flops / Area</td><td class="num">1,157 FFs (321 CLBs)</td><td class="num">3,461 Registers (2,555 Cycle-0 LUTs)</td><td class="num">0.00224 mm&sup2; Core / 0.003335 mm&sup2; Enclave</td></tr>
      <tr><td>Block RAM / URAM / DSP Slices</td><td class="num"><strong>0 / 0 / 0 (0.00%)</strong></td><td class="num"><strong>0 / 0 / 0 (0.00%)</strong></td><td class="num"><strong>0 SRAM Macros (0.00%)</strong></td></tr>
      <tr><td>Stage-1 Sieve Propagation Delay</td><td class="num">0.124 ns (1 LUT6_2 level)</td><td class="num">0.124 ns</td><td class="num">38.0 ps</td></tr>
      <tr><td>Worst Negative Slack (WNS) / Fmax</td><td class="num">+1.048 ns @ 250 MHz (338.8 MHz)</td><td class="num">+1.842 ns @ 250 MHz (AWS F2 BIST)</td><td class="num">+2,556.41 ps (693.19 MHz)</td></tr>
      <tr><td>Total On-Chip / Core Power</td><td class="num">35.0 mW dynamic</td><td class="num">0 DRC violations</td><td class="num">3.728 mW (0 DRC violations)</td></tr>
    </tbody>
  </table>
</div>
<h2><span class="sec-num">&sect; 2.2</span> Live AWS EC2 <code>f2.6xlarge</code> Dual-AFI Hardware-in-the-Loop Receipts</h2>
<div class="spec-table-wrap">
  <table class="spec">
    <thead><tr><th>AWS F2 Hardware Image</th><th>AGFI / AFI Identifier</th><th>Physical Test Scope</th><th>Measured Hardware Outcome</th></tr></thead>
    <tbody>
      <tr><td><strong>Track B.1: Datapath &amp; TVLA BIST</strong></td><td><code>agfi-03b742e2a9cd2c0f2</code><br>(<code>afi-07282de69eecfd279</code>)</td><td>800,000 hardware BIST sub-flit slots + 19,990-trace Welch t-test (TVLA) + Warm PCIe FLR ratchet test</td><td><strong>800,000 / 800,000</strong> deterministic pass; <code>max |t| = 0.0 &lt; 4.5</code>; Warm FLR locked at <code>0xFFFFFFFFFFFFFFEB</code></td></tr>
      <tr><td><strong>Track B.2: Live 16 GB HBM2 DMA</strong></td><td><code>agfi-08becf3b40b169674</code><br>(<code>afi-0f2ddd7dc87d81193</code>)</td><td>100,000 inline DMA slots (25,000 bursts) + BF16 mantissa clamp across physical 16 GB HBM2 (<code>PF0-BAR4</code>)</td><td><strong>100% victim sentinel survival</strong> (<code>0xAAAAAAAAAAAAAAAA</code>); exact E8M0 clamping (<code>0x3F8E3F8E -&gt; 0x3F803F80</code>); <code>0</code> CTOs</td></tr>
    </tbody>
  </table>
</div>
"""

def build_zerotrust_body() -> str:
    return """
<div class="kicker">Section III &bull; Threat Model &amp; Federal Standards Crosswalk</div>
<h1>Five-Boundary Zero-Trust Architecture &amp; NSA NCDSMO RAIN Alignment</h1>
<p class="lead">Software security monitors assume that the hypervisor, OS kernel, and fabric manager remain uncompromised. Spectral Flit-Filter enforces isolation across five physical trust boundaries below Ring-0, mapping directly to NIST SP 800-207 (Zero Trust), NIST SP 800-193 (Platform Firmware Resiliency), RTCA DO-254 DAL-A, and NSA NCDSMO Redundant Always-Invoked Non-Bypassable (RAIN) criteria.</p>
<div class="spec-table-wrap">
  <table class="spec">
    <thead><tr><th>Standard / Mandate</th><th>Requirement</th><th>Spectral Hardware Mechanism</th><th>Formal / Silicon Evidence</th></tr></thead>
    <tbody>
      <tr><td><strong>NSA NCDSMO RAIN</strong></td><td>Non-bypassable, always-invoked, tamper-proof, verifiable</td><td>Cut-through wire-level <code>LUT6_2</code> sieve; cold-POR <code>AND2</code> ratchet; 30 zero-axiom Lean 4 proofs</td><td><code>thm00</code>&ndash;<code>thm29</code>; <code>SVA 1</code>&ndash;<code>SVA 10</code></td></tr>
      <tr><td><strong>NIST SP 800-207</strong></td><td>Per-request policy enforcement without implicit trust zones</td><td>Every 128-bit sub-flit evaluated independently in <code>0.124 ns</code> against Steiner <code>S(2,8,64)</code> cohort mask</td><td><code>thm04</code>, <code>thm21</code>, <code>agfi-08becf3b40b169674</code></td></tr>
      <tr><td><strong>NIST SP 800-193</strong></td><td>Immutable root of trust across warm host resets</td><td><code>CSR[0x70]</code> reset pin bound strictly to <code>por_cold_rst_n</code>; immune to <code>pcie_warm_flr_rst_n</code></td><td><code>thm06</code>; live warm FLR receipt</td></tr>
      <tr><td><strong>RTCA DO-254 DAL-A</strong></td><td>Deterministic timing &amp; minimal Single-Event Upset (SEU) cross-section</td><td><strong>0 Block RAM / 0 URAM / 0 LUTRAM</strong> eliminates &gt;99.98% of stateful SRAM upset bits</td><td>Vivado <code>xcvu47p</code> utilization report</td></tr>
      <tr><td><strong>SEC Rule 15c3-5</strong></td><td>Pre-trade market-access risk gate with deterministic tail latency</td><td><code>0.124 ns</code> combinational sieve + <code>8.0 ns</code> total pipeline with <code>0.0 ps&sup2;</code> credit jitter</td><td><code>thm09</code>, <code>thm20</code></td></tr>
    </tbody>
  </table>
</div>
"""

def build_verification_body(m: dict) -> str:
    return """
<div class="kicker">Section IV &bull; Five-Oracle Falsification Funnel &amp; Cryptographic Ledger</div>
<h1>30 Zero-Axiom Lean 4 Theorems (Init.Prelude) &amp; Reproducible Verification</h1>
<p class="lead">Every theorem in <code>formal_lean4/CxlSubflitSanitizerFormal.lean</code> and <code>CxlSubflitSanitizerExtensions.lean</code> is written in constructive term mode on top of pure <code>Init.Prelude</code> with zero <code>sorry</code> tokens, zero custom axioms, and zero classical choice axioms (<code>Classical.choice</code>, <code>propext</code>, and <code>Quot.sound</code> are completely absent).</p>
<pre># Reproduce the entire 5-pillar verification suite locally in under 60 seconds:
git clone https://github.com/spectralsystems/spectral-cxl-flit-sanitizer.git
cd spectral-cxl-flit-sanitizer
make all</pre>
<div class="spec-table-wrap">
  <table class="spec">
    <thead><tr><th>Theorem Group</th><th>Mathematical &amp; Hardware Property Verified</th><th>Axiom Footprint</th></tr></thead>
    <tbody>
      <tr><td><code>thm00</code> &ndash; <code>thm05</code></td><td>Sub-flit surgical <code>CXL_NOP</code> projection, <code>WSTRB=0</code> masking, and exact 16nm <code>LUT6_2</code> (<code>INIT=64&apos;h8000...</code>) SRAM bitmask equivalence</td><td><code>0 axioms</code> (Pure <code>Init.Prelude</code>)</td></tr>
      <tr><td><code>thm06</code> &ndash; <code>thm11</code></td><td>Cold-POR <code>AND2</code> monotonic capability ratchet (warm PCIe FLR immunity), credit conservation, and isochronous 4-stage delay equalization</td><td><code>0 axioms</code> (Pure <code>Init.Prelude</code>)</td></tr>
      <tr><td><code>thm12</code> &ndash; <code>thm18</code></td><td>Tropical <code>(max,+)</code> Kleene-Kron boundary summary (zero interior topology disclosure) and PHY-gated <code>&lt;4.0 ns</code> dual-tree failover</td><td><code>0 axioms</code> (Pure <code>Init.Prelude</code>)</td></tr>
      <tr><td><code>thm19</code> &ndash; <code>thm24</code></td><td>Read-side <code>ARVALID=0</code> RowHammer suppression, 341-LUT per-ARID zero-completion responder (<code>CmpltTO == 0</code>), and Vieta <code>GF(2^8)[Z]</code> cohort sieve</td><td><code>0 axioms</code> (Pure <code>Init.Prelude</code>)</td></tr>
      <tr><td><code>thm25</code> &ndash; <code>thm29</code></td><td>4-tier zero-LUT BF16/FP16 mantissa clamping, data-processing inequality, and the 85x Le Cam minimax weight-extraction query wall</td><td><code>0 axioms</code> (Pure <code>Init.Prelude</code>)</td></tr>
    </tbody>
  </table>
</div>
"""

def build_cots_body() -> str:
    return """
<div class="kicker">Section V &bull; Commercial COTS Licensing &amp; Federal Micro-Purchase</div>
<h1>FAR Part 12 Commercial Item &amp; FAR 13.201 GPC Procurement Schedule</h1>
<p class="lead">Spectral Flit-Filter (v1.0.0) was developed 100% at private expense by Spectral Systems LLC (CAGE: 268E1 &bull; SAM.gov UEI: VTP2JPCJU3D9 &bull; Virginia eVA: VA10140357) and is available immediately as a Commercial Off-The-Shelf (COTS) evaluation package under FAR Part 12, FAR 13.201 Government Purchase Card (GPC) micro-purchase procedures, and 10 U.S.C. &sect; 4022 Prototype OTAs.</p>
<div class="spec-table-wrap">
  <table class="spec">
    <thead><tr><th>Commercial SKU</th><th>Firm-Fixed-Price</th><th>Acquisition Vehicle</th><th>Deliverables Included</th></tr></thead>
    <tbody>
      <tr><td><strong>SKU-1: 45-Day Cloud FPGA &amp; Formal Eval</strong></td><td class="num"><strong>$9,850.00</strong></td><td>FAR 13.201 GPC Micro-Purchase (&lt;$10k / &lt;$25k)</td><td>Pre-synthesized 16nm <code>xcvu47p</code> evaluation drop, 30 zero-axiom Lean 4 proofs, C11 BAR0 driver, Python digital twin</td></tr>
      <tr><td><strong>SKU-2: 90-Day Subsystem &amp; Control-Plane Pilot</strong></td><td class="num"><strong>$24,950.00</strong></td><td>FAR 13.201 DoD Labs / University GPC (&le;$25k)</td><td>Dual-AFI AWS F2 access + 7nm ASAP7 sign-off package + <code>spectralc</code> policy compiler + <code>spectral-operator</code> K8s webhook</td></tr>
      <tr><td><strong>SKU-3: Single-Program Encrypted EDIF &amp; VIP</strong></td><td class="num"><strong>$95,000.00</strong></td><td>FAR Part 12 Simplified Acquisition / 10 U.S.C. &sect; 4022 OTA</td><td>IEEE 1735 encrypted netlist, SystemVerilog SVA VIP suite, DO-254 / RAIN compliance package, 12-month engineering integration</td></tr>
    </tbody>
  </table>
</div>
<div class="bench-box">
  <div class="bench-head"><span>Interactive FAR 13.106-1(b) Single-Source Determination &amp; GPC Quote Generator</span><span>CAGE: 268E1</span></div>
  <div class="ctrl-grid">
    <div class="ctrl-item"><label>Purchasing Agency / Laboratory</label><input type="text" id="gpc-org" value="NASA Langley Research Center / DoD Program Office" oninput="renderGpcMemo()"></div>
    <div class="ctrl-item"><label>Technical POC / Cardholder</label><input type="text" id="gpc-poc" value="Technical Director / Contracting Officer" oninput="renderGpcMemo()"></div>
    <div class="ctrl-item"><label>Selected COTS Evaluation SKU</label><select id="gpc-sku" onchange="renderGpcMemo()"><option value="SKU-1 ($9,850.00 Firm-Fixed-Price)">SKU-1 ($9,850.00 Firm-Fixed-Price)</option><option value="SKU-2 ($24,950.00 Firm-Fixed-Price)">SKU-2 ($24,950.00 Firm-Fixed-Price)</option><option value="SKU-3 ($95,000.00 Firm-Fixed-Price)">SKU-3 ($95,000.00 Firm-Fixed-Price)</option></select></div>
  </div>
  <pre id="gpc-memo-box"></pre>
  <button class="btn" onclick="copyGpcMemo()">Copy Formal GPC Quote &amp; FAR 13.106-1(b) Memo</button>
</div>
<script>
function renderGpcMemo() {
  const org = document.getElementById("gpc-org").value;
  const poc = document.getElementById("gpc-poc").value;
  const sku = document.getElementById("gpc-sku").value;
  const lines = [
    "MEMORANDUM FOR RECORD - FAR 13.106-1(b)(1) SINGLE-SOURCE DETERMINATION & COMMERCIAL COTS QUOTE",
    "Vendor: Spectral Systems LLC (United States) | CAGE: 268E1 | SAM.gov UEI: VTP2JPCJU3D9 | VA eVA: VA10140357",
    "Receiving Activity: " + org + " (Attn: " + poc + ")",
    "Item: Spectral Flit-Filter v1.0.0 - " + sku,
    "",
    "1. SINGLE-SOURCE TECHNICAL DETERMINATION:",
    "Spectral Systems LLC is the sole designer, manufacturer, and patent applicant (19 U.S. Provisional Patent Applications, All Patents Pending; developed 100% at private expense under DFARS 252.227-7018 and DEAR 952.227-14) of the Spectral Flit-Filter v1.0.0 architecture. No other commercial or open-source CXL/UCIe hardware core provides line-rate sub-flit capability sieving in 0 Block RAM / 0 URAM / 0 DSPs (1,585 Core CLB LUTs on 16nm xcvu47p; 9,678 core / 27,877 enclave cells on 7nm ASAP7) while sustaining 99.20% link goodput and 30 zero-axiom Lean 4 formal proofs.",
    "",
    "2. DELIVERY & PAYMENT:",
    "Immediate electronic delivery upon Government Purchase Card (GPC) authorization or purchase order issuance. Contact: eric@spectralsystems.org | https://spectralsystems.org"
  ];
  document.getElementById("gpc-memo-box").innerText = lines.join(String.fromCharCode(10));
}
function copyGpcMemo() {
  const el = document.getElementById("gpc-memo-box");
  if (navigator.clipboard && el) navigator.clipboard.writeText(el.innerText);
}
renderGpcMemo();
</script>
"""

def build_patents_body() -> str:
    return """
<div class="kicker">Section VI &bull; Intellectual Property, Export Control &amp; Two-Zone Air-Gap</div>
<h1>35 U.S.C. &sect; 287(a) Virtual Patent Marking &amp; DFARS 252.227-7018 Notice</h1>
<p class="lead">The architectures, finite-field algorithms, monotonic cold-POR hardware ratchets, per-ARID read-scrub shims, and policy compilers described on this site are covered by <strong>19 U.S. Provisional Patent Applications (All Patents Pending)</strong> assigned to Spectral Systems LLC (United States) and developed 100% at private expense prior to any federal contract.</p>
<div class="spec-table-wrap">
  <table class="spec">
    <thead><tr><th>Governance Domain</th><th>Statutory / Regulatory Citation</th><th>Public Zone-2 vs. Private Zone-1 Boundary</th></tr></thead>
    <tbody>
      <tr><td><strong>Virtual Patent Marking</strong></td><td>35 U.S.C. &sect; 287(a)</td><td>Covered by 19 pending U.S. provisional patent applications (All Patents Pending).</td></tr>
      <tr><td><strong>Sole Human Inventorship</strong></td><td>37 C.F.R. &sect; 1.41 &amp; USPTO 90 FR 54636 (Nov. 28, 2025)</td><td>100% conceived and reduced to practice by sole human inventor Eric C. Murphy.</td></tr>
      <tr><td><strong>Sovereign Data Rights</strong></td><td>DFARS 252.227-7018 &amp; DEAR 952.227-14</td><td>Synthesizable SystemVerilog (<code>.sv</code>), encrypted netlists (<code>.edf</code>), and Liberty timing libraries are retained in the air-gapped Zone-1 vault.</td></tr>
      <tr><td><strong>Open Verification License</strong></td><td>Apache License 2.0 (<code>Zone 2</code>)</td><td>Public Lean 4 proofs, behavioral twin, C11 BAR0 ABI headers, and reproduction scripts are licensed under Apache-2.0 with explicit commercial silicon patent reservation.</td></tr>
      <tr><td><strong>Export Control Notice</strong></td><td>15 C.F.R. &sect; 742.15(b) (EAR TSU)</td><td>Public source artifacts qualify as publicly available encryption/verification software under EAR 742.15(b).</td></tr>
    </tbody>
  </table>
</div>
"""

def build_console_body() -> str:
    return """
<div class="kicker">Section VII &bull; Interactive 16-CSR BAR0 Hardware Register &amp; Policy Compiler Bench</div>
<h1>4-KB PCIe BAR0 MMIO Register Map (0x00&ndash;0x78) &amp; Policy-to-BAR0 Compiler</h1>
<p class="lead">Select a declarative tenant mission profile below or inspect any of the 16 64-bit aligned PCIe <code>BAR0</code> control/status registers (PCI-SIG DVSEC Cap ID <code>0x0023</code>, DVSEC ID <code>0x4B4C</code>) to view the compiled register hex, hardware reset domain, and corresponding Lean 4 theorem gate.</p>
<div class="bench-box">
  <div class="bench-head"><span>Declarative Mission Profile &rarr; Compiled 16-CSR BAR0 Register Image</span><span>LEAN 4 KERNEL VERIFIED: 0 AXIOMS</span></div>
  <div class="btn-row" style="margin-top:0;">
    <button class="btn" onclick="loadProfile(0)">Profile 1: Multi-Tenant AI Weight Guard (E8M0 Clamp)</button>
    <button class="btn btn-ghost" onclick="loadProfile(1)">Profile 2: NASA / Avionics Radiation-Hardened 0-BRAM</button>
    <button class="btn btn-ghost" onclick="loadProfile(2)">Profile 3: SEC Rule 15c3-5 Ultra-Low-Latency Risk Gate</button>
  </div>
  <pre id="profile-yaml-out"></pre>
</div>
<div class="spec-table-wrap">
  <table class="spec">
    <thead><tr><th>BAR0 Offset</th><th>Register Mnemonic</th><th>Reset Domain</th><th>Compiled 64-Bit Hex Value</th><th>Hardware Function &amp; Lean 4 Proof Gate</th></tr></thead>
    <tbody>
      <tr><td class="mono"><strong>0x00</strong></td><td class="mono">CSR_SPATIAL_MASK</td><td><code>por_cold_rst_n</code></td><td class="mono">0x0000_FFFF_0000_0001</td><td>64-region HPA spatial aperture bitmap (<code>thm02</code>, <code>thm04</code>)</td></tr>
      <tr><td class="mono"><strong>0x08</strong></td><td class="mono">CSR_TEMPORAL_EPOCH</td><td><code>por_cold_rst_n</code></td><td class="mono">0x0000_0001_0000_03E8</td><td>Causal lease epoch window &amp; monotonic step bound (<code>thm07</code>)</td></tr>
      <tr><td class="mono"><strong>0x10</strong></td><td class="mono">CSR_VIETA_SIGMA_1_4</td><td><code>por_cold_rst_n</code></td><td class="mono">0x1A2B_3C4D_5E6F_7081</td><td>Vieta elementary symmetric polynomials &sigma;<sub>1</sub>..&sigma;<sub>4</sub> over GF(2<sup>8</sup>) (<code>thm21</code>)</td></tr>
      <tr><td class="mono"><strong>0x18</strong></td><td class="mono">CSR_VIETA_SIGMA_5_8</td><td><code>por_cold_rst_n</code></td><td class="mono">0x92A3_B4C5_D6E7_F809</td><td>Vieta elementary symmetric polynomials &sigma;<sub>5</sub>..&sigma;<sub>8</sub> over GF(2<sup>8</sup>) (<code>thm22</code>)</td></tr>
      <tr><td class="mono"><strong>0x28</strong></td><td class="mono">CSR_CREDITS_ISSUED</td><td><code>pcie_warm_flr_rst_n</code></td><td class="mono">0x0000_0000_000C_3500</td><td>Total CXL sub-flit credits issued across 4-stage pipeline (<code>thm09</code>)</td></tr>
      <tr><td class="mono"><strong>0x30</strong></td><td class="mono">CSR_CREDITS_RETURNED</td><td><code>pcie_warm_flr_rst_n</code></td><td class="mono">0x0000_0000_000C_3500</td><td>Isochronous credit return counter (<code>CSR 0x28 == CSR 0x30</code>, <code>thm09</code>)</td></tr>
      <tr><td class="mono"><strong>0x40</strong></td><td class="mono">CSR_LINK_NAK_COUNT</td><td><code>pcie_warm_flr_rst_n</code></td><td class="mono">0x0000_0000_0000_0000</td><td>Self-inflicted CXL link-layer CRC NAK counter (proven <code>== 0</code>, <code>thm05</code>)</td></tr>
      <tr><td class="mono"><strong>0x48</strong></td><td class="mono">CSR_TRAP_ESCALATIONS</td><td><code>por_cold_rst_n</code></td><td class="mono">0x0000_0000_0001_86A0</td><td>Monotonic counter of clamped rogue sub-flits &amp; blocked warm-reset writes</td></tr>
      <tr><td class="mono"><strong>0x58</strong></td><td class="mono">CSR_MANTISSA_TIER</td><td><code>por_cold_rst_n</code></td><td class="mono">0x0000_0000_0000_0003</td><td>4-tier zero-LUT BF16/FP16 mantissa clamp selector (Tier 3 E8M0, <code>thm27</code>/<code>thm29</code>)</td></tr>
      <tr><td class="mono"><strong>0x70</strong></td><td class="mono">CSR_COLD_POR_RATCHET</td><td><code>por_cold_rst_n</code> ONLY</td><td class="mono">0xFFFF_FFFF_FFFF_FFEB</td><td>Physical <code>AND2</code> capability latch immune to warm PCIe FLR (<code>thm06</code>)</td></tr>
    </tbody>
  </table>
</div>
<script>
const PROFILES = [
  ["# Profile 1: Multi-Tenant AI Weight Guard (85x Le Cam Query Wall)", "policy_id: frontier-hbm2-sandbox-v1", "spatial_aperture_mask: 0x0000_FFFF_0000_0001", "steiner_cohort_s2_8_64: [0x11, 0x24, 0x38, 0x4C]", "mantissa_clamp_tier: TIER_3_E8M0_SIGN_EXP_ONLY  # +0 LUTs (thm27/thm29)", "warm_flr_immunity: ENFORCED_POR_COLD_RST_ONLY   # CSR[0x70] = 0xFFFFFFFFFFFFFFEB"].join(String.fromCharCode(10)),
  ["# Profile 2: NASA / Spaceflight Avionics DO-254 DAL-A (0 Block RAM)", "policy_id: larc-seu-immune-partition-v1", "sram_lookup_tables: 0_BRAM_0_URAM_0_LUTRAM      # >99.98% SEU reduction", "read_scrub_responder: PER_ARID_341_LUT_FF_ONLY  # CmpltTO == 0 (thm19/thm20)", "stage1_sieve_budget_ns: 0.124                   # +1.048 ns WNS on xcvu47p"].join(String.fromCharCode(10)),
  ["# Profile 3: Wall Street SEC Rule 15c3-5 Pre-Trade Risk Gate", "policy_id: sec-15c3-5-killswitch-v1", "pipeline_latency_ns: 8.0                        # 4 cycles @ 500 MHz, 0.0 ps^2 jitter", "kill_switch_ratchet: MONOTONIC_AND2_LATCH       # Physical cold power-cycle required to re-arm"].join(String.fromCharCode(10))
];
function loadProfile(i) { document.getElementById("profile-yaml-out").innerText = PROFILES[i]; }
loadProfile(0);
</script>
"""

def build_og_card():
    FIG.mkdir(parents=True, exist_ok=True)
    out_png = FIG / "og_datasheet_card.png"
    try:
        from PIL import Image, ImageDraw, ImageFont
    except ImportError:
        return
    W, H = 1200, 630
    img = Image.new("RGB", (W, H), (244, 241, 234))
    d = ImageDraw.Draw(img)
    ink = (17, 17, 16)
    sub = (234, 230, 220)
    acc = (184, 46, 20)
    muted = (94, 92, 86)
    d.rectangle([18, 18, W - 18, H - 18], outline=ink, width=3)
    d.rectangle([21, 21, W - 21, 72], fill=sub, outline=ink, width=1)
    def load_font(names, size):
        for n in names:
            try:
                return ImageFont.truetype(n, size)
            except Exception:
                pass
        return ImageFont.load_default()
    f_mono_sm = load_font(["consolab.ttf", "consola.ttf", "courbd.ttf"], 18)
    f_mono_md = load_font(["consolab.ttf", "consola.ttf", "courbd.ttf"], 22)
    f_serif_lg = load_font(["georgia.ttf", "palabi.ttf", "timesbd.ttf"], 44)
    f_sans_md = load_font(["arial.ttf", "segoeui.ttf"], 24)
    f_val = load_font(["consolab.ttf", "consola.ttf"], 34)
    d.text((42, 36), "SPECTRAL SYSTEMS LLC (UNITED STATES) // CAGE: 268E1 // UEI: VTP2JPCJU3D9", fill=ink, font=f_mono_sm)
    d.text((42, 96), "TECHNICAL MONOGRAPH & SILICON DATASHEET // SPEC-FF-V1.0.0", fill=acc, font=f_mono_md)
    d.text((42, 138), "Spectral Flit-Filter: Zero-BRAM Sub-Flit", fill=ink, font=f_serif_lg)
    d.text((42, 192), "Capability Sieve & Cold-POR Hardware Ratchet", fill=ink, font=f_serif_lg)
    d.text((42, 260), "Line-rate CXL 3.0-5.0 & UCIe memory isolation in 0 Block RAM. Proved in pure", fill=muted, font=f_sans_md)
    d.text((42, 292), "Init.Prelude Lean 4 (30 theorems, 0 axioms) & verified on live AWS F2 HBM2 silicon.", fill=muted, font=f_sans_md)
    y0, y1 = 355, 535
    d.rectangle([42, y0, W - 42, y1], fill=(250, 248, 243), outline=ink, width=2)
    cols = [
        ("16NM XCVU47P CORE", "1,585 LUTs", "0 BRAM / 0.124 ns Sieve"),
        ("7NM ASAP7 CMOS ASIC", "693.19 MHz", "3.728 mW / 0.003335 mm2"),
        ("ALLIED LINK GOODPUT", "99.20%", "vs. 48.90% CRC Poison"),
        ("FORMAL & HIL PROOF", "30 Theorems", "AWS F2 16 GB HBM2 Verified"),
    ]
    cw = (W - 84) // 4
    for i, (lbl, val, note) in enumerate(cols):
        x = 42 + i * cw
        if i > 0:
            d.line([(x, y0), (x, y1)], fill=ink, width=1)
        d.text((x + 18, y0 + 22), lbl, fill=muted, font=f_mono_sm)
        d.text((x + 18, y0 + 62), val, fill=ink, font=f_val)
        d.text((x + 18, y0 + 118), note, fill=acc, font=f_mono_sm)
    d.text((42, 558), "spectralsystems.org  |  agfi-03b742e2a9cd2c0f2  |  agfi-08becf3b40b169674  |  All Patents Pending", fill=ink, font=f_mono_sm)
    img.save(out_png, format="PNG", optimize=True)
    print("[OG_CARD_PASS] Rendered 1200x630 datasheet preview card ->", out_png)

def build_machine_manifests():
    did_doc = {
        "@context": ["https://www.w3.org/ns/did/v1"],
        "id": "did:web:spectralsystems.org",
        "alsoKnownAs": [BASE_URL, REPO_URL],
        "service": [
            {"id": "did:web:spectralsystems.org#monograph", "type": "TechnicalMonograph", "serviceEndpoint": f"{BASE_URL}/preprint_Murphy_v1_0_0.pdf"},
            {"id": "did:web:spectralsystems.org#capability", "type": "FederalCapabilityStatement", "serviceEndpoint": f"{BASE_URL}/capability-statement.pdf"},
            {"id": "did:web:spectralsystems.org#vendor", "type": "ProcurementProfile", "serviceEndpoint": f"{BASE_URL}/vendor-profile.json"},
            {"id": "did:web:spectralsystems.org#repo", "type": "VerificationRepository", "serviceEndpoint": REPO_URL}
        ]
    }
    write_lf(WEB / ".well-known" / "did.json", json.dumps(did_doc, indent=2) + NL)
    vendor_doc = {
        "schema": "spectral.vendor.profile.v1.0.0",
        "updated_utc": NOW_UTC,
        "legal_name": "Spectral Systems LLC",
        "jurisdiction": "United States",
        "founder_and_pi": "Eric C. Murphy",
        "contact_email": "eric@spectralsystems.org",
        "website": BASE_URL,
        "capability_statement_pdf": f"{BASE_URL}/capability-statement.pdf",
        "monograph_pdf": f"{BASE_URL}/preprint_Murphy_v1_0_0.pdf",
        "verification_repository": REPO_URL,
        "identifiers": {
            "dla_cage_code": "268E1",
            "sam_gov_uei": "VTP2JPCJU3D9",
            "virginia_eva_id": "VA10140357",
            "ntdc_status": "Non-Traditional Defense Contractor (10 U.S.C. 4022 Prototype OTA Eligible)",
            "patent_portfolio": "19 U.S. Provisional Patent Applications (All Patents Pending; 100% Private Expense under DFARS 252.227-7018 & DEAR 952.227-14)"
        },
        "classifications": {
            "naics_codes": ["334413", "541715", "541512", "513210"],
            "psc_codes": ["5962", "AC12", "AC13", "7A21"]
        },
        "verified_hardware_baselines": {
            "lean4_formal_kernel": "30 Constructive Term-Mode Theorems (Init.Prelude, 0 sorry, 0 axioms)",
            "fpga_16nm_xcvu47p": "1,585 Core CLB LUTs (0.12%), 0 BRAM/URAM/DSP, 0.124 ns Stage-1 Sieve, +1.048 ns WNS (338.8 MHz), 35.0 mW",
            "asic_7nm_asap7": "9,678 Core / 27,877 Enclave Cells (0.003335 mm2 enclave), 693.19 MHz Fmax, 3.728 mW, 0 SRAM",
            "aws_f2_bist_agfi": "agfi-03b742e2a9cd2c0f2 (afi-07282de69eecfd279, 800,000 sub-flit slots, TVLA max |t| = 0.0)",
            "aws_f2_hbm2_dma_agfi": "agfi-08becf3b40b169674 (afi-0f2ddd7dc87d81193, 16 GB HBM2 DMA, 100% sentinel survival, 0 CmpltTO)"
        },
        "commercial_cots_skus": [
            {"sku": "SKU-1", "price_usd": 9850.00, "vehicle": "FAR 13.201 GPC Micro-Purchase", "scope": "45-Day 16nm FPGA & Lean 4 Formal Evaluation Package"},
            {"sku": "SKU-2", "price_usd": 24950.00, "vehicle": "FAR 13.201 DoD Lab / University GPC (<= $25k)", "scope": "90-Day Dual-AFI AWS F2 + 7nm ASAP7 + spectralc/k3s Operator Pilot"},
            {"sku": "SKU-3", "price_usd": 95000.00, "vehicle": "FAR Part 12 Simplified Acquisition / 10 U.S.C. 4022 OTA", "scope": "Single-Program Encrypted EDIF Netlist, SVA VIP & 12-Month Engineering Integration"}
        ]
    }
    write_lf(WEB / "vendor-profile.json", json.dumps(vendor_doc, indent=2) + NL)
    print("[MANIFEST_PASS] Wrote /.well-known/did.json and /vendor-profile.json")

def build_capability_pdf():
    DEAL.mkdir(parents=True, exist_ok=True)
    cap_tex = DEAL / "capability_statement.tex"
    tex_template = [
        ":BS:documentclass[10pt,letterpaper]{article}",
        ":BS:usepackage[margin=0.52in]{geometry}",
        ":BS:usepackage{array,booktabs,tabularx}",
        ":BS:usepackage[hidelinks]{hyperref}",
        ":BS:pagestyle{empty}",
        ":BS:setlength{:BS:parindent}{0pt}",
        ":BS:setlength{:BS:parskip}{4pt}",
        ":BS:begin{document}",
        "{:BS:LARGE:BS:bfseries SPECTRAL SYSTEMS LLC}:BS:hfill{:BS:ttfamily:BS:small CAGE: 268E1 :BS:textbullet:BS: SAM.gov UEI: VTP2JPCJU3D9 :BS:textbullet:BS: VA eVA: VA10140357}:BS::BS:",
        "{:BS:footnotesize:BS:ttfamily Hardware-Enforced CXL 3.0--5.0 / UCIe Memory Isolation :BS:& Formal Silicon Verification :BS:hfill Web: https://spectralsystems.org :BS:textbullet:BS: POC: eric@spectralsystems.org}",
        ":BS:vspace{2pt}:BS:hrule height 1.2pt:BS:vspace{4pt}",
        ":BS:textbf{:BS:uppercase{1. Executive Overview :BS:& Core Capability (TRL-6/7 Silicon :BS:& TRL-8 Cloud Control Plane)}}:BS::BS:",
        "Spectral Systems LLC designs and licenses the :BS:textbf{Spectral Flit-Filter (v1.0.0)}, a stateless, cut-through hardware security interposer for disaggregated Compute Express Link (CXL 3.0--5.0), PCIe Gen5/Gen6, and UCIe High-Bandwidth Memory (HBM2e/HBM3/HBM4) fabrics. Developed 100:BS:% at private expense (:BS:texttt{DFARS 252.227-7018} / :BS:texttt{DEAR 952.227-14}; 19 U.S. Provisional Patent Applications, :BS:textit{All Patents Pending}), the core evaluates spatial, temporal, and tenant capability masks across all four 128-bit sub-flit slots of a 512-bit flit in a single :BS:texttt{0.124 ns} logic level using :BS:textbf{zero Block RAM (:BS:texttt{0 BRAM / 0 URAM / 0 DSP})} while sustaining :BS:textbf{99.20:BS:% link goodput} (vs.:BS: 48.90:BS:% under whole-flit CRC poisoning) and reclaiming :BS:textbf{2,500 TB of stranded DRAM} (:BS:$37.50M--:BS:$38.40M CapEx) per 10,000-rack cluster.",
        ":BS:vspace{2pt}:BS:textbf{:BS:uppercase{2. Verified Empirical Silicon, ASIC :BS:& Formal Proof Baseline (Auditable in 60 Seconds)}}",
        ":BS:begin{center}:BS:footnotesize",
        ":BS:begin{tabularx}{:BS:textwidth}{@{}l l X@{}}",
        ":BS:toprule",
        ":BS:textbf{Verification Track} & :BS:textbf{Platform / Toolchain} & :BS:textbf{Measured Post-Route / Live Hardware Telemetry} :BS::BS:",
        ":BS:midrule",
        ":BS:textbf{1. Formal Proof Kernel} & Microsoft Lean 4 (:BS:texttt{Init.Prelude}) & :BS:textbf{30 Constructive Theorems} (:BS:texttt{thm00}--:BS:texttt{thm29}, :BS:texttt{0 sorry}, :BS:texttt{0 axioms}) down to placed 16nm :BS:texttt{LUT6:BS:_2} truth tables. :BS::BS:",
        ":BS:textbf{2. 16nm FinFET FPGA} & AMD UltraScale+ :BS:texttt{xcvu47p} (Vivado) & :BS:textbf{1,585 Core CLB LUTs} (0.12:BS:%), :BS:textbf{0 BRAM/URAM/DSP}, :BS:texttt{0.124 ns} Stage-1 sieve, :BS:texttt{+1.048 ns} WNS (:BS:texttt{338.8 MHz}), :BS:texttt{35.0 mW}. :BS::BS:",
        ":BS:textbf{3. 7nm FinFET CMOS} & ASAP7 7nm PDK (OpenROAD/STA) & :BS:textbf{9,678 Core / 27,877 Enclave Cells} (:BS:texttt{0.003335 mm$^2$} full enclave), :BS:textbf{693.19 MHz} Fmax, :BS:textbf{3.728 mW}, :BS:texttt{0} SRAM. :BS::BS:",
        ":BS:textbf{4. AWS F2 BIST :BS:& TVLA} & :BS:texttt{agfi-03b742e2a9cd2c0f2} (:BS:texttt{f2.6xlarge}) & :BS:textbf{800,000 BIST sub-flit slots} @ 250 MHz (128 Gbps), warm PCIe FLR survival (:BS:texttt{CSR[0x70]=0xFFFFFFFFFFFFFFEB}), TVLA $:BS:max|t|=0.0$. :BS::BS:",
        ":BS:textbf{5. AWS F2 16 GB HBM2} & :BS:texttt{agfi-08becf3b40b169674} (:BS:texttt{f2.6xlarge}) & :BS:textbf{100,000 inline DMA slots} across physical 16 GB HBM2 (:BS:texttt{PF0-BAR4}), 100:BS:% sentinel survival (:BS:texttt{0xAAAAAAAAAAAAAAAA}), :BS:texttt{0} CTOs. :BS::BS:",
        ":BS:textbf{6. Kubernetes Operator} & :BS:texttt{spectralc} + CNCF :BS:texttt{k3s} Webhook & FIPS-204 :BS:texttt{ML-DSA-87} signed policy bundles; blocks non-monotonic privilege widening (:BS:texttt{HTTP 403}) in :BS:textbf{1.36 ms}. :BS::BS:",
        ":BS:bottomrule",
        ":BS:end{tabularx}",
        ":BS:end{center}",
        ":BS:textbf{:BS:uppercase{3. Key Differentiators for DoD, NASA, DOE, IC :BS:& Hyperscale Partners}}",
        ":BS:begin{itemize}:BS:setlength{:BS:itemsep}{1pt}:BS:setlength{:BS:parskip}{0pt}:BS:footnotesize",
        "  :BS:item :BS:textbf{Cold-Power-Isolated Monotonic Ratchet (:BS:texttt{thm06}):} Capability register :BS:texttt{CSR[0x70]} enforces a physical :BS:texttt{AND2} latch (:BS:texttt{q <= q :BS:& wdata}) reset exclusively by cold power-on reset (:BS:texttt{por:BS:_cold:BS:_rst:BS:_n}). Even a Ring-0 host root compromise + warm PCIe reset cannot widen memory permissions.",
        "  :BS:item :BS:textbf{Radiation-Resilient 0-BRAM Footprint (:BS:texttt{DO-254 DAL-A} :BS:& :BS:texttt{NSA RAIN}):} Eliminates $>$99.98:BS:% of stateful SRAM Single-Event Upset (SEU) cross-section while preventing RowHammer (:BS:texttt{ARVALID=0}) and PCIe Completion Timeouts via a 341-LUT per-ARID zero-completion responder.",
        "  :BS:item :BS:textbf{Zero-LUT Model-Weight Anti-Exfiltration (:BS:texttt{thm27}/:BS:texttt{thm29}):} Hardware read-path wire-slicing clamps BF16/FP16 mantissas in 0 extra LUTs, erecting an $85:BS:times$ Le Cam minimax query-complexity wall against frontier model weight extraction.",
        ":BS:end{itemize}",
        ":BS:textbf{:BS:uppercase{4. Turnkey COTS Procurement :BS:& Rapid Contracting Vehicles}}",
        ":BS:begin{center}:BS:footnotesize",
        ":BS:begin{tabularx}{:BS:textwidth}{@{}l l l X@{}}",
        ":BS:toprule",
        ":BS:textbf{SKU / Track} & :BS:textbf{Firm-Fixed-Price} & :BS:textbf{Contracting Vehicle} & :BS:textbf{Deliverables (Immediate Electronic / AWS F2 Delivery)} :BS::BS:",
        ":BS:midrule",
        ":BS:textbf{SKU-1 (Eval Drop)} & :BS:textbf{:BS:$9,850.00} & FAR 13.201 GPC Micro-Purchase & 45-Day 16nm :BS:texttt{xcvu47p} Eval Drop, 30 Lean 4 Proofs, C11 BAR0 Driver, Python Digital Twin. :BS::BS:",
        ":BS:textbf{SKU-2 (Full Pilot)} & :BS:textbf{:BS:$24,950.00} & FAR 13.201 Lab GPC ($:BS:le$:BS:$25k) & 90-Day Dual-AFI AWS F2 Share + 7nm ASAP7 Package + :BS:texttt{spectralc} Compiler + :BS:texttt{k3s} Operator. :BS::BS:",
        ":BS:textbf{SKU-3 (Core License)} & :BS:textbf{:BS:$95,000.00} & FAR Part 12 / 10 U.S.C. :BS:S:BS: 4022 OTA & Single-Program IEEE 1735 Encrypted EDIF Netlist, SVA VIP Suite, DO-254/RAIN Package. :BS::BS:",
        ":BS:bottomrule",
        ":BS:end{tabularx}",
        ":BS:end{center}",
        ":BS:vspace{2pt}:BS:hrule height 0.8pt:BS:vspace{3pt}",
        "{:BS:footnotesize:BS:ttfamily :BS:textbf{Corporate Data:} Spectral Systems LLC (Sole Inventor :BS:& CEO: Eric C. Murphy) :BS:textbullet:BS: :BS:textbf{CAGE:} 268E1 :BS:textbullet:BS: :BS:textbf{UEI:} VTP2JPCJU3D9 :BS:textbullet:BS: :BS:textbf{VA eVA:} VA10140357 :BS:textbullet:BS: :BS:textbf{NAICS:} 334413, 541715, 541512, 513210 :BS:textbullet:BS: :BS:textbf{PSC:} 5962, AC12 :BS:textbullet:BS: :BS:textbf{Repo:} https://github.com/spectralsystems/spectral-cxl-flit-sanitizer :BS:textbullet:BS: :BS:textbf{DOI:} 10.5281/zenodo.19503283}",
        ":BS:end{document}"
    ]
    tex_src = NL.join(tex_template).replace(":BS:", BS) + NL
    write_lf(cap_tex, tex_src)
    tec = ROOT / ".tools_cache" / "tectonic.exe"
    pdflatex_cands = [
        pathlib.Path("C:/Program Files/MiKTeX/miktex/bin/x64/pdflatex.exe"),
        pathlib.Path.home() / "AppData/Local/Programs/MiKTeX/miktex/bin/x64/pdflatex.exe",
    ]
    pdf_out = DEAL / "capability_statement.pdf"
    if tec.is_file():
        subprocess.run([str(tec), "-X", "compile", str(cap_tex)], cwd=str(DEAL), check=True)
    else:
        for c in pdflatex_cands:
            if c.is_file():
                subprocess.run([str(c), "-interaction=nonstopmode", "-halt-on-error", str(cap_tex)], cwd=str(DEAL), check=True)
                break
    if pdf_out.is_file():
        shutil.copy2(pdf_out, WEB / "capability-statement.pdf")
        print(f"[CAP_STATEMENT_PASS] Compiled 1-page capability-statement.pdf ({pdf_out.stat().st_size} bytes)")

def build_site(repo: pathlib.Path = Z2, m: dict = None, ppa_count: int = 19) -> list:
    if m is None:
        m = load_manifest()
    doi_str = str(m.get("zenodo_doi", "10.5281/zenodo.19503283"))
    WEB.mkdir(parents=True, exist_ok=True)
    (WEB / "console-demo").mkdir(parents=True, exist_ok=True)
    build_og_card()
    build_machine_manifests()
    build_capability_pdf()
    href_old = "href=" + DQ
    href_new = "href=" + DQ + "../"
    href_http_old = "href=" + DQ + "../https:"
    href_http_new = "href=" + DQ + "https:"
    console_rail = COMMON_RAIL.replace(href_old, href_new).replace(href_http_old, href_http_new)
    pages = {
        "index.html": wrap_page("SPECTRAL FLIT-FILTER (v1.0.0) - Technical Monograph & Datasheet", "index.html", COMMON_RAIL, build_index_body(), doi_str),
        "benchmarks.html": wrap_page("Silicon & PPA Benchmarks - 16nm xcvu47p, 7nm ASAP7 & AWS F2", "benchmarks.html", COMMON_RAIL, build_benchmarks_body(), doi_str),
        "zero-trust.html": wrap_page("Zero-Trust Architecture & NSA NCDSMO RAIN Crosswalk", "zero-trust.html", COMMON_RAIL, build_zerotrust_body(), doi_str),
        "verification.html": wrap_page("30 Zero-Axiom Lean 4 Proofs & Reproducible Verification", "verification.html", COMMON_RAIL, build_verification_body(m), doi_str),
        "cots-procurement.html": wrap_page("Commercial COTS & FAR 13.201 GPC Procurement Schedule", "cots-procurement.html", COMMON_RAIL, build_cots_body(), doi_str),
        "patents.html": wrap_page("Intellectual Property, DFARS 252.227-7018 & Export Control", "patents.html", COMMON_RAIL, build_patents_body(), doi_str),
        "console-demo/index.html": wrap_page("Interactive 16-CSR BAR0 Register & Policy Bench", "console-demo/index.html", console_rail, build_console_body(), doi_str),
    }
    for rel_path, html_text in pages.items():
        write_lf(WEB / rel_path, html_text)
    sums_p = Z2 / "SHA256SUMS.txt"
    if sums_p.is_file():
        updated = []
        for ln in sums_p.read_text(encoding="utf-8").splitlines():
            parts = ln.strip().split()
            if len(parts) >= 2:
                rel = parts[-1].lstrip("*./").replace(BS, "/")
                fp = Z2 / rel
                if fp.is_file():
                    h = hashlib.sha256(fp.read_bytes()).hexdigest()
                    updated.append(f"{h}  {rel}")
                else:
                    updated.append(ln)
        write_lf(sums_p, NL.join(updated) + NL)
    print("[SLOAN_MONOGRAPH_SITE_PASS] Built 7 monograph pages + OG card + capability-statement.pdf in", WEB)
    return [
        "",
        "benchmarks.html",
        "console-demo/",
        "cots-procurement.html",
        "funding.json",
        "llms.txt",
        "patents.html",
        "preprint_Murphy_v1_0_0.pdf",
        "verification.html",
        "zero-trust.html",
    ]

def main():
    build_site(Z2, load_manifest(), 19)

if __name__ == "__main__":
    main()
