# Session notes — __PROJECT__ (cockpit / daily)

Bitácora del **centro de control mismo** (no de un cliente): qué se tocó del
entorno, del daily, de los proyectos. Caps: ~300 líneas, podá lo viejo.

Last updated: __DATE__

---

## Current state

Cockpit / daily driver. Agrega todos los proyectos en `__PROJECTS_ROOT__/`.
- `task: …` → parte trabajo en accionables (ver CLAUDE.md → Cockpit).
- `daily` → rollup de todos los proyectos (En progreso · Próximo · Blockers).
- Memoria: SessionStart hook carga `team-memory/` + este SESSION.md cada sesión;
  engram MCP para memoria persistente; Stop hook fuerza el upkeep al cerrar.

---

## Log

- __DATE__ — cockpit creado con `ds daily`; full env (skills + dublin-agent +
  hooks + engram), apuntando a `__PROJECTS_ROOT__/`.
