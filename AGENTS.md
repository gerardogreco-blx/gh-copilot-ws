# AGENTS.md — Workshop Repo

Questo file è il "system prompt" del repository: ogni agente che lavora qui lo legge prima di iniziare.

## Scopo del repo

Repository del workshop "The Agent Strikes Back" su GitHub Copilot (2026). Contiene 4 moduli hands-on con 3 starter per linguaggio (.NET 10, TypeScript, Python).

Il workshop guida il partecipante a creare progressivamente, **a livello del root del repo** (cioè qui), le seguenti customizations Copilot Chat:
- `.github/skills/endpoint-creator/SKILL.md` (creata in M1)
- `.github/agents/code-reviewer.agent.md` (creata in M2)
- `.github/agents/dba.agent.md` + `.github/hooks/subagent-start.json` + `.copilot/hooks/subagent-start.{sh,ps1}` + `.copilot/context/db-schema.sql` (creati in M3 — iniezione di contesto via SubagentStart)
- `.github/hooks/pre-tool-use.json` + `.copilot/policy.yml` + `.copilot/hooks/pre-tool-use.{sh,ps1}` (M3, appendice — policy enforcement via PreToolUse)
- `plugins/copilot-safety-guard/` (creato in M4 — impacchetta un sottoinsieme curato: skill + code-reviewer + safety hook)

## Stack per linguaggio

### .NET 10 (`modules/Mn/{starters,solution}/dotnet/`)
- ASP.NET Core 10 Minimal API
- Test: xUnit + `Microsoft.AspNetCore.Mvc.Testing`
- Struttura file:
  - `Program.cs` — bootstrap web app, chiama `MapTasks()`
  - `Tasks/TaskItem.cs` — record immutabile
  - `Tasks/TaskStore.cs` — store in-memory (singleton via DI)
  - `Tasks/TasksEndpoints.cs` — definizioni endpoint
  - `Tasks.Tests/` — test integrazione via `WebApplicationFactory<Program>`

### TypeScript / Node 20 (`modules/Mn/{starters,solution}/typescript/`)
- Hono 4 su Node 20 (ESM)
- Test: vitest
- Struttura file:
  - `src/index.ts` — `createApp()` ritorna app Hono
  - `src/tasks/store.ts` — `TaskStore` + tipi
  - `src/tasks/routes.ts` — funzione `tasksRoutes()`
  - `src/tasks/*.test.ts` — test accanto al codice
- Usa `.js` per import locali (ESM Node): `from "./tasks/routes.js"`

### Python 3.11 (`modules/Mn/{starters,solution}/python/`)
- FastAPI su Python 3.11+
- Test: pytest + `fastapi.testclient.TestClient`
- Struttura file:
  - `app/main.py` — FastAPI app + endpoint
  - `app/store.py` — `TaskStore` + dataclass `TaskItem`
  - `tests/test_tasks.py` — test integrazione

## Convenzioni cross-linguaggio

- **Lingua**: italiano per testi rivolti ai partecipanti (README, doc, hint). Inglese per nomi file, codice, branch, commit message, skill/agent content.
- **Naming endpoint**: kebab-case nei path (`/tasks/stats`, non `/taskStats`).
- **Validazione input**: invalido → 400 con body `{ "error": "<messaggio>" }`.
- **Status code**: 200 GET, 201 POST con Location header, 200 PATCH, 404 not found, 400 validation error.
- **Test obbligatorio**: ogni endpoint ha 1 happy-path + 1 error case.

## Vincoli

- NON usare un DB reale. Lo store in-memory è voluto per il workshop.
- NON aggiungere middleware (auth, logging, ecc.) negli starter.
- NON modificare i record/dataclass immutabili.
- NON modificare file in `modules/Mn/solution/` durante un modulo — sono reference per chi si blocca, da copiare al root se necessario.
- NON commitare `.env`, `audit.log`, file in `secrets/`, file `.key`/`.pem`.

## Dove trovare cosa

- `modules/Mn/README.md` — istruzioni del modulo n (M1, M2, M3, M4).
- `modules/Mn/starters/<lang>/` — codice di partenza per il linguaggio scelto.
- `modules/Mn/solution/<lang>/` — codice allo stato finale del modulo.
- `modules/Mn/solution/.github/`, `modules/Mn/solution/.copilot/` — customizations cumulative (skill, agent, hook, policy) come reference da copiare al root del repo se ci si blocca.
- `docs/timing-conduzione.md` — runbook minuto per minuto per gli speaker.
- `docs/glossario.md` — termini agentic spiegati.
- `docs/follow-up.md` — risorse post-workshop.
