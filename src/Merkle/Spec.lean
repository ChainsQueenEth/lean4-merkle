import Merkle.Core
/-- Abstract Merkle membership model (spec-level). -/
namespace Merkle

/-- Abstract type of node labels. In practice, this could be bytes. -/
abbrev Label := Nat

/-- Abstract hash function placeholder. -/
def hash (a b : Label) : Label := a + 1315423911 * b

open Dir
 
/-- Inductive membership relation: leaf appears under root along a path. -/
inductive Membership : Label → Label → (Merkle.Path Label) → Prop
| refl (x : Label) : Membership x x []
| stepL {root leaf sib : Label} {rest : Merkle.Path Label}
    (h : Membership (hash sib leaf) root rest) :
    Membership leaf root ((Dir.left, sib) :: rest)
| stepR {root leaf sib : Label} {rest : Merkle.Path Label}
    (h : Membership (hash leaf sib) root rest) :
    Membership leaf root ((Dir.right, sib) :: rest)

theorem membership_refl (x : Label) : Membership x x [] := Membership.refl x

end Merkle
