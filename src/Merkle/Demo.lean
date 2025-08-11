import Merkle.Verify

/-! Executable demo to showcase Merkle verification examples from Verify.lean. -/
namespace Merkle

open IO

/-- Pretty-print a label (list of bytes) like [1, 10, 11]. -/
def labelToString (xs : Label) : String :=
  let parts := xs.map (fun b => toString (UInt8.toNat b))
  "[" ++ String.intercalate ", " parts ++ "]"

/-- Pretty-print direction. -/
def dirToString (d : Dir) : String :=
  match d with
  | Dir.left => "left"
  | Dir.right => "right"

/-- Print each fold step for learning: shows dir, sibling, and new accumulator. -/
def showFoldSteps (title : String) (leaf : Label) (p : Path Label) : IO Unit :=
  let rec go (i : Nat) (acc : Label) (steps : List (Dir × Label)) : IO Unit :=
    match steps with
    | [] => pure ()
    | (d, sib) :: rest =>
      let acc' := match d with
        | Dir.left  => hashRight sib acc
        | Dir.right => hashRight acc sib
      let line := s!"  step {i+1}: dir={dirToString d}, sib={labelToString sib} -> acc={labelToString acc'}"
      (do println line; go (i+1) acc' rest)
  do
    println s!"{title}:"
    println s!"  start leaf = {labelToString leaf}"
    go 0 leaf p

/-- Run the demo cases from Verify.lean and print results. -/
def main : IO Unit := do
  -- Import demo bindings from Verify
  let _ := demoRoot; let _ := demoLeaf; let _ := demoPath; let _ := demoPathBad
  let ok := verify demoRoot demoLeaf demoPath
  let bad := verify demoRoot demoLeaf demoPathBad
  println s!"Demo 1: verify demoRoot demoLeaf demoPath      → {ok} (expect: true)"
  println s!"Demo 2: verify demoRoot demoLeaf demoPathBad   → {bad} (expect: false)"

  -- Mini tree demo
  let _ := L0; let _ := L1; let _ := L2; let _ := L3
  let _ := N01; let _ := N23; let _ := RootR; let _ := pathL2
  let ok2 := verify RootR L2 pathL2
  let bad2 := verify RootR L2bad pathL2
  println ""
  println s!"MiniTree: verify RootR L2 pathL2              → {ok2} (expect: true)"
  println s!"MiniTree: verify RootR L2bad pathL2           → {bad2} (expect: false)"

  -- Verbose step-by-step views
  println ""
  showFoldSteps "Verbose Demo fold (demoLeaf, demoPath)" demoLeaf demoPath
  println ""
  showFoldSteps "Verbose MiniTree fold (L2, pathL2)" L2 pathL2

end Merkle

/-! Top-level entry point required by Lean executables.
Delegates to `Merkle.main` defined above. -/
def main : IO Unit := Merkle.main
