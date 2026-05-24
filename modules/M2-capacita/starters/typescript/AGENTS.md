# AGENTS.md — Task API (TypeScript)

## Stack
- Hono 4 su Node 20 (ESM)
- Test: vitest

## Struttura
- `src/index.ts` — `createApp()` ritorna un'app Hono; il main avvia il server solo se invocato direttamente.
- `src/tasks/store.ts` — `TaskStore` class + tipi `TaskItem`, `TaskStatus`.
- `src/tasks/routes.ts` — funzione `tasksRoutes()` che ritorna un sub-app Hono.
- `src/tasks/*.test.ts` — test accanto al codice.

## Convenzioni
- **Naming endpoint**: kebab-case nei path.
- **Validazione**: input non valido → `c.json({ error: "..." }, 400)`.
- **Status code**: 200 GET, 201 POST, 200 PATCH, 404 not found, 400 validation.
- **Test**: ogni route ha test happy + error case con `app.request(...)`.
- **Import**: usa `.js` per import locali (ESM Node), e.g. `from "./tasks/routes.js"`.

## Vincoli
- NON aggiungere DB reali o framework esterni.
- NON cambiare TaskStore in singleton globale: ogni `createApp()` ne crea uno nuovo.
- NON usare CommonJS — il progetto è ESM (`"type": "module"`).
