# Workshop "The Agent Strikes Back" - GitHub Copilot 2026

> Workshop hands-on su Spec-Driven Development, AGENTS.md, Skills, Subagents, MCP, Hooks, Plugins & Marketplace

### Step 1 - Fork del repository

Click sul pulsante **"Fork"** in alto a destra in questa pagina, oppure usa direttamente questo link:

👉 **[Fork render93/gh-copilot-ws](https://github.com/render93/gh-copilot-ws/fork)** 👈

Nella pagina che si apre:
- **Owner**: il tuo account GitHub (lascia il default)
- **Repository name**: lascia `gh-copilot-ws` (o cambia se preferisci)
- **"Copy the main branch only"**: ✅ lasciato spuntato
- Click **"Create fork"**

### Step 2 - Crea il Codespace

**Dal tuo fork** (`github.com/TUO-USERNAME/gh-copilot-ws`):
1. Click sul pulsante verde **"Code"**.
2. Tab **"Codespaces"** => click sui tre puntini => "New with options...".

Si apre la pagina **"Create codespace"** di GitHub.

### Step 3 - Configura il Codespace

Nella pagina di creazione lascia invariati:
- **Branch**: `main`
- **Region**: `Europe West`
- **Machine type**: `2-core`
- ⚠️ **Dev container configuration**: scegli una voce in base al linguaggio che preferisci usare

| Opzione nel dropdown | Scegli se vuoi… |
|---|---|
| `Workshop · .NET 10` | seguire con lo starter ASP.NET Core Minimal API |
| `Workshop · TypeScript (Node 20)` | seguire con lo starter Hono (TS) |
| `Workshop · Python 3.11` | seguire con lo starter FastAPI |

> 🚫 **NON scegliere `Default project configuration`**: è l'opzione fallback di GitHub che usa un'immagine generica senza la pre-installazione di Copilot, MCP server, dipendenze del workshop.

Ogni devcontainer dedicato installa solo l'SDK del suo linguaggio. Se a metà workshop vuoi cambiare linguaggio, crea un secondo Codespace con un altro devcontainer dal dropdown - quello di partenza non si perde.

Click **"Create codespace"** in basso a destra.

Attendere qualche minuto per la creazione e l'inizializzazione del Codespace. Al termine nel tab `Terminale` dovresti vedere il messaggio `==> Done. Open modules/M1-istruzioni/README.md to start.`.

### Step 4 - Avvio MCP server (Context7)
Il server MCP Context7 potrebbe non partire automaticamente al primo avvio del Codespace.

Aprire Command Palette => `MCP: List Servers` => seleziona `context7` => `Avvia Server`.

### Step 5 - Cambio lingua della UI
Per cambiare la lingua della UI di VS Code (menu, notifiche, ecc.):
1. Command Palette => `Configure Display Language`
2. Scegli la lingua preferita (es. `english`)

### Configurazione locale

Se per qualche motivo non puoi usare Codespaces, puoi seguire il workshop in locale. Vedi [setup locale](#setup-locale-fallback).

## Setup locale

Se non puoi usare GitHub Codespaces, puoi seguire il workshop in locale.

### Step 1 - Prerequisiti software

| Tool | Note |
|---|---|
| Git | per clonare il repo |
| VS Code (≥ 1.110) | per agent mode e plugin support |
| Estensione `GitHub.copilot` + `GitHub.copilot-chat` | sottoscrizione Copilot attiva richiesta |
| Node.js 20+ | richiesto **solo se scegli lo starter TypeScript**. Context7 ora è un endpoint HTTP hosted, non più un processo locale |
| **Uno** tra .NET 10 SDK / Python 3.11+ | solo per il linguaggio di starter che scegli (TypeScript usa già Node) |
| `jq` (Unix) o PowerShell 7+ (Windows) | necessario per gli hook script in M3/M4 |

### Step 2 - Passi setup

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

### Step 3 - Verifica che lo starter giri

Per testare che lo starter funzioni prima di iniziare i moduli:

```bash
# .NET
cd modules/M1-istruzioni/starters/dotnet
dotnet test           # => 2 test passano
dotnet run            # => server su http://localhost:5000

# TypeScript
cd modules/M1-istruzioni/starters/typescript
npm test              # => 2 test passano
npm run dev           # => server su http://localhost:3000

# Python
cd modules/M1-istruzioni/starters/python
source .venv/bin/activate
pytest                # => 2 test passano
uvicorn app.main:app  # => server su http://localhost:8000
```

### Step 4 - Configurazione MCP server (Context7) in locale

Il repo contiene già `.vscode/mcp.json` al root del workspace, configurato per usare l'endpoint HTTP hosted di Context7 (`https://mcp.context7.com/mcp`).

VS Code Copilot Chat rileva il file all'apertura del workspace e ti propone di abilitare il server, accetta quando richiesto.

Se non parte automaticamente: Command Palette => `MCP: List Servers` => seleziona `context7` => `Avvia Server`.

### Step 5 - Configurazione hook (per M3 e M4)

> **Dove crei i file durante il workshop**: tutte le customizations Copilot (skill, subagent, hook, plugin) che creerai durante i moduli vanno **al root del workspace** (`/workspaces/gh-copilot-ws/`), non dentro la cartella delle starter. Il README di ogni modulo te lo ricorda. Le starter contengono solo il codice della Task API (.NET / TS / Python) per il linguaggio che hai scelto.

Dovrai creare (come parte degli esercizi di M3 e M4) al root del workspace: `.github/hooks/pre-tool-use.json` (il file di registrazione) e `.copilot/hooks/pre-tool-use.sh` (la versione bash) + `.copilot/hooks/pre-tool-use.ps1` (la versione PowerShell).

Per abilitare i hook in Copilot Chat, aprire le impostazioni di VS Code (`Ctrl+,`) e cercare `chat.useHooks`, poi spuntare la casella per abilitare i hook.

> Su Windows, modifica `.github/hooks/pre-tool-use.json` per puntare alla versione `.ps1`:

```json
{
  "hooks": {
    "PreToolUse": [
      { "type": "command", "command": "pwsh -File ./.copilot/hooks/pre-tool-use.ps1", "timeout": 15 }
    ]
  }
}
```

## Si parte

> ⚠️ **Importante — non cambiare il workspace root**
>
> Il workspace VS Code deve **rimanere il root del repo** (`/workspaces/gh-copilot-ws`) per tutto il workshop. Apri i README dei moduli come **file** (Explorer sidebar oppure `Cmd/Ctrl+P` → digita il path), **NON** con `File → Open Folder` sulla cartella del modulo.
>
> Perché: tutte le customizations Copilot (skill, subagent, hook, plugin) che creerai vanno al **root del workspace** — se cambi workspace finiscono nel posto sbagliato e Copilot non le carica.
>
> Suggerimento UX: con il README aperto, premi `Cmd+Shift+V` (macOS) o `Ctrl+Shift+V` (Win/Linux) per il preview Markdown formattato.

Apri [`modules/M1-istruzioni/README.md`](modules/M1-istruzioni/README.md) per iniziare il modulo 1 e buona workshop! 🚀
