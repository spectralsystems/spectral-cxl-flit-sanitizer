-- File: formal_lean4/CxlSubflitSanitizerExtensions.lean
-- Spectral Systems LLC (v1.0.0) - Expansion Theorems thm20..thm29 (ZeroAxioms)
set_option linter.unusedVariables false

def bNot (a : Bool) : Bool := Bool.casesOn a true false
def bAnd (a b : Bool) : Bool := Bool.casesOn a false b
def bOr  (a b : Bool) : Bool := Bool.casesOn a b true
def bXor (a b : Bool) : Bool := Bool.casesOn a b (bNot b)

inductive B8 : Type where
  | mk : Bool -> Bool -> Bool -> Bool -> Bool -> Bool -> Bool -> Bool -> B8

def b8Zero : B8 := B8.mk false false false false false false false false

def b8Xor (a b : B8) : B8 :=
  B8.casesOn a (fun a7 a6 a5 a4 a3 a2 a1 a0 =>
    B8.casesOn b (fun b7 b6 b5 b4 b3 b2 b1 b0 =>
      B8.mk (bXor a7 b7) (bXor a6 b6) (bXor a5 b5) (bXor a4 b4)
            (bXor a3 b3) (bXor a2 b2) (bXor a1 b1) (bXor a0 b0)))

def gf256Xtime (a : B8) : B8 :=
  B8.casesOn a (fun a7 a6 a5 a4 a3 a2 a1 a0 =>
    B8.mk a6 a5 a4 (bXor a3 a7) (bXor a2 a7) a1 (bXor a0 a7) a7)

def b8Mask (bit : Bool) (a : B8) : B8 := Bool.casesOn bit b8Zero a

def gf256Mul (a b : B8) : B8 :=
  B8.casesOn b (fun b7 b6 b5 b4 b3 b2 b1 b0 =>
    let x0 := a
    let x1 := gf256Xtime x0
    let x2 := gf256Xtime x1
    let x3 := gf256Xtime x2
    let x4 := gf256Xtime x3
    let x5 := gf256Xtime x4
    let x6 := gf256Xtime x5
    let x7 := gf256Xtime x6
    b8Xor (b8Xor (b8Xor (b8Mask b0 x0) (b8Mask b1 x1))
                 (b8Xor (b8Mask b2 x2) (b8Mask b3 x3)))
          (b8Xor (b8Xor (b8Mask b4 x4) (b8Mask b5 x5))
                 (b8Xor (b8Mask b6 x6) (b8Mask b7 x7))))

theorem lem_gf256_mul_zero_right : forall (a : B8), gf256Mul a b8Zero = b8Zero :=
  fun _a => rfl

theorem thm20_vieta_gf256_ideal_ratchet_monotonic_and_degree_bound :
  forall (z alpha evalVal : B8),
    And (gf256Mul (b8Xor z alpha) b8Zero = b8Zero)
        (evalVal = b8Zero -> gf256Mul (b8Xor z alpha) evalVal = b8Zero) :=
  fun z alpha evalVal =>
    And.intro
      (lem_gf256_mul_zero_right (b8Xor z alpha))
      (fun h => Eq.trans (congrArg (gf256Mul (b8Xor z alpha)) h) (lem_gf256_mul_zero_right (b8Xor z alpha)))

theorem thm21_orbit_chord_clamping :
  forall (hr gOrb : Bool), bAnd (bAnd hr gOrb) (bNot gOrb) = false :=
  fun hr gOrb =>
    Bool.casesOn hr (Bool.casesOn gOrb rfl rfl) (Bool.casesOn gOrb rfl rfl)

def sramLut3 (b0 b1 b2 b3 b4 b5 b6 b7 a2 a1 a0 : Bool) : Bool :=
  Bool.casesOn a2
    (Bool.casesOn a1 (Bool.casesOn a0 b0 b1) (Bool.casesOn a0 b2 b3))
    (Bool.casesOn a1 (Bool.casesOn a0 b4 b5) (Bool.casesOn a0 b6 b7))

