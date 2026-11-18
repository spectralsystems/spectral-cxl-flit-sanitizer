-- File: formal_lean4/CxlSubflitSanitizerV110Expansion.lean
-- Spectral Systems LLC (CAGE: 268E1 | UEI: VTP2JPCJU3D9)
-- Part II (v1.1.0) Pure Init.Prelude Term-Mode Expansion: thm30..thm37 (0 sorry, 0 axioms)
-- Baseline helpers below match CxlSubflitSanitizerFormal.lean & CxlSubflitSanitizerExtensions.lean verbatim.
set_option linter.unusedVariables false

def bNot (a : Bool) : Bool := Bool.casesOn a true false
def bAnd (a b : Bool) : Bool := Bool.casesOn a false b
def bOr  (a b : Bool) : Bool := Bool.casesOn a b true
def bXor (a b : Bool) : Bool := Bool.casesOn a b (bNot b)
abbrev Word64 := Nat -> Bool

def lut6O5_80 (pt ps s : Bool) : Bool := Bool.casesOn pt false (Bool.casesOn ps false s)
def lut6O6_2A (pt ps s : Bool) : Bool := Bool.casesOn pt s (Bool.casesOn ps s false)
def dualRailFault (okRail violRail : Bool) : Bool := bNot (bXor okRail violRail)

def sramLut3 (b0 b1 b2 b3 b4 b5 b6 b7 a2 a1 a0 : Bool) : Bool :=
  Bool.casesOn a2
    (Bool.casesOn a1 (Bool.casesOn a0 b0 b1) (Bool.casesOn a0 b2 b3))
    (Bool.casesOn a1 (Bool.casesOn a0 b4 b5) (Bool.casesOn a0 b6 b7))

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
    let x0 := a; let x1 := gf256Xtime x0; let x2 := gf256Xtime x1; let x3 := gf256Xtime x2
    let x4 := gf256Xtime x3; let x5 := gf256Xtime x4; let x6 := gf256Xtime x5; let x7 := gf256Xtime x6
    b8Xor (b8Xor (b8Xor (b8Mask b0 x0) (b8Mask b1 x1)) (b8Xor (b8Mask b2 x2) (b8Mask b3 x3)))
          (b8Xor (b8Xor (b8Mask b4 x4) (b8Mask b5 x5)) (b8Xor (b8Mask b6 x6) (b8Mask b7 x7))))

-- === Part II (v1.1.0) Foundational Algebraic & Arithmetic Lemmas (Pure Init.Prelude) ===

theorem lem_false_imp (P : Prop) (h : false = true) : P :=
  @Eq.rec Bool false (fun b _ => Bool.casesOn b True P) True.intro true h

theorem lem_bxor_cancel : forall (u v : Bool), bXor (bXor u v) v = u :=
  fun u v => Bool.casesOn u (Bool.casesOn v rfl rfl) (Bool.casesOn v rfl rfl)

theorem lem_bxor_false_right : forall (u : Bool), bXor u false = u :=
  fun u => Bool.casesOn u rfl rfl

theorem lem_bxor_self : forall (u : Bool), bXor u u = false :=
  fun u => Bool.casesOn u rfl rfl

theorem lem_bxor_assoc : forall (u v w : Bool), bXor (bXor u v) w = bXor u (bXor v w) :=
  fun u v w =>
    Bool.casesOn u
      (Bool.casesOn v (Bool.casesOn w rfl rfl) (Bool.casesOn w rfl rfl))
      (Bool.casesOn v (Bool.casesOn w rfl rfl) (Bool.casesOn w rfl rfl))

theorem lem_bxor_four : forall (p q r s : Bool), bXor (bXor p q) (bXor r s) = bXor (bXor p r) (bXor q s) :=
  fun p q r s =>
    Bool.casesOn p
      (Bool.casesOn q
        (Bool.casesOn r (Bool.casesOn s rfl rfl) (Bool.casesOn s rfl rfl))
        (Bool.casesOn r (Bool.casesOn s rfl rfl) (Bool.casesOn s rfl rfl)))
      (Bool.casesOn q
        (Bool.casesOn r (Bool.casesOn s rfl rfl) (Bool.casesOn s rfl rfl))
        (Bool.casesOn r (Bool.casesOn s rfl rfl) (Bool.casesOn s rfl rfl)))

theorem b8Cong {x7 y7 x6 y6 x5 y5 x4 y4 x3 y3 x2 y2 x1 y1 x0 y0 : Bool}
  (h7 : x7 = y7) (h6 : x6 = y6) (h5 : x5 = y5) (h4 : x4 = y4)
  (h3 : x3 = y3) (h2 : x2 = y2) (h1 : x1 = y1) (h0 : x0 = y0) :
  B8.mk x7 x6 x5 x4 x3 x2 x1 x0 = B8.mk y7 y6 y5 y4 y3 y2 y1 y0 :=
  congr (congr (congr (congr (congr (congr (congr (congrArg B8.mk h7) h6) h5) h4) h3) h2) h1) h0

theorem b8Xor2 {u1 u2 v1 v2 : B8} (hu : u1 = u2) (hv : v1 = v2) : b8Xor u1 v1 = b8Xor u2 v2 :=
  congr (congrArg b8Xor hu) hv

theorem lem_b8xor_cancel : forall (a m : B8), b8Xor (b8Xor a m) m = a :=
  fun a m =>
    B8.casesOn a (fun a7 a6 a5 a4 a3 a2 a1 a0 =>
      B8.casesOn m (fun m7 m6 m5 m4 m3 m2 m1 m0 =>
        b8Cong (lem_bxor_cancel a7 m7) (lem_bxor_cancel a6 m6)
               (lem_bxor_cancel a5 m5) (lem_bxor_cancel a4 m4)
               (lem_bxor_cancel a3 m3) (lem_bxor_cancel a2 m2)
               (lem_bxor_cancel a1 m1) (lem_bxor_cancel a0 m0)))

theorem lem_b8xor_zero_left : forall (a : B8), b8Xor b8Zero a = a :=
  fun a => B8.casesOn a (fun _ _ _ _ _ _ _ _ => rfl)

theorem lem_b8xor_zero_right : forall (a : B8), b8Xor a b8Zero = a :=
  fun a =>
    B8.casesOn a (fun a7 a6 a5 a4 a3 a2 a1 a0 =>
      b8Cong (lem_bxor_false_right a7) (lem_bxor_false_right a6)
             (lem_bxor_false_right a5) (lem_bxor_false_right a4)
             (lem_bxor_false_right a3) (lem_bxor_false_right a2)
             (lem_bxor_false_right a1) (lem_bxor_false_right a0))

theorem lem_b8xor_self : forall (a : B8), b8Xor a a = b8Zero :=
  fun a =>
    B8.casesOn a (fun a7 a6 a5 a4 a3 a2 a1 a0 =>
      b8Cong (lem_bxor_self a7) (lem_bxor_self a6) (lem_bxor_self a5) (lem_bxor_self a4)
             (lem_bxor_self a3) (lem_bxor_self a2) (lem_bxor_self a1) (lem_bxor_self a0))

theorem lem_b8xor_assoc : forall (a b c : B8), b8Xor (b8Xor a b) c = b8Xor a (b8Xor b c) :=
  fun a b c =>
    B8.casesOn a (fun a7 a6 a5 a4 a3 a2 a1 a0 =>
      B8.casesOn b (fun b7 b6 b5 b4 b3 b2 b1 b0 =>
        B8.casesOn c (fun c7 c6 c5 c4 c3 c2 c1 c0 =>
          b8Cong (lem_bxor_assoc a7 b7 c7) (lem_bxor_assoc a6 b6 c6)
                 (lem_bxor_assoc a5 b5 c5) (lem_bxor_assoc a4 b4 c4)
                 (lem_bxor_assoc a3 b3 c3) (lem_bxor_assoc a2 b2 c2)
                 (lem_bxor_assoc a1 b1 c1) (lem_bxor_assoc a0 b0 c0))))

theorem lem_b8xor_four : forall (p q r s : B8), b8Xor (b8Xor p q) (b8Xor r s) = b8Xor (b8Xor p r) (b8Xor q s) :=
  fun p q r s =>
    B8.casesOn p (fun p7 p6 p5 p4 p3 p2 p1 p0 =>
      B8.casesOn q (fun q7 q6 q5 q4 q3 q2 q1 q0 =>
        B8.casesOn r (fun r7 r6 r5 r4 r3 r2 r1 r0 =>
          B8.casesOn s (fun s7 s6 s5 s4 s3 s2 s1 s0 =>
            b8Cong (lem_bxor_four p7 q7 r7 s7) (lem_bxor_four p6 q6 r6 s6)
                   (lem_bxor_four p5 q5 r5 s5) (lem_bxor_four p4 q4 r4 s4)
                   (lem_bxor_four p3 q3 r3 s3) (lem_bxor_four p2 q2 r2 s2)
                   (lem_bxor_four p1 q1 r1 s1) (lem_bxor_four p0 q0 r0 s0)))))

-- === thm30: 6-Round Feistel Bijection over B8xB8 & Mode-C Snoop-Evict Closure ===

inductive PairB8 : Type where
  | mk : B8 -> B8 -> PairB8

def feistelEncRound (f : B8 -> B8) (p : PairB8) : PairB8 :=
  PairB8.casesOn p (fun l r => PairB8.mk r (b8Xor l (f r)))

def feistelDecRound (f : B8 -> B8) (p : PairB8) : PairB8 :=
  PairB8.casesOn p (fun l r => PairB8.mk (b8Xor r (f l)) l)

theorem lem_feistel_dec_enc (f : B8 -> B8) (p : PairB8) : feistelDecRound f (feistelEncRound f p) = p :=
  PairB8.casesOn p (fun l r => congrArg (fun z => PairB8.mk z r) (lem_b8xor_cancel l (f r)))

theorem lem_feistel_enc_dec (f : B8 -> B8) (p : PairB8) : feistelEncRound f (feistelDecRound f p) = p :=
  PairB8.casesOn p (fun l r => congrArg (PairB8.mk l) (lem_b8xor_cancel r (f l)))

def feistelEnc6 (f0 f1 f2 f3 f4 f5 : B8 -> B8) (p : PairB8) : PairB8 :=
  feistelEncRound f5 (feistelEncRound f4 (feistelEncRound f3 (feistelEncRound f2 (feistelEncRound f1 (feistelEncRound f0 p)))))

def feistelDec6 (f0 f1 f2 f3 f4 f5 : B8 -> B8) (p : PairB8) : PairB8 :=
  feistelDecRound f0 (feistelDecRound f1 (feistelDecRound f2 (feistelDecRound f3 (feistelDecRound f4 (feistelDecRound f5 p)))))

theorem lem_peel {A : Type} (d : A -> A) {u v w : A} (hInner : u = v) (hOuter : d v = w) : d u = w :=
  Eq.trans (congrArg d hInner) hOuter

theorem lem_feistel_dec6_enc6 (f0 f1 f2 f3 f4 f5 : B8 -> B8) (x : PairB8) :
  feistelDec6 f0 f1 f2 f3 f4 f5 (feistelEnc6 f0 f1 f2 f3 f4 f5 x) = x :=
  let x1 := feistelEncRound f0 x
  let x2 := feistelEncRound f1 x1
  let x3 := feistelEncRound f2 x2
  let x4 := feistelEncRound f3 x3
  let x5 := feistelEncRound f4 x4
  let p5 := lem_feistel_dec_enc f5 x5
  let p4 := lem_peel (feistelDecRound f4) p5 (lem_feistel_dec_enc f4 x4)
  let p3 := lem_peel (feistelDecRound f3) p4 (lem_feistel_dec_enc f3 x3)
  let p2 := lem_peel (feistelDecRound f2) p3 (lem_feistel_dec_enc f2 x2)
  let p1 := lem_peel (feistelDecRound f1) p2 (lem_feistel_dec_enc f1 x1)
  lem_peel (feistelDecRound f0) p1 (lem_feistel_dec_enc f0 x)

