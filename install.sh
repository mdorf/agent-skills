#!/usr/bin/env bash
# Symlink a skill from this repo into the user-level skill directories of
# Claude Code (~/.claude/skills) and OpenAI Codex (~/.agents/skills).
#
# Usage:
#   ./install.sh [--claude|--codex] <skill-name>   install one skill
#   ./install.sh [--claude|--codex] --all          install every skill under skills/
#   ./install.sh --list                            list available skills
#
# By default skills are linked for both tools. Use --claude or --codex to
# target one (e.g. if Claude Code already gets the skills via the plugin
# marketplace, use --codex to avoid duplicates).

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_SRC="$REPO_DIR/skills"
TARGETS=("$HOME/.claude/skills" "$HOME/.agents/skills")

case "${1:-}" in
  --claude) TARGETS=("$HOME/.claude/skills"); shift ;;
  --codex)  TARGETS=("$HOME/.agents/skills"); shift ;;
esac

list_skills() {
  find "$SKILLS_SRC" -mindepth 2 -maxdepth 2 -name SKILL.md -exec dirname {} \; | xargs -n1 basename | sort
}

install_skill() {
  local name="$1"
  local src="$SKILLS_SRC/$name"
  if [[ ! -f "$src/SKILL.md" ]]; then
    echo "error: no skill named '$name' (expected $src/SKILL.md)" >&2
    exit 1
  fi
  for target_dir in "${TARGETS[@]}"; do
    mkdir -p "$target_dir"
    local dest="$target_dir/$name"
    if [[ -L "$dest" ]]; then
      rm "$dest"
    elif [[ -e "$dest" ]]; then
      echo "skip: $dest exists and is not a symlink (remove it manually to replace)" >&2
      continue
    fi
    ln -s "$src" "$dest"
    echo "linked $dest -> $src"
  done
}

case "${1:-}" in
  --list)
    list_skills
    ;;
  --all)
    while IFS= read -r name; do
      install_skill "$name"
    done < <(list_skills)
    ;;
  "")
    echo "usage: $0 <skill-name> | --all | --list" >&2
    exit 1
    ;;
  *)
    install_skill "$1"
    ;;
esac
