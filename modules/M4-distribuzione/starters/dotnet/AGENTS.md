# AGENTS.md — Task API (.NET)

## Stack
- .NET 8 Minimal API (`Program.cs` + `TasksEndpoints.cs`)
- Test: xUnit + `Microsoft.AspNetCore.Mvc.Testing` (`Tasks.Tests/`)

## Struttura
- `Program.cs` — bootstrap web app, chiama `MapTasks()`
- `Tasks/TaskItem.cs` — record immutabile
- `Tasks/TaskStore.cs` — store in-memory thread-unsafe (per workshop va bene)
- `Tasks/TasksEndpoints.cs` — definizioni endpoint
- `Tasks.Tests/` — test integrazione via `WebApplicationFactory<Program>`

## Convenzioni
- **Naming endpoint**: kebab-case nei path (`/tasks/stats`, non `/taskStats`).
- **Validazione**: input non valido → `Results.BadRequest(new { error = "..." })`.
- **Status code**: 200 GET, 201 POST con `Created($"/tasks/{id}", ...)`, 200 PATCH, 404 not found, 400 validation error.
- **Test**: ogni endpoint ha almeno 1 happy-path + 1 error case in `TasksEndpointsTests.cs`.
- **Test pattern**: usa `WebApplicationFactory<Program>` (Program ha `public partial class Program { }`).

## Vincoli
- NON usare un DB reale. Lo store in-memory è voluto.
- NON aggiungere middleware (auth, logging, ecc.) negli starter.
- NON modificare `TaskItem` per renderlo mutable.