theorem lem_feistel_enc6_dec6 (f0 f1 f2 f3 f4 f5 : B8 -> B8) (y : PairB8) :
  feistelEnc6 f0 f1 f2 f3 f4 f5 (feistelDec6 f0 f1 f2 f3 f4 f5 y) = y :=
  let y1 := feistelDecRound f5 y
  let y2 := feistelDecRound f4 y1
  let y3 := feistelDecRound f3 y2
  let y4 := feistelDecRound f2 y3
  let y5 := feistelDecRound f1 y4
  let q0 := lem_feistel_enc_dec f0 y5
  let q1 := lem_peel (feistelEncRound f1) q0 (lem_feistel_enc_dec f1 y4)
  let q2 := lem_peel (feistelEncRound f2) q1 (lem_feistel_enc_dec f2 y3)
  let q3 := lem_peel (feistelEncRound f3) q2 (lem_feistel_enc_dec f3 y2)
  let q4 := lem_peel (feistelEncRound f4) q3 (lem_feistel_enc_dec f4 y1)
  lem_peel (feistelEncRound f5) q4 (lem_feistel_enc_dec f5 y)

def stripUpperB8 (p : PairB8) : PairB8 := PairB8.casesOn p (fun _ uPage => PairB8.mk b8Zero uPage)

def snoopEvictRestore (f0 f1 f2 f3 f4 f5 : B8 -> B8) (guardOk : Bool) (alpha uPage : B8) : PairB8 :=
  Bool.casesOn guardOk (PairB8.mk b8Zero b8Zero)
    (stripUpperB8 (feistelDec6 f0 f1 f2 f3 f4 f5 (feistelEnc6 f0 f1 f2 f3 f4 f5 (PairB8.mk alpha uPage))))

theorem thm30_bijective_snoop_evict_commutative_closure :
  forall (f0 f1 f2 f3 f4 f5 : B8 -> B8) (x y : PairB8) (alpha uPage : B8),
    And (feistelDec6 f0 f1 f2 f3 f4 f5 (feistelEnc6 f0 f1 f2 f3 f4 f5 x) = x)
        (And (feistelEnc6 f0 f1 f2 f3 f4 f5 (feistelDec6 f0 f1 f2 f3 f4 f5 y) = y)
             (And (snoopEvictRestore f0 f1 f2 f3 f4 f5 true alpha uPage = PairB8.mk b8Zero uPage)
                  (snoopEvictRestore f0 f1 f2 f3 f4 f5 false alpha uPage = PairB8.mk b8Zero b8Zero))) :=
  fun f0 f1 f2 f3 f4 f5 x y alpha uPage =>
    And.intro (lem_feistel_dec6_enc6 f0 f1 f2 f3 f4 f5 x)
      (And.intro (lem_feistel_enc6_dec6 f0 f1 f2 f3 f4 f5 y)
        (And.intro (congrArg stripUpperB8 (lem_feistel_dec6_enc6 f0 f1 f2 f3 f4 f5 (PairB8.mk alpha uPage))) rfl))

-- === thm31: Unclamped Window-Paced Vieta Degree (<= 8), Shadow Compaction, & 32-Slot FIFO Invariant ===

def natBle : Nat -> Nat -> Bool :=
  @Nat.rec (fun _ => Nat -> Bool)
    (fun _ => true)
    (fun _ ih b => @Nat.rec (fun _ => Bool) false (fun bPred _ => ih bPred) b)

theorem lem_band_true_left : forall (x y : Bool), bAnd x y = true -> x = true :=
  fun x y => Bool.casesOn x (fun h => lem_false_imp (false = true) h) (fun _ => rfl)

theorem lem_band_true_right : forall (x y : Bool), bAnd x y = true -> y = true :=
  fun x y => Bool.casesOn x (fun h => lem_false_imp (y = true) h) (fun h => h)

theorem lem_band_intro : forall (x y : Bool), x = true -> y = true -> bAnd x y = true :=
  fun x y hx hy => Eq.trans (congrArg (fun u => bAnd u y) hx) hy

theorem lem_bor_elim {P : Prop} (x y : Bool) (hOr : bOr x y = true)
  (hx : x = true -> P) (hy : y = true -> P) : P :=
  ((fun (b : Bool) =>
    Bool.casesOn b
      (fun (_ : x = false) (h1 : y = true) => hy h1)
      (fun (hTrue : x = true) (_ : true = true) => hx hTrue))
    : forall (b : Bool), x = b -> bOr b y = true -> P)
  x rfl hOr

theorem lem_ble0_eq_zero (k : Nat) (h0 : natBle k 0 = true) : k = 0 :=
  (@Nat.rec (fun n => natBle n 0 = true -> n = 0)
    (fun _ => rfl)
    (fun m _ (hm : false = true) => lem_false_imp (Nat.succ m = 0) hm)
    k) h0

theorem lem_ble6_add_const (d : Nat) (hBase : natBle d 6 = true) :
  And (natBle d 8 = true) (And (natBle (Nat.succ d) 8 = true) (natBle (Nat.succ (Nat.succ d)) 8 = true)) :=
  (@Nat.rec (fun x => natBle x 6 = true ->
      And (natBle x 8 = true) (And (natBle (Nat.succ x) 8 = true) (natBle (Nat.succ (Nat.succ x)) 8 = true)))
    (fun _ => And.intro rfl (And.intro rfl rfl))
    (fun x1 _ =>
      @Nat.rec (fun y1 => natBle (Nat.succ y1) 6 = true ->
          And (natBle (Nat.succ y1) 8 = true)
              (And (natBle (Nat.succ (Nat.succ y1)) 8 = true) (natBle (Nat.succ (Nat.succ (Nat.succ y1))) 8 = true)))
        (fun _ => And.intro rfl (And.intro rfl rfl))
        (fun x2 _ =>
          @Nat.rec (fun y2 => natBle (Nat.succ (Nat.succ y2)) 6 = true ->
              And (natBle (Nat.succ (Nat.succ y2)) 8 = true)
                  (And (natBle (Nat.succ (Nat.succ (Nat.succ y2))) 8 = true)
                       (natBle (Nat.succ (Nat.succ (Nat.succ (Nat.succ y2)))) 8 = true)))
            (fun _ => And.intro rfl (And.intro rfl rfl))
            (fun x3 _ =>
              @Nat.rec (fun y3 => natBle (Nat.succ (Nat.succ (Nat.succ y3))) 6 = true ->
                  And (natBle (Nat.succ (Nat.succ (Nat.succ y3))) 8 = true)
                      (And (natBle (Nat.succ (Nat.succ (Nat.succ (Nat.succ y3)))) 8 = true)
                           (natBle (Nat.succ (Nat.succ (Nat.succ (Nat.succ (Nat.succ y3))))) 8 = true)))
                (fun _ => And.intro rfl (And.intro rfl rfl))
                (fun x4 _ =>
                  @Nat.rec (fun y4 => natBle (Nat.succ (Nat.succ (Nat.succ (Nat.succ y4)))) 6 = true ->
                      And (natBle (Nat.succ (Nat.succ (Nat.succ (Nat.succ y4)))) 8 = true)
                          (And (natBle (Nat.succ (Nat.succ (Nat.succ (Nat.succ (Nat.succ y4))))) 8 = true)
                               (natBle (Nat.succ (Nat.succ (Nat.succ (Nat.succ (Nat.succ (Nat.succ y4)))))) 8 = true)))
                    (fun _ => And.intro rfl (And.intro rfl rfl))
                    (fun x5 _ =>
                      @Nat.rec (fun y5 => natBle (Nat.succ (Nat.succ (Nat.succ (Nat.succ (Nat.succ y5))))) 6 = true ->
                          And (natBle (Nat.succ (Nat.succ (Nat.succ (Nat.succ (Nat.succ y5))))) 8 = true)
                              (And (natBle (Nat.succ (Nat.succ (Nat.succ (Nat.succ (Nat.succ (Nat.succ y5)))))) 8 = true)
                                   (natBle (Nat.succ (Nat.succ (Nat.succ (Nat.succ (Nat.succ (Nat.succ (Nat.succ y5))))))) 8 = true)))
                        (fun _ => And.intro rfl (And.intro rfl rfl))
                        (fun x6 _ =>
                          @Nat.rec (fun y6 => natBle (Nat.succ (Nat.succ (Nat.succ (Nat.succ (Nat.succ (Nat.succ y6)))))) 6 = true ->
                              And (natBle (Nat.succ (Nat.succ (Nat.succ (Nat.succ (Nat.succ (Nat.succ y6)))))) 8 = true)
                                  (And (natBle (Nat.succ (Nat.succ (Nat.succ (Nat.succ (Nat.succ (Nat.succ (Nat.succ y6))))))) 8 = true)
                                       (natBle (Nat.succ (Nat.succ (Nat.succ (Nat.succ (Nat.succ (Nat.succ (Nat.succ (Nat.succ y6)))))))) 8 = true)))
                            (fun _ => And.intro rfl (And.intro rfl rfl))
                            (fun x7 _ h7 => lem_false_imp _ h7)
                            x6)
                        x5)
                    x4)
                x3)
            x2)
        x1)
    d) hBase

theorem lem_ble6_ble2_sum_ble8 :
  forall (baseDeg drainArr : Nat),
    natBle baseDeg 6 = true -> natBle drainArr 2 = true -> natBle (baseDeg + drainArr) 8 = true :=
  fun baseDeg drainArr hBase =>
    @Nat.rec (fun k => natBle k 2 = true -> natBle (baseDeg + k) 8 = true)
      (fun _ => And.left (lem_ble6_add_const baseDeg hBase))
      (fun k1 _ =>
        @Nat.rec (fun m1 => natBle (Nat.succ m1) 2 = true -> natBle (baseDeg + Nat.succ m1) 8 = true)
          (fun _ => And.left (And.right (lem_ble6_add_const baseDeg hBase)))
          (fun k2 _ =>
            @Nat.rec (fun m2 => natBle (Nat.succ (Nat.succ m2)) 2 = true -> natBle (baseDeg + Nat.succ (Nat.succ m2)) 8 = true)
              (fun _ => And.right (And.right (lem_ble6_add_const baseDeg hBase)))
              (fun k3 _ h3 => lem_false_imp _ h3)
              k2)
          k1)
      drainArr

inductive AirlockState : Type where
  | mk : Nat -> Nat -> Nat -> AirlockState

inductive AirlockEvent : Type where
  | mk : Bool -> Nat -> Nat -> Nat -> AirlockEvent

def actDegOf (s : AirlockState) : Nat := AirlockState.casesOn s (fun a _ _ => a)

def airlockInv (s : AirlockState) : Bool :=
  AirlockState.casesOn s (fun actDeg shadDeg fifoCnt =>
    bAnd (natBle actDeg 8) (bAnd (natBle shadDeg 6) (natBle fifoCnt 32)))

def airlockStepRaw (s : AirlockState) (ev : AirlockEvent) : AirlockState :=
  AirlockState.casesOn s (fun actDeg shadDeg _fifoCnt =>
    AirlockEvent.casesOn ev (fun doSwap drainArr nextShad nextFifo =>
      Bool.casesOn doSwap
        (AirlockState.mk (actDeg + drainArr) nextShad nextFifo)
        (AirlockState.mk shadDeg 0 0)))

def airlockStepAdm (s : AirlockState) (ev : AirlockEvent) : Bool :=
  AirlockState.casesOn s (fun actDeg _shadDeg _fifoCnt =>
    AirlockEvent.casesOn ev (fun doSwap drainArr nextShad nextFifo =>
      Bool.casesOn doSwap
        (bAnd (bOr (natBle drainArr 0) (bAnd (natBle actDeg 6) (natBle drainArr 2)))
              (bAnd (natBle nextShad 6) (natBle nextFifo 32)))
        true))

