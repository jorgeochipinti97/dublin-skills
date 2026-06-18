#!/bin/zsh

# Dublin Skills Installer — multi-tool (Claude Code / OpenCode / Codex CLI / Universal)

set -e

# Resolve symlinks to find the real directory
SCRIPT_PATH="$0"
if [[ -L "$SCRIPT_PATH" ]]; then
    SCRIPT_PATH="$(readlink "$SCRIPT_PATH")"
fi
SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_PATH")" && pwd)"
SKILLS_SOURCE="$SCRIPT_DIR/skills"
AGENTS_SOURCE="$SCRIPT_DIR/agents"
ENV_SOURCE="$SCRIPT_DIR/env"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
DIM='\033[2m'
NC='\033[0m'

# Detect language (Spanish if LANG starts with es_, otherwise English)
if [[ "$LANG" == es_* ]]; then
    L_AVAILABLE="Skills disponibles"
    L_INSTALL_ALL="Instalar todas"
    L_EXIT="Salir"
    L_SELECT="Selecciona skills (numeros separados por espacio, 'a' para todas)"
    L_INSTALLING_ALL="Instalando todas las skills..."
    L_INSTALLING_SELECTED="Instalando skills seleccionadas..."
    L_INSTALLING_SPECIFIED="Instalando skills especificadas..."
    L_SKILL_NOT_FOUND="Skill no encontrada"
    L_SOURCE_NOT_FOUND="Directorio fuente no existe"
    L_DIR_NOT_FOUND="Directorio no existe"
    L_TARGET_DIR="Directorio destino"
    L_TARGET_PATH="Path destino"
    L_CREATING_DIR="Creando directorio destino"
    L_DIR_EXISTS="Directorio destino ya existe"
    L_INVALID_NUM="Numero invalido"
    L_DONE="Instalacion completada."
    L_INSTALLED_IN="Skills instaladas en"
    L_EXITING="Saliendo..."
    L_UPDATING="Actualizando skills instaladas..."
    L_NO_SKILLS="No hay skills instaladas para actualizar"
    L_UPDATED="Actualizacion completada."
    L_AGENT_INSTALLING="Instalando dublin-agent en"
    L_AGENT_BACKUP="Backup creado en"
    L_AGENT_DONE="Agente instalado."
    L_AGENT_NOT_FOUND="No se encontro el archivo del agente"
    L_SELECT_TOOL="Para que tool?"
    L_SELECT_SCOPE="Scope?"
    L_TOOL_CLAUDE="Claude Code"
    L_TOOL_OPENCODE="OpenCode (sst.dev)"
    L_TOOL_CODEX="Codex CLI (OpenAI)"
    L_TOOL_UNIVERSAL="Universal (~/.agents/skills/ — las 3 tools lo leen)"
    L_SCOPE_USER="User (global, todas las sesiones)"
    L_SCOPE_PROJECT="Project (solo este directorio)"
    L_INVALID_TOOL="Tool invalida"
    L_INVALID_SCOPE="Scope invalido"
    L_AGENT_NOT_SUPPORTED="Codex CLI no soporta agents (usa AGENTS.md). Saltado."
    L_AGENT_TOOL_PROMPT="Para que tool instalo el agente?"
    L_USAGE="Uso"
    L_TOOL_LABEL="Tool"
    L_SCOPE_LABEL="Scope"
else
    L_AVAILABLE="Available skills"
    L_INSTALL_ALL="Install all"
    L_EXIT="Exit"
    L_SELECT="Select skills (space-separated numbers, 'a' for all)"
    L_INSTALLING_ALL="Installing all skills..."
    L_INSTALLING_SELECTED="Installing selected skills..."
    L_INSTALLING_SPECIFIED="Installing specified skills..."
    L_SKILL_NOT_FOUND="Skill not found"
    L_SOURCE_NOT_FOUND="Source directory not found"
    L_DIR_NOT_FOUND="Directory not found"
    L_TARGET_DIR="Target directory"
    L_TARGET_PATH="Target path"
    L_CREATING_DIR="Creating target directory"
    L_DIR_EXISTS="Target directory already exists"
    L_INVALID_NUM="Invalid number"
    L_DONE="Installation complete."
    L_INSTALLED_IN="Skills installed in"
    L_EXITING="Exiting..."
    L_UPDATING="Updating installed skills..."
    L_NO_SKILLS="No skills installed to update"
    L_UPDATED="Update complete."
    L_AGENT_INSTALLING="Installing dublin-agent into"
    L_AGENT_BACKUP="Backup saved to"
    L_AGENT_DONE="Agent installed."
    L_AGENT_NOT_FOUND="Agent file not found"
    L_SELECT_TOOL="Which tool?"
    L_SELECT_SCOPE="Scope?"
    L_TOOL_CLAUDE="Claude Code"
    L_TOOL_OPENCODE="OpenCode (sst.dev)"
    L_TOOL_CODEX="Codex CLI (OpenAI)"
    L_TOOL_UNIVERSAL="Universal (~/.agents/skills/ — read by all 3 tools)"
    L_SCOPE_USER="User (global, all sessions)"
    L_SCOPE_PROJECT="Project (this directory only)"
    L_INVALID_TOOL="Invalid tool"
    L_INVALID_SCOPE="Invalid scope"
    L_AGENT_NOT_SUPPORTED="Codex CLI does not support agents (uses AGENTS.md). Skipped."
    L_AGENT_TOOL_PROMPT="Install agent for which tool?"
    L_USAGE="Usage"
    L_TOOL_LABEL="Tool"
    L_SCOPE_LABEL="Scope"
fi

print_header() {
    echo "${BLUE}"
    echo "╔═══════════════════════════════════════════╗"
    echo "║       Dublin Skills Installer             ║"
    echo "╚═══════════════════════════════════════════╝"
    echo "${NC}"
}

print_usage() {
    cat <<USAGE
${L_USAGE}:
  ds new <project-path>                 # scaffold a NEW project (git + SESSION/TASKS) + full env
  ds daily <path> [--projects=<dir>]    # scaffold a cockpit / daily driver (task-breakdown + daily rollup)
  ds team-init <path>                   # scaffold the TEAM hub (roster + registry + board + members)
  ds team-add <proyecto> <git-url>      # register a shared repo in the hub (run inside the hub)
  ds team-board [--pull]                # regenerate BOARD.md + members/ (--pull: git pull --ff-only each repo first)
  ds assign "<texto>" @handle [en <proyecto>]  # assign a task to a teammate in the right TASKS.md
  ds install                            # install/upgrade the FULL environment in existing project (asks tool + scope)
  ds install <project-path>             # full environment into a project
  ds install --tool=claude --scope=project # non-interactive
  ds install --force                    # force-refresh rules even if unchanged
  ds doctor <path>                      # check if a project (or folder of projects) is up to date
  (alias: 'ds team' still works — same as 'ds install')
  ds                                    # interactive wizard (skills only)
  ds <project-path>                     # interactive, project scope
  ds <project-path> --all               # all skills, project scope (Claude default)
  ds <project-path> skill1 skill2       # specific skills
  ds --tool=<tool> --scope=<scope> --all
  ds agent                              # install dublin-agent (asks tool)
  ds agent --tool=<tool>                # install dublin-agent for specific tool
  ds update <path>                      # update installed skills
  ds list                               # list available skills

Team environment (ds team) installs: all skills + dublin-agent + team rules
(CLAUDE.md / AGENTS.md) + shared memory + change-safety hook (Claude Code).

Tools:    claude | opencode | codex | universal
Scopes:   user | project

Universal scope writes to ~/.agents/skills/ — read by Claude Code, OpenCode AND Codex CLI.
USAGE
}

