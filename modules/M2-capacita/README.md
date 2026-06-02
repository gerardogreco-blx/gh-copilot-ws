# Modulo M2 - Capacità · Subagents + MCP

> Obiettivo: vedere due assi indipendenti con cui si estende un agente. **Subagents**: delega di task con contesto isolato. **MCP**: protocollo standard per esporre nuovi tool e risorse all'agente.

> 🔵 **Claude Code (estensione VS Code)?** Modulo identico. MCP è uno standard cross-tool: lo stesso server Context7 si usa da entrambi. Il subagent `code-reviewer` ha lo **stesso corpo** (system prompt); cambiano solo il frontmatter (nomi dei tool Claude) e la cartella (`.claude/agents/`). Sotto ogni passo trovi un blocco 🔵 con l'equivalente esatto.

## Teoria

### Subagent

Un subagent è un agente "figlio" invocato dal main agent per gestire un task delimitato. La caratteristica chiave è il **contesto isolato**: il subagent non eredita la cronologia conversazionale del main agent - riceve solo il prompt esplicito che gli si passa.

Conseguenze concrete:
- **Riduzione del rumore in input**: il subagent non deve discriminare tra istruzioni rilevanti per il suo task e dettagli accumulati nella conversazione precedente. La sua attenzione è concentrata sull'input ricevuto.
- **Output strutturato verso il main agent**: il main agent riceve un risultato sintetico, non l'intero ragionamento intermedio. Questo limita la crescita del contesto del main agent (e quindi il costo per turno).
- **Parallelizzabilità**: subagent indipendenti possono essere eseguiti in parallelo. Esempio tipico: lanciare contemporaneamente tre agenti `code-reviewer` su 3 file diversi e poi fare aggregare i risultati dal main agent.

**Quando usare un subagent**: task ben definito, isolabile, con output verificabile (code review di un file, generazione di test per una funzione, ricerca focalizzata, refactor mirato).

**Quando NON usare un subagent**: conversazione iterativa, esplorazione open-ended, Q&A. In questi casi, il contesto completo è un asset, non un rumore.

#### Anatomia di un subagent

Un subagent è definito in un file `agents/<nome>.agent.md` con frontmatter YAML:

```yaml
---
name: code-reviewer
description: Specialized subagent for code review. Invoke when you want a structured review of a file or function for correctness, security, AGENTS.md compliance, and test coverage.
tools: [search, 'context7/*']
model: claude-sonnet-4-6
---
```

- `name`: identificatore invocabile (`@code-reviewer` nella chat).
- `description`: criterio di selezione del subagent da parte del main agent. L'agente principale sceglie quale subagent invocare in base alla descrizione più adatta al task da delegare, se non specificato esplicitamente.
- `tools`: **allowlist** dei tool che il subagent può usare (principio del minimo privilegio - ad esempio il code-reviewer non ha bisogno di `edit`).
- `model`: opzionale, per scelta di un modello specifico al subagent. 

### MCP (Model Context Protocol)

MCP è uno standard che permette agli agenti AI di interagire con strumenti e sorgenti dati esterne tramite un’interfaccia comune. Un MCP server funge da ponte tra l’agente e i sistemi esterni, traducendo le richieste dell’AI nella logica specifica del tool sottostante, come API, filesystem o servizi custom.

Un MCP server è un processo, locale o remoto, che implementa questo protocollo ed espone una o più capacità utilizzabili dagli agenti. L’agente lo registra come provider di strumenti e, quando necessario, invoca i tool esposti dal server tramite MCP. Grazie a questo approccio, lo stesso MCP server può essere riutilizzato da agenti differenti (come GitHub Copilot o Anthropic Claude) senza dover modificare l’implementazione del server.

**Quando un MCP server fornisce valore**: quando espone capacità che **non sono già disponibili come CLI standard**. Un MCP che utilizza le API di GitHub aggiunge poco rispetto a chiedere all'agente di usare quei comandi tramite CLI.

`Context7` espone *documentazione aggiornata* delle librerie del progetto (recuperata via API). Non c'è un equivalente CLI generico; il problema "le mie librerie sono cambiate e l'agente conosce una versione vecchia" è reale e non risolto altrimenti.

### Composizione subagent + MCP

