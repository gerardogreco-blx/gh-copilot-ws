# Modulo M1 — Istruzioni · AGENTS.md + Skills · 18 min

> Obiettivo: capire cosa sono AGENTS.md e le Skills, e vedere la differenza tra "regole sempre attive" e "know-how on-demand".

## Teoria (5 min)

### AGENTS.md
- Standard cross-tool (Copilot, Claude, altri coding agent): il "system prompt" del repo.
- **Viene iniettato in ogni prompt** della sessione → ogni riga costa token.
- Cosa includere:
  - Regole architetturali (stack, layering, dipendenze)
  - Convenzioni (naming, error handling, validation, test pattern)
  - Vincoli non negoziabili ("mai modificare X", "sempre eseguire Y")
  - Punti di ingresso (dove trovare cosa)
- Cosa NON includere:
  - Documentazione esaustiva del progetto
  - Esempi prolissi
  - Decisioni storiche o cambiamenti frequenti
- **Vincolo pratico**: idealmente < 200 righe, hard-cap ~500. Se serve solo a volte → mettilo in una Skill.

### Skill
- Unità componibile, caricata **on-demand** quando l'agente la giudica rilevante.
- Anatomia:
  ```
  skills/<nome>/
  ├── SKILL.md          ← frontmatter YAML + corpo istruzioni
  ├── scripts/          ← (opzionale)
  └── resources/        ← (opzionale)
  ```
- Frontmatter di SKILL.md:
  ```yaml
  ---
  name: nome-skill
  description: Frase su quando questa skill è rilevante (NON cosa contiene)
  ---
  ```
  Il `description` è il criterio con cui l'agente decide se caricarla. Scrivilo in termini di *quando*, non di *cosa*.

### Cheat mnemonico
*"AGENTS.md = chi sei. Skill = cosa sai fare bene."*

## Hands-on (10 min)

Scegli il tuo linguaggio (`starters/dotnet`, `starters/typescript`, `starters/python`) e segui.

### Step 1 — AGENTS.md guida l'agente (3')

Lo starter ha già un `AGENTS.md` che descrive: stack scelto, struttura della Task API, regola "ogni endpoint ha un test".

In Copilot Chat (modalità Agent) chiedi:
> Aggiungi un endpoint `GET /tasks/stats` che restituisce il conteggio dei task per stato (`{ "todo": N, "done": M }`). Segui le convenzioni del repo.

Osserva: l'agente segue le convenzioni di AGENTS.md (validazione, posizione del file, test).

### Step 2 — Crea una Skill (5')

Crea `skills/endpoint-creator/SKILL.md` con questo contenuto:

```yaml
---
name: endpoint-creator
description: Da usare quando si crea un nuovo endpoint REST in questo repo. Spiega validazione, struttura test, error handling con problem details.
---

# Come si crea un endpoint REST qui

1. **Posizione**: il nuovo endpoint va in `Tasks/TasksEndpoints.cs` (.NET) / `src/tasks/routes.ts` (TS) / `app/main.py` (Python).
2. **Validazione**: input invalido → 400 con body `{ "error": "<messaggio>" }`.
3. **Status code**: GET 200, POST 201, PATCH 200, NOT FOUND 404.
4. **Test obbligatorio**: ogni endpoint ha almeno 1 happy-path e 1 error case.
5. **Convenzioni di naming**: i route in kebab-case (`/tasks/stats`, non `/taskStats`).
```

Poi chiedi a Copilot:
> Aggiungi un endpoint `DELETE /tasks/:id` che cancella un task. Usa la skill endpoint-creator.

### Step 3 — Diff (2')

Osserva la differenza: prima senza skill (output generico), ora con skill (output allineato alle regole).

## Wrap (3')

- **AGENTS.md = regole sempre valide**, paga token sempre.
- **Skill = know-how specifico**, paga token solo se richiamata.
- Soglia decisionale: se la regola serve "a volte", in una Skill; se è "sempre vera nel repo", in AGENTS.md.

## Output del modulo
- Un `AGENTS.md` letto e capito nella tua starter.
- Una skill funzionante in `skills/endpoint-creator/`.

Se sei bloccato: `solution/{linguaggio}/` ha lo stato finale del modulo.

➡️ Prossimo modulo: [`../M2-capacita/README.md`](../M2-capacita/README.md)
