#!/bin/zsh

# Dublin Skills Installer

set -e

# Resolve symlinks to find the real directory
SCRIPT_PATH="$0"
if [[ -L "$SCRIPT_PATH" ]]; then
    SCRIPT_PATH="$(readlink "$SCRIPT_PATH")"
fi
SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_PATH")" && pwd)"
SKILLS_SOURCE="$SCRIPT_DIR/skills"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
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
    L_CREATING_DIR="Creando directorio .claude/"
    L_DIR_EXISTS="Directorio .claude/ ya existe"
    L_INVALID_NUM="Numero invalido"
    L_DONE="Instalacion completada."
    L_INSTALLED_IN="Skills instaladas en"
    L_EXITING="Saliendo..."
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
    L_CREATING_DIR="Creating .claude/ directory"
    L_DIR_EXISTS="Directory .claude/ already exists"
    L_INVALID_NUM="Invalid number"
    L_DONE="Installation complete."
    L_INSTALLED_IN="Skills installed in"
    L_EXITING="Exiting..."
fi

print_header() {
    echo "${BLUE}"
    echo "╔═══════════════════════════════════════════╗"
    echo "║       Dublin Skills Installer             ║"
    echo "╚═══════════════════════════════════════════╝"
    echo "${NC}"
}

# Available skills (relative path from skills/)
typeset -A SKILLS
SKILLS=(
    bind-api "bind-api"
    brand-guidelines "brand-guidelines"
    domain-modeler "architecture/domain-modeler"
    hexagonal-architect "architecture/hexagonal-architect"
    premium-frontend-design "frontend/premium-frontend-design"
    product-planner "product/product-planner"
    skill-creator "skill-creator"
    systems-thinking "discovery/systems-thinking"
    tdd-workflow "implementation/tdd-workflow"
)

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

install_skill() {
    local skill_name=$1
    local target_dir=$2
    local skill_path="${SKILLS[$skill_name]}"

    if [[ -z "$skill_path" ]]; then
        echo "${RED}${L_SKILL_NOT_FOUND}: '$skill_name'${NC}"
        return 1
    fi

    local source_path="$SKILLS_SOURCE/$skill_path"
    local dest_path="$target_dir/skills/$skill_name"

    if [[ ! -d "$source_path" ]]; then
        echo "${RED}${L_SOURCE_NOT_FOUND}: $source_path${NC}"
        return 1
    fi

    mkdir -p "$dest_path"
    rsync -av --exclude='.DS_Store' "$source_path/" "$dest_path/" > /dev/null 2>&1

    echo "${GREEN}  ✓ $skill_name${NC}"
}

install_all() {
    local target_dir=$1
    echo "${BLUE}${L_INSTALLING_ALL}${NC}"
    echo ""
    for skill in ${(k)SKILLS}; do
        install_skill "$skill" "$target_dir"
    done
}

main() {
    print_header

    local target_dir="${1:-.}"
    target_dir="$(cd "$target_dir" 2>/dev/null && pwd)" || {
        echo "${RED}${L_DIR_NOT_FOUND}: $1${NC}"
        exit 1
    }

    local claude_dir="$target_dir/.claude"

    echo "${L_TARGET_DIR}: ${BLUE}$target_dir${NC}"
    echo ""

    if [[ ! -d "$claude_dir" ]]; then
        echo "${YELLOW}${L_CREATING_DIR}${NC}"
        mkdir -p "$claude_dir/skills"
    else
        echo "${GREEN}${L_DIR_EXISTS}${NC}"
        mkdir -p "$claude_dir/skills"
    fi
    echo ""

    if [[ $# -gt 1 ]]; then
        shift
        if [[ "$1" == "--all" ]] || [[ "$1" == "-a" ]]; then
            install_all "$claude_dir"
        else
            echo "${BLUE}${L_INSTALLING_SPECIFIED}${NC}"
            echo ""
            for skill in "$@"; do
                install_skill "$skill" "$claude_dir"
            done
        fi
    else
        list_skills

        echo -n "${L_SELECT}: "
        read -r selection

        if [[ "$selection" == "q" ]]; then
            echo "${L_EXITING}"
            exit 0
        fi

        if [[ "$selection" == "a" ]]; then
            install_all "$claude_dir"
        else
            echo ""
            echo "${BLUE}${L_INSTALLING_SELECTED}${NC}"
            echo ""

            local skill_names=(${(k)SKILLS})
            for num in ${=selection}; do
                local index=$num
                if [[ $index -ge 1 ]] && [[ $index -le ${#skill_names[@]} ]]; then
                    install_skill "${skill_names[$index]}" "$claude_dir"
                else
                    echo "${RED}  ✗ ${L_INVALID_NUM}: $num${NC}"
                fi
            done
        fi
    fi

    echo ""
    echo "${GREEN}${L_DONE}${NC}"
    echo ""
    echo "${L_INSTALLED_IN}: ${BLUE}$claude_dir/skills/${NC}"
}

main "$@"
