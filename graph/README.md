# Sembl V4.3 Graph Foundation

This directory is the regenerated first-run output after the hard reset.

The artifacts are produced from `sembl_docs/**` and enforce the V4.3 flow:

```text
Docs -> Concept Graph -> UI Graph -> Normalized Graph -> Task Graph -> Execution Packets
```

This run does not scaffold application code. Application work must start from
`task_graph.json` and the scoped packets in `task-packets/`.

## Canonical Rules

- `sembl_docs/v_4.3.md` is the methodology authority.
- All other docs under `sembl_docs/**` are canonical peers.
- Peer-doc conflicts are resolved by domain ownership, not a fixed hierarchy.
- The persisted normalized graph uses only the six node types and six edge types
  defined by System Design and DB Schema.
- Future changes must mutate docs/specs or graph state first, then regenerate the
  affected task graph slice before implementation.
