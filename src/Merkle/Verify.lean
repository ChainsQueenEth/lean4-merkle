import Merkle.Core
/-! Executable Merkle verifier (toy), byte-style labels with domain separation. -/
namespace Merkle

abbrev Byte := UInt8
abbrev Label := List Byte            -- simple byte-like label
open Dir

/-- Domain tags for left/right to avoid ambiguity in encoding. -/
def tagLeft : Byte := (0 : UInt8)
def tagRight : Byte := (1 : UInt8)

/-- Tagged concatenation as a toy "hash". In practice, replace with SHA/Keccak/Poseidon. -/
def hashConcat (tag : Byte) (xs ys : Label) : Label := tag :: (xs ++ ys)

def hashLeft (sib acc : Label) : Label := hashConcat tagLeft sib acc
def hashRight (acc sib : Label) : Label := hashConcat tagRight acc sib

/-- Fold a path starting from the leaf to compute a candidate root. -/
def fold (leaf : Label) (p : Path Label) : Label :=
  p.foldl (init := leaf) (fun acc (e : Dir × Label) =>
    match e with
    | (Dir.left, sib)  => hashRight sib acc
    | (Dir.right, sib) => hashRight acc sib)

/-- Verify a leaf against a root with a given path. -/
def verify (root leaf : Label) (p : Path Label) : Bool :=
  decide (fold leaf p = root)

/-! # Demo
Small executable example with byte-like leaves.
-/

def b (n : Nat) : Byte := UInt8.ofNat n

def demoLeaf : Label := [b 5]
def demoPath : Path Label := [(Dir.left, [b 7]), (Dir.right, [b 3])]
def demoRoot : Label := fold demoLeaf demoPath

-- Expect: `true` (run via `lake build merkle-demo` or `lake exe merkle-demo`)

/-- Negative case: tweak a sibling so the path is invalid for `demoRoot`. Expect: `false`. -/
def demoPathBad : Path Label := [(Dir.left, [b 8]), (Dir.right, [b 3])]

/-! # Mini Tree Demo (realistic shape)
Leaves L0..L3 (byte labels), internal nodes with domain-tagged hashing.
Parent(left,right) = hashRight left right
Path for L2 to Root: [(Dir.right, L3), (Dir.left, N01)]
-/

-- Leaves
def L0 : Label := [b 10]
def L1 : Label := [b 11]
def L2 : Label := [b 12]
def L3 : Label := [b 13]

-- Internal nodes
def N01 : Label := hashRight L0 L1
def N23 : Label := hashRight L2 L3
def RootR : Label := hashRight N01 N23

-- Membership path for L2 up to RootR
def pathL2 : Path Label := [(Dir.right, L3), (Dir.left, N01)]

-- Expect: `true` (run via `merkle-demo`)

-- Negative: flip a leaf value; path no longer valid
def L2bad : Label := [b 14]
-- Expect: `false` (run via `merkle-demo`)

end Merkle
