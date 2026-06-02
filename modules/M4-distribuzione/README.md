# Modulo M4 - Distribuzione · Plugins & Marketplace

> Obiettivo: trasformare gli artefatti agentic privati (skill, subagent, hook, configurazioni di MCP server) in **unità distribuibili e installabili** condivisibili col team o l'organizzazione.

> 🔵 **Claude Code (estensione VS Code)?** Modulo identico nei concetti: plugin = bundle versionato, marketplace = registry Git. Differenze tecniche: il manifest è `.claude-plugin/plugin.json` (i componenti `skills/`, `agents/`, `hooks/hooks.json` sono **auto-scoperti** dalle cartelle convenzionali), il marketplace è `.claude-plugin/marketplace.json`, e l'installazione usa i comandi `/plugin marketplace add` e `/plugin install`. Sotto ogni passo trovi un blocco 🔵. Riferimenti in `modules/M4-distribuzione/solution/.claude/` e `modules/M4-distribuzione/solution/plugins/claude-safety-guard/`.

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

Registrato il marketplace in 1a, installa il plugin:

1. Apri la Extensions view con `Cmd+Shift+X` (macOS) o `Ctrl+Shift+X` (Windows/Linux).
2. Digita `@agentPlugins` nella barra di ricerca: compaiono i plugin dei marketplace configurati.
3. Click su **Install** in corrispondenza di `dev-guardian`.

<details>
<summary>🔵 <b>Claude Code — Step 1 (installa un marketplace + plugin reale)</b></summary>

Il marketplace `render93/gh-copilot-dev-days-2026` è in formato Copilot (`.github/plugin/marketplace.json`), quindi non è installabile da Claude Code, che legge `.claude-plugin/marketplace.json`. Per provare l'installazione di un plugin **reale** con Claude Code usa il marketplace community ufficiale (stesso flusso in due fasi: registri il source, poi installi un plugin):

```
/plugin marketplace add anthropics/claude-plugins-community
/plugin
```

Il comando `/plugin` apre il gestore: vai su **Marketplaces**, sfoglia i plugin del community marketplace e clicca **Install** su uno a tua scelta. (In alternativa: `/plugin install <nome>@claude-community`.) Concetto identico allo Step 1 Copilot: prima il source, poi il singolo plugin.

</details>

### Step 2 - Ispeziona dev-guardian

Prima di costruire il tuo, guarda com'è fatto un plugin reale. Apri la cartella del plugin [`dev-guardian`](https://github.com/render93/gh-copilot-dev-days-2026/tree/main/plugins/dev-guardian) e osserva l'anatomia del bundle:

- `plugin.json` — il manifest: dichiara `skills`, `agents`, `hooks` (e `mcpServers`) puntando alle rispettive directory/file.
- `hooks.json` — mappa un evento (es. `preToolUse`) allo script da eseguire.
- `skills/`, `agents/`, `scripts/` — i componenti veri e propri.

È la stessa struttura che ricreerai nello Step 3 per il tuo plugin.

<details>
<summary>🔵 <b>Claude Code — Step 2 (ispeziona un plugin reale)</b></summary>

Stesso obiettivo: guardare l'anatomia di un plugin reale prima di costruirne uno. Apri la cartella di un plugin che hai installato dal community marketplace (oppure sfoglia un repo di plugin Claude su GitHub) e osserva:
- `.claude-plugin/plugin.json` — il manifest (name, version, description).
- `hooks/hooks.json` — mappa un evento (es. `PreToolUse`) allo script.
- `skills/`, `agents/`, `scripts/` — i componenti, **auto-scoperti** dalle cartelle convenzionali (non serve elencarli nel manifest).

È la stessa struttura che ricreerai nello Step 3.

</details>

### Step 3 - Crea il tuo plugin

Combina gli artefatti dei moduli precedenti in un plugin coerente: `copilot-safety-guard`. Crea un nuovo repository con questa struttura **nella root del workspace** (`<repo-root>/plugins/copilot-safety-guard/`):

