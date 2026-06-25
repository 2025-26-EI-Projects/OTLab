#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/../.."

MOUNTS_FILE=".landingPage/hugo.generated-mounts.yaml"

cat > "$MOUNTS_FILE" << 'EOF'
module:
  mounts:
    - source: .landingPage/archetypes
      target: archetypes
    - source: .landingPage/layouts
      target: layouts
    - source: .landingPage/static
      target: static
    - source: .landingPage/i18n
      target: i18n
    - source: .landingPage/content
      target: content
EOF

while IFS= read -r labdir; do
  labname=$(basename "$labdir")
  cat >> "$MOUNTS_FILE" << EOF
    - source: $labname
      target: content/labs/$labname
EOF
done < <(find . -maxdepth 1 -type d -name "OTLab[0-9]*" | sort)

hugo server --config .landingPage/hugo.yaml,"$MOUNTS_FILE" -D
