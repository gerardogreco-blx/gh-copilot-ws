---
name: endpoint-creator
description: Use when creating a new REST endpoint in this repo. Covers validation, code location, status codes, test structure, and naming conventions.
---

# How to create a REST endpoint in this repo

## 1. Code location
- **.NET**: `modules/M1-istruzioni/starters/dotnet/Tasks/TasksEndpoints.cs` — add the route inside `MapTasks(this WebApplication app)`.
- **TypeScript**: `modules/M1-istruzioni/starters/typescript/src/tasks/routes.ts` — add the route inside `tasksRoutes()`.
- **Python**: `modules/M1-istruzioni/starters/python/app/main.py` — define a function decorated with `@app.<verb>`.

## 2. Input validation
- Invalid input (missing field, wrong type, value out of domain) must return status `400` with body `{ "error": "<short message>" }`.
- Python: use a `pydantic.BaseModel` for the request body.
- TypeScript: use type-narrowing checks (`typeof body.title === "string"`).
- .NET: use a record + manual checks like `string.IsNullOrWhiteSpace`.

## 3. Status codes
| Operation        | Status |
|------------------|--------|
| GET (read)       | 200    |
| POST (create)    | 201 + `Location` header |
| PATCH (update)   | 200    |
| Resource missing | 404    |
| Validation fail  | 400    |

## 4. Mandatory tests
Every endpoint ships with:
- one **happy path** test (valid input → expected status + body)
- one **error case** test (invalid input → 400 with a specific message)

## 5. Naming
- REST paths in kebab-case (`/tasks/stats`, never `/taskStats`).
- Typed path parameters when possible (`{id:int}` in .NET).
