# Demo (merkle-demo)

Purpose: runnable examples showcasing true/false outcomes without `#eval`.

- Entry: `Merkle.Demo` (executable: `merkle-demo`)
- Uses `Verify.verify` with hardcoded sample cases

## Sequence
```mermaid
sequenceDiagram
  participant User
  participant Demo
  participant Verify
  User->>Demo: lake exe merkle-demo
  Demo->>Verify: run sample 1 (expect true)
  Verify-->>Demo: true
  Demo->>Verify: run sample 2 (expect false)
  Verify-->>Demo: false
  Demo->>Verify: run sample 3 (mini tree)
  Verify-->>Demo: true/false
  Demo-->>User: prints results (one per line)
```

## How to run
```bash
lake build merkle-demo && lake exe merkle-demo
```

Expected output (example):
```
true
false
true
false
```

## Blockchain mapping
- Mirrors how wallets/light clients might locally verify a few proofs against a known root.
- Useful for demos, docs, tutorials; not meant for production deployment by itself.
