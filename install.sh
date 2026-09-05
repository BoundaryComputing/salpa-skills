#!/usr/bin/env bash
# Copy the skills into a project, for every agent that reads them.
#
#   ./install.sh [project-dir]     default: the current directory
#
# Claude Code, OpenCode, Grok Build and Goose read .claude/skills/; pi and Qwen Code read
# .agents/skills/. Both are written, so the same copy serves whichever you use. Re-run to update.
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
target="${1:-.}"
for dest in ".claude/skills" ".agents/skills"; do
  mkdir -p "$target/$dest"
  for skill in "$here"/skills/*/; do
    name="$(basename "$skill")"
    rm -rf "$target/$dest/$name"
    cp -R "$skill" "$target/$dest/$name"
    echo "installed $name -> $target/$dest/$name"
  done
done
