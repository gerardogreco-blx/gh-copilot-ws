# Modulo M4 — Distribuzione · Plugins & Marketplace

> Obiettivo: trasformare gli artefatti agentic privati (skill, subagent, hook, MCP config) in **unità distribuibili e installabili** condivisibili col team o l'organizzazione.

## Teoria

### Plugin

Un plugin è un **bundle versionato** che raccoglie più componenti agentic in un singolo artefatto con un manifest dichiarativo. Un plugin può contenere:

- una o più **skill**
- uno o più **custom agent (subagent)**
- una o più definizioni di **hook**
- una o più configurazioni di **MCP server**
- eventualmente **slash command**

Il file manifest (tipicamente `plugin.json`) elenca i componenti e i loro file path relativi. Un plugin installato espone tutti i suoi componenti all'agente come se fossero stati definiti localmente nel repository.

### Marketplace

Un **marketplace** è un registry di plugin pubblicato come repository Git accessibile (pubblico o privato). Contiene un indice di plugin (di solito una struttura `plugins/<nome>/` con i manifest) e funge da source per l'installazione. Concettualmente è analogo a un package registry (npm, NuGet, PyPI), ma per artefatti agentic invece che per librerie di codice.

Tipologie:
- **Awesome GitHub Copilot** — marketplace pubblico mantenuto da GitHub, è il default per Copilot CLI e Copilot Chat in VS Code.
- **Marketplace di terze parti** — chiunque può pubblicare un repo Git come marketplace. Si registra al client (CLI o IDE) come source aggiuntiva.
- **Enterprise-managed plugins** — distribuzione interna controllata, dove un admin enterprise gestisce centralmente quali plugin sono disponibili agli utenti dell'organizzazione.

### Portabilità del bundle

Lo stesso plugin (stessa struttura di file + manifest) può essere consumato da **superfici diverse** senza modifiche:
- **Copilot CLI** (terminal),
- **Copilot Chat in VS Code** (IDE),
- **Claude Code**.

È la stessa proprietà che ha `AGENTS.md` come standard cross-tool, estesa all'intero modello di estensione agentic.

## Hands-on

### Step 1 — Installa un marketplace + plugin reale

Useremo il marketplace [render93/gh-copilot-dev-days-2026](https://github.com/render93/gh-copilot-dev-days-2026), che contiene 3 plugin showcase (`pr-helper`, `dev-guardian`, `story-crafter`).

#### Cosa fa lo speaker dal palco (Copilot CLI)

Per dimostrazione, dalla terminale:

```bash
copilot plugin marketplace add https://github.com/render93/gh-copilot-dev-days-2026.git
copilot plugin install dev-guardian
```

Questi sono i comandi del **Copilot CLI** — *non* funzionano in VS Code Copilot Chat (che ha un meccanismo separato).

#### Cosa fai tu in VS Code Copilot Chat

La procedura in IDE è diversa. Hai due opzioni:

**Opzione A — Da Command Palette** (la più veloce):
1. Apri Command Palette con `Cmd+Shift+P` (macOS) o `Ctrl+Shift+P` (Windows/Linux).
2. Digita ed esegui: `Chat: Install Plugin From Source`.
3. Incolla l'URL: `https://github.com/render93/gh-copilot-dev-days-2026`.
4. VS Code clona il repo e installa i plugin disponibili. Trovi i file installati sotto `~/.copilot/installed-plugins/_direct/`.

**Opzione B — Da Agent Customizations editor**:
1. Apri Copilot Chat.
2. Click sull'icona ingranaggio "Configure Chat" → si apre l'Agent Customizations editor (in alternativa: Command Palette → `Chat: Open Customizations`).
3. Vai alla sezione **Plugins** → click sul pulsante `+` → incolla l'URL del repository → conferma.

**Configurare un marketplace aggiuntivo (opzionale, per il futuro)**:

Se vuoi che VS Code conosca il marketplace come source persistente per più plugin, aggiungi questo al tuo `settings.json` di **utente** (non di workspace — le marketplace si configurano solo a livello user):

```json
"chat.plugins.marketplaces": [
  "https://github.com/render93/gh-copilot-dev-days-2026"
]
```

Apri Command Palette → `Preferences: Open User Settings (JSON)` per modificarlo.

### Step 2 — Ispeziona `dev-guardian`

Una volta installato `dev-guardian`, esploralo (è una cartella di file leggibili — un plugin non è una black box). Contiene:

- **3 skill** in `dev-guardian/skills/`
- **1 custom agent** `test-writer` in `dev-guardian/agents/`
- **1 MCP server** `filesystem` configurato
- **2 hook**: `postToolUse` e `sessionStart`

Punto chiave: il hook `postToolUse` di `dev-guardian` usa **lo stesso meccanismo** che hai costruito tu in M3 (un hook che riceve JSON su stdin e termina con un exit code). Stesso contratto, scopo applicativo diverso (audit invece di blocco).

### Step 3 — Impacchetta il tuo plugin

Combina gli artefatti dei moduli precedenti in un plugin coerente: `copilot-safety-guard`. Crea questa struttura nel tuo starter:

```
plugins/copilot-safety-guard/
├── plugin.json
├── skills/
│   └── endpoint-creator/SKILL.md      (copiata da M1)
├── agents/
│   └── code-reviewer.agent.md          (copiato da M2)
└── hooks/
    ├── pre-tool-use.sh                  (copiato da M3, variante bash)
    └── pre-tool-use.ps1                 (copiato da M3, variante pwsh)
```

Il plugin manifest (`plugin.json`) dichiara la chiave `hooks.preToolUse` puntando direttamente allo script. Quando un utente installa il plugin, il client (Copilot CLI / Copilot Chat / Claude Code) registra automaticamente il hook con il proprio meccanismo nativo — non serve creare manualmente `.github/hooks/pre-tool-use.json` come avresti fatto a mano. Il manifest è il "punto di registrazione" centralizzato del bundle.

E un manifest `plugins/copilot-safety-guard/plugin.json`:

```json
{
  "name": "copilot-safety-guard",
  "version": "0.1.0",
  "description": "Workshop plugin: endpoint-creator skill + code-reviewer subagent + safety PreToolUse hook for guarded agentic development.",
  "components": {
    "skills": ["./skills/endpoint-creator"],
    "agents": ["./agents/code-reviewer.agent.md"],
    "hooks": {
      "preToolUse": "./hooks/pre-tool-use.sh"
    },
    "mcpServers": []
  },
  "author": "Workshop Participant",
  "license": "MIT"
}
```

Per pubblicarlo davvero: fork del tuo repo, push su GitHub, e da quel punto chiunque può installarlo con la stessa procedura di Step 1 (puntando al tuo URL invece che a `render93/gh-copilot-dev-days-2026`). In aula non pubblichiamo — è una dimostrazione della pipeline, non un atto di distribuzione.

## Wrap

- Plugin = unità di distribuzione dell'estensione agentic.
- Marketplace = registry da cui i plugin si installano (pubblico, privato, o enterprise-managed).
- Tre superfici (CLI, VS Code Chat, Claude Code), un solo bundle. Stesso pattern di `AGENTS.md` cross-tool, esteso a tutto il sistema di estensione.

## Cosa ti porti a casa

- `dev-guardian` installato e ispezionato come reference completo.
- Plugin `plugins/copilot-safety-guard/` nel tuo starter, con manifest, pronto in teoria per essere pubblicato.

Se ti blocchi: `solution/{linguaggio}/` contiene il bundle plugin completo.

➡️ Ora il microfono passa al co-speaker per **M5 — Spec-Driven Development**.
