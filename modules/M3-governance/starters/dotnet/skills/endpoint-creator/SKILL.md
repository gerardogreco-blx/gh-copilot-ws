---
name: endpoint-creator
description: Da usare quando si crea un nuovo endpoint REST in questo repo. Spiega validazione, posizione, status code, struttura test, naming.
---

# Come si crea un endpoint REST qui

## 1. Posizione del codice
- **.NET**: `Tasks/TasksEndpoints.cs` (metodo statico in `TasksEndpoints` esteso da `MapTasks(this WebApplication app)`).
- **TypeScript**: `src/tasks/routes.ts` (funzione `tasksRoutes()`).
- **Python**: `app/main.py` (funzione decorata con `@app.<verb>`).

## 2. Validazione input
- Input invalido (campo mancante, tipo sbagliato, valore fuori dominio) → status `400` con body JSON `{ "error": "<messaggio breve>" }`.
- Per il body, in Python usa `pydantic.BaseModel`. In TS controlla type-narrowing + `typeof`. In .NET usa record + check manuale `string.IsNullOrWhiteSpace`.

## 3. Status code da rispettare
| Operazione      | Status |
|-----------------|--------|
| GET (read)      | 200    |
| POST (create)   | 201 + `Location` header |
| PATCH (update)  | 200    |
| Resource missing| 404    |
| Validation fail | 400    |

## 4. Test obbligatorio
Ogni endpoint ha:
- 1 test **happy path** (input valido → status atteso + body corretto)
- 1 test **error case** (input invalido → 400 con messaggio specifico)
I test stanno accanto al codice di produzione (`Tasks.Tests/`, `src/tasks/*.test.ts`, `tests/test_tasks.py`).

## 5. Naming
- Path REST: kebab-case (`/tasks/stats`, NON `/taskStats`).
- IDs nei path: typed quando possibile (`{id:int}` in .NET).
