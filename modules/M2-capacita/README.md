# Modulo M2 — Capacità · Subagents + MCP · 18 min

> Obiettivo: vedere come un agente può **delegare** task (subagent) e **acquisire nuovi tool** (MCP).

## Teoria (5 min)

### Subagent
- Task delegato a un agente "figlio" con **contesto isolato** (non eredita la chat: solo il prompt che gli passi).
- Vantaggi del contesto isolato:
  - Non "annacqua" l'attenzione con la conversazione precedente
  - Il main agent riceve un riassunto pulito, non i dettagli intermedi
  - Parallelizzabile (più subagent in parallelo per task indipendenti)
- Quando usare un subagent vs ask mode:
  - **Subagent**: task ben definito e isolabile (review file, refactor funzione, ricerca focalizzata, generazione test).
  - **Ask mode**: conversazione iterativa, esplorazione, Q&A.

#### Anatomia di un subagent
```
agents/<nome>.agent.md
```

Frontmatter:
```yaml
---
name: code-reviewer
description: Specializzato in code review (correttezza, sicurezza, conformità ad AGENTS.md). Usalo per file/funzioni singole.
tools: [Read, Grep, Bash]
model: claude-sonnet-4-6
---
```

Il `description` è il criterio con cui il main agent decide quando invocarlo. `tools` restringe cosa può fare (minimo privilegio).

### MCP
- "USB-C per i tool dell'agente". Estende **come** l'agente acquisisce capacità, non chi le usa.
- Un MCP server espone **tools** (funzioni invocabili) e **resources** (dati leggibili) via protocollo standard.
- **Quando un MCP ha senso**: quando il problema **non è già risolto da una CLI standard**. Esempio: `gh-mcp` è meno utile perché esiste `gh`. **Context7** risolve un problema vero: docs aggiornate delle librerie, non risolto da CLI esistenti.

### Insieme
- Subagent = chi fa, con quale contesto.
- MCP = quali tool e dati ha in mano.
- Pattern componibile: subagent code-reviewer che usa Context7 per verificare API attuali.

## Hands-on (10 min)

### Step 1 — Attiva Context7 e usalo (4')

In Copilot Chat (Agent), aggiungi Context7 come server MCP (la configurazione è in `.devcontainer/mcp/context7.json` — copiala nelle settings di Copilot Chat).

Poi chiedi:
> Usando le docs attuali della libreria del tuo starter (FastAPI / Hono / ASP.NET Core) tramite Context7, verifica che il handler di `POST /tasks` usi l'API più recente. Se trovi un'API più moderna per la validazione, proponi un refactor.

Osserva l'MCP fetchare le docs nella chat.

### Step 2 — Invoca un subagent custom (4')

Lo starter ha già un subagent: `agents/code-reviewer.agent.md`. Aprilo per vederne il frontmatter.

Poi in Copilot Chat:
> @code-reviewer revisiona il controller dei task per correttezza, gestione errori e conformità al nostro AGENTS.md.

Osserva: il subagent parte con contesto isolato, restituisce una review strutturata.

### Step 3 — Componi i due (2')

Chiedi:
> @code-reviewer revisiona il controller usando Context7 per verificare che ogni chiamata libreria sia ancora API corrente.

## Wrap (3')

- **Subagent**: chi fa il lavoro, su quale slice, con quale contesto isolato.
- **MCP**: quali tool e quali dati ha l'agente.
- Insieme: sistema componibile dove ogni unità ha responsabilità chiara.

## Output del modulo
- Context7 MCP configurato e funzionante.
- Un subagent `code-reviewer` custom invocabile via `@code-reviewer`.

Se sei bloccato: `solution/{linguaggio}/`.

➡️ Prossimo: [`../M3-governance/README.md`](../M3-governance/README.md)
