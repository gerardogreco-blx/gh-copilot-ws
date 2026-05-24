# Soluzione attesa M2

A fine modulo dovresti vedere:

1. **Context7 attivo** in Copilot Chat: nell'elenco dei server MCP collegati c'è `context7`, e quando lo invochi vedi le docs nelle risposte.

2. **Subagent `code-reviewer` invocabile**: il file `agents/code-reviewer.agent.md` è presente nella tua starter e `@code-reviewer` parte restituendo una review nei 5 blocchi (Correctness, Security, AGENTS.md compliance, Test coverage, Suggested fixes).

3. **Composizione**: `@code-reviewer` può usare Context7. Output deve referenziare docs aggiornate quando applicabile.

## Verifica manuale
- Apri `agents/code-reviewer.agent.md` — frontmatter leggibile.
- Settings Copilot Chat → MCP servers → `context7` ✓.
