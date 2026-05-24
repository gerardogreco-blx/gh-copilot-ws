# Modulo M2 — Capacità · Subagents + MCP

> Obiettivo: vedere due assi indipendenti con cui si estende un agente. **Subagents**: delega di task con contesto isolato. **MCP**: protocollo standard per esporre nuovi tool e risorse all'agente.

## Teoria

### Subagent

Un subagent è un agente "figlio" invocato dal main agent per gestire un task delimitato. La caratteristica chiave è il **contesto isolato**: il subagent non eredita la cronologia conversazionale del main agent — riceve solo il prompt esplicito che gli si passa.

Conseguenze concrete:
- **Riduzione del rumore in input**: il subagent non deve discriminare tra istruzioni rilevanti per il suo task e dettagli accumulati nella conversazione precedente. La sua attenzione è concentrata sull'input ricevuto.
- **Output strutturato verso il main agent**: il main agent riceve un risultato sintetico, non l'intero ragionamento intermedio. Questo limita la crescita del contesto del main agent (e quindi il costo per turno).
- **Parallelizzabilità**: subagent indipendenti possono essere eseguiti in parallelo. Esempio tipico: lanciare contemporaneamente `code-reviewer` su 3 file diversi.

**Quando usare un subagent**: task ben definito, isolabile, con output verificabile (code review di un file, generazione di test per una funzione, ricerca focalizzata, refactor mirato).

**Quando NON usare un subagent**: conversazione iterativa, esplorazione open-ended, Q&A — meglio restare in modalità chat.

#### Anatomia di un subagent

Un subagent è definito in un file `agents/<nome>.agent.md` con frontmatter YAML:

```yaml
---
name: code-reviewer
description: Specialized subagent for code review. Invoke when you want a structured review of a file or function for correctness, security, AGENTS.md compliance, and test coverage.
tools: [Read, Grep, Bash]
model: claude-sonnet-4-6
---
```

- `name`: identificatore invocabile (`@code-reviewer` nella chat).
- `description`: criterio di selezione del subagent da parte del main agent. Anche qui, in termini di *quando invocarlo*.
- `tools`: **allowlist** dei tool che il subagent può usare (principio del minimo privilegio — il code-reviewer non ha bisogno di `Write` o `Edit`).
- `model`: opzionale, per pinning di un modello specifico al subagent.

### MCP (Model Context Protocol)

MCP è un **protocollo aperto** per esporre *tools* (funzioni invocabili) e *resources* (dati leggibili) a un agente, separando il contratto di interazione (JSON-RPC su stdio o HTTP) dall'implementazione del server.

Un MCP server è un processo (locale o remoto) che parla questo protocollo. L'agente lo registra come fornitore di capacità, e quando ha bisogno di un tool esposto dal server, lo invoca attraverso il protocollo. Lo stesso server può essere consumato da agenti diversi (Copilot, Claude, ecc.) senza modifiche.

**Quando un MCP server fornisce valore**: quando espone capacità che **non sono già disponibili come CLI standard**. Un MCP che wrappa `git` o `gh` aggiunge poco rispetto a chiedere all'agente di usare quei comandi direttamente.

**Esempio buono**: `Context7` espone *documentazione aggiornata* delle librerie del progetto (recuperata via API). Non c'è un equivalente CLI generico; il problema "le mie librerie sono cambiate e l'agente conosce una versione vecchia" è reale e non risolto altrimenti.

**Esempio meno utile**: `gh-mcp` espone le API di GitHub. Ma il CLI `gh` fa già lo stesso, ed è già nel PATH dell'agente.

### Composizione subagent + MCP

I due assi sono ortogonali:
- Il **subagent** definisce *chi* esegue, *con quale slice* di scope, *con quale contesto*.
- L'**MCP** definisce *quali tool* sono disponibili durante l'esecuzione.

Un subagent che gira con accesso a un MCP è un'unità di lavoro componibile e auditabile.

## Hands-on

### Step 1 — Attiva Context7 in Copilot Chat e usalo

Lo starter ha già pronto il file di configurazione MCP a livello workspace: `.vscode/mcp.json`.

```json
{
  "servers": {
    "context7": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp"]
    }
  }
}
```

Questo è il path che VS Code Copilot Chat riconosce automaticamente per gli MCP server di workspace. Quando apri il Codespace (o il workspace in locale), VS Code rileva il file e ti propone di avviare il server.

**Per gestire i server MCP**:
- Da Command Palette: `MCP: Open Workspace Folder Configuration` apre il file di config corrente.
- Da Command Palette: `MCP: List Servers` mostra l'elenco dei server registrati e il loro stato (running / stopped).
- Click sull'icona ingranaggio in Copilot Chat → "MCP Servers" per la stessa UI grafica.

**Verifica**: in Copilot Chat (Agent mode), dovresti vedere `context7` nell'elenco dei server attivi. Al primo utilizzo, `npx -y @upstash/context7-mcp` scarica il package se non già presente (il `post-create.sh` del devcontainer lo pre-scarica per noi).

Ora chiedi all'agente:
> Verifica che il handler di `POST /tasks` usi l'API attuale della libreria del mio starter (FastAPI / Hono / ASP.NET Core). Usa Context7 per recuperare le docs più recenti e dimmi se ci sono pattern più moderni per la validazione.

Osserva: l'agente invoca un tool di Context7 (visibile nella chat come tool-call), riceve le docs, e produce un'analisi confrontando il codice attuale con l'API documentata.

### Step 2 — Invoca il subagent `code-reviewer`

Lo starter contiene `agents/code-reviewer.agent.md` con il frontmatter visto sopra. Aprilo e leggilo: nota la allowlist di tool (`Read`, `Grep`, `Bash` — niente `Write`/`Edit`).

In Copilot Chat:
> @code-reviewer revisiona il controller dei task (`TasksEndpoints.cs` / `routes.ts` / `main.py`) per correttezza, sicurezza e conformità ad AGENTS.md.

Osserva:
- il subagent parte (la chat mostra l'invocazione del subagent come task separato);
- il contesto della tua conversazione precedente NON viene passato — solo il prompt esplicito;
- l'output è strutturato nei 5 blocchi definiti dal subagent (Correctness, Security, AGENTS.md compliance, Test coverage, Suggested fixes).

### Step 3 — Composizione: subagent + MCP insieme

Chiedi:
> @code-reviewer revisiona il controller dei task. Usa Context7 per verificare che ogni chiamata libreria usi l'API attuale (non deprecata).

Il subagent ha accesso a Context7 attraverso l'agente che lo invoca: la review include ora un check di conformità alla versione corrente delle librerie.

## Wrap

- **Subagent**: unità di esecuzione delegata, contesto isolato, output strutturato, eventualmente parallelizzabile.
- **MCP**: protocollo per esporre tool/risorse all'agente. Vale la pena quando il problema risolto **non è già coperto da una CLI standard**.
- Insieme producono pattern componibili e auditabili: "chi fa cosa, con quale contesto, con quali tool".

## Cosa ti porti a casa

- `context7` MCP server registrato e funzionante in Copilot Chat.
- Subagent `code-reviewer` invocabile via `@code-reviewer` nello starter.

Se ti blocchi: `solution/{linguaggio}/` ha lo stato finale del modulo.

➡️ Prossimo modulo: [`../M3-governance/README.md`](../M3-governance/README.md)