theorem lem_airlockStepRaw_inv :
  forall (s : AirlockState) (ev : AirlockEvent),
    airlockInv s = true -> airlockStepAdm s ev = true -> airlockInv (airlockStepRaw s ev) = true :=
  fun s ev =>
    AirlockState.casesOn s (fun actDeg shadDeg fifoCnt hI =>
      let hA8 := lem_band_true_left (natBle actDeg 8) _ hI
      let hRest := lem_band_true_right (natBle actDeg 8) _ hI
      let hS6 := lem_band_true_left (natBle shadDeg 6) (natBle fifoCnt 32) hRest
      AirlockEvent.casesOn ev (fun doSwap drainArr nextShad nextFifo =>
        Bool.casesOn doSwap
          (fun hAd =>
            let hOr := lem_band_true_left _ _ hAd
            let hBounds := lem_band_true_right _ _ hAd
            let hSum8 : natBle (actDeg + drainArr) 8 = true :=
              lem_bor_elim (natBle drainArr 0) (bAnd (natBle actDeg 6) (natBle drainArr 2)) hOr
                (fun hZero =>
                  Eq.trans (congrArg (fun z => natBle (actDeg + z) 8) (lem_ble0_eq_zero drainArr hZero)) hA8)
                (fun hPaced =>
                  lem_ble6_ble2_sum_ble8 actDeg drainArr
                    (lem_band_true_left (natBle actDeg 6) (natBle drainArr 2) hPaced)
                    (lem_band_true_right (natBle actDeg 6) (natBle drainArr 2) hPaced))
            lem_band_intro _ _ hSum8 hBounds)
          (fun _ =>
            lem_band_intro (natBle shadDeg 8) true
              (And.left (lem_ble6_add_const shadDeg hS6)) rfl)))

def runAirlockRaw (t : Nat) (s0 : AirlockState) (sched : Nat -> AirlockEvent) : AirlockState :=
  @Nat.rec (fun _ => AirlockState) s0 (fun k prev => airlockStepRaw prev (sched k)) t

def runAirlockAdm (t : Nat) (s0 : AirlockState) (sched : Nat -> AirlockEvent) : Bool :=
  @Nat.rec (fun _ => Bool) true
    (fun k prevOk => bAnd prevOk (airlockStepAdm (runAirlockRaw k s0 sched) (sched k))) t

theorem thm31_unbounded_horizon_ic3_and_dual_bank_compaction :
  forall (t : Nat) (sched : Nat -> AirlockEvent) (baseDeg drainArr : Nat),
    And (runAirlockAdm t (AirlockState.mk 0 0 0) sched = true ->
          And (airlockInv (runAirlockRaw t (AirlockState.mk 0 0 0) sched) = true)
              (natBle (actDegOf (runAirlockRaw t (AirlockState.mk 0 0 0) sched)) 8 = true))
        (natBle baseDeg 6 = true -> natBle drainArr 2 = true -> natBle (baseDeg + drainArr) 8 = true) :=
  fun t sched baseDeg drainArr =>
    let s0 := AirlockState.mk 0 0 0
    let hInd : runAirlockAdm t s0 sched = true -> airlockInv (runAirlockRaw t s0 sched) = true :=
      @Nat.rec (fun n => runAirlockAdm n s0 sched = true -> airlockInv (runAirlockRaw n s0 sched) = true)
        (fun _ => rfl)
        (fun k ih hAdmSucc =>
          let hPrev := lem_band_true_left (runAirlockAdm k s0 sched) _ hAdmSucc
          let hStep := lem_band_true_right (runAirlockAdm k s0 sched) _ hAdmSucc
          lem_airlockStepRaw_inv (runAirlockRaw k s0 sched) (sched k) (ih hPrev) hStep)
        t
    And.intro
      (fun hAdm =>
        let hInv := hInd hAdm
        let hDeg := AirlockState.casesOn (runAirlockRaw t s0 sched)
                      (fun a sh fi hI => lem_band_true_left (natBle a 8) (bAnd (natBle sh 6) (natBle fi 32)) hI) hInv
        And.intro hInv hDeg)
      (lem_ble6_ble2_sum_ble8 baseDeg drainArr)

-- === thm32: CSS Split-Coset Folded Syndrome Exactness & Graph Betti Cycle-Rank Induction ===

abbrev CodewordB8 := Nat -> B8
def xorVecB8 (u v : CodewordB8) : CodewordB8 := fun i => b8Xor (u i) (v i)

theorem lem_succ_add : forall (a b : Nat), Nat.succ a + b = Nat.succ (a + b) :=
  fun a b => @Nat.rec (fun k => Nat.succ a + k = Nat.succ (a + k)) rfl (fun _ ih => congrArg Nat.succ ih) b

inductive GraphBuild : Type where
  | empty        : GraphBuild
  | addVertex    : GraphBuild -> GraphBuild
  | addTreeEdge  : GraphBuild -> GraphBuild
  | addChordEdge : GraphBuild -> GraphBuild

noncomputable def gEdges  : GraphBuild -> Nat := @GraphBuild.rec (fun _ => Nat) 0 (fun _ e => e) (fun _ e => Nat.succ e) (fun _ e => Nat.succ e)
noncomputable def gComps  : GraphBuild -> Nat := @GraphBuild.rec (fun _ => Nat) 0 (fun _ c => Nat.succ c) (fun _ c => c) (fun _ c => c)
noncomputable def gVerts  : GraphBuild -> Nat := @GraphBuild.rec (fun _ => Nat) 0 (fun _ v => Nat.succ v) (fun _ v => Nat.succ v) (fun _ v => v)
noncomputable def gBetti1 : GraphBuild -> Nat := @GraphBuild.rec (fun _ => Nat) 0 (fun _ b => b) (fun _ b => b) (fun _ b => Nat.succ b)

theorem lem_graph_euler_betti : forall (g : GraphBuild), gEdges g + gComps g = gVerts g + gBetti1 g :=
  fun g =>
    @GraphBuild.rec (fun x => gEdges x + gComps x = gVerts x + gBetti1 x)
      rfl
      (fun x ih => Eq.trans (congrArg Nat.succ ih) (Eq.symm (lem_succ_add (gVerts x) (gBetti1 x))))
      (fun x ih =>
        Eq.trans (lem_succ_add (gEdges x) (gComps x))
          (Eq.trans (congrArg Nat.succ ih) (Eq.symm (lem_succ_add (gVerts x) (gBetti1 x)))))
      (fun x ih => Eq.trans (lem_succ_add (gEdges x) (gComps x)) (congrArg Nat.succ ih))
      g

theorem thm32_spanning_forest_cycle_rank_and_cochain_exactness :
  forall (g : GraphBuild) (synH : CodewordB8 -> B8) (m c : CodewordB8) (tau0 tau1 : B8),
    (forall u v : CodewordB8, synH (xorVecB8 u v) = b8Xor (synH u) (synH v)) ->
    synH c = b8Zero ->
    And (gEdges g + gComps g = gVerts g + gBetti1 g)
        (And (synH (xorVecB8 m c) = synH m)
             (b8Xor (b8Xor tau0 tau0) tau1 = tau1)) :=
  fun g synH m c tau0 tau1 hLin hKer =>
    And.intro (lem_graph_euler_betti g)
      (And.intro
        (Eq.trans (hLin m c) (Eq.trans (congrArg (b8Xor (synH m)) hKer) (lem_b8xor_zero_right (synH m))))
        (Eq.trans (congrArg (fun z => b8Xor z tau1) (lem_b8xor_self tau0)) (lem_b8xor_zero_left tau1)))

-- === thm33: Non-Abelian GF(2^8) [0x11B] Affine Hop Composition & Epoch Query-Budget Ratchet ===

theorem lem_b8xor8_merge (a0 a1 a2 a3 a4 a5 a6 a7 b0 b1 b2 b3 b4 b5 b6 b7 : B8) :
  b8Xor (b8Xor (b8Xor (b8Xor a0 b0) (b8Xor a1 b1)) (b8Xor (b8Xor a2 b2) (b8Xor a3 b3)))
        (b8Xor (b8Xor (b8Xor a4 b4) (b8Xor a5 b5)) (b8Xor (b8Xor a6 b6) (b8Xor a7 b7)))
  =
  b8Xor (b8Xor (b8Xor (b8Xor a0 a1) (b8Xor a2 a3)) (b8Xor (b8Xor a4 a5) (b8Xor a6 a7)))
        (b8Xor (b8Xor (b8Xor b0 b1) (b8Xor b2 b3)) (b8Xor (b8Xor b4 b5) (b8Xor b6 b7))) :=
  let m03 := Eq.trans (b8Xor2 (lem_b8xor_four a0 b0 a1 b1) (lem_b8xor_four a2 b2 a3 b3))
               (lem_b8xor_four (b8Xor a0 a1) (b8Xor b0 b1) (b8Xor a2 a3) (b8Xor b2 b3))
  let m47 := Eq.trans (b8Xor2 (lem_b8xor_four a4 b4 a5 b5) (lem_b8xor_four a6 b6 a7 b7))
               (lem_b8xor_four (b8Xor a4 a5) (b8Xor b4 b5) (b8Xor a6 a7) (b8Xor b6 b7))
  Eq.trans (b8Xor2 m03 m47)
    (lem_b8xor_four (b8Xor (b8Xor a0 a1) (b8Xor a2 a3)) (b8Xor (b8Xor b0 b1) (b8Xor b2 b3))
                    (b8Xor (b8Xor a4 a5) (b8Xor a6 a7)) (b8Xor (b8Xor b4 b5) (b8Xor b6 b7)))

theorem lem_mask_xor_bit (u v : Bool) (x : B8) : b8Mask (bXor u v) x = b8Xor (b8Mask u x) (b8Mask v x) :=
  Bool.casesOn u
    (Bool.casesOn v rfl (Eq.symm (lem_b8xor_zero_left x)))
    (Bool.casesOn v (Eq.symm (lem_b8xor_zero_right x)) (Eq.symm (lem_b8xor_self x)))

theorem lem_gf256_distrib_left (a u v : B8) : gf256Mul a (b8Xor u v) = b8Xor (gf256Mul a u) (gf256Mul a v) :=
  B8.casesOn u (fun u7 u6 u5 u4 u3 u2 u1 u0 =>
    B8.casesOn v (fun v7 v6 v5 v4 v3 v2 v1 v0 =>
      let x0 := a; let x1 := gf256Xtime x0; let x2 := gf256Xtime x1; let x3 := gf256Xtime x2
      let x4 := gf256Xtime x3; let x5 := gf256Xtime x4; let x6 := gf256Xtime x5; let x7 := gf256Xtime x6
      Eq.trans
        (b8Xor2
          (b8Xor2 (b8Xor2 (lem_mask_xor_bit u0 v0 x0) (lem_mask_xor_bit u1 v1 x1))
                  (b8Xor2 (lem_mask_xor_bit u2 v2 x2) (lem_mask_xor_bit u3 v3 x3)))
          (b8Xor2 (b8Xor2 (lem_mask_xor_bit u4 v4 x4) (lem_mask_xor_bit u5 v5 x5))
                  (b8Xor2 (lem_mask_xor_bit u6 v6 x6) (lem_mask_xor_bit u7 v7 x7))))
        (lem_b8xor8_merge
          (b8Mask u0 x0) (b8Mask u1 x1) (b8Mask u2 x2) (b8Mask u3 x3)
          (b8Mask u4 x4) (b8Mask u5 x5) (b8Mask u6 x6) (b8Mask u7 x7)
          (b8Mask v0 x0) (b8Mask v1 x1) (b8Mask v2 x2) (b8Mask v3 x3)
          (b8Mask v4 x4) (b8Mask v5 x5) (b8Mask v6 x6) (b8Mask v7 x7))))

theorem lem_xtime_xor (a b : B8) : gf256Xtime (b8Xor a b) = b8Xor (gf256Xtime a) (gf256Xtime b) :=
  B8.casesOn a (fun a7 a6 a5 a4 a3 a2 a1 a0 =>
    B8.casesOn b (fun b7 b6 b5 b4 b3 b2 b1 b0 =>
      b8Cong rfl rfl rfl (lem_bxor_four a3 b3 a7 b7) (lem_bxor_four a2 b2 a7 b7)
             rfl (lem_bxor_four a0 b0 a7 b7) rfl))