# Available skills (relative path from skills/)
typeset -A SKILLS
SKILLS=(
    ai-avatar-director "ugc/ai-avatar-director"
    api-architect "architecture/api-architect"
    auth-architect "security/auth-architect"
    backend-performance "backend/backend-performance"
    bind-api "bind-api"
    blog-writer "content/blog-writer"
    brand-guidelines "brand-guidelines"
    brand-identity "brand-identity"
    change-safety "ops/change-safety"
    claude-md-keeper "meta/claude-md-keeper"
    database-architect "data/database-architect"
    data-viz-architect "data/data-viz-architect"
    domain-modeler "architecture/domain-modeler"
    error-handling "implementation/error-handling"
    forms-and-validation "frontend/forms-and-validation"
    frontend-foundation "frontend/frontend-foundation"
    frontend-output-validator "frontend/frontend-output-validator"
    orchestrator "meta/orchestrator"
    git-workflow "github/git-workflow"
    github-safety "github/github-safety"
    hexagonal-architect "architecture/hexagonal-architect"
    infra-security "infra-security"
    institutional-site-architect "content/institutional-site-architect"
    landing-page-architect "content/landing-page-architect"
    mobile-design "frontend/mobile-design"
    premium-frontend-design "frontend/premium-frontend-design"
    product-tour "frontend/product-tour"
    react-performance "frontend/react-performance"
    product-planner "product/product-planner"
    product-ux-advisor "product/product-ux-advisor"
    remotion-video "media/remotion-video"
    sdd-workflow "methodology/sdd-workflow"
    session-bridge "meta/session-bridge"
    skill-creator "skill-creator"
    systems-thinking "discovery/systems-thinking"
    tdd-workflow "implementation/tdd-workflow"
    testing-strategy "implementation/testing-strategy"
    ugc-post-production "ugc/ugc-post-production"
    ugc-scriptwriter "ugc/ugc-scriptwriter"
    ugc-video-prompting "ugc/ugc-video-prompting"
)

# Resolve skills directory path for a given tool + scope.
#   $1 = tool (claude|opencode|codex|universal)
#   $2 = scope (user|project)
#   $3 = base path (only used when scope=project; cwd by default)
# Echoes the absolute target path for the skills/ directory.
resolve_skills_path() {
    local tool="$1"
    local scope="$2"
    local base="${3:-$PWD}"

    case "$tool" in
        claude)
            if [[ "$scope" == "user" ]]; then
                echo "$HOME/.claude/skills"
            else
                echo "$base/.claude/skills"
            fi
            ;;
        opencode)
            if [[ "$scope" == "user" ]]; then
                echo "$HOME/.config/opencode/skills"
            else
                echo "$base/.opencode/skills"
            fi
            ;;
        codex|universal)
            if [[ "$scope" == "user" ]]; then
                echo "$HOME/.agents/skills"
            else
                echo "$base/.agents/skills"
            fi
            ;;
        *)
            return 1
            ;;
    esac
}

# Resolve agent file path for a given tool + scope.
#   $1 = tool (claude|opencode)  — codex returns empty (not supported)
#   $2 = scope (user|project)
#   $3 = base path (project)
resolve_agent_path() {
    local tool="$1"
    local scope="$2"
    local base="${3:-$PWD}"

    case "$tool" in
        claude)
            if [[ "$scope" == "user" ]]; then
                echo "$HOME/.claude/agents"
            else
                echo "$base/.claude/agents"
            fi
            ;;
        opencode)
            if [[ "$scope" == "user" ]]; then
                echo "$HOME/.config/opencode/agents"
            else
                echo "$base/.opencode/agents"
            fi
            ;;
        codex|universal)
            echo ""
            ;;
        *)
            return 1
            ;;
    esac
}

list_skills() {
    echo "${YELLOW}${L_AVAILABLE}:${NC}"
    echo ""
    local i=1
    for skill in ${(k)SKILLS}; do
        echo "  $i) $skill"
        ((i++))
    done
    echo ""
    echo "  a) $L_INSTALL_ALL"
    echo "  q) $L_EXIT"
    echo ""
}

select_tool_interactive() {
    echo "${YELLOW}${L_SELECT_TOOL}${NC}"
    echo "  1) $L_TOOL_CLAUDE"
    echo "  2) $L_TOOL_OPENCODE"
    echo "  3) $L_TOOL_CODEX"
    echo "  4) $L_TOOL_UNIVERSAL"
    echo ""
    echo -n "[1-4, default 1]: "
    read -r choice
    case "${choice:-1}" in
        1) TOOL="claude" ;;
        2) TOOL="opencode" ;;
        3) TOOL="codex" ;;
        4) TOOL="universal" ;;
        *) echo "${RED}${L_INVALID_TOOL}${NC}"; exit 1 ;;
    esac
    echo ""
}

select_scope_interactive() {
    echo "${YELLOW}${L_SELECT_SCOPE}${NC}"
    echo "  1) $L_SCOPE_USER"
    echo "  2) $L_SCOPE_PROJECT"
    echo ""
    echo -n "[1-2, default 2]: "
    read -r choice
    case "${choice:-2}" in
        1) SCOPE="user" ;;
        2) SCOPE="project" ;;
        *) echo "${RED}${L_INVALID_SCOPE}${NC}"; exit 1 ;;
    esac
    echo ""
}

install_skill() {
    local skill_name=$1
    local target_skills_dir=$2
    local skill_path="${SKILLS[$skill_name]}"

    if [[ -z "$skill_path" ]]; then
        echo "${RED}${L_SKILL_NOT_FOUND}: '$skill_name'${NC}"
        return 1
    fi

    local source_path="$SKILLS_SOURCE/$skill_path"
    local dest_path="$target_skills_dir/$skill_name"

    if [[ ! -d "$source_path" ]]; then
        echo "${RED}${L_SOURCE_NOT_FOUND}: $source_path${NC}"
        return 1
    fi

    mkdir -p "$dest_path"
    rsync -av --exclude='.DS_Store' "$source_path/" "$dest_path/" > /dev/null 2>&1

    echo "${GREEN}  ✓ $skill_name${NC}"
}

install_all() {
    local target_skills_dir=$1
    echo "${BLUE}${L_INSTALLING_ALL}${NC}"
    echo ""
    for skill in ${(k)SKILLS}; do
        install_skill "$skill" "$target_skills_dir"
    done
}

