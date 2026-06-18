<!-- DUBLIN-TEAMHUB:START -->
<!-- Team-hub instructions — installed by `ds team-init`. Lives OUTSIDE the team-rules managed block; re-running replaces only what's between these TEAMHUB markers. -->

# Team Hub — coordinación del equipo __TEAM__

Este repo es el **hub de coordinación** del equipo, **no** un proyecto de producto.
Centraliza: roster (`TEAM.md`), repos en común (`REGISTRY.md`), board agregado
(`BOARD.md`, generado) y tasks por integrante (`members/`, generado).

## Verdad distribuida (clave)
- La **fuente de verdad de cada task** es el `TASKS.md` del repo de ESE proyecto, no el board.
- **`BOARD.md` y `members/` son generados** por `ds team-board` — **nunca los edites a mano**.
- "Ver el estado" = el **último `git pull`** de cada repo. **No es tiempo real** (no hay servidor).
  Si alguien se asignó algo y no pusheó, no lo ves. Decilo así, no inventes estado.

## Asignación — tag `@handle`
- Una task se asigna poniéndole `@handle` en el `TASKS.md` del repo:
  `- [ ] [acme] @nahuel add invoice export`.
- Sin tag = sin asignar (la agarra quien pueda). El `handle` es el de `TEAM.md`.
- `ds assign "<texto>" @handle [en <proyecto>]` lo hace por vos en el `TASKS.md` correcto.

## Comandos
- `ds team-add <proyecto> <git-url>` — registrar un repo en común (+ mapear su path local).
- `ds team-board` — regenerar `BOARD.md` + `members/<handle>.md` desde los `TASKS.md` clonados.
- "el board del equipo" / "las tasks de @nahuel" → regenerá con `ds team-board` y leé
  `BOARD.md` / `members/<handle>.md`.

## Reglas del hub
- **On demand** — no precargues los `TASKS.md` de todos los repos; leé cuando se pida.
- **Cero inventos** — si un repo no está clonado/mapeado en `team.local.md`, decilo; no inventes su estado.
- `team.local.md` (paths locales por-máquina) es **gitignored**; nunca lo commitees.
- `.engram/` SÍ se commitea — es la memoria del equipo viajando por git.

<!-- DUBLIN-TEAMHUB:END -->