theorem lem_xtime_xor_step {w u v : B8} (h : w = b8Xor u v) :
  gf256Xtime w = b8Xor (gf256Xtime u) (gf256Xtime v) :=
  Eq.trans (congrArg gf256Xtime h) (lem_xtime_xor u v)

theorem lem_xtime_mask (bit : Bool) (x : B8) : gf256Xtime (b8Mask bit x) = b8Mask bit (gf256Xtime x) :=
  Bool.casesOn bit rfl rfl

theorem lem_mul_mask_right (a : B8) (bit : Bool) (y : B8) : gf256Mul a (b8Mask bit y) = b8Mask bit (gf256Mul a y) :=
  Bool.casesOn bit rfl rfl

def b8E0 : B8 := B8.mk false false false false false false false true
def b8E1 : B8 := B8.mk false false false false false false true  false
def b8E2 : B8 := B8.mk false false false false false true  false false
def b8E3 : B8 := B8.mk false false false false true  false false false
def b8E4 : B8 := B8.mk false false false true  false false false false
def b8E5 : B8 := B8.mk false false true  false false false false false
def b8E6 : B8 := B8.mk false true  false false false false false false
def b8E7 : B8 := B8.mk true  false false false false false false false

def b8Unit0 (b : Bool) : B8 := B8.mk false false false false false false false b
def b8Unit1 (b : Bool) : B8 := B8.mk false false false false false false b     false
def b8Unit2 (b : Bool) : B8 := B8.mk false false false false false b     false false
def b8Unit3 (b : Bool) : B8 := B8.mk false false false false b     false false false
def b8Unit4 (b : Bool) : B8 := B8.mk false false false b     false false false false
def b8Unit5 (b : Bool) : B8 := B8.mk false false b     false false false false false
def b8Unit6 (b : Bool) : B8 := B8.mk false b     false false false false false false
def b8Unit7 (b : Bool) : B8 := B8.mk b     false false false false false false false

def b8FromBasis (y : B8) : B8 :=
  B8.casesOn y (fun y7 y6 y5 y4 y3 y2 y1 y0 =>
    b8Xor (b8Xor (b8Xor (b8Mask y0 b8E0) (b8Mask y1 b8E1)) (b8Xor (b8Mask y2 b8E2) (b8Mask y3 b8E3)))
          (b8Xor (b8Xor (b8Mask y4 b8E4) (b8Mask y5 b8E5)) (b8Xor (b8Mask y6 b8E6) (b8Mask y7 b8E7))))

theorem lem_mask_eq_unit (f : Bool -> B8) (e : B8) (h0 : b8Zero = f false) (h1 : e = f true) (b : Bool) :
  b8Mask b e = f b :=
  Bool.casesOn b h0 h1

theorem lem_bxor_f1 (b : Bool) : bXor b false = b := Bool.casesOn b rfl rfl
theorem lem_bxor_f2 (b : Bool) : bXor (bXor b false) false = b := Bool.casesOn b rfl rfl
theorem lem_bxor_f3 (b : Bool) : bXor (bXor (bXor b false) false) false = b := Bool.casesOn b rfl rfl

theorem lem_b8_basis (y : B8) : b8FromBasis y = y :=
  B8.casesOn y (fun y7 y6 y5 y4 y3 y2 y1 y0 =>
    let uEq : b8FromBasis (B8.mk y7 y6 y5 y4 y3 y2 y1 y0) =
              b8Xor (b8Xor (b8Xor (b8Unit0 y0) (b8Unit1 y1)) (b8Xor (b8Unit2 y2) (b8Unit3 y3)))
                    (b8Xor (b8Xor (b8Unit4 y4) (b8Unit5 y5)) (b8Xor (b8Unit6 y6) (b8Unit7 y7))) :=
      b8Xor2
        (b8Xor2 (b8Xor2 (lem_mask_eq_unit b8Unit0 b8E0 rfl rfl y0) (lem_mask_eq_unit b8Unit1 b8E1 rfl rfl y1))
                (b8Xor2 (lem_mask_eq_unit b8Unit2 b8E2 rfl rfl y2) (lem_mask_eq_unit b8Unit3 b8E3 rfl rfl y3)))
        (b8Xor2 (b8Xor2 (lem_mask_eq_unit b8Unit4 b8E4 rfl rfl y4) (lem_mask_eq_unit b8Unit5 b8E5 rfl rfl y5))
                (b8Xor2 (lem_mask_eq_unit b8Unit6 b8E6 rfl rfl y6) (lem_mask_eq_unit b8Unit7 b8E7 rfl rfl y7)))
    Eq.trans uEq
      (b8Cong rfl (lem_bxor_f1 y6) (lem_bxor_f1 y5) (lem_bxor_f2 y4)
              (lem_bxor_f1 y3) (lem_bxor_f2 y2) (lem_bxor_f2 y1) (lem_bxor_f3 y0)))

def gf256Xt8 (a : B8) : B8 :=
  gf256Xtime (gf256Xtime (gf256Xtime (gf256Xtime (gf256Xtime (gf256Xtime (gf256Xtime (gf256Xtime a)))))))

def gf256PolyRhs (a : B8) : B8 :=
  let x1 := gf256Xtime a; let x2 := gf256Xtime x1; let x3 := gf256Xtime x2; let x4 := gf256Xtime x3
  b8Xor (b8Xor a x1) (b8Xor x3 x4)

theorem lem_ch_xor {u v : B8} (hu : gf256Xt8 u = gf256PolyRhs u) (hv : gf256Xt8 v = gf256PolyRhs v) :
  gf256Xt8 (b8Xor u v) = gf256PolyRhs (b8Xor u v) :=
  let s1 := lem_xtime_xor u v; let s2 := lem_xtime_xor_step s1
  let s3 := lem_xtime_xor_step s2; let s4 := lem_xtime_xor_step s3
  let s5 := lem_xtime_xor_step s4; let s6 := lem_xtime_xor_step s5
  let s7 := lem_xtime_xor_step s6; let s8 := lem_xtime_xor_step s7
  let rhsEq : gf256PolyRhs (b8Xor u v) = b8Xor (gf256PolyRhs u) (gf256PolyRhs v) :=
    Eq.trans
      (b8Xor2 (Eq.trans (b8Xor2 rfl s1) (lem_b8xor_four u v (gf256Xtime u) (gf256Xtime v)))
              (Eq.trans (b8Xor2 s3 s4) (lem_b8xor_four _ _ _ _)))
      (lem_b8xor_four (b8Xor u (gf256Xtime u)) (b8Xor v (gf256Xtime v)) _ _)
  Eq.trans s8 (Eq.trans (b8Xor2 hu hv) (Eq.symm rhsEq))

theorem lem_ch_mask (bit : Bool) (e : B8) (he : gf256Xt8 e = gf256PolyRhs e) :
  gf256Xt8 (b8Mask bit e) = gf256PolyRhs (b8Mask bit e) :=
  Bool.casesOn bit rfl he

theorem lem_cayley_hamilton (a : B8) : gf256Xt8 a = gf256PolyRhs a :=
  B8.casesOn a (fun a7 a6 a5 a4 a3 a2 a1 a0 =>
    let hb := lem_ch_xor
      (lem_ch_xor (lem_ch_xor (lem_ch_mask a0 b8E0 rfl) (lem_ch_mask a1 b8E1 rfl))
                  (lem_ch_xor (lem_ch_mask a2 b8E2 rfl) (lem_ch_mask a3 b8E3 rfl)))
      (lem_ch_xor (lem_ch_xor (lem_ch_mask a4 b8E4 rfl) (lem_ch_mask a5 b8E5 rfl))
                  (lem_ch_xor (lem_ch_mask a6 b8E6 rfl) (lem_ch_mask a7 b8E7 rfl)))
    let bEq := lem_b8_basis (B8.mk a7 a6 a5 a4 a3 a2 a1 a0)
    Eq.trans (congrArg gf256Xt8 (Eq.symm bEq)) (Eq.trans hb (congrArg gf256PolyRhs bEq)))

theorem lem_xr2 (z : B8) : b8Xor (b8Xor z b8Zero) b8Zero = z :=
  Eq.trans (congrArg (fun w => b8Xor w b8Zero) (lem_b8xor_zero_right z)) (lem_b8xor_zero_right z)

theorem lem_xr3 (z : B8) : b8Xor (b8Xor (b8Xor z b8Zero) b8Zero) b8Zero = z :=
  Eq.trans (congrArg (fun w => b8Xor w b8Zero) (lem_xr2 z)) (lem_b8xor_zero_right z)

theorem lem_mul_e0 (a : B8) : gf256Mul a b8E0 = a := lem_xr3 a
theorem lem_mul_e1 (a : B8) : gf256Mul a b8E1 = gf256Xtime a :=
  B8.casesOn a (fun a7 a6 a5 a4 a3 a2 a1 a0 => lem_xr2 (gf256Xtime (B8.mk a7 a6 a5 a4 a3 a2 a1 a0)))
theorem lem_mul_e2 (a : B8) : gf256Mul a b8E2 = gf256Xtime (gf256Xtime a) :=
  B8.casesOn a (fun a7 a6 a5 a4 a3 a2 a1 a0 => lem_xr2 (gf256Xtime (gf256Xtime (B8.mk a7 a6 a5 a4 a3 a2 a1 a0))))
theorem lem_mul_e3 (a : B8) : gf256Mul a b8E3 = gf256Xtime (gf256Xtime (gf256Xtime a)) :=
  B8.casesOn a (fun a7 a6 a5 a4 a3 a2 a1 a0 => lem_b8xor_zero_right (gf256Xtime (gf256Xtime (gf256Xtime (B8.mk a7 a6 a5 a4 a3 a2 a1 a0)))))
theorem lem_mul_e4 (a : B8) : gf256Mul a b8E4 = gf256Xtime (gf256Xtime (gf256Xtime (gf256Xtime a))) :=
  B8.casesOn a (fun a7 a6 a5 a4 a3 a2 a1 a0 => lem_xr2 (gf256Xtime (gf256Xtime (gf256Xtime (gf256Xtime (B8.mk a7 a6 a5 a4 a3 a2 a1 a0))))))
theorem lem_mul_e5 (a : B8) : gf256Mul a b8E5 = gf256Xtime (gf256Xtime (gf256Xtime (gf256Xtime (gf256Xtime a)))) :=
  B8.casesOn a (fun a7 a6 a5 a4 a3 a2 a1 a0 => lem_b8xor_zero_right (gf256Xtime (gf256Xtime (gf256Xtime (gf256Xtime (gf256Xtime (B8.mk a7 a6 a5 a4 a3 a2 a1 a0)))))))
theorem lem_mul_e6 (a : B8) : gf256Mul a b8E6 = gf256Xtime (gf256Xtime (gf256Xtime (gf256Xtime (gf256Xtime (gf256Xtime a))))) :=
  B8.casesOn a (fun a7 a6 a5 a4 a3 a2 a1 a0 => lem_b8xor_zero_right (gf256Xtime (gf256Xtime (gf256Xtime (gf256Xtime (gf256Xtime (gf256Xtime (B8.mk a7 a6 a5 a4 a3 a2 a1 a0))))))))
theorem lem_mul_e7 (a : B8) : gf256Mul a b8E7 = gf256Xtime (gf256Xtime (gf256Xtime (gf256Xtime (gf256Xtime (gf256Xtime (gf256Xtime a)))))) :=
  B8.casesOn a (fun _ _ _ _ _ _ _ _ => rfl)