update_skills() {
    local base_path="$1"
    # Heuristic: try to detect existing installations across all known paths.
    local candidates=(
        "$base_path/.claude/skills"
        "$base_path/.opencode/skills"
        "$base_path/.agents/skills"
        "$HOME/.claude/skills"
        "$HOME/.config/opencode/skills"
        "$HOME/.agents/skills"
    )

    local found=0
    for skills_dir in "${candidates[@]}"; do
        [[ -d "$skills_dir" ]] || continue
        local has_skill=0
        for skill_folder in "$skills_dir"/*/; do
            [[ -d "$skill_folder" ]] || continue
            local skill_name=$(basename "$skill_folder")
            if [[ -n "${SKILLS[$skill_name]}" ]]; then
                if [[ $has_skill -eq 0 ]]; then
                    echo "${BLUE}${L_UPDATING} ${DIM}($skills_dir)${NC}"
                    has_skill=1
                fi
                install_skill "$skill_name" "$skills_dir"
                found=1
            fi
        done
        [[ $has_skill -eq 1 ]] && echo ""
    done

    if [[ $found -eq 0 ]]; then
        echo "${RED}${L_NO_SKILLS}${NC}"
        exit 1
    fi

    echo "${GREEN}${L_UPDATED}${NC}"
}

install_agent_for() {
    local tool="$1"
    local scope="${2:-user}"
    local base="${3:-$PWD}"

    if [[ "$tool" == "codex" ]]; then
        echo "${YELLOW}${L_AGENT_NOT_SUPPORTED}${NC}"
        return 0
    fi

    local agent_dest_dir
    agent_dest_dir="$(resolve_agent_path "$tool" "$scope" "$base")" || {
        echo "${RED}${L_INVALID_TOOL}: $tool${NC}"
        return 1
    }

    if [[ -z "$agent_dest_dir" ]]; then
        echo "${YELLOW}${L_AGENT_NOT_SUPPORTED}${NC}"
        return 0
    fi

    local agent_src="$AGENTS_SOURCE/dublin-agent.md"
    local agent_refs_src="$AGENTS_SOURCE/dublin-agent/references"
    local agent_dest="$agent_dest_dir/dublin-agent.md"
    local agent_refs_dest="$agent_dest_dir/dublin-agent/references"

    if [[ ! -f "$agent_src" ]]; then
        echo "${RED}${L_AGENT_NOT_FOUND}: $agent_src${NC}"
        return 1
    fi

    mkdir -p "$agent_dest_dir"

    if [[ -f "$agent_dest" ]]; then
        local backup="$agent_dest.bak.$(date +%Y%m%d-%H%M%S)"
        cp "$agent_dest" "$backup"
        echo "${YELLOW}  ${L_AGENT_BACKUP}: $backup${NC}"
    fi

    echo "${BLUE}${L_AGENT_INSTALLING}: $agent_dest_dir${NC}"
    cp "$agent_src" "$agent_dest"
    echo "${GREEN}  ✓ dublin-agent.md${NC}"

    if [[ -d "$agent_refs_src" ]]; then
        mkdir -p "$agent_refs_dest"
        rsync -av --exclude='.DS_Store' "$agent_refs_src/" "$agent_refs_dest/" > /dev/null 2>&1
        echo "${GREEN}  ✓ dublin-agent/references/${NC}"
    fi
}

select_agent_tool_interactive() {
    echo "${YELLOW}${L_AGENT_TOOL_PROMPT}${NC}"
    echo "  1) $L_TOOL_CLAUDE"
    echo "  2) $L_TOOL_OPENCODE"
    echo "  3) Both (Claude + OpenCode)"
    echo ""
    echo -n "[1-3, default 1]: "
    read -r choice
    case "${choice:-1}" in
        1) AGENT_TOOLS=("claude") ;;
        2) AGENT_TOOLS=("opencode") ;;
        3) AGENT_TOOLS=("claude" "opencode") ;;
        *) echo "${RED}${L_INVALID_TOOL}${NC}"; exit 1 ;;
    esac
    echo ""
}

# --- Team environment ---------------------------------------------------------

# Instructions file (team rules) target for a given tool + scope.
resolve_rules_path() {
    local tool="$1" scope="$2" base="${3:-$PWD}"
    case "$tool" in
        claude)
            [[ "$scope" == "user" ]] && echo "$HOME/.claude/CLAUDE.md" || echo "$base/CLAUDE.md" ;;
        opencode|codex|universal)
            [[ "$scope" == "user" ]] && echo "$HOME/.agents/AGENTS.md" || echo "$base/AGENTS.md" ;;
        *) return 1 ;;
    esac
}

# Base config dir (where .claude / .agents live) for memory + hooks.
resolve_config_dir() {
    local tool="$1" scope="$2" base="${3:-$PWD}"
    case "$tool" in
        claude)
            [[ "$scope" == "user" ]] && echo "$HOME/.claude" || echo "$base/.claude" ;;
        opencode)
            [[ "$scope" == "user" ]] && echo "$HOME/.config/opencode" || echo "$base/.opencode" ;;
        codex|universal)
            [[ "$scope" == "user" ]] && echo "$HOME/.agents" || echo "$base/.agents" ;;
        *) return 1 ;;
    esac
}

backup_file() {
    local f="$1"
    if [[ -f "$f" ]]; then
        local b="$f.bak.$(date +%Y%m%d-%H%M%S)"
        cp "$f" "$b"
        echo "${YELLOW}  ↳ backup: $b${NC}"
    fi
}

# Install team rules into the instructions file, merged between markers.
install_rules() {
    local tool="$1" scope="$2" base="$3"
    local src="$ENV_SOURCE/rules/TEAM-RULES.md"
    local dest
    dest="$(resolve_rules_path "$tool" "$scope" "$base")" || return 1

    [[ -f "$src" ]] || { echo "${RED}  ✗ TEAM-RULES.md not found${NC}"; return 1; }
    mkdir -p "$(dirname "$dest")"

    local START="<!-- DUBLIN-TEAM-RULES:START -->"
    local END="<!-- DUBLIN-TEAM-RULES:END -->"

    if [[ ! -f "$dest" ]]; then
        cp "$src" "$dest"
        echo "${GREEN}  ✓ rules → $dest${NC}"
        return 0
    fi

    # Extract the managed block (markers inclusive) from a file.
    _extract_block() {
        awk -v s="$START" -v e="$END" '$0~s{f=1} f{print} $0~e{f=0}' "$1"
    }

    if grep -qF "$START" "$dest"; then
        # Refresh by default — but only touch the file if the block actually
        # changed (no noise, no needless backups). --force ignores the check.
        if [[ $FORCE_FLAG -eq 0 ]] && diff -q <(_extract_block "$dest") <(_extract_block "$src") >/dev/null 2>&1; then
            echo "${GREEN}  ✓ rules up to date → $dest${NC}"
            return 0
        fi
        backup_file "$dest"
        # Drop the old managed block.
        awk -v s="$START" -v e="$END" '$0~s{skip=1} skip==0{print} $0~e{skip=0}' "$dest" > "$dest.tmp"
        # Strip trailing blank lines, then append the fresh block.
        awk 'NF{p=NR} {a[NR]=$0} END{for(i=1;i<=p;i++) print a[i]}' "$dest.tmp" > "$dest"
        rm -f "$dest.tmp"
        printf '\n\n' >> "$dest"
        cat "$src" >> "$dest"
        echo "${GREEN}  ✓ rules refreshed → $dest${NC}"
    else
        backup_file "$dest"
        printf '\n\n' >> "$dest"
        cat "$src" >> "$dest"
        echo "${GREEN}  ✓ rules appended → $dest${NC}"
    fi
}

# Copy the human-readable docs (operating model + cheatsheet) to the project root.
install_operating_model() {
    local base="$1"
    local f
    for f in OPERATING-MODEL.md CHEATSHEET.md; do
        local src="$ENV_SOURCE/$f"
        local dest="$base/$f"
        [[ -f "$src" ]] || continue
        [[ -f "$dest" ]] && backup_file "$dest"
        cp "$src" "$dest"
        echo "${GREEN}  ✓ $f → $dest${NC}"
    done
}

# Copy pre-seeded shared memories.
install_memory() {
    local tool="$1" scope="$2" base="$3"
    local src="$ENV_SOURCE/memory"
    local cfg
    cfg="$(resolve_config_dir "$tool" "$scope" "$base")" || return 1
    local dest="$cfg/team-memory"

    [[ -d "$src" ]] || { echo "${YELLOW}  • no team-memory to install${NC}"; return 0; }
    mkdir -p "$dest"
    rsync -av --exclude='.DS_Store' "$src/" "$dest/" > /dev/null 2>&1
    echo "${GREEN}  ✓ team-memory → $dest${NC}"
}

# Install change-safety hook + merge settings.json (Claude Code only).
install_hooks() {
    local tool="$1" scope="$2" base="$3"
    if [[ "$tool" != "claude" ]]; then
        echo "${YELLOW}  • hooks are Claude Code-only — skipped for $tool${NC}"
        return 0
    fi
    local cfg
    cfg="$(resolve_config_dir "$tool" "$scope" "$base")" || return 1
    local hooks_dir="$cfg/hooks"
    local guard_src="$ENV_SOURCE/hooks/change-safety-guard.sh"
    local loader_src="$ENV_SOURCE/hooks/session-context-loader.sh"
    local nudge_src="$ENV_SOURCE/hooks/context-upkeep-nudge.sh"
    local settings_src="$ENV_SOURCE/hooks/settings.json"
    local settings_dest="$cfg/settings.json"

    mkdir -p "$hooks_dir"
    cp "$guard_src" "$hooks_dir/change-safety-guard.sh"
    chmod +x "$hooks_dir/change-safety-guard.sh"
    echo "${GREEN}  ✓ change-safety-guard.sh → $hooks_dir${NC}"
    cp "$loader_src" "$hooks_dir/session-context-loader.sh"
    chmod +x "$hooks_dir/session-context-loader.sh"
    echo "${GREEN}  ✓ session-context-loader.sh → $hooks_dir${NC}"
    cp "$nudge_src" "$hooks_dir/context-upkeep-nudge.sh"
    chmod +x "$hooks_dir/context-upkeep-nudge.sh"
    echo "${GREEN}  ✓ context-upkeep-nudge.sh → $hooks_dir${NC}"

    if [[ ! -f "$settings_dest" ]]; then
        cp "$settings_src" "$settings_dest"
        echo "${GREEN}  ✓ settings.json → $settings_dest${NC}"
    elif command -v jq >/dev/null 2>&1; then
        backup_file "$settings_dest"
        jq -s '.[0] * .[1]' "$settings_dest" "$settings_src" > "$settings_dest.tmp" \
            && mv "$settings_dest.tmp" "$settings_dest"
        echo "${GREEN}  ✓ settings.json merged → $settings_dest${NC}"
    else
        echo "${YELLOW}  • settings.json exists and jq is not installed — merge manually:${NC}"
        echo "${DIM}    add the PreToolUse hook from $settings_src${NC}"
    fi
}

# Wire engram (persistent memory) as an MCP server for Claude Code.
# Writes/merges <project>/.mcp.json. The binary itself is per-machine: we detect
# it and print the install command rather than installing it silently.
install_engram() {
    local tool="$1" scope="$2" base="$3"
    local src="$ENV_SOURCE/mcp/mcp.json"

    if [[ "$tool" != "claude" ]]; then
        echo "${YELLOW}  • engram MCP wiring targets Claude Code — configure manually for $tool${NC}"
        return 0
    fi

    local dest="$base/.mcp.json"
    if [[ ! -f "$dest" ]]; then
        cp "$src" "$dest"
        echo "${GREEN}  ✓ engram MCP → $dest${NC}"
    elif command -v jq >/dev/null 2>&1; then
        backup_file "$dest"
        jq -s '.[0] * .[1] | .mcpServers = ((.[0].mcpServers // {}) + (.[1].mcpServers // {}))' \
            "$dest" "$src" 2>/dev/null > "$dest.tmp" \
            && mv "$dest.tmp" "$dest" \
            || { jq -s '.[0].mcpServers.engram = .[1].mcpServers.engram | .[0]' "$dest" "$src" > "$dest.tmp" && mv "$dest.tmp" "$dest"; }
        echo "${GREEN}  ✓ engram MCP merged → $dest${NC}"
    else
        echo "${YELLOW}  • .mcp.json exists and jq is missing — add the engram block from $src manually${NC}"
    fi

    if command -v engram >/dev/null 2>&1; then
        echo "${GREEN}  ✓ engram binary found ($(command -v engram))${NC}"
    else
        echo "${YELLOW}  ! engram binary not installed. Each developer runs once:${NC}"
        echo "${DIM}      brew install gentleman-programming/tap/engram${NC}"
        echo "${DIM}      (or: claude plugin marketplace add Gentleman-Programming/engram && claude plugin install engram)${NC}"
    fi
}

# Remove skill folders no longer in the model (moved to a hidden backup dir,
# which Claude Code ignores since it starts with a dot).
prune_orphan_skills() {
    local skills_dir="$1"
    [[ -d "$skills_dir" ]] || return 0
    for d in "$skills_dir"/*/; do
        [[ -d "$d" ]] || continue
        local name="$(basename "$d")"
        [[ "$name" == .* ]] && continue
        if [[ -z "${SKILLS[$name]}" ]]; then
            local bakdir="$skills_dir/.dublin-orphans"
            mkdir -p "$bakdir"
            mv "$d" "$bakdir/$name-$(date +%Y%m%d-%H%M%S)"
            echo "${YELLOW}  ↳ pruned orphan skill: $name (backup in .dublin-orphans/)${NC}"
        fi
    done
}

