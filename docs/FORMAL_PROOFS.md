# Mathematical Specification & Lean 4 Proof Kernel

## 1. Cellular Sheaf Stalk Decomposition on CXL Flits
Each 512-bit CXL 3.0/4.0 flit is partitioned into four 128-bit protocol slots $s_i \in \{0,1\}^{128}$ accompanied by capability stalk $p_i$. In Stage 1 ($\le 38.0\text{ ps}$), the hardware computes the orthogonal split:

$$s_i = (s_i \land p_i) \oplus (s_i \land \neg p_i)$$

A slot belongs to the kernel of the defect operator $\ker(I \oplus P)$ if and only if $(s_i \land \neg p_i) = 0$.

## 2. Interactive Verification via GitHub Codespaces
Click **Code → Codespaces → Create codespace on main** at the top of this repository to launch an interactive browser VS Code instance with Microsoft Lean 4 pre-installed and inspect `formal_lean4/SheafCosetIsometry.lean` live.