theorem lem_mxr_xor (a : B8) {u v : B8}
  (hu : gf256Mul a (gf256Xtime u) = gf256Xtime (gf256Mul a u))
  (hv : gf256Mul a (gf256Xtime v) = gf256Xtime (gf256Mul a v)) :
  gf256Mul a (gf256Xtime (b8Xor u v)) = gf256Xtime (gf256Mul a (b8Xor u v)) :=
  Eq.trans (congrArg (gf256Mul a) (lem_xtime_xor u v))
    (Eq.trans (lem_gf256_distrib_left a (gf256Xtime u) (gf256Xtime v))
      (Eq.trans (b8Xor2 hu hv)
        (Eq.trans (Eq.symm (lem_xtime_xor (gf256Mul a u) (gf256Mul a v)))
          (congrArg gf256Xtime (Eq.symm (lem_gf256_distrib_left a u v))))))

theorem lem_mxr_mask (a : B8) (bit : Bool) (e : B8)
  (he : gf256Mul a (gf256Xtime e) = gf256Xtime (gf256Mul a e)) :
  gf256Mul a (gf256Xtime (b8Mask bit e)) = gf256Xtime (gf256Mul a (b8Mask bit e)) :=
  Bool.casesOn bit rfl he

theorem lem_mxr_e7 (a : B8) : gf256Mul a (gf256Xtime b8E7) = gf256Xtime (gf256Mul a b8E7) :=
  let h1B : gf256Xtime b8E7 = b8Xor (b8Xor b8E0 b8E1) (b8Xor b8E3 b8E4) := rfl
  let hD := Eq.trans (congrArg (gf256Mul a) h1B)
              (Eq.trans (lem_gf256_distrib_left a (b8Xor b8E0 b8E1) (b8Xor b8E3 b8E4))
                (b8Xor2 (Eq.trans (lem_gf256_distrib_left a b8E0 b8E1) (b8Xor2 (lem_mul_e0 a) (lem_mul_e1 a)))
                        (Eq.trans (lem_gf256_distrib_left a b8E3 b8E4) (b8Xor2 (lem_mul_e3 a) (lem_mul_e4 a)))))
  Eq.trans hD (Eq.trans (Eq.symm (lem_cayley_hamilton a)) (congrArg gf256Xtime (Eq.symm (lem_mul_e7 a))))

theorem lem_mul_xtime_right (a y : B8) : gf256Mul a (gf256Xtime y) = gf256Xtime (gf256Mul a y) :=
  let he0 : gf256Mul a (gf256Xtime b8E0) = gf256Xtime (gf256Mul a b8E0) := Eq.trans (lem_mul_e1 a) (congrArg gf256Xtime (Eq.symm (lem_mul_e0 a)))
  let he1 : gf256Mul a (gf256Xtime b8E1) = gf256Xtime (gf256Mul a b8E1) := Eq.trans (lem_mul_e2 a) (congrArg gf256Xtime (Eq.symm (lem_mul_e1 a)))
  let he2 : gf256Mul a (gf256Xtime b8E2) = gf256Xtime (gf256Mul a b8E2) := Eq.trans (lem_mul_e3 a) (congrArg gf256Xtime (Eq.symm (lem_mul_e2 a)))
  let he3 : gf256Mul a (gf256Xtime b8E3) = gf256Xtime (gf256Mul a b8E3) := Eq.trans (lem_mul_e4 a) (congrArg gf256Xtime (Eq.symm (lem_mul_e3 a)))
  let he4 : gf256Mul a (gf256Xtime b8E4) = gf256Xtime (gf256Mul a b8E4) := Eq.trans (lem_mul_e5 a) (congrArg gf256Xtime (Eq.symm (lem_mul_e4 a)))
  let he5 : gf256Mul a (gf256Xtime b8E5) = gf256Xtime (gf256Mul a b8E5) := Eq.trans (lem_mul_e6 a) (congrArg gf256Xtime (Eq.symm (lem_mul_e5 a)))
  let he6 : gf256Mul a (gf256Xtime b8E6) = gf256Xtime (gf256Mul a b8E6) := Eq.trans (lem_mul_e7 a) (congrArg gf256Xtime (Eq.symm (lem_mul_e6 a)))
  B8.casesOn y (fun y7 y6 y5 y4 y3 y2 y1 y0 =>
    let hb := lem_mxr_xor a
      (lem_mxr_xor a (lem_mxr_xor a (lem_mxr_mask a y0 b8E0 he0) (lem_mxr_mask a y1 b8E1 he1))
                     (lem_mxr_xor a (lem_mxr_mask a y2 b8E2 he2) (lem_mxr_mask a y3 b8E3 he3)))
      (lem_mxr_xor a (lem_mxr_xor a (lem_mxr_mask a y4 b8E4 he4) (lem_mxr_mask a y5 b8E5 he5))
                     (lem_mxr_xor a (lem_mxr_mask a y6 b8E6 he6) (lem_mxr_mask a y7 b8E7 (lem_mxr_e7 a))))
    let bEq := lem_b8_basis (B8.mk y7 y6 y5 y4 y3 y2 y1 y0)
    Eq.trans (congrArg (fun z => gf256Mul a (gf256Xtime z)) (Eq.symm bEq))
      (Eq.trans hb (congrArg (fun z => gf256Xtime (gf256Mul a z)) bEq)))

theorem lem_mul_xt_step {a y z : B8} (h : gf256Mul a y = z) : gf256Mul a (gf256Xtime y) = gf256Xtime z :=
  Eq.trans (lem_mul_xtime_right a y) (congrArg gf256Xtime h)

theorem lem_mul_mask_step (a : B8) (bit : Bool) {y z : B8} (h : gf256Mul a y = z) :
  gf256Mul a (b8Mask bit y) = b8Mask bit z :=
  Eq.trans (lem_mul_mask_right a bit y) (congrArg (b8Mask bit) h)

theorem lem_assoc_xor (a2 : B8) {u v w1 w2 : B8}
  (hu : gf256Mul a2 u = w1) (hv : gf256Mul a2 v = w2) :
  gf256Mul a2 (b8Xor u v) = b8Xor w1 w2 :=
  Eq.trans (lem_gf256_distrib_left a2 u v) (b8Xor2 hu hv)

theorem lem_gf256_assoc (a2 a1 x : B8) : gf256Mul a2 (gf256Mul a1 x) = gf256Mul (gf256Mul a2 a1) x :=
  let m0 : gf256Mul a2 a1 = gf256Mul a2 a1 := rfl
  let m1 := lem_mul_xt_step m0; let m2 := lem_mul_xt_step m1; let m3 := lem_mul_xt_step m2
  let m4 := lem_mul_xt_step m3; let m5 := lem_mul_xt_step m4; let m6 := lem_mul_xt_step m5
  let m7 := lem_mul_xt_step m6
  B8.casesOn x (fun x7 x6 x5 x4 x3 x2 x1 x0 =>
    lem_assoc_xor a2
      (lem_assoc_xor a2
        (lem_assoc_xor a2 (lem_mul_mask_step a2 x0 m0) (lem_mul_mask_step a2 x1 m1))
        (lem_assoc_xor a2 (lem_mul_mask_step a2 x2 m2) (lem_mul_mask_step a2 x3 m3)))
      (lem_assoc_xor a2
        (lem_assoc_xor a2 (lem_mul_mask_step a2 x4 m4) (lem_mul_mask_step a2 x5 m5))
        (lem_assoc_xor a2 (lem_mul_mask_step a2 x6 m6) (lem_mul_mask_step a2 x7 m7))))

def gf256AffHop (a b x : B8) : B8 := b8Xor (gf256Mul a x) b
def b8Bit0Proj (x : B8) : Bool := B8.casesOn x (fun _ _ _ _ _ _ _ z0 => z0)
def b8Hex03 : B8 := B8.mk false false false false false false true true
def b8Hex05 : B8 := B8.mk false false false false false true false true
def chooseReset (cnt : Nat) (g : Bool) : Nat := Bool.casesOn g (Nat.succ cnt) 0
def epochBudgetReset (cnt qMax : Nat) : Nat := chooseReset cnt (natBle qMax cnt)

theorem thm33_nonabelian_path_history_and_query_budget_ratchet :
  forall (a2 b2 a1 b1 x : B8) (cnt : Nat),
    And (gf256AffHop a2 b2 (gf256AffHop a1 b1 x) = gf256AffHop (gf256Mul a2 a1) (b8Xor (gf256Mul a2 b1) b2) x)
        (And (Not (gf256AffHop b8Hex03 b8Hex05 (gf256AffHop b8E1 b8E0 b8Zero)
                   = gf256AffHop b8E1 b8E0 (gf256AffHop b8Hex03 b8Hex05 b8Zero)))
             (epochBudgetReset cnt cnt = 0)) :=
  fun a2 b2 a1 b1 x cnt =>
    let hComp := Eq.trans (congrArg (fun z => b8Xor z b2) (lem_gf256_distrib_left a2 (gf256Mul a1 x) b1))
                   (Eq.trans (congrArg (fun z => b8Xor (b8Xor z (gf256Mul a2 b1)) b2) (lem_gf256_assoc a2 a1 x))
                     (lem_b8xor_assoc (gf256Mul (gf256Mul a2 a1) x) (gf256Mul a2 b1) b2))
    let hReflBle : forall n : Nat, natBle n n = true :=
      fun n => @Nat.rec (fun k => natBle k k = true) rfl (fun _ ih => ih) n
    And.intro hComp
      (And.intro
        (fun hEq => lem_false_imp False (congrArg b8Bit0Proj hEq))
        (congrArg (chooseReset cnt) (hReflBle cnt)))

-- === thm34: Word64 Double-Tap Involution (L_a^2 = RotL_2a) & Perm64 Gauge Flattening ===

theorem lem_zero_add : forall (a : Nat), 0 + a = a :=
  fun a => @Nat.rec (fun k => 0 + k = k) rfl (fun _ ih => congrArg Nat.succ ih) a

theorem lem_add_assoc : forall (x y z : Nat), (x + y) + z = x + (y + z) :=
  fun x y z => @Nat.rec (fun k => (x + y) + k = x + (y + k)) rfl (fun _ ih => congrArg Nat.succ ih) z

theorem lem_add_comm : forall (x y : Nat), x + y = y + x :=
  fun x y =>
    @Nat.rec (fun k => x + k = k + x)
      (Eq.symm (lem_zero_add x))
      (fun k ih => Eq.trans (congrArg Nat.succ ih) (Eq.symm (lem_succ_add k x))) y

theorem lem_two_mul : forall (a : Nat), 2 * a = a + a :=
  fun a =>
    @Nat.rec (fun k => 2 * k = k + k) rfl
      (fun k ih => Eq.trans (congrArg (fun z => Nat.succ (Nat.succ z)) ih)
                            (Eq.symm (congrArg Nat.succ (lem_succ_add k k)))) a

def L_op (a : Nat) (m : Word64) (i : Nat) : Bool :=
  bXor (bXor (m i) (m (i + a))) (m (i + 32))

theorem lem_double_tap_bool :
  forall (b1 b2 b3 b5 b6 : Bool),
    bXor (bXor (bXor (bXor b1 b2) b3) (bXor (bXor b2 b5) b6)) (bXor (bXor b3 b6) b1) = b5 :=
  fun b1 b2 b3 b5 b6 =>
    Bool.casesOn b1
      (Bool.casesOn b2
        (Bool.casesOn b3 (Bool.casesOn b5 (Bool.casesOn b6 rfl rfl) (Bool.casesOn b6 rfl rfl))
                         (Bool.casesOn b5 (Bool.casesOn b6 rfl rfl) (Bool.casesOn b6 rfl rfl)))
        (Bool.casesOn b3 (Bool.casesOn b5 (Bool.casesOn b6 rfl rfl) (Bool.casesOn b6 rfl rfl))
                         (Bool.casesOn b5 (Bool.casesOn b6 rfl rfl) (Bool.casesOn b6 rfl rfl))))
      (Bool.casesOn b2
        (Bool.casesOn b3 (Bool.casesOn b5 (Bool.casesOn b6 rfl rfl) (Bool.casesOn b6 rfl rfl))
                         (Bool.casesOn b5 (Bool.casesOn b6 rfl rfl) (Bool.casesOn b6 rfl rfl)))
        (Bool.casesOn b3 (Bool.casesOn b5 (Bool.casesOn b6 rfl rfl) (Bool.casesOn b6 rfl rfl))
                         (Bool.casesOn b5 (Bool.casesOn b6 rfl rfl) (Bool.casesOn b6 rfl rfl))))