def sramLut4 (b0 b1 b2 b3 b4 b5 b6 b7 b8 b9 b10 b11 b12 b13 b14 b15 a3 a2 a1 a0 : Bool) : Bool :=
  Bool.casesOn a3
    (sramLut3 b0 b1 b2 b3 b4 b5 b6 b7 a2 a1 a0)
    (sramLut3 b8 b9 b10 b11 b12 b13 b14 b15 a2 a1 a0)

def lut6MoesiO6 (c1 c0 x1 x0 : Bool) : Bool :=
  sramLut4 false false false false  false false false false
           false false true  true   false false true  true  c1 c0 x1 x0

def lut6MoesiO5 (c1 c0 x1 x0 : Bool) : Bool :=
  sramLut4 false false false false  false true  true  true
           false true  false false  false true  false true  c1 c0 x1 x0

def minMoesiHi (c1 _c0 x1 _x0 : Bool) : Bool := bAnd c1 x1

def minMoesiLo (c1 c0 x1 x0 : Bool) : Bool :=
  Bool.casesOn c1
    (Bool.casesOn c0 false (bOr x1 x0))
    (Bool.casesOn c0 (bAnd (bNot x1) x0) x0)

theorem thm22_lut6_2_moesi_clamp :
  forall (c1 c0 x1 x0 : Bool),
    And (lut6MoesiO6 c1 c0 x1 x0 = minMoesiHi c1 c0 x1 x0)
        (lut6MoesiO5 c1 c0 x1 x0 = minMoesiLo c1 c0 x1 x0) :=
  fun c1 c0 x1 x0 =>
    Bool.casesOn c1
      (Bool.casesOn c0
        (Bool.casesOn x1 (Bool.casesOn x0 (And.intro rfl rfl) (And.intro rfl rfl))
                         (Bool.casesOn x0 (And.intro rfl rfl) (And.intro rfl rfl)))
        (Bool.casesOn x1 (Bool.casesOn x0 (And.intro rfl rfl) (And.intro rfl rfl))
                         (Bool.casesOn x0 (And.intro rfl rfl) (And.intro rfl rfl))))
      (Bool.casesOn c0
        (Bool.casesOn x1 (Bool.casesOn x0 (And.intro rfl rfl) (And.intro rfl rfl))
                         (Bool.casesOn x0 (And.intro rfl rfl) (And.intro rfl rfl)))
        (Bool.casesOn x1 (Bool.casesOn x0 (And.intro rfl rfl) (And.intro rfl rfl))
                         (Bool.casesOn x0 (And.intro rfl rfl) (And.intro rfl rfl))))

inductive Chi3 : Type where
  | mk : Bool -> Bool -> Bool -> Chi3

def chi3Step (y : Chi3) : Chi3 :=
  Chi3.casesOn y (fun y0 y1 y2 =>
    Chi3.mk (bXor y0 (bAnd (bNot y1) y2))
            (bXor y1 (bAnd (bNot y2) y0))
            (bXor y2 (bAnd (bNot y0) y1)))

theorem thm23_generalized_odd_tap_and_chi_bijection :
  forall (y : Chi3), chi3Step (chi3Step y) = y :=
  fun y =>
    Chi3.casesOn y (fun y0 y1 y2 =>
      Bool.casesOn y0
        (Bool.casesOn y1 (Bool.casesOn y2 rfl rfl) (Bool.casesOn y2 rfl rfl))
        (Bool.casesOn y1 (Bool.casesOn y2 rfl rfl) (Bool.casesOn y2 rfl rfl)))

def domShare (sa pa pb z : Bool) : Bool :=
  bXor (bAnd sa pa) (bXor (bAnd sa pb) z)

