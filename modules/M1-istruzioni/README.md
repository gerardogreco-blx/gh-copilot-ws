# Modulo M1 — Istruzioni · AGENTS.md + Skills

> Obiettivo: capire **come si descrive un repo a un agente** (AGENTS.md) e **come si forniscono procedure on-demand componibili** (Skills). Vedere in pratica la differenza tra "regole sempre attive" e "know-how caricato quando serve".

## Teoria

### AGENTS.md

`AGENTS.md` è lo standard `de facto` cross-tool (GitHub Copilot, Claude Code, e altri coding agent) per descrivere il *contratto* del repository all'agente. È un file Markdown a livello root che viene **caricato in tutte le sessioni agentic** e iniettato come parte del system prompt — perciò ogni riga ha un costo in token.

**Cosa includere**:
- **Regole architetturali**: stack tecnologico, layering, decisioni di design che non si vogliono violare.
- **Convenzioni di codice**: naming, validation, error handling, struttura dei test.
- **Vincoli non negoziabili**: cose che l'agente non deve mai fare ("non modificare X", "esegui sempre Y prima di commit").
- **Punti di ingresso**: dove cercare cosa nel repository (mappa rapida).

**Cosa NON includere**:
- Documentazione esaustiva del progetto (sta nei `docs/`).
- Esempi lunghi di codice (vanno in skill o in commenti del codice).
- Storia delle decisioni o changelog (lo dice `git log`).
- Informazioni che cambiano frequentemente (ad ogni modifica si paga la regression del prompt).

**Vincolo pratico di lunghezza**: < 200 righe è sano, hard-cap sui 500. Sopra questa soglia: il costo in token per prompt diventa percepibile, l'attenzione dell'agente si distribuisce, ed è il segnale che alcune regole vanno spostate in una Skill (caricata solo quando serve).

### Skill

Una Skill è una **unità di know-how componibile**, caricata dall'agente **solo quando rilevante per il task corrente**. È una cartella con questa struttura:

```
skills/<nome-skill>/
├── SKILL.md          ← frontmatter YAML + corpo istruzioni
├── scripts/          ← (opzionale) script eseguibili
└── resources/        ← (opzionale) template, esempi, schema
```

Il file `SKILL.md` ha un frontmatter YAML con due campi critici:

```yaml
---
name: endpoint-creator
description: Use when creating a new REST endpoint in this repo. Covers validation, code location, status codes, test structure, and naming.
---
```

- `name`: identificatore tecnico in kebab-case.
- `description`: la frase con cui l'agente decide **se e quando** caricare la skill. Va scritta in termini di *quando è utile* (trigger condition), **non** di *cosa contiene* (table of contents). Una buona `description` produce auto-loading affidabile; una vaga richiede di nominare esplicitamente la skill ad ogni invocazione.

### Differenza pratica AGENTS.md vs Skill

| | AGENTS.md | Skill |
|---|---|---|
| Caricamento | sempre, in ogni prompt | on-demand, quando l'agente lo decide |
| Costo token | costante | pagato solo se serve |
| Granularità | regole macro del repo | procedura specifica (es. "creare un endpoint") |
| Numero per repo | uno (al root) | molte (composabili) |

Regola di pollice: *"se questa regola serve sempre, in AGENTS.md. Se serve solo a volte, in una Skill."*

## Hands-on

Scegli il tuo linguaggio in `starters/dotnet`, `starters/typescript`, `starters/python` e segui i passi.

### Step 1 — Verifica che AGENTS.md guidi l'agente

Lo starter ha già un `AGENTS.md` che descrive: stack, struttura della Task API, convenzioni di naming, validazione, status code, vincolo "ogni endpoint ha un test".

In Copilot Chat (modalità **Agent**) chiedi:
> Aggiungi un endpoint `GET /tasks/stats` che restituisce il conteggio dei task per stato in formato `{ "todo": N, "done": M }`.

Osserva nella risposta dell'agente:
- la posizione del nuovo endpoint (allineata alle convenzioni in AGENTS.md);
- la validazione (assente in questo caso perché è una GET, ma corretta dove serve);
- lo status code di risposta (`200` per la GET);
- il test generato accanto al codice di produzione.

**Verifica**: l'agente segue il contratto del repo *senza che tu glielo abbia detto in chat*. È AGENTS.md che lo ha guidato.

### Step 2 — Crea una Skill e osserva l'auto-loading

Crea il file `skills/endpoint-creator/SKILL.md` nel tuo starter, con questo contenuto:

```yaml
---
name: endpoint-creator
description: Use when creating a new REST endpoint in this repo. Covers validation, code location, status codes, test structure, and naming.
---

# How to create a REST endpoint in this repo

## 1. Code location
- .NET: `Tasks/TasksEndpoints.cs` (inside `MapTasks`)
- TypeScript: `src/tasks/routes.ts` (inside `tasksRoutes()`)
- Python: `app/main.py` (function decorated with `@app.<verb>`)

## 2. Input validation
- Invalid input → 400 with body `{ "error": "<short message>" }`
- Python: pydantic.BaseModel; TS: type-narrowing; .NET: record + manual checks

## 3. Status codes
- 200 GET · 201 POST + Location header · 200 PATCH · 404 not found · 400 validation

## 4. Tests
Every endpoint ships with one happy path test and one error case test.

## 5. Naming
Kebab-case paths (`/tasks/stats`). Typed path params (`{id:int}` in .NET).
```

Ora chiedi all'agente, **senza nominare la skill**:
> Aggiungi un endpoint `DELETE /tasks/:id` che cancella un task esistente.

Osserva: l'agente carica autonomamente la skill `endpoint-creator` perché la `description` del frontmatter dichiara *"Use when creating a new REST endpoint"*, e il prompt soddisfa quel trigger. Vedrai nella chat (a seconda della superficie) un riferimento esplicito tipo *"Loading skill: endpoint-creator"* oppure la skill comparirà nella context list del turno.

### Step 3 — Confronta gli output

Ripeti lo stesso prompt di Step 1 (l'endpoint stats) ma con la skill ora presente.

Confronta:
- la struttura del codice (più aderente alle regole della skill);
- la presenza/qualità dei test (la skill rende il test "obbligatorio" esplicitamente);
- il formato degli errori (allineato al template `{ "error": "..." }`).

Il punto pedagogico: **AGENTS.md** dà il contesto sempre presente, ma **una Skill** è il modo per codificare *procedure specifiche* senza pagare il costo in token quando non servono.

## Wrap

- AGENTS.md = identità del repo, regole sempre vere, paghi token sempre.
- Skill = know-how procedurale, caricato on-demand quando il `description` matcha il task.
- Triage: la regola serve "sempre"? → AGENTS.md. Serve "a volte"? → Skill. Costa meno e non distrae.

## Cosa ti porti a casa

- Un `AGENTS.md` reale nel tuo starter (lo trovi al root del linguaggio scelto).
- Una skill `skills/endpoint-creator/` con frontmatter scritto in modo che si auto-attivi.

Se ti blocchi: `solution/{linguaggio}/` ha lo stato finale del modulo.

➡️ Prossimo modulo: [`../M2-capacita/README.md`](../M2-capacita/README.md)