inductive Perm64 : Type where
  | mk : (Nat -> Nat) -> (Nat -> Nat) -> Perm64

def permFwd (p : Perm64) : Nat -> Nat := Perm64.casesOn p (fun f _ => f)
def permBwd (p : Perm64) : Nat -> Nat := Perm64.casesOn p (fun _ b => b)
def isPermBijection (p : Perm64) : Prop :=
  And (forall k : Nat, permBwd p (permFwd p k) = k)
      (forall k : Nat, permFwd p (permBwd p k) = k)

def piTilde (u v pi : Perm64) (k : Nat) : Nat :=
  permBwd pi (permFwd v (permBwd u k))

theorem thm34_autonomous_discovery_involutive_and_gauge_invariance :
  forall (m : Word64), (forall k : Nat, m (k + 64) = m k) ->
  forall (u v pi : Perm64), isPermBijection u -> isPermBijection v -> isPermBijection pi ->
  forall (a i : Nat),
    And (L_op a (L_op a m) i = m (i + 2 * a))
        (permBwd v (permFwd pi (piTilde u v pi (permFwd u i))) = i) :=
  fun m hPer u v pi hu hv hpi a i =>
    let hIdx5 : (i + a) + a = i + 2 * a :=
      Eq.trans (lem_add_assoc i a a) (congrArg (fun z => i + z) (Eq.symm (lem_two_mul a)))
    let hIdx8 : (i + 32) + a = (i + a) + 32 :=
      Eq.trans (lem_add_assoc i 32 a)
        (Eq.trans (congrArg (fun z => i + z) (lem_add_comm 32 a)) (Eq.symm (lem_add_assoc i a 32)))
    let hIdx9 : m ((i + 32) + 32) = m i :=
      Eq.trans (congrArg m (lem_add_assoc i 32 32)) (hPer i)
    let hRewrite :=
      congr
        (congrArg bXor
          (congrArg (fun z5 => bXor (bXor (bXor (m i) (m (i + a))) (m (i + 32)))
                                    (bXor (bXor (m (i + a)) z5) (m ((i + a) + 32))))
                    (congrArg m hIdx5)))
        (congr (congrArg (fun z8 => bXor (bXor (m (i + 32)) z8)) (congrArg m hIdx8)) hIdx9)
    let hGauge :=
      Eq.trans (congrArg (fun z => permBwd v (permFwd pi (permBwd pi (permFwd v z)))) (And.left hu i))
        (Eq.trans (congrArg (permBwd v) (And.right hpi (permFwd v i))) (And.left hv i))
    And.intro (Eq.trans hRewrite (lem_double_tap_bool (m i) (m (i + a)) (m (i + 32)) (m (i + 2 * a)) (m ((i + a) + 32))))
              hGauge

-- === thm35: GF(2^8) Commutativity, Exact Bezout-Horner Division Identity, & 0x20 Normal-Basis Frobenius ===

theorem lem_mask_b8xor (bit : Bool) (x y : B8) :
  b8Mask bit (b8Xor x y) = b8Xor (b8Mask bit x) (b8Mask bit y) :=
  Bool.casesOn bit rfl rfl

theorem lem_mask_b8xor_step (bit : Bool) {w x y : B8} (h : w = b8Xor x y) :
  b8Mask bit w = b8Xor (b8Mask bit x) (b8Mask bit y) :=
  Eq.trans (congrArg (b8Mask bit) h) (lem_mask_b8xor bit x y)

theorem lem_gf256_distrib_right (u v b : B8) :
  gf256Mul (b8Xor u v) b = b8Xor (gf256Mul u b) (gf256Mul v b) :=
  B8.casesOn b (fun b7 b6 b5 b4 b3 b2 b1 b0 =>
    let s0 : b8Xor u v = b8Xor u v := rfl
    let s1 := lem_xtime_xor u v; let s2 := lem_xtime_xor_step s1
    let s3 := lem_xtime_xor_step s2; let s4 := lem_xtime_xor_step s3
    let s5 := lem_xtime_xor_step s4; let s6 := lem_xtime_xor_step s5
    let s7 := lem_xtime_xor_step s6
    let u0 := u; let u1 := gf256Xtime u0; let u2 := gf256Xtime u1; let u3 := gf256Xtime u2
    let u4 := gf256Xtime u3; let u5 := gf256Xtime u4; let u6 := gf256Xtime u5; let u7 := gf256Xtime u6
    let v0 := v; let v1 := gf256Xtime v0; let v2 := gf256Xtime v1; let v3 := gf256Xtime v2
    let v4 := gf256Xtime v3; let v5 := gf256Xtime v4; let v6 := gf256Xtime v5; let v7 := gf256Xtime v6
    Eq.trans
      (b8Xor2
        (b8Xor2 (b8Xor2 (lem_mask_b8xor_step b0 s0) (lem_mask_b8xor_step b1 s1))
                (b8Xor2 (lem_mask_b8xor_step b2 s2) (lem_mask_b8xor_step b3 s3)))
        (b8Xor2 (b8Xor2 (lem_mask_b8xor_step b4 s4) (lem_mask_b8xor_step b5 s5))
                (b8Xor2 (lem_mask_b8xor_step b6 s6) (lem_mask_b8xor_step b7 s7))))
      (lem_b8xor8_merge
        (b8Mask b0 u0) (b8Mask b1 u1) (b8Mask b2 u2) (b8Mask b3 u3)
        (b8Mask b4 u4) (b8Mask b5 u5) (b8Mask b6 u6) (b8Mask b7 u7)
        (b8Mask b0 v0) (b8Mask b1 v1) (b8Mask b2 v2) (b8Mask b3 v3)
        (b8Mask b4 v4) (b8Mask b5 v5) (b8Mask b6 v6) (b8Mask b7 v7)))

theorem lem_mask_zero (bit : Bool) : b8Mask bit b8Zero = b8Zero :=
  Bool.casesOn bit rfl rfl

theorem lem_mul_zero_left (a : B8) : gf256Mul b8Zero a = b8Zero :=
  B8.casesOn a (fun a7 a6 a5 a4 a3 a2 a1 a0 =>
    b8Xor2
      (b8Xor2 (b8Xor2 (lem_mask_zero a0) (lem_mask_zero a1))
              (b8Xor2 (lem_mask_zero a2) (lem_mask_zero a3)))
      (b8Xor2 (b8Xor2 (lem_mask_zero a4) (lem_mask_zero a5))
              (b8Xor2 (lem_mask_zero a6) (lem_mask_zero a7))))

theorem lem_mul_e0_basis (y : B8) : gf256Mul b8E0 y = b8FromBasis y :=
  B8.casesOn y (fun _ _ _ _ _ _ _ _ => rfl)

theorem lem_mul_e0_left (y : B8) : gf256Mul b8E0 y = y :=
  Eq.trans (lem_mul_e0_basis y) (lem_b8_basis y)

theorem lem_e1_xor {u v : B8}
  (hu : gf256Mul b8E1 u = gf256Xtime u)
  (hv : gf256Mul b8E1 v = gf256Xtime v) :
  gf256Mul b8E1 (b8Xor u v) = gf256Xtime (b8Xor u v) :=
  Eq.trans (lem_gf256_distrib_left b8E1 u v)
    (Eq.trans (b8Xor2 hu hv) (Eq.symm (lem_xtime_xor u v)))

theorem lem_e1_mask (bit : Bool) (e : B8) (he : gf256Mul b8E1 e = gf256Xtime e) :
  gf256Mul b8E1 (b8Mask bit e) = gf256Xtime (b8Mask bit e) :=
  Bool.casesOn bit rfl he

theorem lem_mul_e1_left (y : B8) : gf256Mul b8E1 y = gf256Xtime y :=
  B8.casesOn y (fun y7 y6 y5 y4 y3 y2 y1 y0 =>
    let hb := lem_e1_xor
      (lem_e1_xor (lem_e1_xor (lem_e1_mask y0 b8E0 rfl) (lem_e1_mask y1 b8E1 rfl))
                  (lem_e1_xor (lem_e1_mask y2 b8E2 rfl) (lem_e1_mask y3 b8E3 rfl)))
      (lem_e1_xor (lem_e1_xor (lem_e1_mask y4 b8E4 rfl) (lem_e1_mask y5 b8E5 rfl))
                  (lem_e1_xor (lem_e1_mask y6 b8E6 rfl) (lem_e1_mask y7 b8E7 rfl)))
    let bEq := lem_b8_basis (B8.mk y7 y6 y5 y4 y3 y2 y1 y0)
    Eq.trans (congrArg (gf256Mul b8E1) (Eq.symm bEq)) (Eq.trans hb (congrArg gf256Xtime bEq)))

theorem lem_xtime_mul_left (u y : B8) : gf256Mul (gf256Xtime u) y = gf256Xtime (gf256Mul u y) :=
  Eq.trans (congrArg (fun z => gf256Mul z y) (Eq.symm (lem_mul_e1 u)))
    (Eq.trans (Eq.symm (lem_gf256_assoc u b8E1 y))
      (Eq.trans (congrArg (gf256Mul u) (lem_mul_e1_left y))
        (lem_mul_xtime_right u y)))

theorem lem_comm_xt_step {e a : B8} (h : gf256Mul e a = gf256Mul a e) :
  gf256Mul (gf256Xtime e) a = gf256Mul a (gf256Xtime e) :=
  Eq.trans (lem_xtime_mul_left e a)
    (Eq.trans (congrArg gf256Xtime h) (Eq.symm (lem_mul_xtime_right a e)))

theorem lem_comm_xor (a : B8) {u v : B8}
  (hu : gf256Mul u a = gf256Mul a u)
  (hv : gf256Mul v a = gf256Mul a v) :
  gf256Mul (b8Xor u v) a = gf256Mul a (b8Xor u v) :=
  Eq.trans (lem_gf256_distrib_right u v a)
    (Eq.trans (b8Xor2 hu hv) (Eq.symm (lem_gf256_distrib_left a u v)))

theorem lem_comm_mask (a : B8) (bit : Bool) (e : B8)
  (he : gf256Mul e a = gf256Mul a e) :
  gf256Mul (b8Mask bit e) a = gf256Mul a (b8Mask bit e) :=
  Bool.casesOn bit (lem_mul_zero_left a) he

theorem lem_gf256_comm (b a : B8) : gf256Mul b a = gf256Mul a b :=
  let c0 : gf256Mul b8E0 a = gf256Mul a b8E0 := Eq.trans (lem_mul_e0_left a) (Eq.symm (lem_mul_e0 a))
  let c1 : gf256Mul b8E1 a = gf256Mul a b8E1 := lem_comm_xt_step c0
  let c2 : gf256Mul b8E2 a = gf256Mul a b8E2 := lem_comm_xt_step c1
  let c3 : gf256Mul b8E3 a = gf256Mul a b8E3 := lem_comm_xt_step c2
  let c4 : gf256Mul b8E4 a = gf256Mul a b8E4 := lem_comm_xt_step c3
  let c5 : gf256Mul b8E5 a = gf256Mul a b8E5 := lem_comm_xt_step c4
  let c6 : gf256Mul b8E6 a = gf256Mul a b8E6 := lem_comm_xt_step c5
  let c7 : gf256Mul b8E7 a = gf256Mul a b8E7 := lem_comm_xt_step c6
  B8.casesOn b (fun b7 b6 b5 b4 b3 b2 b1 b0 =>
    let hb := lem_comm_xor a
      (lem_comm_xor a (lem_comm_xor a (lem_comm_mask a b0 b8E0 c0) (lem_comm_mask a b1 b8E1 c1))
                      (lem_comm_xor a (lem_comm_mask a b2 b8E2 c2) (lem_comm_mask a b3 b8E3 c3)))
      (lem_comm_xor a (lem_comm_xor a (lem_comm_mask a b4 b8E4 c4) (lem_comm_mask a b5 b8E5 c5))
                      (lem_comm_xor a (lem_comm_mask a b6 b8E6 c6) (lem_comm_mask a b7 b8E7 c7)))
    let bEq := lem_b8_basis (B8.mk b7 b6 b5 b4 b3 b2 b1 b0)
    Eq.trans (congrArg (fun z => gf256Mul z a) (Eq.symm bEq))
      (Eq.trans hb (congrArg (gf256Mul a) bEq)))