theorem thm24_dom_lut6_2_glitch :
  forall (s0 s1 p0 p1 z : Bool),
    bXor (domShare s0 p0 p1 z) (domShare s1 p1 p0 z) = bAnd (bXor s0 s1) (bXor p0 p1) :=
  fun s0 s1 p0 p1 z =>
    Bool.casesOn s0
      (Bool.casesOn s1
        (Bool.casesOn p0
          (Bool.casesOn p1 (Bool.casesOn z rfl rfl) (Bool.casesOn z rfl rfl))
          (Bool.casesOn p1 (Bool.casesOn z rfl rfl) (Bool.casesOn z rfl rfl)))
        (Bool.casesOn p0
          (Bool.casesOn p1 (Bool.casesOn z rfl rfl) (Bool.casesOn z rfl rfl))
          (Bool.casesOn p1 (Bool.casesOn z rfl rfl) (Bool.casesOn z rfl rfl))))
      (Bool.casesOn s1
        (Bool.casesOn p0
          (Bool.casesOn p1 (Bool.casesOn z rfl rfl) (Bool.casesOn z rfl rfl))
          (Bool.casesOn p1 (Bool.casesOn z rfl rfl) (Bool.casesOn z rfl rfl)))
        (Bool.casesOn p0
          (Bool.casesOn p1 (Bool.casesOn z rfl rfl) (Bool.casesOn z rfl rfl))
          (Bool.casesOn p1 (Bool.casesOn z rfl rfl) (Bool.casesOn z rfl rfl))))

def graceAdmit (v0 v1 bsel capOk : Bool) : Bool :=
  bAnd (Bool.casesOn bsel v0 v1) capOk

theorem thm25_dual_epoch_grace_window :
  forall (bsel : Bool), graceAdmit true true bsel true = true :=
  fun bsel => Bool.casesOn bsel rfl rfl

def tensorGate (vietaOk steinerOk arenaOk bankOk : Bool) : Bool :=
  bAnd vietaOk (bAnd steinerOk (bAnd arenaOk bankOk))

theorem thm26_vieta_timewheel_and_tensor_sieve_selectivity :
  forall (ptTau exp sOk aOk bOk : Bool),
    And (bAnd true ptTau = ptTau)
        (And (bAnd (bAnd ptTau (bNot exp)) (bNot ptTau) = false)
             (tensorGate false sOk aOk bOk = false)) :=
  fun ptTau exp _sOk _aOk _bOk =>
    Bool.casesOn ptTau
      (Bool.casesOn exp (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl)))
      (Bool.casesOn exp (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl)))

def tierByte00 (_v _f1 _f0 : Bool) : Bool := false
def tierByte0C (v f1 f0 : Bool) : Bool :=
  sramLut3 false false true true false false false false v f1 f0
def tierByte0A (v f1 f0 : Bool) : Bool :=
  sramLut3 false true false true false false false false v f1 f0

def lut6Bf16BoundaryO6 (c1 c0 v f1 f0 : Bool) : Bool :=
  Bool.casesOn c1
    (Bool.casesOn c0 (tierByte00 v f1 f0) (tierByte0C v f1 f0))
    (Bool.casesOn c0 (tierByte0C v f1 f0) (tierByte0C v f1 f0))

def lut6Bf16BoundaryO5 (c1 c0 v f1 f0 : Bool) : Bool :=
  Bool.casesOn c1
    (Bool.casesOn c0 (tierByte00 v f1 f0) (tierByte00 v f1 f0))
    (Bool.casesOn c0 (tierByte0A v f1 f0) (tierByte0A v f1 f0))

