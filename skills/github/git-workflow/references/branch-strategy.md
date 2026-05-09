# Branch Strategy

## Default: GitHub Flow (equipos chicos / SaaS / web)

```
main ────●────●────●────●────●────●─── (always deployable)
          \        \         /
           feat/x   fix/y───/
```

- `main` siempre deployable
- Toda branch sale de `main`
- PR contra `main`
- Mergea con squash (default) o rebase
- Deploy automático desde `main` (si CI pasa)

**Cuándo NO usar GitHub Flow:**
- Producto con releases versionadas + soporte multi-versión (libraries, frameworks) → considerar Trunk-Based con release branches
- Equipos > 30 devs en mismo repo → Trunk-Based con feature flags

## Naming

```
<type>/<descripcion-kebab-case>
```

| Type | Uso |
|---|---|
| `feat/` | Feature nueva |
| `fix/` | Bugfix |
| `chore/` | Mantenimiento (deps, config, refactor sin cambio funcional) |
| `docs/` | Solo documentación |
| `refactor/` | Refactor con cambio estructural pero mismo comportamiento |
| `perf/` | Mejora de performance |
| `test/` | Solo tests |
| `hotfix/` | Fix urgente a prod (sale de main, vuelve a main) |

Ejemplos:
- `feat/checkout-coupon`
- `fix/login-iphone-safari`
- `chore/upgrade-next-15`
- `hotfix/payment-timeout`

**Anti-patterns:**
- `martin-cambios` (nombre de persona, sin contexto)
- `feature-1` (genérico)
- `working-branch` (no dice nada)
- `main2` (peligroso)

## Vida máxima — 7 días

> **Eternal Branch** = branch que vive > 7 días sin merge ni rebase con main.

**Por qué duele:**
- Conflicts crecen exponencial con el tiempo
- Code review imposible cuando el branch tiene 2 semanas de drift
- El que abrió el branch ya no recuerda el contexto
- Bloquea features dependientes

**Reglas:**
1. Si el alcance no entra en 7 días → partir en sub-branches
2. Si no se puede partir → rebase diario contra `main` (rama propia, no pusheada o solo pusheada por vos)
3. Si la PR está abierta > 5 días sin review → escalar al lead. NO acumular

**Excepción:** branches "long-running" para grandes refactors → usar feature flag y mergear en chunks aislados detrás del flag, no acumular todo en una branch.

## Integration patterns

### Daily integration (recomendado)

Cada dev al final del día:
```bash
git fetch origin
git rebase origin/main   # rama personal, no pusheada con otros
# O si la pushaste compartida:
git merge origin/main
```

Esto reduce conflicts del fin de feature a un goteo diario.

### Stacked PRs (cuando una feature depende de otra en review)

```
main ──● feat/A (PR #100, en review)
            ↓
            feat/B (PR #101, depende de A, base = feat/A)
                ↓
                feat/C (PR #102, depende de B)
```

- PR #101 base contra `feat/A`, no `main`
- Cuando #100 mergea, rebasear #101 contra `main`, lo mismo en cascada
- Herramientas: [Graphite](https://graphite.dev), [Sapling](https://sapling-scm.com), `git-spr`

## Branch protection (configurar en GitHub UI o `gh api`)

Para `main`:

- [x] Require a pull request before merging
- [x] Require approvals: 1 (mín) — 2 si > 5 devs
- [x] Dismiss stale approvals when new commits are pushed
- [x] Require review from Code Owners (si tenés CODEOWNERS)
- [x] Require status checks: `ci/typecheck`, `ci/test`, `ci/lint`, `commitlint`
- [x] Require branches to be up to date before merging
- [x] Require conversation resolution before merging
- [x] Require signed commits (opcional, recomendado en stacks sensibles)
- [x] Require linear history (fuerza squash/rebase, prohibe merge commits)
- [x] **Do not allow bypassing the above** (incluso admins)
- [x] Restrict deletions
- [x] **Block force pushes**

Script `gh api` listo en `team-templates.md`.

## Eternal Branch — cómo detectarlo

```bash
# Branches con > 7 días sin commit
git for-each-ref --sort=-committerdate refs/heads/ \
  --format='%(committerdate:short) %(refname:short)' | \
  awk -v cutoff="$(date -v-7d +%Y-%m-%d)" '$1 < cutoff'
```

Si aparece más de 2-3 ramas en el output, hay deuda acumulándose.

## Cleanup

Después de merge:
```bash
git checkout main
git pull --ff-only
git branch -d feat/x   # local
# Remote se borra solo si activaste "Automatically delete head branches" en GitHub repo settings
```

Cleanup masivo de branches viejas:
```bash
git fetch --prune  # elimina referencias remotas borradas
git branch --merged main | grep -v '^\*' | grep -v 'main' | xargs -r git branch -d
```
