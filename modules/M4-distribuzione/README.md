# Modulo M4 — Distribuzione · Plugins & Marketplace · 14 min

> Obiettivo: vedere come un plugin **bundle-zia** skill + subagent + hook + MCP in un singolo artefatto distribuibile.

## Teoria (4 min)

### Cos'è un plugin
Bundle (skill + agent + hook + MCP config) con manifest versionato. Installabile da marketplace come unità singola.

### Marketplace
- **Awesome GitHub Copilot** — marketplace default per CLI e VS Code Chat.
- **Enterprise-managed plugins** — distribuzione interna controllata.

### Portabilità
Lo **stesso bundle** funziona su **tre superfici**: Copilot CLI, Copilot Chat in VS Code, Claude Code. Una pipeline di distribuzione.

## Hands-on (7 min)

### Step 1 — Installa un plugin reale (3')

Lo speaker mostra dal proiettore (Copilot CLI):
```
copilot plugin marketplace add https://github.com/render93/gh-copilot-dev-days-2026.git
copilot plugin install dev-guardian
```

Tu dal Codespace (VS Code Copilot Chat):
1. Apri pannello Copilot Chat
2. Tasto destro → "Manage Plugins" → "Add from URL"
3. Incolla `https://github.com/render93/gh-copilot-dev-days-2026`
4. Installa `dev-guardian`

Esplora cosa fornisce `dev-guardian`:
- 3 skill
- 1 agent `test-writer`
- 1 MCP filesystem
- 2 hook (`postToolUse`, `sessionStart`)

**Punto chiave**: l'hook `postToolUse` di dev-guardian usa lo stesso meccanismo che hai costruito in M3 (PreToolUse). Stesso pattern, applicazione diversa.

### Step 2 — Impacchetta il tuo plugin (4')

Crea `plugins/copilot-safety-guard/` con:

```
plugins/copilot-safety-guard/
├── plugin.json
├── skills/endpoint-creator/SKILL.md      (da M1)
├── agents/code-reviewer.agent.md          (da M2)
└── hooks/pre-tool-use.sh                  (da M3)
```

Crea `plugins/copilot-safety-guard/plugin.json`:
```json
{
  "name": "copilot-safety-guard",
  "version": "0.1.0",
  "description": "Plugin di workshop che bundleizza endpoint-creator skill, code-reviewer subagent e safety hook PreToolUse.",
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

Non pubblichi: vedi *come* si farebbe.

## Wrap (3')

- Plugin = unit of distribution dell'agentic dev.
- Tre superfici, stesso bundle. Eco di AGENTS.md cross-tool, scalato.

## Output del modulo
- `dev-guardian` installato e ispezionato.
- Plugin `plugins/copilot-safety-guard/` con manifest.

Se sei bloccato: `solution/{linguaggio}/`.

➡️ Ora il microfono passa al co-speaker per M5 (Spec-Driven Development).
