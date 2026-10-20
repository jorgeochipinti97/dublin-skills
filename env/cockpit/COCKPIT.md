<!-- DUBLIN-COCKPIT:START -->
<!-- Cockpit instructions — installed by `ds daily`. Lives OUTSIDE the team-rules managed block; re-running `ds daily` replaces only what's between these COCKPIT markers. -->

# Cockpit — daily driver de __USER__

Este directorio **no es un proyecto cliente**. Es el **centro de control / daily
driver**. Se vive acá todos los días. El trabajo del agente es dos cosas:
**partir tareas** y **dar el daily** de todos los proyectos.

## "task:" / "tarea:" — partir trabajo en accionables
Cuando se diga `task: <algo>` o `tarea: <algo>`:
1. Si es chico y claro → una línea en `## Backlog` de `TASKS.md`.
2. Si es grande/ambiguo → **partilo en sub-tareas accionables** (verbo + objeto,
   cada una hacible de una sentada) en `## Backlog`. Ordená por:
   **deadline → desbloquea a otras → impacto → esfuerzo**. Mostrá el orden.
3. Si dice "para mí" / "mía" / "personal" → va a `TASKS.__USER__.local.md` (gitignored).
4. Si la tarea es de un proyecto concreto ("en <proj>: …") → escribila en el
   `TASKS.md` **de ese proyecto** (en `__PROJECTS_ROOT__/<proj>/`), no acá. Acá
   solo lo global/personal y lo que no tiene proyecto todavía.

## "daily" / "standup" / "qué tengo hoy" / "resumen" — rollup de TODO
El rollup lo arma un script, no vos: `STATUS.md` se regenera solo al abrir la
sesión (hook) y llega inyectado en el contexto. Si piden el daily más tarde,
corré `ds status` y leé `STATUS.md`.
1. Resumilo **más activo/reciente primero**, un bloque corto por proyecto:
   **En progreso · Próximo · Blockers**. Quotá lo que dice `STATUS.md`, no
   inventes progreso. Los parados y los sin SESSION.md, en una línea cada uno.
2. Si hace falta más detalle de un proyecto, recién ahí leé su `SESSION.md`.
3. Cerrá con las **tareas del cockpit** (`TASKS.md` + `TASKS.__USER__.local.md`):
   qué está en `## Doing`, qué hay arriba del backlog.

## Reglas del cockpit
- **On demand only** — fuera de `STATUS.md`, no leas SESSION/TASKS de otros
  proyectos salvo que se nombre uno.
- **Cero inventos** — si no está en el archivo, no lo afirmes (ya es hard rule).
- **Marcar hecho** — "marcá <x> como hecho [en <proj>]" → mover la línea a `## Done`.
- El `SESSION.md` de acá es la bitácora del **cockpit mismo** (qué se tocó del
  entorno/daily/proyectos), no de un cliente.

<!-- DUBLIN-COCKPIT:END -->
