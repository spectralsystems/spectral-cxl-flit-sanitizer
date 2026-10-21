namespace SpectralCore

class XORSpace (α : Type) where
  zero      : α
  add       : α → α → α
  add_assoc : ∀ a b c : α, add (add a b) c = add a (add b c)
  add_comm  : ∀ a b : α, add a b = add b a
  add_self  : ∀ a : α, add a a = zero
  add_zero  : ∀ a : α, add a zero = a

open XORSpace

theorem zero_add [XORSpace α] (a : α) : add zero a = a := by
  rw [add_comm zero a]
  exact add_zero a

theorem add_cancel_right [XORSpace α] (a b : α) : add (add a b) b = a := by
  rw [add_assoc a b b]
  rw [add_self b]
  exact add_zero a

theorem add_cancel_left [XORSpace α] (a b : α) : add a (add a b) = b := by
  rw [← add_assoc a a b]
  rw [add_self a]
  exact zero_add b

instance : XORSpace Bool where
  zero      := false
  add       := bne
  add_assoc := by intro a b c; cases a <;> cases b <;> cases c <;> rfl
  add_comm  := by intro a b; cases a <;> cases b <;> rfl
  add_self  := by intro a; cases a <;> rfl
  add_zero  := by intro a; cases a <;> rfl

instance [XORSpace α] [XORSpace β] : XORSpace (α × β) where
  zero      := (zero, zero)
  add x y   := (add x.1 y.1, add x.2 y.2)
  add_assoc := by intro a b c; cases a; cases b; cases c; simp only [add_assoc]
  add_comm  := by intro a b; cases a; cases b; simp only [add_comm]
  add_self  := by intro a; cases a; simp only [add_self]
  add_zero  := by intro a; cases a; simp only [add_zero]

