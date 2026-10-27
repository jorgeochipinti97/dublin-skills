# `env/` — Dublin Team Environment

Everything `./install.sh install` installs **on top of** the skills + dublin-agent,
so a new developer is productive after two commands:

```bash
git clone https://github.com/jorgeochipinti97/dublin-skills.git
cd dublin-skills && ./install.sh install
```

## Contents

| Path | What it is | Installed to (Claude Code, project scope) |
|---|---|---|
| `rules/TEAM-RULES.md` | Team working rules (priority over agent defaults) | `<project>/CLAUDE.md` (merged, marker-delimited) |
| `OPERATING-MODEL.md` | Human onboarding doc — roles + flow | `<project>/OPERATING-MODEL.md` |
| `templates/` | Scaffold for `new`: `SESSION.md`, `TASKS.md`, `gitignore` | project root (via `install.sh new`) |
| `cockpit/` | Scaffold for `daily`: `COCKPIT.md` instructions + cockpit `SESSION.md`/`TASKS.md` | project root + instructions file (via `install.sh daily`) |
| `memory/` | Pre-seeded shared team memories | `<project>/.claude/team-memory/` |
| `hooks/settings.json` | Hook wiring (no LLM tokens at runtime) | `<project>/.claude/settings.json` (merged) |
| `hooks/change-safety-guard.sh` | Bash PreToolUse guard — blocks destructive ops | `<project>/.claude/hooks/` |
| `hooks/session-context-loader.sh` | SessionStart hook — hard-rules banner + team-memory + SESSION.md every session, warns if engram is missing | `<project>/.claude/hooks/` |
| `hooks/projects-status.sh` | Daily rollup generator (markdown, no LLM) — used by `ds status` and by the loader in a cockpit | `<project>/.claude/hooks/` |
| `voice/voz.sh` | `ds voz` — tasks by voice (whisper.cpp + Ollama, local), runs from the repo, not installed into projects | — |
| `cerebro/cerebro.sh` | `ds cerebro` — study brains: markdown folder ⇄ NotebookLM (notebooklm-py), runs from the repo, not installed into projects | — |
| `factura/factura.sh` + `factura/factura_pdf.py` | `ds factura` — ARCA electronic invoices (wsfe): emit, PDF with QR, mark paid; logged in `finanzas.md`. Credentials and issuer data live in `~/.config/dublin/arca`, never in the repo | — |
| `panel/panel.ts` + `panel/panel.html` | `ds panel` — local personal panel (projects kanban, calendar, cerebros, MCPs, finances), Bun, no deps, runs from the repo | — |
| `hooks/context-upkeep-nudge.sh` | Stop hook — forces SESSION/TASKS update when source changed but wasn't logged | `<project>/.claude/hooks/` |
| `mcp/mcp.json` | engram persistent-memory MCP server | `<project>/.mcp.json` (merged) |

## Two ways in

- **`./install.sh new <path>`** — scaffold a brand-new project: `git init`,
  drop in `SESSION.md` / `TASKS.md` / `.gitignore` (from `templates/`, with
  `__PROJECT__` / `__DATE__` filled), then install the full environment.
- **`./install.sh install [<path>]`** — layer the environment onto a project that
  already exists.

dublin-skills is the **model/source**: the team installs the environment into
their own working repos and works there, not inside this repo.

## Herramientas personales (`ds panel`, `ds cerebro`, `ds factura`, `ds voz`)

Corren desde este repo y **cada persona usa sus propios datos**. El repo es solo
el código: nada personal se guarda acá adentro (y `.gitignore` lo bloquea por si
acaso). Clonás, actualizás con `git pull`, y tus datos quedan intactos.

### Dónde vive cada cosa (todo fuera del repo)

| Qué | Dónde | Cambiarlo con |
|---|---|---|
| Carpeta de tus proyectos | `~/.config/dublin/projects-root` (se pregunta la 1ª vez) | `$DUBLIN_PROJECTS` |
| Finanzas + facturas | `finanzas.md`, al lado de la carpeta de proyectos | `$DUBLIN_FINANZAS` |
| Estudio / libros / nutrición / mascotas | `estudio.md`, `libros.md`, `nutricion.md`, `mascotas.md`, al lado de `finanzas.md` | `$DUBLIN_ESTUDIO`, `$DUBLIN_LIBROS`, `$DUBLIN_NUTRICION`, `$DUBLIN_MASCOTAS` |
| Cerebros (NotebookLM) | carpeta que elegís, guardada en `~/.config/dublin/cerebros-root` | `$DUBLIN_CEREBROS` |
| Calendarios | `~/.config/dublin/calendars` (permisos 600, se cargan desde el panel) | — |
| Datos de facturación ARCA | `~/.config/dublin/arca` + tu certificado `.crt`/`.key` | — |
| Ficha de cada proyecto | `<proyecto>/FICHA.local.md` (gitignored) | — |
| Preferencias del panel (foco, fijados, alias) | `~/.config/dublin/panel-*` | — |

