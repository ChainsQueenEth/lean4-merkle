# Core (types and helpers)

Purpose: foundational types used by both the Spec (model) and Verify (implementation).

- Dir: direction of a Merkle step (Left | Right)
- Path: a list of steps; each step carries a direction and the sibling hash
- Hash: placeholder over Nat in this toy model (swap for real hash later)

## Flowchart
```mermaid
flowchart LR
  Dir[Dir: Left or Right]
  Step[Step: Dir + siblingHash]
  Path[Path: List of Steps]
  Hash[Hash placeholder]

  Dir --> Step
  Step --> Path
  Path --> Hash
```

## Minimal example
- Path encoding a proof of two steps: Right with sibling 3, then Left with sibling 1:
  - [(Right, 3), (Left, 1)]

## Blockchain mapping
- Path is the inclusion proof: sibling nodes plus their orientation.
- Dir corresponds to whether the current hash goes left or right when combining.
- Hash is a stand-in for Keccak/SHA/Poseidon in production.

## Notes
- Use domain separation or tags for Left/Right when hashing in real systems.
- Replace Nat hashes with bytes and a standard/circuit-friendly hash.