theorem ppa12_cut_through_zero_nak_syndrome
    [XORSpace M] [XORSpace C] [XORSpace E]
    (crc : M → C) (fec : M → C → E)
    (h_crc_lin : ∀ x y : M, crc (add x y) = add (crc x) (crc y))
    (h_fec_lin : ∀ (m dm : M) (c dc : C),
      fec (add m dm) (add c dc) = add (fec m c) (fec dm dc))
    (m dm : M) (c : C) (e : E)
    (h_valid_crc : crc m = c)
    (h_valid_fec : fec m c = e) :
    let m' := add m dm
    let dc := crc dm
    let de := fec dm dc
    let c' := add c dc
    let e' := add e de
    (add (crc m') c' = zero) ∧ (add (fec m' c') e' = zero) := by
  constructor
  · show add (crc (add m dm)) (add c (crc dm)) = zero
    rw [h_crc_lin m dm, h_valid_crc]
    exact add_self (add c (crc dm))
  · show add (fec (add m dm) (add c (crc dm))) (add e (fec dm (crc dm))) = zero
    rw [h_fec_lin m dm c (crc dm), h_valid_fec]
    exact add_self (add e (fec dm (crc dm)))

theorem ppa12_prefix_independence
    [XORSpace H] [XORSpace T] [XORSpace C]
    (crc_head : H → C) (crc_tail : T → C)
    (h_tail_lin : ∀ t1 t2 : T, crc_tail (add t1 t2) = add (crc_tail t1) (crc_tail t2))
    (m_head : H) (m_tail delta_tail : T) :
    add (crc_head (add m_head zero)) (crc_tail (add m_tail delta_tail)) =
    add (add (crc_head m_head) (crc_tail m_tail)) (crc_tail delta_tail) := by
  rw [add_zero m_head, h_tail_lin m_tail delta_tail]
  rw [add_assoc (crc_head m_head) (crc_tail m_tail) (crc_tail delta_tail)]

theorem ppa12_lopt_subflit_zero_syndrome
    [XORSpace S0] [XORSpace S1] [XORSpace C0] [XORSpace C1]
    (crc0 : S0 → C0) (crc1 : S1 → C1)
    (h_lin0 : ∀ a b : S0, crc0 (add a b) = add (crc0 a) (crc0 b))
    (h_lin1 : ∀ a b : S1, crc1 (add a b) = add (crc1 a) (crc1 b))
    (s0 ds0 : S0) (s1 ds1 : S1) (c0 : C0) (c1 : C1)
    (hv0 : crc0 s0 = c0) (hv1 : crc1 s1 = c1) :
    (add (crc0 (add s0 ds0)) (add c0 (crc0 ds0)) = zero) ∧
    (add (crc1 (add s1 ds1)) (add c1 (crc1 ds1)) = zero) := by
  constructor
  · rw [h_lin0 s0 ds0, hv0, add_self]
  · rw [h_lin1 s1 ds1, hv1, add_self]

def ratchetStep (s delta : Nat) : Nat := s + delta

def ratchetFold : Nat → List Nat → Nat
  | s, []      => s
  | s, d :: ds => ratchetFold (ratchetStep s d) ds

theorem ratchetStep_monotone (s delta : Nat) : s ≤ ratchetStep s delta := by
  unfold ratchetStep
  exact Nat.le_add_right s delta

theorem ppa11_antifuse_monotonic_ratchet (updates : List Nat) (s : Nat) :
    s ≤ ratchetFold s updates := by
  induction updates generalizing s with
  | nil =>
    unfold ratchetFold
    exact Nat.le_refl s
  | cons d ds ih =>
    unfold ratchetFold
    have h1 : s ≤ ratchetStep s d := ratchetStep_monotone s d
    have h2 : ratchetStep s d ≤ ratchetFold (ratchetStep s d) ds := ih (ratchetStep s d)
    exact Nat.le_trans h1 h2

theorem ppa6_12_schur_boundary_observability
    [XORSpace InternalState] [XORSpace BoundarySignature]
    (P_I_to_B : InternalState → BoundarySignature)
    (h_lin : ∀ x y : InternalState, P_I_to_B (add x y) = add (P_I_to_B x) (P_I_to_B y))
    (h_schur_pnr_nullspace_free : ∀ d : InternalState, P_I_to_B d = zero → d = zero)
    (x y : InternalState)
    (h_same_boundary_measurement : P_I_to_B x = P_I_to_B y) :
    x = y := by
  have h_diff_zero : P_I_to_B (add x y) = zero := by
    rw [h_lin x y, h_same_boundary_measurement]
    exact add_self (P_I_to_B y)
  have h_xy_zero : add x y = zero := h_schur_pnr_nullspace_free (add x y) h_diff_zero
  calc x
    _ = add x zero        := (add_zero x).symm
    _ = add x (add y y)   := by rw [add_self y]
    _ = add (add x y) y   := (add_assoc x y y).symm
    _ = add zero y        := by rw [h_xy_zero]
    _ = y                 := zero_add y

def gf256Mul (a b : UInt8) : UInt8 := Id.run do
  let mut p : UInt8 := 0
  let mut aVar : UInt8 := a
  let mut bVar : UInt8 := b
  for _ in [0, 1, 2, 3, 4, 5, 6, 7] do
    if (bVar &&& 1) != 0 then
      p := p ^^^ aVar
    let hi := (aVar &&& 0x80) != 0
    aVar := aVar <<< 1
    if hi then
      aVar := aVar ^^^ 0x1D
    bVar := bVar >>> 1
  return p

def gf256CrcStep (reg byte : UInt8) : UInt8 :=
  gf256Mul (reg ^^^ byte) 0x07

def gf256CrcList (bytes : List UInt8) : UInt8 :=
  bytes.foldl gf256CrcStep 0

def xorLists (xs ys : List UInt8) : List UInt8 :=
  List.zipWith (· ^^^ ·) xs ys

#eval
  let payload : List UInt8 := [0x12, 0x34, 0x56, 0x78, 0x9A, 0xBC, 0xDE, 0xF0]
  let mask    : List UInt8 := [0x00, 0x00, 0x00, 0x00, 0xFF, 0xA5, 0x5A, 0x0F]
  let origCrc := gf256CrcList payload
  let diffCrc := gf256CrcList mask
  let modCrc  := gf256CrcList (xorLists payload mask)
  let rxSyndrome := modCrc ^^^ (origCrc ^^^ diffCrc)
  s!"[BUILD-1 LEAN 4 KERNEL CHECK] OrigCRC={origCrc}, DiffCRC={diffCrc}, ModCRC={modCrc}, ReceiverSyndrome={rxSyndrome} (Expected: 0)"

end SpectralCore