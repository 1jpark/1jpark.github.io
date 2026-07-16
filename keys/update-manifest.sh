#!/usr/bin/env bash
#
# update-manifest.sh
# Regenerates data/manifest.json from every *.asc file present in data/.
#
# Usage:
#   ./update-manifest.sh              # uses ./data relative to this script
#   ./update-manifest.sh /path/to/keys/data
#
# Typical workflow to add a new key:
#   1. cp new-key.asc data/some-slug.asc
#   2. ./update-manifest.sh
#   (that's it — index.html picks it up on next page load)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATA_DIR="${1:-$SCRIPT_DIR/data}"
MANIFEST="$DATA_DIR/manifest.json"

if [[ ! -d "$DATA_DIR" ]]; then
  echo "error: data directory not found: $DATA_DIR" >&2
  exit 1
fi

shopt -s nullglob
files=("$DATA_DIR"/*.asc)
shopt -u nullglob

if [[ ${#files[@]} -eq 0 ]]; then
  echo "warning: no .asc files found in $DATA_DIR" >&2
fi

{
  echo "["
  count=${#files[@]}
  i=0
  for f in "${files[@]}"; do
    i=$((i+1))
    name="$(basename "$f")"
    # sort by filename for stable, deterministic output
    printf '  "%s"' "$name"
    if [[ $i -lt $count ]]; then printf ','; fi
    printf '\n'
  done
  echo "]"
} | python3 -c "
import json, sys
names = json.load(sys.stdin)
names.sort()
print(json.dumps(names, indent=2))
" > "$MANIFEST"

echo "wrote $MANIFEST with ${#files[@]} key(s):"
printf '  - %s\n' "$(basename -a "${files[@]}" 2>/dev/null || true)"
