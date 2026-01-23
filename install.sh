#!/bin/zsh

# Dublin Skills Installer
# Instala skills de Claude Code en tu proyecto

set -e

# Resolver symlinks para encontrar el directorio real
SCRIPT_PATH="$0"
if [[ -L "$SCRIPT_PATH" ]]; then
    SCRIPT_PATH="$(readlink "$SCRIPT_PATH")"
fi
SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_PATH")" && pwd)"
SKILLS_SOURCE="$SCRIPT_DIR/skills"

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_header() {
    echo "${BLUE}"
    echo "╔═══════════════════════════════════════════╗"
    echo "║       Dublin Skills Installer             ║"
    echo "╚═══════════════════════════════════════════╝"
    echo "${NC}"
}

# Skills disponibles (ruta relativa desde skills/)
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
    echo "${YELLOW}Skills disponibles:${NC}"
    echo ""
    local i=1
    for skill in ${(k)SKILLS}; do
        echo "  $i) $skill"
        ((i++))
    done
    echo ""
    echo "  a) Instalar todas"
    echo "  q) Salir"
    echo ""
}

install_skill() {
    local skill_name=$1
    local target_dir=$2
    local skill_path="${SKILLS[$skill_name]}"

    if [[ -z "$skill_path" ]]; then
        echo "${RED}Skill '$skill_name' no encontrada${NC}"
        return 1
    fi

    local source_path="$SKILLS_SOURCE/$skill_path"
    local dest_path="$target_dir/skills/$skill_name"

    if [[ ! -d "$source_path" ]]; then
        echo "${RED}Directorio fuente no existe: $source_path${NC}"
        return 1
    fi

    # Crear directorio destino
    mkdir -p "$dest_path"

    # Copiar archivos (excluyendo .DS_Store)
    rsync -av --exclude='.DS_Store' "$source_path/" "$dest_path/" > /dev/null 2>&1

    echo "${GREEN}  ✓ $skill_name${NC}"
}

install_all() {
    local target_dir=$1
    echo "${BLUE}Instalando todas las skills...${NC}"
    echo ""
    for skill in ${(k)SKILLS}; do
        install_skill "$skill" "$target_dir"
    done
}

main() {
    print_header

    # Determinar directorio destino
    local target_dir="${1:-.}"
    target_dir="$(cd "$target_dir" 2>/dev/null && pwd)" || {
        echo "${RED}Directorio no existe: $1${NC}"
        exit 1
    }

    local claude_dir="$target_dir/.claude"

    echo "Directorio destino: ${BLUE}$target_dir${NC}"
    echo ""

    # Crear .claude si no existe
    if [[ ! -d "$claude_dir" ]]; then
        echo "${YELLOW}Creando directorio .claude/${NC}"
        mkdir -p "$claude_dir/skills"
    else
        echo "${GREEN}Directorio .claude/ ya existe${NC}"
        mkdir -p "$claude_dir/skills"
    fi
    echo ""

    # Modo interactivo o argumentos
    if [[ $# -gt 1 ]]; then
        # Instalación por argumentos
        shift  # Quitar el primer argumento (directorio)
        if [[ "$1" == "--all" ]] || [[ "$1" == "-a" ]]; then
            install_all "$claude_dir"
        else
            echo "${BLUE}Instalando skills especificadas...${NC}"
            echo ""
            for skill in "$@"; do
                install_skill "$skill" "$claude_dir"
            done
        fi
    else
        # Modo interactivo
        list_skills

        echo -n "Selecciona skills (números separados por espacio, 'a' para todas): "
        read -r selection

        if [[ "$selection" == "q" ]]; then
            echo "Saliendo..."
            exit 0
        fi

        if [[ "$selection" == "a" ]]; then
            install_all "$claude_dir"
        else
            echo ""
            echo "${BLUE}Instalando skills seleccionadas...${NC}"
            echo ""

            # Convertir selección a array de nombres
            local skill_names=(${(k)SKILLS})
            for num in ${=selection}; do
                local index=$num
                if [[ $index -ge 1 ]] && [[ $index -le ${#skill_names[@]} ]]; then
                    install_skill "${skill_names[$index]}" "$claude_dir"
                else
                    echo "${RED}  ✗ Número inválido: $num${NC}"
                fi
            done
        fi
    fi

    echo ""
    echo "${GREEN}Instalación completada.${NC}"
    echo ""
    echo "Skills instaladas en: ${BLUE}$claude_dir/skills/${NC}"
}

main "$@"
