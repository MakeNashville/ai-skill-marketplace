#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_DIR="$SCRIPT_DIR/skills"

usage() {
    cat <<'USAGE'
Usage:
  ./install.sh [skill-name] <project-path>       Install skill(s)
  ./install.sh --remove [skill-name] <project-path>  Remove skill(s)

Examples:
  ./install.sh /path/to/my-project                    Install all skills
  ./install.sh makerspace-signage-cards /path/to/proj  Install one skill
  ./install.sh --remove /path/to/my-project            Remove all skills
  ./install.sh --remove outline-publisher /path/to/proj Remove one skill
USAGE
    exit 1
}

install_skill() {
    local skill_name="$1"
    local target_dir="$2"
    local skill_source="$SKILLS_DIR/$skill_name"
    local skill_target="$target_dir/.claude/skills/$skill_name"

    if [[ -e "$skill_target" && ! -L "$skill_target" ]]; then
        echo "Error: $skill_target exists and is not a symlink. Remove it manually to proceed." >&2
        return 1
    fi

    mkdir -p "$target_dir/.claude/skills"
    ln -sfn "$skill_source" "$skill_target"
    echo "Installed $skill_name -> $skill_target"
}

remove_skill() {
    local skill_name="$1"
    local target_dir="$2"
    local skill_target="$target_dir/.claude/skills/$skill_name"

    if [[ -L "$skill_target" ]]; then
        rm "$skill_target"
        echo "Removed $skill_name from $target_dir/.claude/skills/"
    elif [[ -e "$skill_target" ]]; then
        echo "Error: $skill_target is not a symlink. Remove it manually." >&2
        return 1
    else
        echo "Skipping $skill_name (not installed in $target_dir)"
    fi
}

# Parse arguments
REMOVE=false
if [[ "${1:-}" == "--remove" ]]; then
    REMOVE=true
    shift
fi

if [[ $# -eq 0 ]]; then
    usage
fi

# Determine if first arg is a skill name or a project path
SKILL_NAME=""
PROJECT_PATH=""

if [[ $# -eq 1 ]]; then
    # Only one arg: must be project path, operate on all skills
    PROJECT_PATH="$1"
elif [[ $# -eq 2 ]]; then
    # Two args: first is skill name, second is project path
    if [[ -d "$SKILLS_DIR/$1" ]]; then
        SKILL_NAME="$1"
        PROJECT_PATH="$2"
    else
        echo "Error: Unknown skill '$1'. Available skills:" >&2
        ls -1 "$SKILLS_DIR" >&2
        exit 1
    fi
else
    usage
fi

# Validate project path
if [[ ! -d "$PROJECT_PATH" ]]; then
    echo "Error: Project directory '$PROJECT_PATH' does not exist." >&2
    exit 1
fi

# Execute
if [[ -n "$SKILL_NAME" ]]; then
    if $REMOVE; then
        remove_skill "$SKILL_NAME" "$PROJECT_PATH"
    else
        install_skill "$SKILL_NAME" "$PROJECT_PATH"
    fi
else
    for skill_dir in "$SKILLS_DIR"/*/; do
        skill="$(basename "$skill_dir")"
        if $REMOVE; then
            remove_skill "$skill" "$PROJECT_PATH"
        else
            install_skill "$skill" "$PROJECT_PATH"
        fi
    done
fi