I due assi sono ortogonali:
- Il **subagent** definisce *chi* esegue, *con quale slice* di scope, *con quale contesto*.
- L'**MCP** definisce *quali tool* sono disponibili durante l'esecuzione.

Un subagent che gira con accesso a un MCP è un'unità di lavoro componibile e auditabile.

## Hands-on

### Step 1 - Attiva Context7 in Copilot Chat e usalo

Il file di configurazione MCP è già presente al root del workspace: `.vscode/mcp.json`.

```json
{
  "servers": {
    "context7": {
      "type": "http",
      "url": "https://mcp.context7.com/mcp"
    }
  }
}
```

**Perché HTTP remoto e non stdio locale**: Context7 espone un endpoint HTTP hosted (`https://mcp.context7.com/mcp`) che fornisce lo stesso protocollo MCP via HTTP invece che via stdio. Conseguenze pratiche:
- nessun processo locale (`npx`, `node`, container) deve girare sulla tua macchina;
- niente download all'avvio: il client apre solo una connessione HTTP;
- non serve Node.js installato se hai scelto solo lo starter .NET o Python.

VS Code Copilot Chat rileva automaticamente il file `.vscode/mcp.json` quando apri il workspace e ti propone di abilitare il server `context7`.

**Per gestire i server MCP**:
- Da Command Palette: `MCP: Open Workspace Folder Configuration` apre il file di config corrente.
- Da Command Palette: `MCP: List Servers` mostra l'elenco dei server registrati e il loro stato.
- Click sull'icona ingranaggio in Copilot Chat => "MCP Servers" per la stessa UI grafica.

Ora chiedi all'agente:
> Nel progetto `@modules/M2-capacita/starters/<linguaggio>` verifica che il handler di `POST /tasks` usi l'API attuale della libreria del mio starter (FastAPI / Hono / ASP.NET Core). Usa Context7 per recuperare le docs più recenti e dimmi se ci sono pattern più moderni per la validazione.

Osserva: l'agente invoca un tool di Context7 (visibile nella chat come tool-call), riceve le docs, e produce un'analisi confrontando il codice attuale con l'API documentata.

<details>
<summary>🔵 <b>Claude Code — Step 1 (Context7 via MCP)</b></summary>

Claude Code usa il file **`.mcp.json`** al root del workspace (già presente), equivalente di `.vscode/mcp.json` ma con la chiave `mcpServers`:

```json
{
  "mcpServers": {
    "context7": { "type": "http", "url": "https://mcp.context7.com/mcp" }
  }
}
```

Stesse conseguenze (HTTP hosted, nessun processo locale, niente Node.js richiesto). Claude Code rileva `.mcp.json` all'apertura del workspace e chiede l'approvazione del server. Per gestire i server MCP digita **`/mcp`** nel pannello Claude Code (stato, abilitazione, autenticazione).

Poi usa **lo stesso prompt** dello Step 1: Claude invoca i tool di Context7 (`resolve-library-id`, `get-library-docs`, visibili come tool-call) e confronta il codice con l'API documentata.

</details>

### Step 2 - Crea il subagent `code-reviewer`

Crea il file `.github/agents/code-reviewer.agent.md` **al root del workspace** con questo contenuto:

```markdown
---
name: code-reviewer
description: Specialized subagent for code review. Invoke when you want a structured review of a file or function for correctness, security, AGENTS.md compliance, and test coverage.
tools: [search, 'context7/*']
model: claude-sonnet-4-6
---

# Code Reviewer Subagent

You are a rigorous but constructive code reviewer. Your output is a structured review.

## What you do

1. **Read AGENTS.md** in the repo (root and the folder of the file under review) to learn the project's conventions.
2. **Read the file under review** and closely related files (tests, store, helpers).
3. **Return a structured output** in these five sections:

   ### Correctness
   Obvious bugs, unhandled edge cases, race conditions, off-by-one errors.

   ### Security
   Unvalidated input, data leaks, missing authorization, outdated dependencies.

   ### AGENTS.md compliance
   Places where the code violates the conventions stated in AGENTS.md (naming, error format, status codes). Cite the specific rule.

   ### Test coverage
   Cases not covered by existing tests. Suggest which tests are missing.

   ### Suggested fixes
   For each problem identified, propose a concrete fix (code snippet when applicable).

## How you operate

- Do not rewrite the code yourself. Let the main agent apply the fixes.
- Be specific: cite line and column when relevant.
- Do not invent conventions. If AGENTS.md does not address a point, do not flag it as a violation.
- If the file is well-written, say so. Do not invent problems.
```

