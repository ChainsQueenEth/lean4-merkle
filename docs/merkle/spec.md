# Spec (Membership model)

Purpose: define what it means for a value to be a member of a Merkle tree rooted at `root` via an inductive relation `Membership`.

- Membership root value path: holds when folding the oriented sibling steps yields `root`.
- Declarative (no computation details here).

## Flowchart
```mermaid
flowchart TD
  V[Leaf value]
  S1{Step 1: dir=Right, sib=s1}
  H1[H1 = hashRight(V, s1)]
  S2{Step 2: dir=Left, sib=s2}
  H2[H2 = hashLeft(s2, H1)]
  R[Root]

  V --> S1 --> H1 --> S2 --> H2 --> R
```

## Minimal example
- If applying steps [(R,3),(L,1)] to value 7 yields 123, then `Membership 123 7 [(R,3),(L,1)]`.

## Blockchain mapping
- This matches inclusion proofs vs. a block header's Merkle root.
- Independent of specific hash; captures the logical contract you want from verifiers.

## Notes
- Keeps the spec separate from the implementation so you can prove properties cleanly.
