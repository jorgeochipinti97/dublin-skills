# PR Conventions

## Tope de tamaño — 400 LOC neto

| Tamaño | Política |
|---|---|
| ≤ 200 LOC | Ideal. Review en < 30 min. |
| 200–400 LOC | OK. Review en 1h. |
| 400–1000 LOC | Warning. Necesita justificación en la descripción. |
| > 1000 LOC | **Frankenstein PR.** Hard limit. Rechazar y partir. |

LOC = líneas agregadas + modificadas. Excluye:
- Archivos generados (`pnpm-lock.yaml`, `bun.lock`, snapshots, builds, migraciones auto)
- Renames puros sin cambio
- Dependencias bumpeadas en bulk

`gh pr diff <n> --stat` te da el conteo real.

## Frankenstein PR — qué es y por qué duele

> PR > 1000 LOC, sin descripción, mezcla refactor + feature + fix + style + dependency bump. "Por las dudas mergeale, ya lo testeé local."

**Por qué duele:**
- Code review se vuelve teatro — nadie lee 1500 líneas a fondo
- Bugs se cuelan porque la atención se diluye
- Si rompe en prod, el `git revert` rompe 4 features no relacionadas
- `git bisect` se vuelve inútil (cada commit del PR cambia 200 archivos)

**Cómo partir:**
1. **Refactor primero** (PR #1, sin cambio funcional, mergea solo)
2. **Feature** (PR #2, encima del refactor)
3. **Style/format** (PR #3, separado, autoaprobable)
4. **Deps bump** (PR #4, separado)

Cada uno es review-able en su propia mesa.

## PR template (`.github/PULL_REQUEST_TEMPLATE.md`)

```markdown
## Why

<!-- 1-3 oraciones: qué problema resuelve esto, por qué AHORA. Linkear ticket / incident / hilo si aplica. -->

## What

<!-- Bullet list de cambios. Escribí PARA EL REVIEWER, no para vos. -->

-
-

## How to test

<!-- Pasos reproducibles. Comandos, URLs, credentials de staging si aplica. -->

1.
2.

## Risk

<!-- Marcar uno -->

- [ ] Low — UI / docs / tests / refactor sin cambio de comportamiento
- [ ] Medium — feature nueva, cambio de API, dependencia mayor
- [ ] High — toca prod data, migración, auth, pagos. Requiere `change-safety`.

## Screenshots / GIF

<!-- Si toca UI: antes / después. Si es API: payload sample. -->

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

## Squash policy

Default: **squash** al mergear. Genera 1 commit en `main` por PR.

Ventajas:
- `main` linear, fácil de leer
- Cada commit en `main` = 1 cambio reviewable y revertible
- Commits feos del feature branch desaparecen

Cuándo usar **rebase merge** (no squash):
- PR con commits que vale la pena conservar individualmente (ej: refactor + feature + tests, cada uno cohesivo)
- Hotfix donde querés trazabilidad granular

Cuándo usar **merge commit** (no recomendado):
- Casi nunca en feature → main
- OK para release branches a main si tu workflow las usa

GitHub repo settings → "Allow merge commits" → desactivado en la mayoría de casos.

## Review checklist (para el reviewer)

Antes de aprobar:

1. **¿Entiendo POR QUÉ se hace este cambio?** Si no → pedir contexto en el "Why"
2. **¿La PR hace UNA cosa?** Si mezcla → pedir partir
3. **¿Hay tests?** Si no → ¿es justificable? (docs, refactor cubierto por tests existentes, etc.)
4. **¿Maneja error / loading / empty / edge cases?** Especialmente en UI / async
5. **¿Hay TODO / FIXME / `console.log` / código comentado?** Bloquear
6. **¿Modifica config sensible (env vars, IAM, DB schema)?** Verificar `change-safety`
7. **¿Toca código que NO está en el "What"?** Pedir explicación o split
8. **¿El commit message squash-able sigue Conventional Commits?**

**Aprobar con comentarios** (≠ "Request changes") cuando:
- Sugerencias menores que el autor puede tomar o no
- Nits de naming, code style sin afectar funcionamiento

**Request changes** cuando:
- Bug detectado
- Falta test crítico
- Contradice la convención del proyecto
- Riesgo de producción no mitigado

## Velocidad de review — SLA del equipo

| Severidad | SLA |
|---|---|
| Hotfix marcado urgente | < 1h en horario laboral |
| PR normal | < 24h |
| PR > 400 LOC | < 48h (más complejo) |
| Draft PR (en construcción) | Sin SLA, no contar |

Si una PR pasa 48h sin review → escalar al lead, no dejar morir.

## Self-review obligatorio antes de pedir review

Antes de marcar PR como "Ready for review", el autor:

1. Lee su propio diff línea por línea (`gh pr view <n>` o GitHub UI)
2. Corre tests local (`bun test` o equivalente)
3. Corre lint (`bun run lint`)
4. Confirma que CI pasa
5. Verifica que la descripción del PR cubre Why / What / How to test / Risk

Si no podés explicarle a un compañero qué hace tu PR en < 2 min → no está listo para review.

## Stacked PRs (cuando partir genera dependencias)

Cuando una PR depende de otra en review:

```
PR #100 (base: main)        — feat/payment-base
  └─ PR #101 (base: #100)   — feat/payment-coupon (depende de #100)
       └─ PR #102 (base: #101) — feat/payment-coupon-ui
```

Reglas:
- Cada PR es reviewable de forma independiente (commits propios)
- Cuando #100 mergea, rebase #101 a main, después #102
- Mencionar dependencia en la descripción: *"Depends on #100"*
- Herramientas: [Graphite](https://graphite.dev), [git-spr](https://github.com/ejoffe/spr)

## CODEOWNERS — review automático

`.github/CODEOWNERS`:

```
# Default
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

# Sensibles
/apps/api/src/auth/     @lead-dev @security
/apps/api/src/payments/ @lead-dev @payments-team
```

GitHub agrega los owners como reviewers automático y bloquea merge sin su aprobación si activaste "Require review from Code Owners".

## Draft PRs — usar más

Mark as draft cuando:
- Querés CI corriendo pero todavía falta laburo
- Querés feedback temprano de approach (no review final)
- Stacked PRs cuyas dependencias todavía están en review

Draft PR no notifica reviewers, no cuenta para el SLA.