Nota la allowlist di tool: nessun edit, solo lettura e ricerca. Inoltre il server MCP `context7` è incluso tra i tool disponibili, quindi il subagent può usarlo per verificare le convenzioni aggiornate.

<details>
<summary>🔵 <b>Claude Code — Step 2 (subagent code-reviewer)</b></summary>

Stesso subagent, in **`.claude/agents/code-reviewer.md`** al root del workspace. Il **corpo è identico** (lo system prompt qui sopra, da "# Code Reviewer Subagent" in giù): copialo tal quale. Cambia solo il **frontmatter**, perché i nomi dei tool e del modello in Claude Code sono diversi da quelli di Copilot:

```markdown
---
name: code-reviewer
description: Specialized subagent for code review. Invoke when you want a structured review of a file or function for correctness, security, AGENTS.md compliance, and test coverage.
tools: Read, Grep, Glob, mcp__context7__resolve-library-id, mcp__context7__get-library-docs
model: sonnet
---
```

Mappatura: l'allowlist Copilot `[search, 'context7/*']` diventa i tool di sola lettura/ricerca di Claude (`Read, Grep, Glob`) più i tool del server MCP Context7 (`mcp__context7__...`). Stesso principio del minimo privilegio: **nessun `Edit`/`Write`**, quindi il subagent non modifica codice. `model: sonnet` è l'alias idiomatico di Claude Code (equivale a `claude-sonnet-4-6`).

Reference: `modules/M2-capacita/solution/.claude/agents/code-reviewer.md`.

</details>

### Step 3.1 - Invoca il subagent `code-reviewer`

- In Copilot Chat, crea una nuova chat e chiedi:
> @code-reviewer revisiona il controller dei task (`TasksEndpoints.cs` / `routes.ts` / `main.py`) nel progetto `@modules/M2-capacita/starters/<linguaggio>` per correttezza, sicurezza e conformità ad AGENTS.md.

Osserva:
- l'output è strutturato nei 5 blocchi definiti dal subagent (Correctness, Security, AGENTS.md compliance, Test coverage, Suggested fixes).
- Nessuna modifica al codice è fatta dal subagent, solo suggerimenti.
- Il subagent è stato richiamato esplicitamente tramite `@code-reviewer`. L'agente può anche essere selezionato implicitamente dal main agent oppure cliccando sulla icona degli agenti (la seconda da sinistra) e scegliendo `code-reviewer` dalla lista.

<details>
<summary>🔵 <b>Claude Code — Step 3.1 (invoca il subagent)</b></summary>

In Claude Code invoca il subagent con **`@agent-code-reviewer`** (digitando `@` compare il typeahead degli agenti). Usa **lo stesso prompt** dello step. In alternativa puoi descrivere il task e lasciare che sia Claude a delegare al subagent in base alla sua `description`, oppure gestire gli agenti con il comando `/agents`. L'output è la stessa struttura a 5 sezioni e il subagent non modifica il codice (nessun tool di scrittura nella allowlist).

</details>

## Wrap

- **Subagent**: unità di esecuzione delegata, contesto isolato, output strutturato, eventualmente parallelizzabile.
- **MCP**: protocollo per esporre tool all'agente. Vale la pena quando il problema risolto **non è già coperto da una CLI standard**.

## Cosa ti porti a casa

- `context7` MCP server registrato e funzionante in Copilot Chat.
- Subagent `code-reviewer` in `.github/agents/code-reviewer.agent.md` al root del workspace, invocabile via `@code-reviewer`.

Se ti blocchi: `solution/.github/agents/code-reviewer.agent.md` contiene la versione di riferimento da copiare al root del repo.

> 🔵 Claude Code: reference in `solution/.claude/agents/code-reviewer.md` (stesso corpo, frontmatter adattato), da copiare in `.claude/agents/code-reviewer.md` al root del repo.

➡️ Prossimo modulo: [`../M3-governance/README.md`](../M3-governance/README.md)