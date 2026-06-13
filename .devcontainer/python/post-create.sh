#!/usr/bin/env bash
set -euo pipefail

echo "==> Workshop post-create (Python)"

# La feature python installa gli eseguibili (uvicorn, pytest, ...) in una cartella
# che non è nel PATH dell'utente. La aggiungiamo dinamicamente (niente versione hardcoded)
# così i comandi sono lanciabili per nome e sparisce il warning di pip.
PY_SCRIPTS="$(python -c 'import sysconfig; print(sysconfig.get_path("scripts"))')"
if [ -n "$PY_SCRIPTS" ]; then
  for rc in "$HOME/.bashrc" "$HOME/.profile"; do
    if [ -f "$rc" ] && ! grep -qF "$PY_SCRIPTS" "$rc"; then
      echo "export PATH=\"$PY_SCRIPTS:\$PATH\"" >> "$rc"
    fi
  done
  export PATH="$PY_SCRIPTS:$PATH"
fi

for module in M1-istruzioni M2-capacita M3-governance M4-distribuzione; do
  for path in "modules/$module/starters/python" "modules/$module/solution/python"; do
    if [ -f "$path/requirements.txt" ]; then
      echo "  - pip install $path"
      (cd "$path" && python -m pip install -q --no-warn-script-location -r requirements.txt) || true
    fi
  done
done

echo "==> Done. Open modules/M1-istruzioni/README.md to start."
