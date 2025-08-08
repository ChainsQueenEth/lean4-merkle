import Merkle.Core
/-- Link between spec (Membership) and executable verify. -/
namespace Merkle

abbrev Byte := UInt8
abbrev Label := List Byte
open Dir
abbrev Path := Merkle.Path Label

-- Re-import spec definitions under same namespace (simple duplication for stub).
inductive Membership : Label → Label → Path → Prop
| refl (x : Label) : Membership x x []
| stepL {root leaf sib : Label} {rest : Path}
    (h : Membership (hashLeft sib leaf) root rest) :
    Membership leaf root ((Dir.left, sib) :: rest)
| stepR {root leaf sib : Label} {rest : Path}
    (h : Membership (hashRight leaf sib) root rest) :
    Membership leaf root ((Dir.right, sib) :: rest)

/-- Domain tags and toy hash matching Verify.lean -/
def tagLeft : Byte := (0 : UInt8)
def tagRight : Byte := (1 : UInt8)

def hashConcat (tag : Byte) (xs ys : Label) : Label := tag :: (xs ++ ys)
def hashLeft (sib acc : Label) : Label := hashConcat tagLeft sib acc
def hashRight (acc sib : Label) : Label := hashConcat tagRight acc sib

/-- Executable fold and verify (same as Verify.lean) -/
def fold (leaf : Label) (p : Path) : Label :=
  p.foldl (init := leaf) (fun acc (e : Dir × Label) =>
    match e with
    | (Dir.left, sib)  => hashLeft sib acc
    | (Dir.right, sib) => hashRight acc sib)

def verify (root leaf : Label) (p : Path) : Bool :=
  decide (fold leaf p = root)

/-- For any path, folding from `leaf` produces a root under which `leaf` is a member. -/
theorem membership_fold_self (leaf : Label) (p : Path) :
  Membership leaf (fold leaf p) p := by
  induction p generalizing leaf with
  | nil =>
      -- fold leaf [] = leaf
      simp [fold, Membership.refl]
  | cons hd tl ih =>
      cases hd with
      | mk dir sib =>
        cases dir with
        | left =>
            -- fold leaf ((left, sib)::tl) = fold (hash sib leaf) tl
            -- apply stepL to the IH at the updated accumulator
            simpa [fold] using Membership.stepL (ih (leaf := hashLeft sib leaf))
        | right =>
            -- fold leaf ((right, sib)::tl) = fold (hash leaf sib) tl
            -- apply stepR to the IH at the updated accumulator
            simpa [fold] using Membership.stepR (ih (leaf := hashRight leaf sib))

/-- Folding along a valid membership path yields the root. -/
theorem fold_eq_of_membership
  {root leaf : Label} {p : Path}
  (h : Membership leaf root p) : fold leaf p = root := by
  induction h with
  | refl x =>
      -- fold leaf [] = leaf
      simp [fold]
  | stepL h ih =>
      -- path head is (left, sib): one fold step hashes (sib, acc)
      simpa [fold] using ih
  | stepR h ih =>
      -- path head is (right, sib): one fold step hashes (acc, sib)
      simpa [fold] using ih

/-- Completeness (toy): valid paths pass verify. -/
 theorem completeness
   {root leaf : Label} {p : Path}
   (h : Membership leaf root p) : verify root leaf p = true := by
   -- Reason: by fold_eq_of_membership then simplify decide of a proved equality
   have h' := fold_eq_of_membership (root := root) (leaf := leaf) (p := p) h
   simpa [verify, h']

/-- Soundness (toy): if verify is true, membership holds. -/
 theorem soundness
   {root leaf : Label} {p : Path}
   (h : verify root leaf p = true) : Membership leaf root p := by
   -- Reason: show Membership leaf (fold leaf p) p, then rewrite with equality from `verify`
   have hEq : fold leaf p = root := by
     -- convert decide to Prop
     have : decide (fold leaf p = root) = true := h
     exact of_decide_true this
   -- build membership to the computed fold root, then rewrite
   have hm : Membership leaf (fold leaf p) p := membership_fold_self leaf p
   simpa [hEq] using hm

end Merkle
