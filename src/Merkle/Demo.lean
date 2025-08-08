import Merkle.Verify

/-! Executable demo to showcase Merkle verification examples from Verify.lean. -/
namespace Merkle

open IO

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

end Merkle