```
plugins/copilot-safety-guard/
├── plugin.json                         (manifest del bundle)
├── hooks.json                          (registra l'hook preToolUse => script)
├── policy.yml                          (regole di blocco lette dagli script hook - copiata da .copilot/policy.yml)
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

> Lo script `pre-tool-use` legge le regole di blocco da `policy.yml` (nella cartella del plugin, risolta dallo script come `../policy.yml`): se quel file non viene impacchettato l'hook gira ma non blocca nulla. Per questo `policy.yml` fa parte del bundle.

<details>
<summary>🔵 <b>Claude Code — Step 3 (crea il tuo plugin)</b></summary>

Stesso bundle, struttura Claude. Crea `plugins/claude-safety-guard/` al root del workspace:

```
plugins/claude-safety-guard/
├── .claude-plugin/
│   └── plugin.json            (manifest: solo metadati — i componenti sono auto-scoperti)
├── hooks/
│   └── hooks.json             (registra l'hook PreToolUse => script)
├── policy.yml                 (regole di blocco, copiata da .claude/policy.yml)
├── skills/
│   └── endpoint-creator/SKILL.md   (copiata da .claude/skills/...)
├── agents/
│   └── code-reviewer.md        (copiato da .claude/agents/code-reviewer.md)
└── scripts/
    ├── pre-tool-use.sh         (versione Claude: tool_name/tool_input, exit 2)
    └── pre-tool-use.ps1
```

`.claude-plugin/plugin.json` contiene **solo metadati**: `skills/`, `agents/` e `hooks/hooks.json` vengono auto-scoperti dalle cartelle convenzionali (non serve dichiararli, a differenza del manifest Copilot).

```json
{
  "name": "claude-safety-guard",
  "version": "0.1.0",
  "description": "Workshop plugin: endpoint-creator skill + code-reviewer subagent + safety PreToolUse hook for guarded agentic development.",
  "author": { "name": "Workshop Participant", "email": "you@example.com" },
  "license": "MIT",
  "keywords": ["safety", "review", "demo", "dev-days-2026"]
}
```

Gli hook si dichiarano in `hooks/hooks.json` (stesso formato della chiave `hooks` di `settings.json`); lo script si referenzia con la variabile `${CLAUDE_PLUGIN_ROOT}`:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash|Edit|Write|MultiEdit",
        "hooks": [
          { "type": "command", "command": "${CLAUDE_PLUGIN_ROOT}/scripts/pre-tool-use.sh", "timeout": 5 }
        ]
      }
    ]
  }
}
```

Come per Copilot, lo script legge `policy.yml` (risolto come `../policy.yml` rispetto a `scripts/`): se non lo impacchetti, l'hook gira ma non blocca nulla. Reference completo: `modules/M4-distribuzione/solution/plugins/claude-safety-guard/`.

</details>

### Step 4 - Pubblica il tuo plugin

Un plugin diventa installabile quando vive in un repository che fa da **marketplace**. Serve un file indice `.github/plugin/marketplace.json` che elenca i plugin del repo:

```json
{
  "name": "my-workshop-marketplace",
  "owner": { "name": "Your Name", "email": "you@example.com" },
  "metadata": {
    "description": "Il mio marketplace del workshop",
    "version": "0.1.0",
    "pluginRoot": "./plugins"
  },
  "plugins": [
    {
      "name": "copilot-safety-guard",
      "description": "endpoint-creator skill + code-reviewer subagent + safety preToolUse hook.",
      "version": "0.1.0",
      "source": "copilot-safety-guard"
    }
  ]
}
```

`pluginRoot` indica la cartella che contiene i plugin (`./plugins`); `source` è il nome della sottocartella del plugin sotto `pluginRoot`. Poi:

1. `git add . && git commit && git push` su un repository Git accessibile. Il tuo fork del workshop va benissimo: ha già `plugins/copilot-safety-guard/` al root.
2. In un altro workspace (o un collega) aggiunge l'URL del tuo repo a `chat.plugins.marketplaces`, esattamente come in **1a** con il marketplace di esempio.
3. `@agentPlugins` => compare `copilot-safety-guard` => **Install**.

Questo chiude il cerchio: hai creato un plugin (Step 3) e l'hai reso installabile da un marketplace, come `dev-guardian` nello Step 1.

<details>
<summary>🔵 <b>Claude Code — Step 4 (pubblica il tuo plugin)</b></summary>

Per Claude Code l'indice del marketplace è **`.claude-plugin/marketplace.json`** al root del repo:

```json
{
  "name": "my-workshop-marketplace",
  "owner": { "name": "Your Name", "email": "you@example.com" },
  "metadata": { "description": "Il mio marketplace del workshop", "version": "0.1.0", "pluginRoot": "./plugins" },
  "plugins": [
    {
      "name": "claude-safety-guard",
      "source": "claude-safety-guard",
      "description": "endpoint-creator skill + code-reviewer subagent + safety PreToolUse hook.",
      "version": "0.1.0"
    }
  ]
}
```

`metadata.pluginRoot` (`./plugins`) viene anteposto ai `source` relativi, quindi `source: "claude-safety-guard"` risolve a `./plugins/claude-safety-guard`. Poi:

1. `git add . && git commit && git push` sul tuo fork (ha già `plugins/claude-safety-guard/` e `.claude-plugin/marketplace.json` al root).
2. Tu (o un collega) in un altro workspace: `/plugin marketplace add <url-del-tuo-repo>` poi `/plugin install claude-safety-guard@my-workshop-marketplace`.

Chiude il cerchio esattamente come la versione Copilot. Reference: `modules/M4-distribuzione/solution/.claude-plugin/marketplace.json`.

</details>

## Wrap

- Plugin = insieme di estensioni per agenti AI (skill, agent, hook, MCP server) raccolti in un bundle versionato con manifest dichiarativo.
- Marketplace = registry da cui i plugin si installano (pubblico, privato o enterprise-managed).

## Cosa ti porti a casa

- `dev-guardian` installato e ispezionato come reference completo.
- Plugin `plugins/copilot-safety-guard/` al root del workspace, con `plugin.json`, `hooks.json` e `policy.yml`.
- Marketplace pubblicato via `.github/plugin/marketplace.json` e plugin installabile con `@agentPlugins`.

Se ti blocchi: `solution/plugins/copilot-safety-guard/` contiene il bundle plugin completo e `solution/.github/plugin/marketplace.json` l'indice del marketplace, da copiare al root del repo.

> 🔵 Claude Code: il bundle di riferimento è in `solution/plugins/claude-safety-guard/` e l'indice del marketplace in `solution/.claude-plugin/marketplace.json`.

🎉 Hai completato tutti i moduli del workshop! Torna al [README principale](../../README.md).
