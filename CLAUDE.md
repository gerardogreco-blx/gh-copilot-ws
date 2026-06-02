# CLAUDE.md — Workshop Repo

> Questo file fa sì che **Claude Code** (estensione VS Code e CLI) usi lo **stesso contratto di repository** di GitHub Copilot. Il contenuto vero vive in `AGENTS.md`: qui sotto lo importiamo, così c'è **una sola fonte di verità** per entrambi gli strumenti — senza duplicare nulla.

@AGENTS.md

## Note specifiche per Claude Code

Il workshop "The Agent Strikes Back" è scritto attorno a GitHub Copilot, ma **ogni modulo ha la controparte Claude Code** (estensione VS Code). Concetti, prompt ed esercizi sono **identici**: cambiano solo i path dei file di configurazione e i comandi dell'IDE. In ogni `modules/Mn/README.md` cerca i blocchi **🔵 Claude Code**.

Mappa delle customizations che il partecipante crea progressivamente con Claude Code (equivalenti delle customizations Copilot elencate sopra in `AGENTS.md`), tutte **al root del workspace**:

- `.claude/skills/endpoint-creator/SKILL.md` (M1) — stesso formato di `.github/skills/...`
- `.claude/agents/code-reviewer.md` (M2) — equivalente di `.github/agents/code-reviewer.agent.md`
- `.claude/agents/dba.md` + `.claude/settings.json` con hook `SubagentStart` (M3 — iniezione di contesto)
- `.claude/settings.json` con hook `PreToolUse` + `.claude/policy.yml` + `.claude/hooks/*.{sh,ps1}` + `.claude/context/db-schema.sql` (M3, appendice — policy enforcement)
- `plugins/claude-safety-guard/` con `.claude-plugin/plugin.json` + `.claude-plugin/marketplace.json` al root (M4)

Configurazione MCP per Claude Code: `.mcp.json` al root del workspace (equivalente di `.vscode/mcp.json` per Copilot).

Riferimento, se ti blocchi: `modules/Mn/solution/.claude/` contiene la versione finale di ogni modulo per Claude Code, in parallelo a `modules/Mn/solution/.github/` (e `.copilot/`) per Copilot.
