# Commit Conventions

## Conventional Commits (estándar)

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Anatomía

- **type** — qué tipo de cambio (ver tabla abajo)
- **scope** *(opcional)* — área del codebase (`auth`, `api`, `checkout`, `ui`)
- **subject** — qué hace, en imperativo presente, ≤ 72 caracteres, sin punto final
- **body** *(opcional)* — POR QUÉ del cambio (no el qué — eso ya está en el diff)
- **footer** *(opcional)* — `BREAKING CHANGE:`, `Closes #123`, `Refs #456`, `Co-Authored-By:`

### Types

| Type | Uso | Ejemplo |
|---|---|---|
| `feat` | Feature nueva | `feat(auth): add Google OAuth login` |
| `fix` | Bugfix | `fix(checkout): prevent double charge on retry` |
| `docs` | Solo docs | `docs(readme): add deployment section` |
| `style` | Formato (no cambia comportamiento) | `style: format with prettier` |
| `refactor` | Refactor (no feature, no fix) | `refactor(api): extract user service` |
| `perf` | Mejora de performance | `perf(list): memoize row renderer` |
| `test` | Tests (agregar / corregir) | `test(auth): cover password reset flow` |
| `build` | Build / deps | `build: bump next to 15.2` |
| `ci` | CI / workflows | `ci: add commitlint to PR check` |
| `chore` | Mantenimiento, scripts, etc. | `chore: update .nvmrc to 22` |
| `revert` | Revertir commit | `revert: feat(auth): add Google OAuth login` |

### Breaking changes

```
feat(api): switch to v2 user payload

The user object now returns `displayName` instead of `name`.
Clients consuming /api/users must update their parsing.

BREAKING CHANGE: User.name renamed to User.displayName
Closes #1234
```

El `BREAKING CHANGE:` en footer (o `!` después del type/scope: `feat(api)!:`) lo detecta `semantic-release` para bumpear major.

## Garbage Commit — qué NUNCA pasar

| BAD | GOOD |
|---|---|
| `fix` | `fix(login): handle 401 from token refresh` |
| `wip` | (no commitees WIP a branch compartida — `git stash` o squash al final) |
| `update` | `chore(deps): update tanstack-query to 5.50` |
| `changes` | `refactor(checkout): extract payment validator` |
| `final` | (no existe "final" — ya viene otro commit) |
| `asdf` | (vergüenza) |
| `merge branch main into feat/x` | (rebase en lugar de merge para evitar este commit; o si mergeás, dejá el default de git) |
| `Co-fix bug from yesterday` | `fix(auth): clear session on logout (regression from #345)` |

**Regla:** si el reviewer no entiende el commit sin abrir el diff, el mensaje no sirve.

### Por qué duele Garbage Commit

- `git log` se vuelve inútil para hacer arqueología
- `git bisect` para encontrar regresiones es 5× más lento (no podés deducir qué hace cada commit)
- Imposible armar changelog auto desde commits
- Code review por commits (en lugar de "todo el PR junto") es imposible

## Subject — reglas

- **Imperativo presente:** `add`, `fix`, `remove` — no `added`, `fixed`, `removing`
- **Minúscula inicial:** `feat: add login` (no `feat: Add login`)
- **Sin punto final**
- **≤ 72 caracteres** (`commit-msg` hook lo enforce)
- **Decí qué cambia, no qué tocaste:**
  - BAD: `feat: edit login.ts`
  - GOOD: `feat(auth): redirect to /onboarding after first login`

## Body — cuándo y cómo

Agregar body cuando:
- El cambio NO es obvio del diff
- Hay tradeoff o decisión arquitectónica
- Hay contexto histórico (incidente, ticket, hilo)

Estructura:

```
feat(checkout): cap retry to 3 attempts on 5xx

The previous infinite retry caused duplicate charges when the
gateway returned 502 with side effects. Capping at 3 with
exponential backoff aligns with the gateway's idempotency window.

Refs INC-2341
```

NO escribir body para decir lo que ya dice el subject. Si no hay nada que aportar, dejar vacío.

## Co-authoring

Cuando es trabajo compartido (pair, mob, agente IA):

```
feat(auth): add passkey support

Co-Authored-By: María Soledad Vargas <maria@empresa.com>
Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
```

GitHub atribuye contribución a ambos.

## commitlint — config recomendada

`commitlint.config.js`:

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
      1,  // warn, no error — los scopes evolucionan
      'always',
      // ajustar al proyecto: ['auth', 'api', 'checkout', 'ui', 'db', ...]
    ],
  },
};
```

Hook husky `.husky/commit-msg`:

```bash
#!/usr/bin/env sh
. "$(dirname -- "$0")/_/husky.sh"

bunx --no -- commitlint --edit ${1}
```

## .gitmessage template

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
git config --global commit.template ~/.gitmessage
# O por proyecto, sin --global, con .gitmessage en repo root
```

## Squash en merge — qué pasa con commits feos del feature branch

Si squasheás el PR al mergear (default recomendado), los commits intermedios feos (`wip`, `fix typo`, `address review`) **desaparecen**. El commit final que queda en `main` es el título del PR + summary, vos lo escribís bien.

Por eso podés ser sucio dentro de tu feature branch (mientras esté solo tuya), siempre que el commit final del squash respete Conventional Commits.

**Excepción:** si trabajan dos personas en el mismo branch, los commits del branch deben ser limpios — no podés squashear el de otro sin acordarlo.
