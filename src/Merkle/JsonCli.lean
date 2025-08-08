import Merkle.Verify
import Merkle.Core
import Lean.Data.Json

/-! JSON-driven test harness for Merkle verify.
Accepts a JSON file with an array of cases. Each case:
{
  "root": [UInt8...],
  "leaf": [UInt8...],
  "path": [ {"dir": "left"|"right", "sib": [UInt8...]}, ... ]
}
-/
namespace Merkle

open Lean
open IO
open Dir

/-- JSON staging types for parsing -/
structure JPathElem where
  dir : String
  sib : List Nat
  deriving Repr, Inhabited, FromJson

structure JCase where
  root : List Nat
  leaf : List Nat
  path : List JPathElem
  deriving Repr, Inhabited, FromJson

/-- Convert Nat bytes to UInt8 with bounds checking -/
private def natBytesToU8 (xs : List Nat) : Except String (List UInt8) := do
  xs.foldlM (init := ([] : List UInt8)) fun acc n =>
    if h : n < 256 then
      pure (acc ++ [UInt8.ofNat n])
    else
      .error s!"byte out of range (0..255): {n}"

private def toDir (s : String) : Except String Dir :=
  if s == "left" then pure Dir.left
  else if s == "right" then pure Dir.right
  else .error s!"unknown dir: {s} (expected 'left' or 'right')"

structure Case where
  root : List UInt8
  leaf : List UInt8
  path : Path (List UInt8)
  deriving Repr

private def transCase (j : JCase) : Except String Case := do
  let root ← natBytesToU8 j.root
  let leaf ← natBytesToU8 j.leaf
  let mut p : Path (List UInt8) := []
  for e in j.path do
    let d ← toDir e.dir
    let s ← natBytesToU8 e.sib
    p := p ++ [(d, s)]
  pure { root, leaf, path := p }

private def parseCases (s : String) : Except String (List Case) := do
  match Json.parse s with
  | .error e => .error s!"JSON parse error: {e}"
  | .ok j =>
    match fromJson? (α := List JCase) j with
    | .error e => .error s!"JSON decode error: {e}"
    | .ok js => js.foldlM (init := ([] : List Case)) (fun acc jc => do
        let c ← transCase jc
        pure (acc ++ [c]))

/-- Read JSON file and return cases. -/
private def readCases (path : System.FilePath) : IO (List Case) := do
  let s ← FS.readFile path
  match parseCases s with
  | .error e => throw <| IO.userError e
  | .ok cs => pure cs

/-- Execute verification for a case. -/
private def runCase (idx : Nat) (c : Case) : IO Unit := do
  let ok := verify c.root c.leaf c.path
  println s!"case {idx}: {ok}"

/-- CLI entry point: expects one argument (path to JSON file). -/
def main (args : List String) : IO UInt32 := do
  match args with
  | [fp] =>
      try
        let cases ← readCases fp
        for (i, c) in cases.enum do
          runCase i c
        pure 0
      catch e =>
        eprintln s!"error: {e.toString}"
        pure 1
  | [] =>
      -- Default to sample vectors to make `lake exe merkle-verify-json` work smoothly.
      let fp := "docs/sample-vectors.json"
      try
        let cases ← readCases fp
        for (i, c) in cases.enum do
          runCase i c
        pure 0
      catch e =>
        eprintln s!"error: {e.toString}"
        pure 1
  | _ =>
      eprintln "usage: merkle-verify-json <path/to/vectors.json>"
      pure 2

end Merkle
