# Team Templates — copy-paste-ready

Todos estos archivos van al **repo del usuario**, NO a este repo de skills.

## 1. CONTRIBUTING.md (root del repo)

```markdown
# Contributing

Bienvenido. Este documento describe cómo trabajamos en git en este repo.

## TL;DR

- Toda branch sale de `main`. Naming: `feat/`, `fix/`, `chore/`, `docs/` + kebab-case.
- Vida máxima de branch: 7 días. Si excede, partir o rebasear contra `main`.
- Commits siguen [Conventional Commits](https://www.conventionalcommits.org/). El `commit-msg` hook lo enforce.
- PR ≤ 400 LOC. Si excede, partir.
- PR necesita mín. 1 review approved + CI verde.
- `--no-verify` está PROHIBIDO. Si un hook falla, fixeá la causa.
- Force push a `main` o branches compartidas: NUNCA.
- Default merge: **squash**. Rebase merge si los commits son cohesivos.

## Setup local

\`\`\`bash
bun install                              # instala deps + husky
git config commit.template .gitmessage   # template de commit
\`\`\`

## Branch flow

\`\`\`bash
git checkout main
git pull --ff-only
git checkout -b feat/descripcion-corta

# laburás, commiteás (los hooks corren solos)

git push -u origin feat/descripcion-corta
gh pr create
\`\`\`

## Commit message

\`\`\`
<type>(<scope>): <subject>

<body opcional>

<footer opcional>
\`\`\`

Types: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, `revert`.

Subject: imperativo presente, ≤ 72 caracteres, sin punto final, minúscula inicial.

Ejemplos:

- `feat(auth): add Google OAuth login`
- `fix(checkout): prevent double charge on retry`
- `chore(deps): bump next to 15.2`

NO valen: `fix`, `wip`, `update`, `changes`, `asdf`. El hook los rechaza.

## PR checklist

Antes de marcar PR como "Ready for review":

- [ ] Self-review: leí mi propio diff línea por línea
- [ ] Tests local pasan
- [ ] Lint pasa
- [ ] CI verde
- [ ] PR description: Why / What / How to test / Risk
- [ ] Sin `console.log`, `debugger`, código comentado, TODOs sin ticket
- [ ] Si toca prod data: rollback plan en la PR

## Conflict resolution

\`\`\`bash
git fetch origin
git rebase origin/main
# resolvés conflicts manualmente
git add <archivos>
git rebase --continue
git push --force-with-lease origin feat/x   # solo si la branch es solo tuya
\`\`\`

NUNCA `git push --force` sin `--with-lease`. NUNCA force push a `main` o branches compartidas.

## Si algo sale mal

1. STOP — no encadenes más comandos git
2. `git status`, `git log --oneline -10`, `git stash list`, `git reflog`
3. Pedí ayuda al canal #git del equipo

`git reflog` recupera commits "perdidos" hasta 90 días atrás. No te asustes.

## Code review SLA

- PR normal: review en < 24h
- PR > 400 LOC: < 48h
- Hotfix urgente: < 1h en horario laboral

## Releases

[describir flujo del proyecto: tag manual, semantic-release, release-please, etc.]
```

## 2. .github/PULL_REQUEST_TEMPLATE.md

```markdown
## Why

<!-- 1-3 oraciones: qué problema resuelve esto, por qué AHORA. Linkear ticket / incident / hilo si aplica. -->

## What

<!-- Bullet list de cambios. Escribí PARA EL REVIEWER. -->

-
-

## How to test

1.
2.

## Risk

- [ ] Low — UI / docs / tests / refactor sin cambio de comportamiento
- [ ] Medium — feature nueva, cambio de API, dependencia mayor
- [ ] High — toca prod data, migración, auth, pagos. Requiere `change-safety`.

## Screenshots / GIF

<!-- Si toca UI: antes / después. -->

## Checklist

- [ ] Conventional Commits respetado
- [ ] Tests agregados o explico por qué no aplica
- [ ] Docs actualizadas si cambia API pública / config
- [ ] No hay `console.log` / `debugger` / código comentado
- [ ] Probé en mobile (si toca UI)
- [ ] Si toca prod: corrí `change-safety` y adjunto rollback plan

## Closes

<!-- Closes #123 -->
```

## 3. .github/CODEOWNERS

```
# Default — todo cambio necesita review del lead
*                       @lead-dev

# Backend
/apps/api/              @backend-team
/packages/db/           @backend-team

# Frontend
/apps/web/              @frontend-team
/packages/ui/           @frontend-team

# Infra
/infra/                 @devops
/.github/workflows/     @devops

# Áreas sensibles — review obligatorio de senior
/apps/api/src/auth/     @lead-dev @security
/apps/api/src/payments/ @lead-dev @payments-team
/scripts/migrate/       @lead-dev
```

## 4. .gitmessage

```
# <type>(<scope>): <subject>           (≤ 72 caracteres)
# │       │             │
# │       │             └─⫸ qué hace en imperativo presente
# │       └─⫸ área (auth/api/checkout/ui/db/...) — opcional
# └─⫸ feat / fix / docs / refactor / perf / test / chore / build / ci / revert
#
# <body>                                 (opcional, blank line antes)
# Por qué del cambio. Contexto. Tradeoffs. NO repetir el qué.
#
# <footer>                               (opcional)
# BREAKING CHANGE: descripción
# Closes #123
# Refs #456
# Co-Authored-By: Nombre <email>
```

