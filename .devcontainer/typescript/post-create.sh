#!/usr/bin/env bash
set -euo pipefail

echo "==> Workshop post-create (TypeScript)"

for module in M1-istruzioni M2-capacita M3-governance M4-distribuzione; do
  for path in "modules/$module/starters/typescript" "modules/$module/solution/typescript"; do
    if [ -f "$path/package.json" ]; then
      echo "  - npm install $path"
      (cd "$path" && npm install --no-audit --no-fund) || true
    fi
  done
done

echo "==> Done. Open modules/M1-istruzioni/README.md to start."
