#!/bin/bash
# install.sh - Symlink compound skill to ~/.claude/skills/

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILLS_DIR="$HOME/.claude/skills"

mkdir -p "$SKILLS_DIR"

ln -sfn "$SCRIPT_DIR/skills/compound" "$SKILLS_DIR/compound"
echo "Linked /compound -> $SKILLS_DIR/compound"

echo ""
echo "compound installed! Command: /compound"