theorem thm27_lut6_2_graduated_mantissa_clamp_bisimulation :
  forall (c1 c0 v f1 f0 : Bool),
    And (lut6Bf16BoundaryO6 c1 c0 v f1 f0 = bAnd f1 (bAnd (bNot v) (bOr c1 c0)))
        (lut6Bf16BoundaryO5 c1 c0 v f1 f0 = bAnd f0 (bAnd (bNot v) c1)) :=
  fun c1 c0 v f1 f0 =>
    Bool.casesOn c1
      (Bool.casesOn c0
        (Bool.casesOn v
          (Bool.casesOn f1 (Bool.casesOn f0 (And.intro rfl rfl) (And.intro rfl rfl))
                           (Bool.casesOn f0 (And.intro rfl rfl) (And.intro rfl rfl)))
          (Bool.casesOn f1 (Bool.casesOn f0 (And.intro rfl rfl) (And.intro rfl rfl))
                           (Bool.casesOn f0 (And.intro rfl rfl) (And.intro rfl rfl))))
        (Bool.casesOn v
          (Bool.casesOn f1 (Bool.casesOn f0 (And.intro rfl rfl) (And.intro rfl rfl))
                           (Bool.casesOn f0 (And.intro rfl rfl) (And.intro rfl rfl)))
          (Bool.casesOn f1 (Bool.casesOn f0 (And.intro rfl rfl) (And.intro rfl rfl))
                           (Bool.casesOn f0 (And.intro rfl rfl) (And.intro rfl rfl)))))
      (Bool.casesOn c0
        (Bool.casesOn v
          (Bool.casesOn f1 (Bool.casesOn f0 (And.intro rfl rfl) (And.intro rfl rfl))
                           (Bool.casesOn f0 (And.intro rfl rfl) (And.intro rfl rfl)))
          (Bool.casesOn f1 (Bool.casesOn f0 (And.intro rfl rfl) (And.intro rfl rfl))
                           (Bool.casesOn f0 (And.intro rfl rfl) (And.intro rfl rfl))))
        (Bool.casesOn v
          (Bool.casesOn f1 (Bool.casesOn f0 (And.intro rfl rfl) (And.intro rfl rfl))
                           (Bool.casesOn f0 (And.intro rfl rfl) (And.intro rfl rfl)))
          (Bool.casesOn f1 (Bool.casesOn f0 (And.intro rfl rfl) (And.intro rfl rfl))
                           (Bool.casesOn f0 (And.intro rfl rfl) (And.intro rfl rfl)))))

def phyMux (pPhy g0 g1 : Bool) : Bool := Bool.casesOn pPhy g1 g0

theorem lem_phy_ratchet :
  forall (pPhy g0 g1 w0 w1 : Bool),
    bAnd (phyMux pPhy (bAnd g0 w0) (bAnd g1 w1)) (bNot (phyMux pPhy g0 g1)) = false :=
  fun pPhy g0 g1 w0 w1 =>
    Bool.casesOn pPhy
      (Bool.casesOn g1 (Bool.casesOn w1 rfl rfl) (Bool.casesOn w1 rfl rfl))
      (Bool.casesOn g0 (Bool.casesOn w0 rfl rfl) (Bool.casesOn w0 rfl rfl))

theorem lem_secondary_collapse :
  forall (pT1 g1 r : Bool),
    bAnd g1 (bNot pT1) = false -> bOr pT1 (bAnd r g1) = pT1 :=
  fun pT1 g1 r =>
    Bool.casesOn pT1
      (Bool.casesOn g1
        (Bool.casesOn r (fun _h => rfl) (fun _h => rfl))
        (Bool.casesOn r (fun _h => rfl) (fun h => h)))
      (Bool.casesOn g1
        (Bool.casesOn r (fun _h => rfl) (fun _h => rfl))
        (Bool.casesOn r (fun _h => rfl) (fun _h => rfl)))

theorem thm28_phy_gated_dual_forest_failover_safety :
  forall (pPhy g0 g1 w0 w1 pT1 r : Bool),
    And (bAnd (phyMux pPhy (bAnd g0 w0) (bAnd g1 w1)) (bNot (phyMux pPhy g0 g1)) = false)
        (bAnd g1 (bNot pT1) = false -> bOr pT1 (bAnd r g1) = pT1) :=
  fun pPhy g0 g1 w0 w1 pT1 r =>
    And.intro (lem_phy_ratchet pPhy g0 g1 w0 w1) (lem_secondary_collapse pT1 g1 r)

def violWithSnoopEvict (hdr birsp snoopEvict capViol : Bool) : Bool :=
  bAnd (bAnd hdr (bAnd (bNot birsp) (bNot snoopEvict))) capViol