# Stamp the install with the model's git SHA so `doctor` can flag stale ones.
write_env_version() {
    local base="$1"
    local sha
    sha="$(git -C "$SCRIPT_DIR" rev-parse --short HEAD 2>/dev/null || echo unknown)"
    printf 'model_sha=%s\ninstalled=%s\n' "$sha" "$(date +%Y-%m-%d)" > "$base/.dublin-env"
}

install_team() {
    local tool="$1" scope="$2" base="$3"

    echo "${BLUE}1/6 Installing all skills…${NC}"
    local skills_dir
    skills_dir="$(resolve_skills_path "$tool" "$scope" "$base")"
    mkdir -p "$skills_dir"
    install_all "$skills_dir"
    prune_orphan_skills "$skills_dir"
    echo ""

    echo "${BLUE}2/6 Installing dublin-agent…${NC}"
    if [[ "$tool" == "universal" ]]; then
        install_agent_for "claude" "$scope" "$base"
        install_agent_for "opencode" "$scope" "$base"
    else
        install_agent_for "$tool" "$scope" "$base"
    fi
    echo ""

    echo "${BLUE}3/6 Installing team rules…${NC}"
    install_rules "$tool" "$scope" "$base"
    install_operating_model "$base"
    echo ""

    echo "${BLUE}4/6 Installing shared memory…${NC}"
    install_memory "$tool" "$scope" "$base"
    echo ""

    echo "${BLUE}5/6 Installing hooks…${NC}"
    install_hooks "$tool" "$scope" "$base"
    echo ""

    echo "${BLUE}6/6 Wiring engram (persistent memory)…${NC}"
    install_engram "$tool" "$scope" "$base"

    write_env_version "$base"
}

# Report whether a project's env matches the current model SHA.
doctor_check_one() {
    local p="$1"
    [[ -f "$p/.dublin-env" ]] || return 1
    local proj_sha cur_sha
    proj_sha="$(grep '^model_sha=' "$p/.dublin-env" | cut -d= -f2)"
    cur_sha="$(git -C "$SCRIPT_DIR" rev-parse --short HEAD 2>/dev/null || echo unknown)"
    if [[ "$proj_sha" == "$cur_sha" ]]; then
        echo "${GREEN}  ✓ up to date ($proj_sha)  —  $(basename "$p")${NC}"
    else
        echo "${YELLOW}  ! outdated: project=$proj_sha  model=$cur_sha  —  $(basename "$p")  (run: ds install \"$p\")${NC}"
    fi
    return 0
}

