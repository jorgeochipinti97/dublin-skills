# sdd-workflow

## Activation Prompts

```
sdd new <change-name>
```

```
sdd ff
```

```
iniciar sdd
```

```
sdd apply
```

```
sdd verify
```

```
sdd archive
```

## Example Use Cases

- Starting a non-trivial feature (plan before coding)
- Refactor touching ≥ 3 files or crossing module boundaries
- Architectural changes
- Migrations
- Any change where the spec matters more than shipping fast

## What it provides

- Triggers (ES / EN) and command list
- Dependency graph: proposal → specs + design → tasks → apply → verify → archive
- Artifact store policy: engram (recommended) / openspec (user-requested files) / none
- Sub-agent launching templates with structured output contract
- Approval gate rules
- Failure modes

## When NOT to use

- Single-file edits
- Quick bug fixes with known cause
- Questions / explanations
- Prototypes

## Pairs With

- `orchestrator` (skill router) — can plan which Dublin skills to use WITHIN each SDD phase
- `testing-strategy` — what to test per SDD phase
- `error-handling` — failure modes during apply
