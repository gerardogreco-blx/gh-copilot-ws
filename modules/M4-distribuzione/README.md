# Modulo M4 - Distribuzione · Plugins & Marketplace

> Obiettivo: trasformare gli artefatti agentic privati (skill, subagent, hook, configurazioni di MCP server) in **unità distribuibili e installabili** condivisibili col team o l'organizzazione.

## Teoria

### Plugin

Un plugin è un **bundle versionato** che raccoglie più componenti agentici in un singolo artefatto con un manifest dichiarativo. Un plugin può contenere:

- una o più **skill**
- uno o più **custom agent (subagent)**
- una o più definizioni di **hook**
- una o più configurazioni di **MCP server**

Il file manifest chiamato `plugin.json` elenca i componenti e i loro file path relativi. Un plugin installato espone tutti i suoi componenti all'agente come se fossero stati definiti localmente nel repository.

### Marketplace

Un **marketplace** è un registry di plugin pubblicato come repository Git accessibile (pubblico o privato). Contiene un indice di plugin e funge da source per l'installazione. Concettualmente è analogo a un package registry (npm, NuGet, PyPI), ma per artefatti agentici invece che per librerie di codice.

### Portabilità del bundle

Lo stesso plugin può essere utilizzato da differenti coding agent:
- **Copilot CLI** (terminal),
- **Copilot Chat in VS Code** (IDE),
- **Claude Code**.

## Hands-on

### Step 1 - Installa un marketplace + plugin reale

Useremo il marketplace [render93/gh-copilot-dev-days-2026](https://github.com/render93/gh-copilot-dev-days-2026) (nome interno `dev-days-2026-marketplace`), che contiene 3 plugin showcase (`pr-helper`, `dev-guardian`, `story-crafter`).

È un **marketplace** - un registry che indicizza più plugin, non un singolo plugin - quindi il flusso è in due fasi: prima lo registri come source, poi sfogli e installi i singoli plugin.

> Il supporto ai plugin è governato dalla setting `chat.plugins.enabled`, gestita a livello **organizzazione**. Se non vedi la sezione Plugins o i comandi `Chat: …`, chiedi al tuo amministratore di abilitarla.

**1a - Registra il marketplace**

Apri i settings di VS Code (`Cmd+,` o `Ctrl+,`) e cerca `chat.plugins.marketplaces`. È un array di URL di repository Git che espongono un marketplace. Aggiungi il marketplace `https://github.com/render93/gh-copilot-dev-days-2026`

**1b - Sfoglia e installa `dev-guardian`**

Registrato il marketplace, installa il plugin in uno di questi modi:

*Da Extensions view*
1. Apri la Extensions view con `Cmd+Shift+X` (macOS) o `Ctrl+Shift+X` (Windows/Linux).
2. Digita `@agentPlugins` nella barra di ricerca: compaiono i plugin dei marketplace configurati.
3. Click su **Install** in corrispondenza di `dev-guardian`.

*Da Impostazioni*
1. Apri le impostazioni di VS Code (`Cmd+,` o `Ctrl+,`) e cerca `chat.plugins.marketplaces`. È un array di URL di repository Git che espongono un marketplace.
2. Aggiungi il marketplace `https://github.com/render93/gh-copilot-dev-days-2026`
3. Digita `@agentPlugins` nella barra di ricerca: compaiono i plugin dei marketplace configurati.
4. Click su **Install** in corrispondenza di `dev-guardian`.

### Step 3 - Crea il tuo plugin

Combina gli artefatti dei moduli precedenti in un plugin coerente: `copilot-safety-guard`. Crea un nuovo repository con questa struttura **nella root del workspace** (`<repo-root>/plugins/copilot-safety-guard/`):

```
plugins/copilot-safety-guard/
├── plugin.json                         (manifest del bundle)
├── hooks.json                          (registra l'hook preToolUse => script)
├── skills/
│   └── endpoint-creator/SKILL.md       (copiata da .github/skills/endpoint-creator/SKILL.md)
├── agents/
│   └── code-reviewer.agent.md          (copiato da .github/agents/code-reviewer.agent.md)
└── scripts/
    ├── pre-tool-use.sh                 (copiato da .copilot/hooks/pre-tool-use.sh)
    └── pre-tool-use.ps1                (copiato da .copilot/hooks/pre-tool-use.ps1)
```

Il manifest `plugins/copilot-safety-guard/plugin.json` dichiara i componenti come **campi top-level**: `skills` e `agents` puntano alle rispettive **directory**, mentre `hooks` punta al file di configurazione `hooks.json`.

```json
{
  "name": "copilot-safety-guard",
  "version": "0.1.0",
  "description": "Workshop plugin: endpoint-creator skill + code-reviewer subagent + safety preToolUse hook for guarded agentic development.",
  "author": {
    "name": "Workshop Participant",
    "email": "you@example.com"
  },
  "license": "MIT",
  "keywords": ["safety", "review", "demo", "dev-days-2026"],
  "skills": "skills",
  "agents": "agents",
  "hooks": "hooks.json"
}
```

Gli hook non si dichiarano nel manifest ma in `hooks.json`, che mappa l'evento al comando da eseguire. Nel formato Copilot lo script si indica con un **path relativo** alla cartella del plugin, usando `bash` per Unix/macOS e `powershell` per Windows:

```json
{
  "version": 1,
  "hooks": {
    "preToolUse": [
      {
        "type": "command",
        "bash": "./scripts/pre-tool-use.sh",
        "powershell": "./scripts/pre-tool-use.ps1",
        "timeoutSec": 5
      }
    ]
  }
}
```

Il manifest quindi non punta direttamente allo script: dichiara `"hooks": "hooks.json"`, e all'installazione il client (Copilot Chat / Copilot CLI / Claude Code) legge `hooks.json` e registra l'hook con il proprio meccanismo nativo - non serve creare manualmente `.github/hooks/pre-tool-use.json` come faresti a mano nel workspace.

## Wrap

- Plugin = insieme di estensioni per agenti AI (skill, agent, hook, MCP server) raccolti in un bundle versionato con manifest dichiarativo.
- Marketplace = registry da cui i plugin si installano (pubblico, privato o enterprise-managed).

## Cosa ti porti a casa

- `dev-guardian` installato e ispezionato come reference completo.
- Plugin `plugins/copilot-safety-guard/` al root del workspace, con `plugin.json` e `hooks.json`, pronto in teoria per essere pubblicato.

Se ti blocchi: `solution/plugins/copilot-safety-guard/` contiene il bundle plugin completo da copiare al root del repo.