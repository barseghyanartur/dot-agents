#!/bin/sh
# Install dot-agents skills into ~/.agents/skills (or $DEST).
# Usage: curl -fsSL https://raw.githubusercontent.com/barseghyanartur/dot-agents/main/scripts/install.sh | sh
set -eu

REPO="barseghyanartur/dot-agents"
REF="${REF:-main}"
DEST="${DEST:-$HOME/.agents/skills}"

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

curl -fsSL "https://codeload.github.com/$REPO/tar.gz/$REF" | tar -xz -C "$tmp"

mkdir -p "$DEST"
for skill in "$tmp"/*/skills/dot-agents-*/; do
    [ -f "$skill/SKILL.md" ] || continue
    name="$(basename "$skill")"
    rm -rf "${DEST:?}/$name"
    cp -R "$skill" "$DEST/$name"
    echo "Installed $name"
done

echo "Done. Skills are in $DEST"
