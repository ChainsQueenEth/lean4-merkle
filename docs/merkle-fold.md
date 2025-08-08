# Merkle Fold Diagram (Toy)

This diagram shows how `fold` recomputes the root from a leaf along a path.

```mermaid
flowchart LR
  subgraph LeafAndPath
    L[Leaf]
    P1[(Dir.right, L3)]
    P2[(Dir.left, N01)]
  end

  subgraph Hashes
    H1[hashRight L L3]
    H2[hashLeft N01 H1]
  end

  %% Split edges and avoid parentheses in labels (Mermaid parser quirk)
  L -->|apply right L3| H1
  H1 -->|apply left N01| H2
  H2 --> R[Root]

  classDef good fill:#e7f7ee,stroke:#1f8b4c,color:#0b3d2e
  classDef step fill:#eef3fb,stroke:#2b6cb0,color:#1a365d
  class L good
  class P1,P2 step
```

Legend:
- `(Dir.right, s)` applies `hashRight acc s`.
- `(Dir.left, s)` applies `hashLeft s acc`.

In `src/Merkle/Verify.lean`, `fold` implements this process using `foldl` with domain-tagged hashing to avoid ambiguity.
