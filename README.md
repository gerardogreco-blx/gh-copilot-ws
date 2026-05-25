# Workshop "The Agent Strikes Back" — GitHub Copilot 2026

> Workshop hands-on di 90 minuti su agenti Copilot: AGENTS.md, Skills, Subagents, MCP, Hooks, Plugins & Marketplace + intro a Spec-Driven Development.

## Per chi partecipa

> ⚠️ **Importante**: questo workshop richiede che tu lavori su un **tuo fork** del repository, non sul repo originale. Solo così potrai committare e pushare le tue modifiche e "portarti a casa" il lavoro fatto.

### Step 1 — Fork del repository

Click sul pulsante **"Fork"** in alto a destra in questa pagina, oppure usa direttamente questo link:

👉 **[Fork render93/gh-copilot-ws](https://github.com/render93/gh-copilot-ws/fork)** 👈

Nella pagina che si apre:
- **Owner**: il tuo account GitHub (lascia il default)
- **Repository name**: lascia `gh-copilot-ws` (o cambia se preferisci)
- **"Copy the main branch only"**: ✅ lasciato spuntato
- Click **"Create fork"**

In ~5 secondi avrai il tuo fork all'URL `https://github.com/TUO-USERNAME/gh-copilot-ws`.

### Step 2 — Crea il Codespace dal TUO fork

⚠️ **Non usare il badge "Open in Codespaces" di questo README originale**: porterebbe al repo di Gerardo, dove non hai write access.

**Dal tuo fork** (`github.com/TUO-USERNAME/gh-copilot-ws`):
1. Click sul pulsante verde **"Code"**.
2. Tab **"Codespaces"** → click **"Create codespace on main"** (oppure i tre puntini → "New with options" per vedere la pagina avanzata).

Si apre la pagina **"Create a new codespace"** di GitHub.

### Step 3 — Configura il Codespace

Nella pagina di creazione lascia invariati:
- **Repository**: `TUO-USERNAME/gh-copilot-ws` (deve essere il tuo fork, non `render93/...`)
- **Branch**: `main`
- **Region**: lascia il default (es. Europe West)
- **Machine type**: `2-core` (sufficiente)

⚠️ **Apri il dropdown "Dev container configuration"** e scegli **uno** di questi 3 — *in base al linguaggio che preferisci usare*:

| Opzione nel dropdown | Scegli se vuoi… |
|---|---|
| `Workshop · .NET 10` | seguire con lo starter ASP.NET Core Minimal API |
| `Workshop · TypeScript (Node 20)` | seguire con lo starter Hono (TS) |
| `Workshop · Python 3.11` | seguire con lo starter FastAPI |

> 🚫 **NON scegliere `Default project configuration`**: è l'opzione fallback di GitHub che usa un'immagine generica senza la pre-installazione di Copilot, MCP server, dipendenze del workshop. Se la selezioni per errore, il Codespace parte ma niente funziona.

Ogni devcontainer dedicato installa solo l'SDK del suo linguaggio (boot ~1-2 min). Se a metà workshop vuoi cambiare linguaggio, crea un secondo Codespace con un altro devcontainer dal dropdown — quello di partenza non si perde.

Click **"Create codespace"** in basso a destra. Attendi 1-2 minuti.

### Step 4 — Verifica setup

Una volta dentro VS Code (in browser):
- l'icona Copilot in basso a destra è **attiva** (non grigia/disabilitata);
- aprendo il pannello inferiore "Output" → "GitHub Copilot Chat" non ci sono errori di autenticazione;
- nel terminal: `git remote -v` deve mostrare il tuo fork come `origin`, non `render93/gh-copilot-ws`.

### Step 5 — Inizia

Apri [`docs/00-intro.md`](docs/00-intro.md) per il quadro generale, poi [`modules/M1-istruzioni/README.md`](modules/M1-istruzioni/README.md) per iniziare.

Se il Codespace non parte (o l'errore è "configurazione non trovata"): vedi [setup locale](#setup-locale-fallback).

---

> **Per gli speaker / chi vuole solo "vedere"** senza interagire/committare: c'è un badge shortcut che apre un Codespace direttamente sul repo originale, ma in modalità sola lettura per chi non è collaborator. Da usare solo per demo, non per il workshop hands-on:
>
> [![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/render93/gh-copilot-ws)

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