theorem lem_bool_horner_cancel :
  forall (s a z w : Bool), bXor s (bXor z w) = bXor (bXor s a) (bXor (bXor z a) w) :=
  fun s a z w =>
    Bool.casesOn s
      (Bool.casesOn a
        (Bool.casesOn z (Bool.casesOn w rfl rfl) (Bool.casesOn w rfl rfl))
        (Bool.casesOn z (Bool.casesOn w rfl rfl) (Bool.casesOn w rfl rfl)))
      (Bool.casesOn a
        (Bool.casesOn z (Bool.casesOn w rfl rfl) (Bool.casesOn w rfl rfl))
        (Bool.casesOn z (Bool.casesOn w rfl rfl) (Bool.casesOn w rfl rfl)))

theorem lem_b8_horner_cancel :
  forall (s a z w : B8), b8Xor s (b8Xor z w) = b8Xor (b8Xor s a) (b8Xor (b8Xor z a) w) :=
  fun s a z w =>
    B8.casesOn s (fun s7 s6 s5 s4 s3 s2 s1 s0 =>
      B8.casesOn a (fun a7 a6 a5 a4 a3 a2 a1 a0 =>
        B8.casesOn z (fun z7 z6 z5 z4 z3 z2 z1 z0 =>
          B8.casesOn w (fun w7 w6 w5 w4 w3 w2 w1 w0 =>
            b8Cong (lem_bool_horner_cancel s7 a7 z7 w7) (lem_bool_horner_cancel s6 a6 z6 w6)
                   (lem_bool_horner_cancel s5 a5 z5 w5) (lem_bool_horner_cancel s4 a4 z4 w4)
                   (lem_bool_horner_cancel s3 a3 z3 w3) (lem_bool_horner_cancel s2 a2 z2 w2)
                   (lem_bool_horner_cancel s1 a1 z1 w1) (lem_bool_horner_cancel s0 a0 z0 w0)))))

theorem lem_mul_swap_left (z d u : B8) :
  gf256Mul z (gf256Mul d u) = gf256Mul d (gf256Mul z u) :=
  Eq.trans (lem_gf256_assoc z d u)
    (Eq.trans (congrArg (fun x => gf256Mul x u) (lem_gf256_comm z d))
      (Eq.symm (lem_gf256_assoc d z u)))

theorem lem_horner_div_step (z alpha sk ePrev qPrev uPrev : B8)
  (hPrev : ePrev = b8Xor qPrev (gf256Mul (b8Xor z alpha) uPrev)) :
  b8Xor sk (gf256Mul z ePrev)
  = b8Xor (b8Xor sk (gf256Mul alpha qPrev))
          (gf256Mul (b8Xor z alpha) (b8Xor qPrev (gf256Mul z uPrev))) :=
  let d := b8Xor z alpha
  let zq := gf256Mul z qPrev
  let aq := gf256Mul alpha qPrev
  let w := gf256Mul d (gf256Mul z uPrev)
  let hLhs : b8Xor sk (gf256Mul z ePrev) = b8Xor sk (b8Xor zq w) :=
    Eq.trans (congrArg (fun x => b8Xor sk (gf256Mul z x)) hPrev)
      (Eq.trans (congrArg (b8Xor sk) (lem_gf256_distrib_left z qPrev (gf256Mul d uPrev)))
        (congrArg (fun x => b8Xor sk (b8Xor zq x)) (lem_mul_swap_left z d uPrev)))
  let hRhs : b8Xor (b8Xor sk aq) (b8Xor (b8Xor zq aq) w)
             = b8Xor (b8Xor sk aq) (gf256Mul d (b8Xor qPrev (gf256Mul z uPrev))) :=
    Eq.trans (congrArg (fun x => b8Xor (b8Xor sk aq) (b8Xor x w)) (Eq.symm (lem_gf256_distrib_right z alpha qPrev)))
      (congrArg (b8Xor (b8Xor sk aq)) (Eq.symm (lem_gf256_distrib_left d qPrev (gf256Mul z uPrev))))
  Eq.trans hLhs (Eq.trans (lem_b8_horner_cancel sk aq zq w) hRhs)

inductive Poly8 : Type where
  | mk : B8 -> B8 -> B8 -> B8 -> B8 -> B8 -> B8 -> B8 -> Poly8

theorem poly8Cong {x1 y1 x2 y2 x3 y3 x4 y4 x5 y5 x6 y6 x7 y7 x8 y8 : B8}
  (h1 : x1 = y1) (h2 : x2 = y2) (h3 : x3 = y3) (h4 : x4 = y4)
  (h5 : x5 = y5) (h6 : x6 = y6) (h7 : x7 = y7) (h8 : x8 = y8) :
  Poly8.mk x1 x2 x3 x4 x5 x6 x7 x8 = Poly8.mk y1 y2 y3 y4 y5 y6 y7 y8 :=
  congr (congr (congr (congr (congr (congr (congr (congrArg Poly8.mk h1) h2) h3) h4) h5) h6) h7) h8

def bezoutDeflate8 (p : Poly8) (alpha : B8) : Poly8 :=
  Poly8.casesOn p (fun s1 s2 s3 s4 s5 s6 s7 s8 =>
    let q1 := b8Xor s1 (gf256Mul alpha b8E0)
    let q2 := b8Xor s2 (gf256Mul alpha q1)
    let q3 := b8Xor s3 (gf256Mul alpha q2)
    let q4 := b8Xor s4 (gf256Mul alpha q3)
    let q5 := b8Xor s5 (gf256Mul alpha q4)
    let q6 := b8Xor s6 (gf256Mul alpha q5)
    let q7 := b8Xor s7 (gf256Mul alpha q6)
    let q8 := b8Xor s8 (gf256Mul alpha q7)
    Poly8.mk q1 q2 q3 q4 q5 q6 q7 q8)

def bezoutReconstruct8 (q : Poly8) (alpha : B8) : Poly8 :=
  Poly8.casesOn q (fun q1 q2 q3 q4 q5 q6 q7 q8 =>
    Poly8.mk (b8Xor q1 (gf256Mul alpha b8E0))
             (b8Xor q2 (gf256Mul alpha q1))
             (b8Xor q3 (gf256Mul alpha q2))
             (b8Xor q4 (gf256Mul alpha q3))
             (b8Xor q5 (gf256Mul alpha q4))
             (b8Xor q6 (gf256Mul alpha q5))
             (b8Xor q7 (gf256Mul alpha q6))
             (b8Xor q8 (gf256Mul alpha q7)))

def polyEval8 (p : Poly8) (z : B8) : B8 :=
  Poly8.casesOn p (fun s1 s2 s3 s4 s5 s6 s7 s8 =>
    let e1 := b8Xor s1 (gf256Mul z b8E0)
    let e2 := b8Xor s2 (gf256Mul z e1)
    let e3 := b8Xor s3 (gf256Mul z e2)
    let e4 := b8Xor s4 (gf256Mul z e3)
    let e5 := b8Xor s5 (gf256Mul z e4)
    let e6 := b8Xor s6 (gf256Mul z e5)
    let e7 := b8Xor s7 (gf256Mul z e6)
    b8Xor s8 (gf256Mul z e7))

def quotEval7 (q : Poly8) (z : B8) : B8 :=
  Poly8.casesOn q (fun q1 q2 q3 q4 q5 q6 q7 _q8 =>
    let u1 := b8Xor q1 (gf256Mul z b8E0)
    let u2 := b8Xor q2 (gf256Mul z u1)
    let u3 := b8Xor q3 (gf256Mul z u2)
    let u4 := b8Xor q4 (gf256Mul z u3)
    let u5 := b8Xor q5 (gf256Mul z u4)
    let u6 := b8Xor q6 (gf256Mul z u5)
    b8Xor q7 (gf256Mul z u6))

def bezoutRem8 (q : Poly8) : B8 :=
  Poly8.casesOn q (fun _ _ _ _ _ _ _ q8 => q8)

theorem lem_bezout_div_identity (p : Poly8) (alpha z : B8) :
  polyEval8 p z =
    b8Xor (bezoutRem8 (bezoutDeflate8 p alpha))
          (gf256Mul (b8Xor z alpha) (quotEval7 (bezoutDeflate8 p alpha) z)) :=
  Poly8.casesOn p (fun s1 s2 s3 s4 s5 s6 s7 s8 =>
    let e1 := b8Xor s1 (gf256Mul z b8E0); let e2 := b8Xor s2 (gf256Mul z e1)
    let e3 := b8Xor s3 (gf256Mul z e2);   let e4 := b8Xor s4 (gf256Mul z e3)
    let e5 := b8Xor s5 (gf256Mul z e4);   let e6 := b8Xor s6 (gf256Mul z e5)
    let e7 := b8Xor s7 (gf256Mul z e6)
    let q1 := b8Xor s1 (gf256Mul alpha b8E0); let q2 := b8Xor s2 (gf256Mul alpha q1)
    let q3 := b8Xor s3 (gf256Mul alpha q2);   let q4 := b8Xor s4 (gf256Mul alpha q3)
    let q5 := b8Xor s5 (gf256Mul alpha q4);   let q6 := b8Xor s6 (gf256Mul alpha q5)
    let q7 := b8Xor s7 (gf256Mul alpha q6)
    let u0 := b8E0; let u1 := b8Xor q1 (gf256Mul z u0); let u2 := b8Xor q2 (gf256Mul z u1)
    let u3 := b8Xor q3 (gf256Mul z u2); let u4 := b8Xor q4 (gf256Mul z u3)
    let u5 := b8Xor q5 (gf256Mul z u4); let u6 := b8Xor q6 (gf256Mul z u5)
    let h1 : e1 = b8Xor q1 (gf256Mul (b8Xor z alpha) u0) :=
      lem_horner_div_step z alpha s1 b8E0 b8E0 b8Zero rfl
    let h2 := lem_horner_div_step z alpha s2 e1 q1 u0 h1
    let h3 := lem_horner_div_step z alpha s3 e2 q2 u1 h2
    let h4 := lem_horner_div_step z alpha s4 e3 q3 u2 h3
    let h5 := lem_horner_div_step z alpha s5 e4 q4 u3 h4
    let h6 := lem_horner_div_step z alpha s6 e5 q5 u4 h5
    let h7 := lem_horner_div_step z alpha s7 e6 q6 u5 h6
    lem_horner_div_step z alpha s8 e7 q7 u6 h7)

theorem lem_bezout_rem_is_eval (p : Poly8) (alpha : B8) :
  bezoutRem8 (bezoutDeflate8 p alpha) = polyEval8 p alpha :=
  Poly8.casesOn p (fun _ _ _ _ _ _ _ _ => rfl)

def b8BetaMin : B8 := b8E5
def gf256Sq (x : B8) : B8 := gf256Mul x x
def gf256Frob8 (x : B8) : B8 :=
  gf256Sq (gf256Sq (gf256Sq (gf256Sq (gf256Sq (gf256Sq (gf256Sq (gf256Sq x)))))))
def gf256Trace (x : B8) : B8 :=
  let c0 := x; let c1 := gf256Sq c0; let c2 := gf256Sq c1; let c3 := gf256Sq c2
  let c4 := gf256Sq c3; let c5 := gf256Sq c4; let c6 := gf256Sq c5; let c7 := gf256Sq c6
  b8Xor (b8Xor (b8Xor c0 c1) (b8Xor c2 c3)) (b8Xor (b8Xor c4 c5) (b8Xor c6 c7))

