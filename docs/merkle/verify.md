# Verify (executable checker)

Purpose: implement the concrete computation that mirrors the spec.

- hashLeft/hashRight: combine current hash with sibling depending on direction
- fold: iterate steps to compute a root from a leaf value
- verify: fold the path and compare to the provided root

## Flowchart
```mermaid
flowchart LR
  In[Inputs: value, root, path] --> Fold[fold(path, value)]
  Fold --> Out[computedRoot]
  Out -->|==?| Check{computedRoot == root}
  Check -->|true| Valid[return true]
  Check -->|false| Invalid[return false]
```

## Minimal example
- value: 7, root: 123, path: [(R,3),(L,1)]
- computedRoot = fold(path, 7)
- verify(root, value, path) = (computedRoot == 123)

## Blockchain mapping
- This is the client-side/on-chain verifier of a Merkle proof against a known root (e.g., block header). 
- In smart contracts or light clients, this function is typically implemented in Solidity/Rust/etc.; here it’s Lean.

## Notes
- In production, ensure domain separation for left/right when hashing.
- Replace placeholder Nat hash with bytes + Keccak/SHA/Poseidon.
