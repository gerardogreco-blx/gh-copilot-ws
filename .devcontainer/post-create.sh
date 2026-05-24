#!/usr/bin/env bash
set -euo pipefail

echo "==> Workshop post-create setup"

# Restore .NET starters (M1-M4)
for module in M1-istruzioni M2-capacita M3-governance M4-distribuzione; do
  for path in "modules/$module/starters/dotnet" "modules/$module/solution/dotnet"; do
    if [ -f "$path/TaskApi.csproj" ] || [ -f "$path"/*.csproj 2>/dev/null ]; then
      echo "  - dotnet restore $path"
      (cd "$path" && dotnet restore --nologo) || true
    fi
  done
done

# Install TS deps
for module in M1-istruzioni M2-capacita M3-governance M4-distribuzione; do
  for path in "modules/$module/starters/typescript" "modules/$module/solution/typescript"; do
    if [ -f "$path/package.json" ]; then
      echo "  - npm install $path"
      (cd "$path" && npm install --no-audit --no-fund) || true
    fi
  done
done

# Python venvs
for module in M1-istruzioni M2-capacita M3-governance M4-distribuzione; do
  for path in "modules/$module/starters/python" "modules/$module/solution/python"; do
    if [ -f "$path/requirements.txt" ]; then
      echo "  - pip install $path"
      (cd "$path" && python -m pip install -q -r requirements.txt) || true
    fi
  done
done

echo "==> Done. Open modules/M1-istruzioni/README.md to start."
