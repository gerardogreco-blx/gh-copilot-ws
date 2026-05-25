#!/usr/bin/env bash
set -euo pipefail

echo "==> Workshop post-create (Python)"

for module in M1-istruzioni M2-capacita M3-governance M4-distribuzione; do
  for path in "modules/$module/starters/python" "modules/$module/solution/python"; do
    if [ -f "$path/requirements.txt" ]; then
      echo "  - pip install $path"
      (cd "$path" && python -m pip install -q -r requirements.txt) || true
    fi
  done
done

echo "==> Done. Open modules/M1-istruzioni/README.md to start."