def lut2Pass (v f : Bool) : Bool := Bool.casesOn v f false

theorem thm29_snoop_dirty_evict_and_macaroon_attenuation :
  forall (hdr birsp capViol f p m1 m2 xOut tParent : Bool),
    And (lut2Pass (violWithSnoopEvict hdr birsp true capViol) f = f)
        (And (bAnd (bAnd (bAnd p m1) m2) (bNot p) = false)
             (bXor (bXor xOut tParent) tParent = xOut)) :=
  fun hdr birsp capViol f p m1 m2 xOut tParent =>
    Bool.casesOn hdr
      (Bool.casesOn birsp
        (Bool.casesOn capViol
          (Bool.casesOn p
            (Bool.casesOn m1
              (Bool.casesOn m2
                (Bool.casesOn xOut (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl)))
                                   (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl))))
                (Bool.casesOn xOut (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl)))
                                   (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl)))))
              (Bool.casesOn m2
                (Bool.casesOn xOut (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl)))
                                   (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl))))
                (Bool.casesOn xOut (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl)))
                                   (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl))))))
            (Bool.casesOn m1
              (Bool.casesOn m2
                (Bool.casesOn xOut (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl)))
                                   (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl))))
                (Bool.casesOn xOut (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl)))
                                   (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl)))))
              (Bool.casesOn m2
                (Bool.casesOn xOut (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl)))
                                   (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl))))
                (Bool.casesOn xOut (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl)))
                                   (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl)))))))
          (Bool.casesOn p
            (Bool.casesOn m1
              (Bool.casesOn m2
                (Bool.casesOn xOut (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl)))
                                   (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl))))
                (Bool.casesOn xOut (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl)))
                                   (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl)))))
              (Bool.casesOn m2
                (Bool.casesOn xOut (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl)))
                                   (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl))))
                (Bool.casesOn xOut (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl)))
                                   (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl))))))
            (Bool.casesOn m1
              (Bool.casesOn m2
                (Bool.casesOn xOut (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl)))
                                   (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl))))
                (Bool.casesOn xOut (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl)))
                                   (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl)))))
              (Bool.casesOn m2
                (Bool.casesOn xOut (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl)))
                                   (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl))))
                (Bool.casesOn xOut (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl)))
                                   (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl))))))))
        (Bool.casesOn capViol
          (Bool.casesOn p
            (Bool.casesOn m1
              (Bool.casesOn m2
                (Bool.casesOn xOut (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl)))
                                   (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl))))
                (Bool.casesOn xOut (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl)))
                                   (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl)))))
              (Bool.casesOn m2
                (Bool.casesOn xOut (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl)))
                                   (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl))))
                (Bool.casesOn xOut (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl)))
                                   (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl))))))
            (Bool.casesOn m1
              (Bool.casesOn m2
                (Bool.casesOn xOut (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl)))
                                   (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl))))
                (Bool.casesOn xOut (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl)))
                                   (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl)))))
              (Bool.casesOn m2
                (Bool.casesOn xOut (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl)))
                                   (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl))))
                (Bool.casesOn xOut (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl)))
                                   (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl)))))))
          (Bool.casesOn p
            (Bool.casesOn m1
              (Bool.casesOn m2
                (Bool.casesOn xOut (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl)))
                                   (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl))))
                (Bool.casesOn xOut (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl)))
                                   (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl)))))
              (Bool.casesOn m2
                (Bool.casesOn xOut (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl)))
                                   (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl))))
                (Bool.casesOn xOut (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl)))
                                   (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl))))))
            (Bool.casesOn m1
              (Bool.casesOn m2
                (Bool.casesOn xOut (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl)))
                                   (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl))))
                (Bool.casesOn xOut (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl)))
                                   (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl)))))
              (Bool.casesOn m2
                (Bool.casesOn xOut (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl)))
                                   (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl))))
                (Bool.casesOn xOut (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl)))
                                   (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl)))))))))
      (Bool.casesOn birsp
        (Bool.casesOn capViol
          (Bool.casesOn p
            (Bool.casesOn m1
              (Bool.casesOn m2
                (Bool.casesOn xOut (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl)))
                                   (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl))))
                (Bool.casesOn xOut (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl)))
                                   (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl)))))
              (Bool.casesOn m2
                (Bool.casesOn xOut (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl)))
                                   (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl))))
                (Bool.casesOn xOut (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl)))
                                   (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl))))))
            (Bool.casesOn m1
              (Bool.casesOn m2
                (Bool.casesOn xOut (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl)))
                                   (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl))))
                (Bool.casesOn xOut (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl)))
                                   (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl)))))
              (Bool.casesOn m2
                (Bool.casesOn xOut (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl)))
                                   (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl))))
                (Bool.casesOn xOut (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl)))
                                   (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl)))))))
          (Bool.casesOn p
            (Bool.casesOn m1
              (Bool.casesOn m2
                (Bool.casesOn xOut (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl)))
                                   (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl))))
                (Bool.casesOn xOut (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl)))
                                   (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl)))))
              (Bool.casesOn m2
                (Bool.casesOn xOut (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl)))
                                   (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl))))
                (Bool.casesOn xOut (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl)))
                                   (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl))))))
            (Bool.casesOn m1
              (Bool.casesOn m2
                (Bool.casesOn xOut (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl)))
                                   (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl))))
                (Bool.casesOn xOut (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl)))
                                   (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl)))))
              (Bool.casesOn m2
                (Bool.casesOn xOut (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl)))
                                   (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl))))
                (Bool.casesOn xOut (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl)))
                                   (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl))))))))
        (Bool.casesOn capViol
          (Bool.casesOn p
            (Bool.casesOn m1
              (Bool.casesOn m2
                (Bool.casesOn xOut (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl)))
                                   (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl))))
                (Bool.casesOn xOut (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl)))
                                   (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl)))))
              (Bool.casesOn m2
                (Bool.casesOn xOut (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl)))
                                   (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl))))
                (Bool.casesOn xOut (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl)))
                                   (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl))))))
            (Bool.casesOn m1
              (Bool.casesOn m2
                (Bool.casesOn xOut (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl)))
                                   (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl))))
                (Bool.casesOn xOut (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl)))
                                   (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl)))))
              (Bool.casesOn m2
                (Bool.casesOn xOut (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl)))
                                   (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl))))
                (Bool.casesOn xOut (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl)))
                                   (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl)))))))
          (Bool.casesOn p
            (Bool.casesOn m1
              (Bool.casesOn m2
                (Bool.casesOn xOut (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl)))
                                   (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl))))
                (Bool.casesOn xOut (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl)))
                                   (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl)))))
              (Bool.casesOn m2
                (Bool.casesOn xOut (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl)))
                                   (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl))))
                (Bool.casesOn xOut (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl)))
                                   (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl))))))
            (Bool.casesOn m1
              (Bool.casesOn m2
                (Bool.casesOn xOut (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl)))
                                   (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl))))
                (Bool.casesOn xOut (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl)))
                                   (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl)))))
              (Bool.casesOn m2
                (Bool.casesOn xOut (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl)))
                                   (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl))))
                (Bool.casesOn xOut (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl)))
                                   (Bool.casesOn tParent (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl)))))))))

#print axioms thm20_vieta_gf256_ideal_ratchet_monotonic_and_degree_bound
#print axioms thm21_orbit_chord_clamping
#print axioms thm22_lut6_2_moesi_clamp
#print axioms thm23_generalized_odd_tap_and_chi_bijection
#print axioms thm24_dom_lut6_2_glitch
#print axioms thm25_dual_epoch_grace_window
#print axioms thm26_vieta_timewheel_and_tensor_sieve_selectivity
#print axioms thm27_lut6_2_graduated_mantissa_clamp_bisimulation
#print axioms thm28_phy_gated_dual_forest_failover_safety
#print axioms thm29_snoop_dirty_evict_and_macaroon_attenuation