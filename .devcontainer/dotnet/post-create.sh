#!/usr/bin/env bash
set -euo pipefail

echo "==> Workshop post-create (.NET)"

for module in M1-istruzioni M2-capacita M3-governance M4-distribuzione; do
  for path in "modules/$module/starters/dotnet" "modules/$module/solution/dotnet"; do
    if compgen -G "$path"/*.csproj > /dev/null; then
      echo "  - dotnet restore $path"
      (cd "$path" && dotnet restore --nologo) || true
    fi
  done
done

echo "==> Done. Open modules/M1-istruzioni/README.md to start."
