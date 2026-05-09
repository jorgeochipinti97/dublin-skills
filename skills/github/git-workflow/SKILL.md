---
name: git-workflow
description: Constructive Git/GitHub team workflow — Conventional Commits, PR conventions, branch strategy, conflict resolution, rebase rules. Auto-invokes on signals like "git setup", "team workflow", "commit convention", "PR template", "branch strategy", "merge conflict", "husky", "commitlint", "CONTRIBUTING.md". Pairs with github-safety (defensive). Produces enforcement that runs LOCAL via git hooks (zero LLM tokens at runtime).
---

# Git Workflow (Team)

Pareja de `github-safety` (defensivo: qué NUNCA hacer). Este skill es **constructivo**: cómo trabaja BIEN un equipo en git, con enforcement automático que **no consume tokens del LLM** porque corre en hooks locales.

## Filosofía — quién enforce qué

| Capa | Enforcement | Costo en tokens |
|---|---|---|
| `pre-commit`, `commit-msg`, `pre-push` (husky) | Local, automático | 0 |
| Branch protection rules + required checks | GitHub server | 0 |
| `CONTRIBUTING.md`, PR template | El humano lee | 0 |
| Skill `git-workflow` (este) | LLM on-demand cuando piden ayuda | bajo |
| Agente recordando reglas en cada interacción | LLM proactivo | alto — EVITAR |

Mandato: **lo que pueda enforcear un hook, lo enforce un hook.** El LLM solo entra cuando el equipo lo invoca para guía o setup.

## 4 AI Tells — patrones a matar

| Nombre | Definición | Fix |
|---|---|---|
| **Garbage Commit** | Mensaje tipo `fix`, `wip`, `asdf`, `update`, `changes` | Conventional Commits + commitlint en `commit-msg` hook |
| **Frankenstein PR** | PR > 400 LOC, sin descripción, mezcla refactor + feature + fix | Tope LOC, PR template obligatorio, squash policy |
| **Eternal Branch** | Branch que vive > 7 días, lejos de main, conflicts garantizados | Branch naming + vida máx + integration daily |
| **History Bomb** | `git push --force` sobre branch compartida, pierde commits de otros | Branch protection: prohibir force push a main + a branches con PR abierto |

## No-negociables

1. **Nadie pushea a `main` directo.** Branch protection lo bloquea.
2. **PR ≤ 400 LOC** (cambios netos). Hard limit 1000. Si excede, partir.
3. **Commits siguen Conventional Commits** o `commit-msg` hook los rechaza.
4. **Branches viven ≤ 7 días.** Si excede, rebase con `main` (rama propia, no pusheada o pusheada solo por vos) o partir el alcance.
5. **`--no-verify` PROHIBIDO.** Si un hook falla, fixeá la causa.
6. **Force push solo a tu branch personal nunca pusheada con otros.** A main / shared branches: NUNCA.
7. **PR mergeado con squash** (default) o rebase. Sin merge commits para feature → main.

## Cuándo invocar este skill

- Setup inicial de repo: *"armame el git workflow para este proyecto"*
- Onboarding de equipo: *"tengo 3 devs nuevos, qué leen?"*
- Conflicto en marcha: *"se me rebotó el rebase"*, *"mergeo o squash?"*
- Auditoría: *"cómo está nuestro flujo, qué arreglamos?"*

NO invocar para una operación git puntual (un commit, un push) — para eso es `github-safety` o git directo.

## Output que produce

Cuando lo invocás en un proyecto, generás (los archivos van al repo del usuario, NO a este repo de skills):

1. **`CONTRIBUTING.md`** — flujo del equipo en lenguaje humano (lee la persona, no el LLM)
2. **`.github/PULL_REQUEST_TEMPLATE.md`** — Why / What / How to test / Risk / Screenshots
3. **`.husky/`** — `pre-commit` (lint+format), `commit-msg` (commitlint), `pre-push` (typecheck/test opcional)
4. **`commitlint.config.js`** — Conventional Commits, scopes del proyecto
5. **`.gitmessage`** — template para `git config commit.template`
6. **`CODEOWNERS`** (si aplica) — review automático por área
7. **Branch protection rules** — instrucciones para configurar en GitHub UI o `gh api` script
8. **`.github/workflows/ci.yml`** mínimo (si no existe) — typecheck + test + lint en PR

Todos los templates están en `references/team-templates.md`, copy-paste-ready.

## Decision tree por situación

| Situación del repo | Acción |
|---|---|
| Repo nuevo, equipo > 1 | Generar TODOS los entregables (1-8) |
| Repo nuevo, solista | `CONTRIBUTING.md` + commitlint + branch protection. Husky opcional |
| Repo viejo sin convención | Generar 1-7. CI (8) si ya tienen tests. Anunciar en commit "convención desde acá" |
| Repo con convención propia | Auditar contra estos no-negociables. Reportar gaps. NO sobreescribir |
| Solo onboarding (templates ya existen) | Apuntar al `CONTRIBUTING.md` + explicar branch flow |

## References (lee on-demand)

- `references/branch-strategy.md` — GitHub Flow, naming, vida máx, integration patterns, **Eternal Branch**
- `references/commit-conventions.md` — Conventional Commits completo, commitlint config, `.gitmessage`, **Garbage Commit** GOOD/BAD
- `references/pr-conventions.md` — tope LOC, template, squash policy, review checklist, **Frankenstein PR**
- `references/conflict-and-rebase.md` — pull --rebase, rebase local OK / shared NO, recovery de force push, **History Bomb**
- `references/team-templates.md` — todos los archivos copy-paste (CONTRIBUTING, PR template, husky, commitlint, .gitmessage, CODEOWNERS, branch protection)

## Pareja con otros skills

- **`github-safety`** — defensivo (qué NO hacer). Si el dolor es "estuvieron por hacer un destructivo", invocar github-safety.
- **`change-safety`** — pre-write a prod. Si la PR toca prod, invocar change-safety en paralelo.
- **`testing-strategy`** — el `pre-push` hook puede correr tests. testing-strategy define cuáles.
- **`tdd-workflow`** — convención de commits encaja con red/green/refactor (`test:` → `feat:` → `refactor:`).

## Output standards

- Conciso — los entregables son archivos, no prosa larga del LLM
- Templates copy-paste-ready, sin placeholders sin marcar
- Si algo es opcional o depende del contexto del usuario, marcarlo con `# OPTIONAL` en el archivo
- Reportar al final qué archivos quedaron en el proyecto + qué rules configurar manualmente en GitHub UI