Activar:

```bash
git config commit.template .gitmessage   # por proyecto
# o
git config --global commit.template ~/.gitmessage
```

## 5. commitlint.config.js

```js
module.exports = {
  extends: ['@commitlint/config-conventional'],
  rules: {
    'subject-case': [2, 'never', ['upper-case', 'pascal-case']],
    'subject-empty': [2, 'never'],
    'subject-full-stop': [2, 'never', '.'],
    'header-max-length': [2, 'always', 72],
    'body-max-line-length': [2, 'always', 100],
    'type-enum': [
      2,
      'always',
      ['feat', 'fix', 'docs', 'style', 'refactor', 'perf', 'test', 'build', 'ci', 'chore', 'revert'],
    ],
    'scope-enum': [
      1,
      'always',
      // ajustar al proyecto:
      // ['auth', 'api', 'checkout', 'ui', 'db', 'infra', 'docs']
    ],
  },
};
```

Install:

```bash
bun add -D @commitlint/cli @commitlint/config-conventional
```

## 6. Husky setup

Install:

```bash
bun add -D husky
bunx husky init
```

`.husky/pre-commit`:

```bash
#!/usr/bin/env sh
. "$(dirname -- "$0")/_/husky.sh"

bunx --no -- lint-staged
```

`.husky/commit-msg`:

```bash
#!/usr/bin/env sh
. "$(dirname -- "$0")/_/husky.sh"

bunx --no -- commitlint --edit ${1}
```

`.husky/pre-push` (opcional, costo: tests local antes de push):

```bash
#!/usr/bin/env sh
. "$(dirname -- "$0")/_/husky.sh"

bun run typecheck && bun run test --run
```

`package.json`:

```json
{
  "scripts": {
    "prepare": "husky"
  },
  "lint-staged": {
    "*.{ts,tsx,js,jsx}": ["eslint --fix", "prettier --write"],
    "*.{json,md,yml,yaml}": ["prettier --write"]
  }
}
```

Install lint-staged:

```bash
bun add -D lint-staged
```

## 7. Branch protection — `gh api` script

`scripts/setup-branch-protection.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

REPO="${1:-}"  # ejemplo: "miorg/mirepo"
if [ -z "$REPO" ]; then
  echo "Usage: $0 <owner/repo>"
  exit 1
fi

gh api -X PUT "repos/$REPO/branches/main/protection" \
  -F required_status_checks.strict=true \
  -F 'required_status_checks.contexts[]=ci/typecheck' \
  -F 'required_status_checks.contexts[]=ci/test' \
  -F 'required_status_checks.contexts[]=ci/lint' \
  -F 'required_status_checks.contexts[]=commitlint' \
  -F enforce_admins=true \
  -F required_pull_request_reviews.required_approving_review_count=1 \
  -F required_pull_request_reviews.dismiss_stale_reviews=true \
  -F required_pull_request_reviews.require_code_owner_reviews=true \
  -F required_linear_history=true \
  -F allow_force_pushes=false \
  -F allow_deletions=false \
  -F required_conversation_resolution=true \
  -F restrictions=null

echo "Branch protection on main configured for $REPO"
```

Run:

```bash
chmod +x scripts/setup-branch-protection.sh
./scripts/setup-branch-protection.sh miorg/mirepo
```

Repo settings UI también permite: Settings → Branches → Add rule → ver `branch-strategy.md` para checklist completo.

## 8. .github/workflows/ci.yml mínimo

```yaml
name: CI

on:
  pull_request:
    branches: [main]
  push:
    branches: [main]

jobs:
  lint:
    name: ci/lint
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: oven-sh/setup-bun@v2
      - run: bun install --frozen-lockfile
      - run: bun run lint

  typecheck:
    name: ci/typecheck
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: oven-sh/setup-bun@v2
      - run: bun install --frozen-lockfile
      - run: bun run typecheck

  test:
    name: ci/test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: oven-sh/setup-bun@v2
      - run: bun install --frozen-lockfile
      - run: bun run test --run

  commitlint:
    name: commitlint
    runs-on: ubuntu-latest
    if: github.event_name == 'pull_request'
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      - uses: oven-sh/setup-bun@v2
      - run: bun install --frozen-lockfile
      - run: bunx commitlint --from origin/${{ github.base_ref }} --to HEAD --verbose
```

## 9. .github/workflows/pr-size.yml (opcional pero útil)

Avisa en PRs > 1000 LOC:

```yaml
name: PR Size

on:
  pull_request:

jobs:
  size:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: codelytv/pr-size-labeler@v1
        with:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          xs_label: 'size/xs'
          xs_max_size: '50'
          s_label: 'size/s'
          s_max_size: '200'
          m_label: 'size/m'
          m_max_size: '400'
          l_label: 'size/l'
          l_max_size: '1000'
          xl_label: 'size/xl'
          fail_if_xl: 'true'
          message_if_xl: 'Esta PR supera 1000 LOC. Considerá partirla — Frankenstein PRs son difíciles de revisar y propensas a bugs.'
```
