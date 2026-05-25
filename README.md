# Workshop "The Agent Strikes Back" — GitHub Copilot 2026

> Workshop hands-on di 90 minuti su agenti Copilot: AGENTS.md, Skills, Subagents, MCP, Hooks, Plugins & Marketplace + intro a Spec-Driven Development.

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/<owner>/<repo>?quickstart=1)

## Per chi partecipa

1. Click su "Open in GitHub Codespaces" qui sopra.
2. Nella pagina di creazione del Codespace, **scegli il tuo devcontainer** tra:
   - `Workshop · .NET 10` — se vuoi seguire con lo starter .NET
   - `Workshop · TypeScript (Node 20)` — per lo starter TypeScript
   - `Workshop · Python 3.11` — per lo starter Python

   Ogni devcontainer installa solo l'SDK che ti serve (boot più rapido). Se a metà workshop vuoi cambiare linguaggio, crea un secondo Codespace con un altro devcontainer (il Codespace di partenza non si perde).
3. Attendi ~1-2 min che il Codespace parta.
4. Verifica che l'icona Copilot in basso a destra sia attiva.
5. Apri `docs/00-intro.md`, poi `modules/M1-istruzioni/README.md`.

Se il Codespace non parte: vedi [setup locale](#setup-locale-fallback).

## Struttura del workshop

| Modulo | Topic | Durata | Presentato da |
|---|---|---|---|
| M1 Istruzioni | AGENTS.md + Skills | 18' | Gerardo |
| M2 Capacità | Subagents + MCP (Context7) | 18' | Gerardo |
| M3 Governance | Hooks (safety guard) | 14' | Gerardo |
| M4 Distribuzione | Plugins & Marketplace | 14' | Gerardo |
| M5 SDD | Spec-Driven Development | 12' | Co-speaker |

## Cosa ti porti a casa

- AGENTS.md letto e capito + skill `endpoint-creator`
- Context7 MCP configurato + subagent `code-reviewer`
- Hook safety guard funzionante + `policy.yml` riusabile
- Plugin bundle `copilot-safety-guard`

## Setup locale (fallback)

Se non puoi usare GitHub Codespaces, puoi seguire il workshop in locale. La superficie obbligatoria è **VS Code + estensione GitHub Copilot autenticata**; gli SDK servono solo per il linguaggio che scegli.

### Prerequisiti software

| Tool | Note |
|---|---|
| Git | per clonare il repo |
| VS Code (≥ 1.110) | per agent mode e plugin support |
| Estensione `GitHub.copilot` + `GitHub.copilot-chat` | sottoscrizione Copilot attiva richiesta |
| Node.js 20+ | richiesto **solo se scegli lo starter TypeScript**. Context7 ora è un endpoint HTTP hosted, non più un processo locale |
| **Uno** tra .NET 10 SDK / Python 3.11+ | solo per il linguaggio di starter che scegli (TypeScript usa già Node) |
| `jq` (Unix) o PowerShell 7+ (Windows) | necessario per gli hook script in M3/M4 |

### Passi setup

```bash
# 1. Clone del repo
git clone https://github.com/<owner>/<repo>.git
cd <repo>

# 2. Apri il workspace in VS Code
code .

# 3. Verifica Copilot attivo (icona in basso a destra in VS Code)

# 4. Restore dipendenze per il tuo linguaggio
#    Solo per il modulo che inizi, non per tutti:

# .NET
cd modules/M1-istruzioni/starters/dotnet && dotnet restore && cd -

# TypeScript
cd modules/M1-istruzioni/starters/typescript && npm install && cd -

# Python (con venv consigliato)
cd modules/M1-istruzioni/starters/python
python3 -m venv .venv
source .venv/bin/activate   # Windows: .venv\Scripts\Activate.ps1
pip install -r requirements.txt
cd -
```

### Verifica che lo starter giri

Per testare che lo starter funzioni prima di iniziare i moduli:

```bash
# .NET
cd modules/M1-istruzioni/starters/dotnet
dotnet test           # → 2 test passano
dotnet run            # → server su http://localhost:5000

# TypeScript
cd modules/M1-istruzioni/starters/typescript
npm test              # → 2 test passano
npm run dev           # → server su http://localhost:3000

# Python
cd modules/M1-istruzioni/starters/python
source .venv/bin/activate
pytest                # → 2 test passano
uvicorn app.main:app  # → server su http://localhost:8000
```

In tutti i casi, una volta avviato il server, una `curl http://localhost:<porta>/tasks` deve restituire `[]`.

### Configurazione MCP server (Context7) in locale

Lo starter contiene già `.vscode/mcp.json` configurato per usare l'endpoint HTTP hosted di Context7 (`https://mcp.context7.com/mcp`). Niente processi locali, niente download.

VS Code Copilot Chat rileva il file all'apertura del workspace e ti propone di abilitare il server. Accetta.

Se non parte automaticamente: Command Palette → `MCP: List Servers` → seleziona `context7` → `Start`.

Per uso intensivo (audience grande, rate limit) puoi configurare una API key personale da [context7.com/dashboard](https://context7.com/dashboard) aggiungendo `headers` al file di config. Per il workshop normale non serve.

### Configurazione hook (per M3 e M4)

Gli starter di M3 e M4 hanno già `.github/hooks/pre-tool-use.json` (il file di registrazione) e `.copilot/hooks/pre-tool-use.sh` (la versione bash) + `.copilot/hooks/pre-tool-use.ps1` (la versione PowerShell).

Per abilitare i hook in Copilot Chat (User Settings JSON):

```json
"chat.useCustomAgentHooks": true
```

Su Windows, modifica `.github/hooks/pre-tool-use.json` per puntare alla versione `.ps1`:

```json
{
  "hooks": {
    "PreToolUse": [
      { "type": "command", "command": "pwsh -File ./.copilot/hooks/pre-tool-use.ps1", "timeout": 15 }
    ]
  }
}
```

### Quale modulo per primo

Apri [`docs/00-intro.md`](docs/00-intro.md) per il quadro generale, poi `modules/M1-istruzioni/README.md`.

## Licenza
MIT
