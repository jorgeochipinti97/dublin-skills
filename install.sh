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
  ds                                    # interactive wizard
  ds <project-path>                     # interactive, project scope
  ds <project-path> --all               # all skills, project scope (Claude default)
  ds <project-path> skill1 skill2       # specific skills
  ds --tool=<tool> --scope=<scope> --all
  ds agent                              # install dublin-agent (asks tool)
  ds agent --tool=<tool>                # install dublin-agent for specific tool
  ds update <path>                      # update installed skills
  ds list                               # list available skills

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

# --- Argument parsing ---------------------------------------------------------

TOOL=""
SCOPE=""
INSTALL_ALL_FLAG=0
COMMAND=""
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
            --all|-a) INSTALL_ALL_FLAG=1 ;;
            --help|-h) print_usage; exit 0 ;;
            agent|update|list)
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
