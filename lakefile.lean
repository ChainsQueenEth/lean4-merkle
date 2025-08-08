import Lake
open Lake DSL

package «lean4-merkle» where
  -- minimal package config

lean_lib «Merkle» where
  srcDir := "src"
  -- exposes modules under src/

-- mathlib4 dependency pinned to Lean 4.7.0
require mathlib from git
  "https://github.com/leanprover-community/mathlib4" @ "v4.7.0"

-- Executable demo that runs the examples without using `#eval` in the editor
lean_exe «merkle-demo» where
  srcDir := "src"
  root := `Merkle.Demo

-- JSON-driven CLI to verify vectors from a file
lean_exe «merkle-verify-json» where
  srcDir := "src"
  root := `Merkle.JsonCli
