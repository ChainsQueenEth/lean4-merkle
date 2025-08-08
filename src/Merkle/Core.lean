/-! Core shared types for the Merkle example. -/
namespace Merkle

/-- Direction in a Merkle path. -/
inductive Dir | left | right deriving DecidableEq, Repr

/-- A Merkle path is a list of (direction × sibling label), generic in the label type. -/
abbrev Path (Label : Type) := List (Dir × Label)

end Merkle