### Puesta en marcha

1. **`ds` en el PATH** — ver [Global command](../README.md#global-command-recommended).
2. **Panel** — `brew install oven-sh/bun/bun`, después `ds panel` → http://127.0.0.1:4321
   (otro puerto: `PANEL_PORT=5000 ds panel`). Solo escucha en tu máquina.
   Antes, decile dónde están tus proyectos (una vez):
   ```bash
   mkdir -p ~/.config/dublin && echo ~/proyectos > ~/.config/dublin/projects-root
   ```
   Sin eso arranca vacío y guarda `finanzas.md` en tu home. Las secciones vacías
   se llenan a medida que las usás.
3. **NotebookLM (`ds cerebro`)** — con tu propia cuenta de Google:
   ```bash
   brew install jq
   uv tool install "notebooklm-py[browser]"
   notebooklm login --browser chrome      # abre Chrome, iniciás sesión, listo
   ds cerebro new "Mi tema" https://…     # crea carpeta + notebook
   ds cerebro sync                        # baja tarjetas, exámenes y reportes al panel
   ```
   Cada uno ve solo sus notebooks. Si la sesión vence, repetí `notebooklm login`.
4. **Facturas ARCA (`ds factura`)** — opcional, solo monotributo/RI con certificado:
   - Generá el certificado en ARCA y asocialo a **wsfe** (Administrador de Relaciones).
   - Creá `~/.config/dublin/arca` con tus datos (lista completa en la cabecera de
     `factura/factura.sh`):
     ```bash
     ARCA_DIR=~/.arca          # carpeta con tu .crt y .key
     ARCA_CUIT=20123456789
     ARCA_PTOVTA=2             # punto de venta "Web Services"
     ARCA_TIPO=11              # 11 = Factura C, 6 = Factura B
     ARCA_ENV=homo             # probá en homologación; "prod" para facturar de verdad
     ARCA_NOMBRE="APELLIDO NOMBRE"
     ARCA_DOMICILIO="Calle 123 - Localidad, Provincia"
     ```
   - `chmod 600 ~/.config/dublin/arca`. Para el PDF hace falta `uv`.
   - Emitir es **irreversible** (solo se anula con nota de crédito): el comando
     siempre pide confirmación.
5. **Voz (`ds voz`)** — `brew install ollama whisper-cpp ffmpeg` + `ollama pull qwen2.5:1.5b`;
   el script avisa qué falta.

### Antes de commitear un cambio a estas herramientas

Nunca pongas datos reales en el código, en ejemplos ni en capturas: CUIT, montos,
clientes, links de calendario, rutas `/Users/<vos>`. Todo lo personal va en
`~/.config/dublin/` o en los `.md` de datos. Chequeo rápido:

```bash
git diff --cached | grep -iE 'cuit|/Users/|calendar/ical|api_key|token'
```

## engram (persistent memory)

`ds install` wires [engram](https://github.com/Gentleman-Programming/engram) — a
standalone Go binary (SQLite-backed) that gives the agent real cross-session
memory (19 MCP tools: `mem_save`, `mem_search`, `mem_session_start`, …). The
`.mcp.json` config is written/merged automatically; the **binary is
per-machine**, so each developer installs it once:

```bash
brew install gentleman-programming/tap/engram
# or, as a Claude Code plugin:
claude plugin marketplace add Gentleman-Programming/engram && claude plugin install engram
```

The config is harmless until the binary exists. Memory is local per developer by
default; `engram serve` (HTTP API) can later back a shared team memory.

## Notes

- **Non-destructive**: every existing file is backed up (`*.bak.<timestamp>`)
  before being touched. Rules are merged between `DUBLIN-TEAM-RULES` markers, so
  hand edits outside the markers survive a re-install.
- **Tool support**: rules install to `CLAUDE.md` for Claude Code and to
  `AGENTS.md` for OpenCode / Codex / Universal. Hooks (`settings.json` +
  guard script) are Claude Code-specific and are skipped for other tools with a
  notice.
- **Editing the rules**: change `rules/TEAM-RULES.md` here, commit, and have the
  team re-run `./install.sh install --force` to pull the update.