def b8RotL1 (x : B8) : B8 := B8.casesOn x (fun x7 x6 x5 x4 x3 x2 x1 x0 => B8.mk x6 x5 x4 x3 x2 x1 x0 x7)
def b8RotL8 (x : B8) : B8 := b8RotL1 (b8RotL1 (b8RotL1 (b8RotL1 (b8RotL1 (b8RotL1 (b8RotL1 (b8RotL1 x)))))))

theorem thm35_vieta_bezout_deflation_and_frobenius_normal_basis :
  forall (p : Poly8) (alpha z x y : B8),
    And (bezoutReconstruct8 (bezoutDeflate8 p alpha) alpha = p)
        (And (And (polyEval8 p z = b8Xor (bezoutRem8 (bezoutDeflate8 p alpha))
                                         (gf256Mul (b8Xor z alpha) (quotEval7 (bezoutDeflate8 p alpha) z)))
                  (bezoutRem8 (bezoutDeflate8 p alpha) = polyEval8 p alpha))
             (And (And (gf256Frob8 b8BetaMin = b8BetaMin) (gf256Trace b8BetaMin = b8E0))
                  (And (b8RotL1 (b8Xor x y) = b8Xor (b8RotL1 x) (b8RotL1 y)) (b8RotL8 x = x)))) :=
  fun p alpha z x y =>
    And.intro
      (Poly8.casesOn p (fun s1 s2 s3 s4 s5 s6 s7 s8 =>
        let q1 := b8Xor s1 (gf256Mul alpha b8E0)
        let q2 := b8Xor s2 (gf256Mul alpha q1)
        let q3 := b8Xor s3 (gf256Mul alpha q2)
        let q4 := b8Xor s4 (gf256Mul alpha q3)
        let q5 := b8Xor s5 (gf256Mul alpha q4)
        let q6 := b8Xor s6 (gf256Mul alpha q5)
        let q7 := b8Xor s7 (gf256Mul alpha q6)
        poly8Cong (lem_b8xor_cancel s1 (gf256Mul alpha b8E0))
                  (lem_b8xor_cancel s2 (gf256Mul alpha q1))
                  (lem_b8xor_cancel s3 (gf256Mul alpha q2))
                  (lem_b8xor_cancel s4 (gf256Mul alpha q3))
                  (lem_b8xor_cancel s5 (gf256Mul alpha q4))
                  (lem_b8xor_cancel s6 (gf256Mul alpha q5))
                  (lem_b8xor_cancel s7 (gf256Mul alpha q6))
                  (lem_b8xor_cancel s8 (gf256Mul alpha q7))))
      (And.intro
        (And.intro (lem_bezout_div_identity p alpha z) (lem_bezout_rem_is_eval p alpha))
        (And.intro
          (And.intro rfl rfl)
          (And.intro
            (B8.casesOn x (fun _ _ _ _ _ _ _ _ => B8.casesOn y (fun _ _ _ _ _ _ _ _ => rfl)))
            (B8.casesOn x (fun _ _ _ _ _ _ _ _ => rfl)))))

-- === thm36: Stage-2 LUT6_2 Functional Sketch (64'h060C0A00_08000000) 32-State Bisimulation ===

def sketchByte00 (_v _f1 _f0 : Bool) : Bool := false
def sketchByte0A (v f1 f0 : Bool) : Bool := sramLut3 false true false true false false false false v f1 f0
def sketchByte0C (v f1 f0 : Bool) : Bool := sramLut3 false false true true false false false false v f1 f0
def sketchByte06 (v f1 f0 : Bool) : Bool := sramLut3 false true true false false false false false v f1 f0
def sketchByte08 (v f1 f0 : Bool) : Bool := sramLut3 false false false true false false false false v f1 f0

def lut6SketchO6 (x1 x0 v f1 f0 : Bool) : Bool :=
  Bool.casesOn x1 (Bool.casesOn x0 (sketchByte00 v f1 f0) (sketchByte0A v f1 f0))
                  (Bool.casesOn x0 (sketchByte0C v f1 f0) (sketchByte06 v f1 f0))
def lut6SketchO5 (x1 x0 v f1 f0 : Bool) : Bool :=
  Bool.casesOn x1 (Bool.casesOn x0 (sketchByte00 v f1 f0) (sketchByte00 v f1 f0))
                  (Bool.casesOn x0 (sketchByte00 v f1 f0) (sketchByte08 v f1 f0))
def b2n (b : Bool) : Nat := Bool.casesOn b 0 1

theorem thm36_lut6_2_streaming_functional_sketch_bisimulation :
  forall (x1 x0 v f1 f0 : Bool),
    And (lut6SketchO6 x1 x0 v f1 f0 = bAnd (bNot v) (bXor (bAnd f1 x1) (bAnd f0 x0)))
        (And (lut6SketchO5 x1 x0 v f1 f0 = bAnd (bNot v) (bAnd (bAnd f1 x1) (bAnd f0 x0)))
             (2 * b2n (lut6SketchO5 x1 x0 v f1 f0) + b2n (lut6SketchO6 x1 x0 v f1 f0)
               = Bool.casesOn v (b2n (bAnd f1 x1) + b2n (bAnd f0 x0)) 0)) :=
  fun x1 x0 v f1 f0 =>
    Bool.casesOn x1
      (Bool.casesOn x0
        (Bool.casesOn v (Bool.casesOn f1 (Bool.casesOn f0 (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl)))
                                         (Bool.casesOn f0 (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl))))
                        (Bool.casesOn f1 (Bool.casesOn f0 (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl)))
                                         (Bool.casesOn f0 (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl)))))
        (Bool.casesOn v (Bool.casesOn f1 (Bool.casesOn f0 (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl)))
                                         (Bool.casesOn f0 (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl))))
                        (Bool.casesOn f1 (Bool.casesOn f0 (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl)))
                                         (Bool.casesOn f0 (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl))))))
      (Bool.casesOn x0
        (Bool.casesOn v (Bool.casesOn f1 (Bool.casesOn f0 (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl)))
                                         (Bool.casesOn f0 (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl))))
                        (Bool.casesOn f1 (Bool.casesOn f0 (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl)))
                                         (Bool.casesOn f0 (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl)))))
        (Bool.casesOn v (Bool.casesOn f1 (Bool.casesOn f0 (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl)))
                                         (Bool.casesOn f0 (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl))))
                        (Bool.casesOn f1 (Bool.casesOn f0 (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl)))
                                         (Bool.casesOn f0 (And.intro rfl (And.intro rfl rfl)) (And.intro rfl (And.intro rfl rfl))))))

-- === thm37: De Morgan Negative-Logic RAIN Dual-Sieve (64'hABABABAB_FEFEFEFE) & Rail Fault Trap ===

def lut6RainDualO5 (ptb psb sb : Bool) : Bool := sramLut3 false true true true true true true true ptb psb sb
def lut6RainDualO6 (ptb psb sb : Bool) : Bool := sramLut3 true true false true false true false true ptb psb sb

theorem thm37_rain_demorgan_dual_sieve_bisimulation :
  forall (pt ps s : Bool),
    And (lut6RainDualO5 (bNot pt) (bNot ps) (bNot s) = bNot (lut6O5_80 pt ps s))
        (And (lut6RainDualO6 (bNot pt) (bNot ps) (bNot s) = bNot (lut6O6_2A pt ps s))
             (And (And (dualRailFault (lut6O5_80 pt ps s) (lut6RainDualO5 (bNot pt) (bNot ps) (bNot s)) = false)
                       (dualRailFault (lut6O6_2A pt ps s) (lut6RainDualO6 (bNot pt) (bNot ps) (bNot s)) = false))
                  (And (dualRailFault false false = true) (dualRailFault true true = true)))) :=
  fun pt ps s =>
    Bool.casesOn pt
      (Bool.casesOn ps
        (Bool.casesOn s (And.intro rfl (And.intro rfl (And.intro (And.intro rfl rfl) (And.intro rfl rfl))))
                        (And.intro rfl (And.intro rfl (And.intro (And.intro rfl rfl) (And.intro rfl rfl)))))
        (Bool.casesOn s (And.intro rfl (And.intro rfl (And.intro (And.intro rfl rfl) (And.intro rfl rfl))))
                        (And.intro rfl (And.intro rfl (And.intro (And.intro rfl rfl) (And.intro rfl rfl))))))
      (Bool.casesOn ps
        (Bool.casesOn s (And.intro rfl (And.intro rfl (And.intro (And.intro rfl rfl) (And.intro rfl rfl))))
                        (And.intro rfl (And.intro rfl (And.intro (And.intro rfl rfl) (And.intro rfl rfl)))))
        (Bool.casesOn s (And.intro rfl (And.intro rfl (And.intro (And.intro rfl rfl) (And.intro rfl rfl))))
                        (And.intro rfl (And.intro rfl (And.intro (And.intro rfl rfl) (And.intro rfl rfl))))))

#print axioms thm30_bijective_snoop_evict_commutative_closure
#print axioms thm31_unbounded_horizon_ic3_and_dual_bank_compaction
#print axioms thm32_spanning_forest_cycle_rank_and_cochain_exactness
#print axioms thm33_nonabelian_path_history_and_query_budget_ratchet
#print axioms thm34_autonomous_discovery_involutive_and_gauge_invariance
#print axioms thm35_vieta_bezout_deflation_and_frobenius_normal_basis
#print axioms thm36_lut6_2_streaming_functional_sketch_bisimulation
#print axioms thm37_rain_demorgan_dual_sieve_bisimulation

-- Auto-appended zero-axiom kernel audit directives
#print axioms lem_false_imp
#print axioms lem_bxor_cancel
#print axioms lem_bxor_false_right
#print axioms lem_bxor_self
#print axioms lem_bxor_assoc
#print axioms lem_bxor_four
#print axioms b8Cong
#print axioms b8Xor2
#print axioms lem_b8xor_cancel
#print axioms lem_b8xor_zero_left
#print axioms lem_b8xor_zero_right
#print axioms lem_b8xor_self
#print axioms lem_b8xor_assoc
#print axioms lem_b8xor_four
#print axioms lem_feistel_dec_enc
#print axioms lem_feistel_enc_dec
#print axioms lem_peel
#print axioms lem_feistel_dec6_enc6
#print axioms lem_feistel_enc6_dec6
#print axioms lem_band_true_left
#print axioms lem_band_true_right
#print axioms lem_band_intro
#print axioms lem_ble6_add_const
#print axioms lem_ble6_ble2_sum_ble8
#print axioms lem_airlockStepRaw_inv#print axioms lem_succ_add
#print axioms lem_graph_euler_betti
#print axioms lem_b8xor8_merge
#print axioms lem_mask_xor_bit
#print axioms lem_gf256_distrib_left
#print axioms lem_xtime_xor
#print axioms lem_xtime_xor_step
#print axioms lem_xtime_mask
#print axioms lem_mul_mask_right
#print axioms lem_mask_eq_unit
#print axioms lem_bxor_f1
#print axioms lem_bxor_f2
#print axioms lem_bxor_f3
#print axioms lem_b8_basis
#print axioms lem_ch_xor
#print axioms lem_ch_mask
#print axioms lem_cayley_hamilton
#print axioms lem_xr2
#print axioms lem_xr3
#print axioms lem_mul_e0
#print axioms lem_mul_e1
#print axioms lem_mul_e2
#print axioms lem_mul_e3
#print axioms lem_mul_e4
#print axioms lem_mul_e5
#print axioms lem_mul_e6
#print axioms lem_mul_e7
#print axioms lem_mxr_xor
#print axioms lem_mxr_mask
#print axioms lem_mxr_e7
#print axioms lem_mul_xtime_right
#print axioms lem_mul_xt_step
#print axioms lem_mul_mask_step
#print axioms lem_assoc_xor
#print axioms lem_gf256_assoc
#print axioms lem_zero_add
#print axioms lem_add_assoc
#print axioms lem_add_comm
#print axioms lem_two_mul
#print axioms lem_double_tap_bool
#print axioms poly8Cong
