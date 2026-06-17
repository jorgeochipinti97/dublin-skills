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
| `memory/` | Pre-seeded shared team memories | `<project>/.claude/team-memory/` |
| `hooks/settings.json` | Hook wiring (no LLM tokens at runtime) | `<project>/.claude/settings.json` (merged) |
| `hooks/change-safety-guard.sh` | Bash PreToolUse guard — blocks destructive ops | `<project>/.claude/hooks/` |
| `hooks/session-context-loader.sh` | SessionStart hook — hard-rules banner + team-memory + SESSION.md every session, warns if engram is missing | `<project>/.claude/hooks/` |
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
