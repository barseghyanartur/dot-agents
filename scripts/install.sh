#!/bin/sh
# Install dot-agents skills into ~/.agents/skills (or $DEST).
# Usage: curl -fsSL https://raw.githubusercontent.com/barseghyanartur/dot-agents/main/scripts/install.sh | sh
set -eu

REPO="barseghyanartur/dot-agents"
REF="${REF:-main}"
DEST="${DEST:-$HOME/.agents/skills}"

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

curl -fsSL -o "$tmp/archive.tar.gz" "https://codeload.github.com/$REPO/tar.gz/$REF"
tar -xzf "$tmp/archive.tar.gz" -C "$tmp"

mkdir -p "$DEST"
count=0
for skill in "$tmp"/*/skills/dot-agents-*/; do
    [ -f "$skill/SKILL.md" ] || continue
    name="$(basename "$skill")"
    rm -rf "${DEST:?}/$name"
    cp -R "$skill" "$DEST/$name"
    echo "Installed $name"
    count=$((count + 1))
done

if [ "$count" -eq 0 ]; then
    echo "Error: no skills found in $REPO@$REF" >&2
    exit 1
fi

echo "Done. Skills are in $DEST"