# `ds doctor [path]` — check one project or scan a folder of projects.
run_doctor() {
    local target="${1:-$PWD}"
    target="$(cd "$target" 2>/dev/null && pwd)" || {
        echo "${RED}${L_DIR_NOT_FOUND}: $1${NC}"; exit 1
    }
    local cur_sha
    cur_sha="$(git -C "$SCRIPT_DIR" rev-parse --short HEAD 2>/dev/null || echo unknown)"
    echo "${BLUE}Dublin env doctor — model @ $cur_sha${NC}"
    echo ""

    # Per-machine check: engram powers persistent memory. If the binary is
    # missing, mem_save/mem_search fail silently — the #1 memory-loss cause.
    if command -v engram >/dev/null 2>&1; then
        echo "${GREEN}  ✓ engram binary found ($(command -v engram)) — persistent memory live${NC}"
    else
        echo "${RED}  🔴 engram NOT installed — persistent memory is DEAD on this machine.${NC}"
        echo "${YELLOW}     mem_save/mem_search silently no-op. Install once:${NC}"
        echo "${DIM}       brew install gentleman-programming/tap/engram${NC}"
    fi
    echo ""

    if doctor_check_one "$target"; then
        return 0
    fi
    local found=0
    for d in "$target"/*/; do
        [[ -d "$d" ]] || continue
        doctor_check_one "${d%/}" && found=1
    done
    [[ $found -eq 0 ]] && echo "${YELLOW}  no Dublin environment found in $target${NC}"
}

# Scaffold a brand-new project with the context structure already in place,
# then layer the full team environment on top.
scaffold_new() {
    local base="$1"
    mkdir -p "$base"
    base="$(cd "$base" && pwd)"
    local project date
    project="$(basename "$base")"
    date="$(date +%Y-%m-%d)"

    echo "${BLUE}Scaffolding new project: ${project}${NC}"

    if [[ ! -d "$base/.git" ]]; then
        (cd "$base" && git init -q) && echo "${GREEN}  ✓ git init${NC}"
    fi

    if [[ ! -f "$base/SESSION.md" ]]; then
        sed -e "s/__PROJECT__/$project/g" -e "s/__DATE__/$date/g" \
            "$ENV_SOURCE/templates/SESSION.md" > "$base/SESSION.md"
        echo "${GREEN}  ✓ SESSION.md${NC}"
    fi

    if [[ ! -f "$base/TASKS.md" ]]; then
        sed -e "s/__PROJECT__/$project/g" \
            "$ENV_SOURCE/templates/TASKS.md" > "$base/TASKS.md"
        echo "${GREEN}  ✓ TASKS.md${NC}"
    fi

    if [[ ! -f "$base/.gitignore" ]]; then
        cp "$ENV_SOURCE/templates/gitignore" "$base/.gitignore"
        echo "${GREEN}  ✓ .gitignore${NC}"
    elif ! grep -q '\*\.local\.md' "$base/.gitignore"; then
        printf '\n# Private personal tasks\n*.local.md\n' >> "$base/.gitignore"
        echo "${GREEN}  ✓ .gitignore (added *.local.md)${NC}"
    fi
    echo ""
}

# Ask which folder the cockpit aggregates (default: the cockpit's parent dir).
# Honors --projects=<path>; only prompts when interactive.
select_projects_root() {
    local cockpit="$1"
    local default_root
    default_root="$(dirname "$cockpit")"
    if [[ -z "$PROJECTS_ROOT" ]]; then
        if [[ -t 0 ]]; then
            printf "${YELLOW}¿En qué carpeta viven los proyectos que el daily va a agregar?${NC} [${default_root}]: "
            local ans; read -r ans
            PROJECTS_ROOT="${ans:-$default_root}"
        else
            PROJECTS_ROOT="$default_root"
        fi
    fi
    PROJECTS_ROOT="${PROJECTS_ROOT/#\~/$HOME}"   # expand a leading ~
}

# Scaffold a cockpit: git init + cockpit-flavored SESSION/TASKS + .gitignore.
scaffold_cockpit() {
    local base="$1" projects_root="$2"
    mkdir -p "$base"; base="$(cd "$base" && pwd)"
    local project date user
    project="$(basename "$base")"
    date="$(date +%Y-%m-%d)"
    user="$(git config user.name 2>/dev/null | awk '{print tolower($1)}')"
    [[ -z "$user" ]] && user="$(whoami)"

    echo "${BLUE}Scaffolding cockpit: ${project}  (agrega: ${projects_root})${NC}"
    [[ -d "$base/.git" ]] || { (cd "$base" && git init -q) && echo "${GREEN}  ✓ git init${NC}"; }

    # sed with '#' delimiter so paths with '/' don't clash.
    local -a sub=(-e "s#__PROJECT__#${project}#g" -e "s#__DATE__#${date}#g" \
                  -e "s#__PROJECTS_ROOT__#${projects_root}#g" -e "s#__USER__#${user}#g")
    if [[ ! -f "$base/SESSION.md" ]]; then
        sed "${sub[@]}" "$ENV_SOURCE/cockpit/SESSION.md" > "$base/SESSION.md"
        echo "${GREEN}  ✓ SESSION.md${NC}"
    fi
    if [[ ! -f "$base/TASKS.md" ]]; then
        sed "${sub[@]}" "$ENV_SOURCE/cockpit/TASKS.md" > "$base/TASKS.md"
        echo "${GREEN}  ✓ TASKS.md${NC}"
    fi
    if [[ ! -f "$base/.gitignore" ]]; then
        cp "$ENV_SOURCE/templates/gitignore" "$base/.gitignore"
        echo "${GREEN}  ✓ .gitignore${NC}"
    fi
    echo ""
}

# Append (or refresh) the cockpit instructions block in the instructions file,
# OUTSIDE the team-rules managed block. Idempotent via COCKPIT markers.
install_cockpit_instructions() {
    local tool="$1" scope="$2" base="$3" projects_root="$4"
    local dest user
    dest="$(resolve_rules_path "$tool" "$scope" "$base")" || return 1
    user="$(git config user.name 2>/dev/null | awk '{print tolower($1)}')"
    [[ -z "$user" ]] && user="$(whoami)"

    local START="<!-- DUBLIN-COCKPIT:START -->"
    local END="<!-- DUBLIN-COCKPIT:END -->"
    local block
    block="$(sed -e "s#__PROJECTS_ROOT__#${projects_root}#g" -e "s#__USER__#${user}#g" \
        "$ENV_SOURCE/cockpit/COCKPIT.md")"

    if [[ -f "$dest" ]] && grep -qF "$START" "$dest"; then
        backup_file "$dest"
        awk -v s="$START" -v e="$END" '$0~s{skip=1} skip==0{print} $0~e{skip=0}' "$dest" > "$dest.tmp"
        mv "$dest.tmp" "$dest"
    fi
    printf '\n%s\n' "$block" >> "$dest"
    echo "${GREEN}  ✓ cockpit instructions → $dest${NC}"
}

# ---- Team hub ---------------------------------------------------------------

# Look up a project's local path from the hub's team.local.md (proyecto=path).
# Builtins only (read/case/printf) — no external command, robust to PATH quirks.
_teamhub_local_path() {
    local hub="$1" proj="$2" line
    [[ -f "$hub/team.local.md" ]] || return 1
    while IFS= read -r line || [[ -n "$line" ]]; do
        case "$line" in
            "${proj}="*) printf '%s\n' "${line#${proj}=}"; return 0 ;;
        esac
    done < "$hub/team.local.md"
    return 1
}

# Scaffold a team-hub: git init + TEAM/REGISTRY/BOARD + members/ + local map.
scaffold_teamhub() {
    local base="$1" team="$2"
    mkdir -p "$base/members"; base="$(cd "$base" && pwd)"
    local date user
    date="$(date +%Y-%m-%d)"
    user="$(git config user.name 2>/dev/null | awk '{print tolower($1)}')"
    [[ -z "$user" ]] && user="$(whoami)"

    echo "${BLUE}Scaffolding team hub: ${team}${NC}"
    [[ -d "$base/.git" ]] || { (cd "$base" && git init -q) && echo "${GREEN}  ✓ git init${NC}"; }

    local -a sub=(-e "s#__TEAM__#${team}#g" -e "s#__DATE__#${date}#g" -e "s#__USER__#${user}#g")
    local f
    for f in TEAM.md REGISTRY.md BOARD.md; do
        [[ -f "$base/$f" ]] && continue
        sed "${sub[@]}" "$ENV_SOURCE/teamhub/$f" > "$base/$f"
        echo "${GREEN}  ✓ $f${NC}"
    done
    [[ -f "$base/.gitignore" ]] || cp "$ENV_SOURCE/teamhub/gitignore" "$base/.gitignore"
    [[ -f "$base/team.local.md" ]] || sed "${sub[@]}" "$ENV_SOURCE/teamhub/team.local.md" > "$base/team.local.md"
    : > "$base/members/.gitkeep"
    echo "${GREEN}  ✓ team.local.md (gitignored) + members/${NC}"
    echo ""
}

# Append (or refresh) the team-hub instructions block, outside the managed block.
install_teamhub_instructions() {
    local tool="$1" scope="$2" base="$3" team="$4"
    local dest
    dest="$(resolve_rules_path "$tool" "$scope" "$base")" || return 1
    local START="<!-- DUBLIN-TEAMHUB:START -->"
    local END="<!-- DUBLIN-TEAMHUB:END -->"
    local block
    block="$(sed -e "s#__TEAM__#${team}#g" "$ENV_SOURCE/teamhub/TEAMHUB.md")"
    if [[ -f "$dest" ]] && grep -qF "$START" "$dest"; then
        backup_file "$dest"
        awk -v s="$START" -v e="$END" '$0~s{skip=1} skip==0{print} $0~e{skip=0}' "$dest" > "$dest.tmp"
        mv "$dest.tmp" "$dest"
    fi
    printf '\n%s\n' "$block" >> "$dest"
    echo "${GREEN}  ✓ team-hub instructions → $dest${NC}"
}

# `ds team-add <proyecto> <git-url>` — register a shared repo + map its local path.
run_team_add() {
    local proj="$1" url="$2" hub="$PWD"
    [[ -f "$hub/REGISTRY.md" ]] || { echo "${RED}No es un team-hub (falta REGISTRY.md). Entrá al hub o corré 'ds team-init'.${NC}"; exit 1; }
    [[ -n "$proj" && -n "$url" ]] || { echo "${RED}Usage: ds team-add <proyecto> <git-url>${NC}"; exit 1; }

    if grep -qE "^\| *${proj} " "$hub/REGISTRY.md"; then
        echo "${YELLOW}  • '${proj}' ya está en el REGISTRY.${NC}"
    else
        printf '| %s | %s | activo |\n' "$proj" "$url" >> "$hub/REGISTRY.md"
        echo "${GREEN}  ✓ ${proj} → REGISTRY.md${NC}"
    fi

    local def ans; def="$(dirname "$hub")/$proj"
    if [[ -z "$PROJECTS_ROOT" && -t 0 ]]; then
        printf "${YELLOW}Path local de '${proj}' en esta máquina${NC} [${def}]: "
        read -r ans
    fi
    [[ -n "$PROJECTS_ROOT" ]] && ans="$PROJECTS_ROOT/$proj"
    ans="${ans:-$def}"; ans="${ans/#\~/$HOME}"
    if grep -qE "^${proj}=" "$hub/team.local.md" 2>/dev/null; then
        echo "${DIM}  (ya mapeado en team.local.md)${NC}"
    else
        printf '%s=%s\n' "$proj" "$ans" >> "$hub/team.local.md"
        echo "${GREEN}  ✓ ${proj} → ${ans}  (team.local.md, local)${NC}"
    fi
}

# `ds team-board` — regenerate BOARD.md + members/<handle>.md from each TASKS.md.
# Pure zsh builtins (read/case/printf/expansion) — no awk/mktemp/grep/sed, so it
# works regardless of PATH/coreutils quirks.
run_team_board() {
    setopt local_options extended_glob
    local hub="$PWD"
    [[ -f "$hub/REGISTRY.md" ]] || { echo "${RED}No es un team-hub (falta REGISTRY.md).${NC}"; exit 1; }
    local date; date="$(date +%Y-%m-%d)"
    local TAB=$'\t'
    local -a rows projects
    local line name rest path bucket p

    # 1. Project names = column 1 of the REGISTRY table (skip header + separator).
    while IFS= read -r line || [[ -n "$line" ]]; do
        [[ "$line" == '|'* ]] || continue
        rest="${line#|}"; name="${rest%%|*}"; name="${name// /}"
        [[ -z "$name" || "$name" == "proyecto" || "$name" == -* ]] && continue
        projects+=("$name")
    done < "$hub/REGISTRY.md"

    # 2. Collect actionable task lines (Doing/Backlog) as "bucket<TAB>proj<TAB>line".
    local missing=""
    for p in "${projects[@]}"; do
        path="$(_teamhub_local_path "$hub" "$p")"
        if [[ -z "$path" || ! -f "$path/TASKS.md" ]]; then
            missing+="  - ${p} (sin mapear/clonar o sin TASKS.md)"$'\n'
            continue
        fi
        # --pull: traer lo último (ff-only, nunca pisa trabajo local) antes de agregar.
        if [[ $PULL_FLAG -eq 1 ]]; then
            if git -C "$path" pull --ff-only >/dev/null 2>&1; then
                echo "${DIM}  ↳ ${p}: pulled${NC}"
            else
                echo "${YELLOW}  ↳ ${p}: pull saltado (sin upstream, sucio, o no fast-forward)${NC}"
            fi
        fi
        bucket=""
        while IFS= read -r line || [[ -n "$line" ]]; do
            case "$line" in
                '## '*) bucket="${line#\#\# }"; bucket="${bucket%% }" ;;
                *'- ['*) [[ "$bucket" == "Doing" || "$bucket" == "Backlog" ]] && rows+=("${bucket}${TAB}${p}${TAB}${line}") ;;
            esac
        done < "$path/TASKS.md"
    done

    # 3. BOARD.md
    local bk r rb rrest rp rl
    {
        echo "# Board del equipo"
        echo ""
        echo "> Generado por \`ds team-board\` el ${date}. NO editar a mano."
        echo "> Refleja el último \`git pull\` de cada repo clonado (no es tiempo real)."
        echo ""
        for bk in Doing Backlog; do
            echo "## ${bk}"
            for r in "${rows[@]}"; do
                rb="${r%%$TAB*}"; rrest="${r#*$TAB}"; rp="${rrest%%$TAB*}"; rl="${rrest#*$TAB}"
                [[ "$rb" == "$bk" ]] && printf '%s  · %s\n' "$rl" "$rp"
            done
            echo ""
        done
        if [[ -n "$missing" ]]; then
            echo "## Repos no visibles (no clonados/mapeados en esta máquina)"
            printf '%s' "$missing"
            echo ""
        fi
    } > "$hub/BOARD.md"
    echo "${GREEN}  ✓ BOARD.md regenerado${NC}"

    # 4. members/<handle>.md — collect handles (@token in any task line).
    [[ -d "$hub/members" ]] || mkdir -p "$hub/members"
    local mf; for mf in "$hub/members"/*.md(N); do rm -f "$mf"; done
    local -A handles
    local w
    for r in "${rows[@]}"; do
        rl="${r##*$TAB}"
        for w in ${(z)rl}; do
            case "$w" in @[A-Za-z0-9_-]##) handles[${w#@}]=1 ;; esac
        done
    done
    local h wrote
    for h in "${(k)handles[@]}"; do
        {
            echo "# Tasks de @${h}  (generado por ds team-board, ${date})"
            echo ""
            for bk in Doing Backlog; do
                wrote=0
                for r in "${rows[@]}"; do
                    rb="${r%%$TAB*}"; rrest="${r#*$TAB}"; rp="${rrest%%$TAB*}"; rl="${rrest#*$TAB}"
                    [[ "$rb" == "$bk" && "$rl" == *"@${h}"* ]] || continue
                    [[ $wrote -eq 0 ]] && { echo "## ${bk}"; wrote=1; }
                    printf '%s  · %s\n' "$rl" "$rp"
                done
                [[ $wrote -eq 1 ]] && echo ""
            done
        } > "$hub/members/${h}.md"
        echo "${GREEN}  ✓ members/${h}.md${NC}"
    done
    : > "$hub/members/.gitkeep"
}

# `ds assign "<texto>" @handle [en <proyecto>]` — tag a task in the right TASKS.md.
run_assign() {
    local text="$1" handle="$2" kw="${3:-}" proj4="${4:-}"
    [[ -n "$text" && -n "$handle" ]] || { echo "${RED}Usage: ds assign \"<texto>\" @handle [en <proyecto>]${NC}"; exit 1; }
    [[ "$handle" == @* ]] || handle="@${handle}"

    setopt local_options extended_glob
    local proj="" tasks="" path
    [[ "$kw" == "en" && -n "$proj4" ]] && proj="$proj4"
    if [[ -n "$proj" ]]; then
        path="$(_teamhub_local_path "$PWD" "$proj")"
        [[ -n "$path" && -f "$path/TASKS.md" ]] || { echo "${RED}No encuentro el TASKS.md de '${proj}' (¿mapeado en team.local.md y clonado?).${NC}"; exit 1; }
        tasks="$path/TASKS.md"
    else
        [[ -f "$PWD/TASKS.md" ]] || { echo "${RED}No hay TASKS.md acá. Usá 'en <proyecto>' desde el hub, o entrá al repo.${NC}"; exit 1; }
        tasks="$PWD/TASKS.md"
    fi

    # Find the first incomplete task containing <texto>; (re)tag it with @handle.
    # Read into an array, edit, write back with `print -rl` — zero external commands.
    local -a out
    local line found=0 stripped pre post
    while IFS= read -r line || [[ -n "$line" ]]; do
        if [[ $found -eq 0 && "$line" == *'- [ ]'* && "$line" == *"$text"* ]]; then
            stripped="${line//@[A-Za-z0-9_-]##[ ]/}"     # drop any existing @handle
            pre="${stripped%%- \[ \] *}"
            post="${stripped#*- \[ \] }"
            out+=("${pre}- [ ] ${handle} ${post}")
            found=1
        else
            out+=("$line")
        fi
    done < "$tasks"

    if [[ $found -eq 0 ]]; then
        echo "${RED}No encontré una task pendiente que contenga: \"${text}\"${NC}"; exit 1
    fi
    print -rl -- "${out[@]}" > "$tasks"
    echo "${GREEN}  ✓ '${text}' → ${handle}  en ${tasks}${NC}"
    echo "${DIM}  Regenerá el board desde el hub: ds team-board${NC}"
}

# --- Argument parsing ---------------------------------------------------------

TOOL=""
SCOPE=""
INSTALL_ALL_FLAG=0
FORCE_FLAG=0
PULL_FLAG=0
COMMAND=""
PROJECTS_ROOT=""
POSITIONAL=()
SKILL_NAMES=()

parse_args() {
    local -a args=("$@")
    local i=1
    while [[ $i -le ${#args[@]} ]]; do
        local arg="${args[$i]}"
        case "$arg" in
            --tool=*) TOOL="${arg#--tool=}" ;;
            --scope=*) SCOPE="${arg#--scope=}" ;;
            --projects=*) PROJECTS_ROOT="${arg#--projects=}" ;;
            --all|-a) INSTALL_ALL_FLAG=1 ;;
            --force|-f) FORCE_FLAG=1 ;;
            --pull) PULL_FLAG=1 ;;
            --help|-h) print_usage; exit 0 ;;
            agent|update|list|team|install|new|daily|team-init|team-add|team-board|assign|doctor)
                if [[ -z "$COMMAND" ]]; then
                    COMMAND="$arg"
                else
                    POSITIONAL+=("$arg")
                fi
                ;;
            *) POSITIONAL+=("$arg") ;;
        esac
        ((i++))
    done
}

# Validate provided tool/scope flags.
validate_flags() {
    if [[ -n "$TOOL" ]]; then
        case "$TOOL" in
            claude|opencode|codex|universal) ;;
            *) echo "${RED}${L_INVALID_TOOL}: $TOOL${NC}"; exit 1 ;;
        esac
    fi
    if [[ -n "$SCOPE" ]]; then
        case "$SCOPE" in
            user|project) ;;
            *) echo "${RED}${L_INVALID_SCOPE}: $SCOPE${NC}"; exit 1 ;;
        esac
    fi
}

main() {
    # Strip carriage returns from arguments (common when copy-pasting from Windows/web)
    local -a clean_args=()
    for arg in "$@"; do
        clean_args+=("${arg//$'\r'/}")
    done
    set -- "${clean_args[@]}"

    print_header

    parse_args "$@"
    validate_flags

    # --- Subcommand: list ---
    if [[ "$COMMAND" == "list" ]]; then
        list_skills
        exit 0
    fi

    # --- Subcommand: agent ---
    if [[ "$COMMAND" == "agent" ]]; then
        local -a AGENT_TOOLS
        if [[ -n "$TOOL" ]]; then
            case "$TOOL" in
                claude|opencode) AGENT_TOOLS=("$TOOL") ;;
                codex)
                    echo "${YELLOW}${L_AGENT_NOT_SUPPORTED}${NC}"
                    exit 0
                    ;;
                universal) AGENT_TOOLS=("claude" "opencode") ;;
            esac
        else
            select_agent_tool_interactive
        fi
        for t in "${AGENT_TOOLS[@]}"; do
            install_agent_for "$t" "user"
        done
        echo ""
        echo "${GREEN}${L_AGENT_DONE}${NC}"
        exit 0
    fi

    # --- Subcommand: update ---
    if [[ "$COMMAND" == "update" ]]; then
        local target_dir="${POSITIONAL[1]:-$PWD}"
        target_dir="$(cd "$target_dir" 2>/dev/null && pwd)" || {
            echo "${RED}${L_DIR_NOT_FOUND}: ${POSITIONAL[1]}${NC}"
            exit 1
        }
        update_skills "$target_dir"
        exit 0
    fi

    # --- Subcommand: doctor (check install freshness) ---
    if [[ "$COMMAND" == "doctor" ]]; then
        run_doctor "${POSITIONAL[1]:-$PWD}"
        exit 0
    fi

    # --- Subcommand: new (scaffold a fresh project + full environment) ---
    if [[ "$COMMAND" == "new" ]]; then
        if [[ ${#POSITIONAL[@]} -lt 1 ]]; then
            echo "${RED}Usage: ds new <name>   (creates ./<name> here, like 'nest new')${NC}"
            exit 1
        fi
        local new_path="${POSITIONAL[1]}"
        # Bare name → create in the current directory (like `nest new <name>`).
        [[ "$new_path" != /* ]] && new_path="$PWD/$new_path"

        # Fail fast (before asking anything) if we can't create here.
        local new_parent
        new_parent="$(dirname "$new_path")"
        if [[ ! -d "$new_path" && ! -w "$new_parent" ]]; then
            echo "${RED}Can't create '$(basename "$new_path")' here — '$new_parent' is read-only.${NC}"
            echo "${YELLOW}Move into a folder of yours first, then run it again:${NC}"
            echo "${DIM}  cd ~/Desktop/main/proyectos${NC}"
            echo "${DIM}  ds new $(basename "$new_path")${NC}"
            exit 1
        fi

        [[ -z "$TOOL" ]] && select_tool_interactive
        [[ -z "$SCOPE" ]] && SCOPE="project"

        scaffold_new "$new_path"
        local new_base
        new_base="$(cd "$new_path" && pwd)"
        install_team "$TOOL" "$SCOPE" "$new_base"
        echo ""
        echo "${GREEN}✓ New project scaffolded with the Dublin operating model: $new_base${NC}"
        exit 0
    fi

    # --- Subcommand: daily (scaffold a cockpit / daily driver + full env) ---
    if [[ "$COMMAND" == "daily" ]]; then
        if [[ ${#POSITIONAL[@]} -lt 1 ]]; then
            echo "${RED}Usage: ds daily <path> [--projects=<dir>]   (your daily cockpit)${NC}"
            exit 1
        fi
        local cp_path="${POSITIONAL[1]}"
        [[ "$cp_path" != /* ]] && cp_path="$PWD/$cp_path"

        local cp_parent
        cp_parent="$(dirname "$cp_path")"
        if [[ ! -d "$cp_path" && ! -w "$cp_parent" ]]; then
            echo "${RED}Can't create '$(basename "$cp_path")' here — '$cp_parent' is read-only.${NC}"
            exit 1
        fi

        [[ -z "$TOOL" ]] && select_tool_interactive
        [[ -z "$SCOPE" ]] && SCOPE="project"
        select_projects_root "$cp_path"

        scaffold_cockpit "$cp_path" "$PROJECTS_ROOT"
        local cp_base
        cp_base="$(cd "$cp_path" && pwd)"
        install_team "$TOOL" "$SCOPE" "$cp_base"
        echo ""
        echo "${BLUE}Installing cockpit instructions…${NC}"
        install_cockpit_instructions "$TOOL" "$SCOPE" "$cp_base" "$PROJECTS_ROOT"
        echo ""
        echo "${GREEN}✓ Cockpit ready: $cp_base${NC}"
        echo "${DIM}  Abrí tu agente acá y decí 'daily' o 'task: <algo>'.${NC}"
        exit 0
    fi

    # --- Subcommand: team-init (scaffold the team coordination hub) ---
    if [[ "$COMMAND" == "team-init" ]]; then
        if [[ ${#POSITIONAL[@]} -lt 1 ]]; then
            echo "${RED}Usage: ds team-init <path>   (the team coordination hub)${NC}"
            exit 1
        fi
        local th_path="${POSITIONAL[1]}"
        [[ "$th_path" != /* ]] && th_path="$PWD/$th_path"
        local th_parent; th_parent="$(dirname "$th_path")"
        if [[ ! -d "$th_path" && ! -w "$th_parent" ]]; then
            echo "${RED}Can't create '$(basename "$th_path")' here — '$th_parent' is read-only.${NC}"
            exit 1
        fi
        [[ -z "$TOOL" ]] && select_tool_interactive
        [[ -z "$SCOPE" ]] && SCOPE="project"
        local team; team="$(basename "$th_path")"
        if [[ -t 0 ]]; then
            printf "${YELLOW}Nombre del equipo${NC} [${team}]: "
            local tn; read -r tn; team="${tn:-$team}"
        fi
        scaffold_teamhub "$th_path" "$team"
        local th_base; th_base="$(cd "$th_path" && pwd)"
        install_team "$TOOL" "$SCOPE" "$th_base"
        echo ""
        echo "${BLUE}Installing team-hub instructions…${NC}"
        install_teamhub_instructions "$TOOL" "$SCOPE" "$th_base" "$team"
        echo ""
        echo "${GREEN}✓ Team hub listo: $th_base${NC}"
        echo "${DIM}  cd \"$th_base\"  &&  ds team-add <proyecto> <git-url>  →  ds team-board${NC}"
        exit 0
    fi

    # --- Subcommand: team-add / team-board / assign (run inside the hub or a repo) ---
    if [[ "$COMMAND" == "team-add" ]]; then
        run_team_add "${POSITIONAL[1]:-}" "${POSITIONAL[2]:-}"; exit 0
    fi
    if [[ "$COMMAND" == "team-board" ]]; then
        run_team_board; exit 0
    fi
    if [[ "$COMMAND" == "assign" ]]; then
        run_assign "${POSITIONAL[1]:-}" "${POSITIONAL[2]:-}" "${POSITIONAL[3]:-}" "${POSITIONAL[4]:-}"; exit 0
    fi

    # --- Subcommand: install (full environment) — alias: team (legacy) ---
    if [[ "$COMMAND" == "install" || "$COMMAND" == "team" ]]; then
        local team_base="$PWD"
        if [[ ${#POSITIONAL[@]} -ge 1 ]]; then
            team_base="$(cd "${POSITIONAL[1]}" 2>/dev/null && pwd)" || {
                echo "${RED}${L_DIR_NOT_FOUND}: ${POSITIONAL[1]}${NC}"
                exit 1
            }
        fi
        [[ -z "$TOOL" ]] && select_tool_interactive
        [[ -z "$SCOPE" ]] && select_scope_interactive

        echo "${L_TOOL_LABEL}:   ${BLUE}$TOOL${NC}"
        echo "${L_SCOPE_LABEL}:  ${BLUE}$SCOPE${NC}"
        echo "${L_TARGET_PATH}:  ${BLUE}$team_base${NC}"
        echo ""
        install_team "$TOOL" "$SCOPE" "$team_base"
        echo ""
        echo "${GREEN}✓ Dublin environment installed.${NC}"
        exit 0
    fi

    # --- Catch mistyped commands early (e.g. `ds nw foo`) ---
    if [[ -z "$COMMAND" && ${#POSITIONAL[@]} -ge 1 ]]; then
        local first="${POSITIONAL[1]}"
        if [[ ! -d "$first" && "$first" != /* && "$first" != .* && "$first" != "." && -z "${SKILLS[$first]}" ]]; then
            echo "${RED}Unknown command: '$first'${NC}"
            echo "${YELLOW}Did you mean one of these?${NC}"
            echo "  ds new <name>        # create a new project here"
            echo "  ds daily <path>      # scaffold a cockpit / daily driver"
            echo "  ds install <path>    # install/upgrade the env in a project"
            echo "  ds doctor <path>     # check which projects are up to date"
            echo "  ds list              # list available skills"
            echo "${DIM}(run 'ds --help' for everything)${NC}"
            exit 1
        fi
    fi

    # --- Default: install skills ---

    # Resolve tool + scope (interactive if not provided)
    if [[ -z "$TOOL" ]]; then
        select_tool_interactive
    fi

    # If first positional is a path, default scope=project unless --scope=user
    local base_path="$PWD"
    if [[ ${#POSITIONAL[@]} -ge 1 ]]; then
        local first="${POSITIONAL[1]}"
        if [[ -d "$first" ]] || [[ "$first" == "." ]] || [[ "$first" == "./"* ]] || [[ "$first" == "/"* ]] || [[ "$first" == "~"* ]]; then
            base_path="$(cd "$first" 2>/dev/null && pwd)" || {
                echo "${RED}${L_DIR_NOT_FOUND}: $first${NC}"
                exit 1
            }
            [[ -z "$SCOPE" ]] && SCOPE="project"
            # Remaining positionals are skill names
            SKILL_NAMES=("${POSITIONAL[@]:1}")
        else
            # First positional is not a path → treat all positionals as skill names
            SKILL_NAMES=("${POSITIONAL[@]}")
        fi
    fi

    if [[ -z "$SCOPE" ]]; then
        select_scope_interactive
    fi

    local target_skills_dir
    target_skills_dir="$(resolve_skills_path "$TOOL" "$SCOPE" "$base_path")" || {
        echo "${RED}${L_INVALID_TOOL}: $TOOL${NC}"
        exit 1
    }

    echo "${L_TOOL_LABEL}:   ${BLUE}$TOOL${NC}"
    echo "${L_SCOPE_LABEL}:  ${BLUE}$SCOPE${NC}"
    echo "${L_TARGET_PATH}:  ${BLUE}$target_skills_dir${NC}"
    echo ""

    if [[ ! -d "$target_skills_dir" ]]; then
        echo "${YELLOW}${L_CREATING_DIR}${NC}"
        mkdir -p "$target_skills_dir"
    else
        echo "${GREEN}${L_DIR_EXISTS}${NC}"
    fi
    echo ""

    # --- Skill selection ---
    if [[ $INSTALL_ALL_FLAG -eq 1 ]]; then
        install_all "$target_skills_dir"
    elif [[ ${#SKILL_NAMES[@]} -gt 0 ]]; then
        echo "${BLUE}${L_INSTALLING_SPECIFIED}${NC}"
        echo ""
        for skill in "${SKILL_NAMES[@]}"; do
            install_skill "$skill" "$target_skills_dir"
        done
    else
        list_skills
        echo -n "${L_SELECT}: "
        read -r selection

        if [[ "$selection" == "q" ]]; then
            echo "${L_EXITING}"
            exit 0
        fi

        if [[ "$selection" == "a" ]]; then
            install_all "$target_skills_dir"
        else
            echo ""
            echo "${BLUE}${L_INSTALLING_SELECTED}${NC}"
            echo ""

            local skill_names=(${(k)SKILLS})
            for num in ${=selection}; do
                local index=$num
                if [[ $index -ge 1 ]] && [[ $index -le ${#skill_names[@]} ]]; then
                    install_skill "${skill_names[$index]}" "$target_skills_dir"
                else
                    echo "${RED}  ✗ ${L_INVALID_NUM}: $num${NC}"
                fi
            done
        fi
    fi

    echo ""
    echo "${GREEN}${L_DONE}${NC}"
    echo ""
    echo "${L_INSTALLED_IN}: ${BLUE}$target_skills_dir${NC}"
}

main "$@"
