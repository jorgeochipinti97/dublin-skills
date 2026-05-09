# git-workflow — Activation Prompts

## Triggers automáticos (el agente lo invoca solo)

- "armame el git workflow para este proyecto"
- "tengo un equipo nuevo, qué configuramos en git"
- "commit convention", "Conventional Commits", "commitlint"
- "branch strategy", "GitHub Flow", "trunk based"
- "PR template", "pull request template", "CONTRIBUTING.md"
- "merge conflict", "se me rompió el rebase", "force push catastrófico"
- "husky", "pre-commit hook", "commit-msg hook"
- "branch protection", "CODEOWNERS"

## Casos de uso

### 1. Setup completo en repo nuevo con equipo

> *"Tengo un repo nuevo y vienen 3 devs nuevos. Necesito el flujo de git seteado: convention, hooks, PR template, branch protection."*

Genera: `CONTRIBUTING.md`, `.github/PULL_REQUEST_TEMPLATE.md`, `CODEOWNERS`, `.gitmessage`, `.husky/`, `commitlint.config.js`, `.github/workflows/ci.yml`, script de branch protection.

### 2. Onboarding de nuevo dev

> *"Entró Lucía al equipo, qué le paso para que entienda el flujo?"*

Apunta a `CONTRIBUTING.md` del repo + sesión de 30 min explicando branch flow + commit conventions + cómo hacer PR.

### 3. Auditoría de repo existente sin convención

> *"Llevamos 6 meses y los commits son un desastre. Cómo arrancamos a poner orden sin romper la historia?"*

- NO reescribe historia
- Marca línea: "Convención desde commit X"
- Agrega `commitlint` que solo enforcea desde HEAD en adelante
- Agrega `CONTRIBUTING.md`, PR template, branch protection
- NO toca commits viejos

### 4. PR Frankenstein detectado

> *"Tengo una PR con 1500 líneas que mezcla refactor, feature y bump de deps. Cómo la parto?"*

Estrategia de partir:
1. Refactor PR primero (sin cambio funcional)
2. Feature PR encima
3. Style/format PR separado
4. Deps bump separado

### 5. Conflict hell

> *"Hice rebase y se rompió todo, perdí commits"*

Recovery por `git reflog` (90 días back). Identificar SHA perdido, rescue branch.

### 6. Garbage Commit endémico

> *"El equipo escribe `fix`, `wip`, `update` como mensajes. Cómo paro esto?"*

Instalar `commitlint` con hook `commit-msg`. El hook rechaza commits inválidos local. CI bloquea merge si los commits del PR no son válidos.

### 7. History Bomb (alguien hizo force push compartido)

> *"Mati hizo force push a `develop` y perdimos commits de 4 personas"*

1. Recovery por `git reflog` de cada dev
2. Branch protection en `develop` para que NUNCA pase de nuevo
3. Postmortem (delegar a `change-safety` para template)

### 8. Stacked PRs

> *"Tengo una feature grande que dividí en 4 PRs encadenadas, cómo manejo las dependencias?"*

Estrategia stacked: cada PR base contra la anterior, rebase en cascada al mergear.

## Pareja con

- `github-safety` — defensivo (qué NO hacer en git)
- `change-safety` — pre-write a prod (cuando la PR toca prod data)
- `testing-strategy` — el `pre-push` hook puede correr tests
- `claude-md-keeper` — actualizar CLAUDE.md del repo del usuario con el flow

## Eficiencia de tokens

Lo central de este skill: **cero tokens runtime**. Todo el enforcement vive en:
- Hooks locales (commitlint, husky)
- GitHub branch protection (server-side)
- `CONTRIBUTING.md` (lo lee el humano)

El LLM solo entra cuando piden ayuda con setup o un caso específico.
