# Workshop "The Agent Strikes Back" — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the GitHub repository for a 90-minute hands-on workshop on GitHub Copilot agentic features (AGENTS.md, Skills, Subagents, MCP, Hooks, Plugins) with 4 modules of theory+practice, 3 language starters (dotnet/typescript/python), a working devcontainer for Codespaces, and runbook docs for the 2 speakers.

**Architecture:** A single-branch GitHub repository organized as `modules/M{1..4}/` (each with `README.md`, `starters/{dotnet,typescript,python}/`, and `solution/{dotnet,typescript,python}/`), a shared `AGENTS.md` at root, a `.devcontainer/` that provisions Node + .NET SDK + Python + Copilot ext + Context7 MCP, a `docs/` folder with intro/glossario/timing/follow-up, and a `plugins/` folder for the M4 bundle. The "Task API" (3 endpoints) is the shared application domain across all modules and languages.

**Tech Stack:**
- **Devcontainer**: `mcr.microsoft.com/devcontainers/universal:2-linux` base (Node 20+, .NET 8 SDK, Python 3.11+)
- **Starters**: ASP.NET Core 8 Minimal API (.NET) · Hono on Node 20 (TypeScript) · FastAPI on Python 3.11 (Python)
- **MCP**: Context7 (`@upstash/context7-mcp` via npx)
- **Plugin format**: `plugin.json` manifest (Copilot CLI/VS Code Chat compatible)
- **Docs**: Markdown only, Italian for participant-facing text, English for code/file names

---

## File Structure (decomposition map)

```
copilot-workshop-2026/
├── .devcontainer/
│   ├── devcontainer.json              [Task 1.1]
│   ├── post-create.sh                 [Task 1.2]
│   └── mcp/
│       └── context7.json              [Task 1.3]
├── .gitignore                         [Task 0.2]
├── README.md                          [Task 0.1 stub, Task 8.1 final]
├── AGENTS.md                          [Task 0.3]
├── docs/
│   ├── 00-intro.md                    [Task 7.1]
│   ├── glossario.md                   [Task 7.2]
│   ├── timing-conduzione.md           [Task 7.3]
│   └── follow-up.md                   [Task 7.4]
├── modules/
│   ├── M1-istruzioni/
│   │   ├── README.md                  [Task 3.1]
│   │   ├── starters/
│   │   │   ├── dotnet/                [Task 2.1 base, Task 3.2 AGENTS.md]
│   │   │   ├── typescript/            [Task 2.2 base, Task 3.2 AGENTS.md]
│   │   │   └── python/                [Task 2.3 base, Task 3.2 AGENTS.md]
│   │   └── solution/
│   │       ├── dotnet/                [Task 3.4]
│   │       ├── typescript/            [Task 3.4]
│   │       └── python/                [Task 3.4]
│   ├── M2-capacita/
│   │   ├── README.md                  [Task 4.1]
│   │   ├── starters/{3 langs}/        [Task 4.2]
│   │   │   └── agents/
│   │   │       └── code-reviewer.agent.md  [Task 4.3]
│   │   └── solution/{3 langs}/        [Task 4.4]
│   ├── M3-governance/
│   │   ├── README.md                  [Task 5.1]
│   │   ├── starters/{3 langs}/
│   │   │   └── .copilot/
│   │   │       ├── policy.yml         [Task 5.2]
│   │   │       └── hooks/
│   │   │           └── pre-tool-use.sh  [Task 5.3]
│   │   └── solution/{3 langs}/        [Task 5.4]
│   └── M4-distribuzione/
│       ├── README.md                  [Task 6.1]
│       ├── starters/{3 langs}/        [Task 6.2 + 6.3]
│       └── solution/{3 langs}/        [Task 6.4]
│           └── plugins/
│               └── copilot-safety-guard/
│                   ├── plugin.json    [Task 6.4]
│                   ├── skills/
│                   ├── agents/
│                   └── hooks/
└── email-template.md                  [Task 8.2]
```

**Responsibility per file** (key files only):
- `AGENTS.md` (root): repo-wide conventions, naming, error handling rules. <200 lines.
- `modules/Mn/README.md`: in Italian, theory + hands-on steps + wrap, ~150-250 lines.
- `modules/Mn/starters/{lang}/`: a runnable Task API + module-specific scaffolding (e.g., M1 has its own `AGENTS.md`, M2 has `agents/`, M3 has `.copilot/policy.yml`).
- `modules/Mn/solution/{lang}/`: the same starter at the end-of-module state (the participant's expected output).
- `docs/timing-conduzione.md`: minute-by-minute runbook for the 2 speakers (what to say, what to click).

---

## Phase 0 — Bootstrap

### Task 0.1: Initialize git repo + README skeleton

**Files:**
- Create: `README.md`

- [ ] **Step 1: Initialize the repo**

Run:
```bash
cd /Users/gerardogreco/Documents/Lavoro/GitHubCopilotWorkshop2026
git init -b main
```

Expected: `Initialized empty Git repository in .git/`

- [ ] **Step 2: Create README.md skeleton**

Write to `README.md`:

```markdown
# Workshop "The Agent Strikes Back" — GitHub Copilot 2026

> Workshop hands-on di 90 minuti su agenti Copilot: AGENTS.md, Skills, Subagents, MCP, Hooks, Plugins & Marketplace.

🚀 **[Open in GitHub Codespaces](#)** (link verrà popolato dopo il push)

## Per chi partecipa

Vai a [`docs/00-intro.md`](docs/00-intro.md) per l'introduzione e poi apri `modules/M1-istruzioni/README.md` per iniziare.

## Per gli speaker

Runbook: [`docs/timing-conduzione.md`](docs/timing-conduzione.md).

## Struttura

- `modules/M1-istruzioni/` — AGENTS.md + Skills (18 min)
- `modules/M2-capacita/` — Subagents + MCP (18 min)
- `modules/M3-governance/` — Hooks (14 min)
- `modules/M4-distribuzione/` — Plugins & Marketplace (14 min)
- M5 — SDD (12 min, presentato dal co-speaker)

## Setup pre-workshop

Vedi [email-template.md](email-template.md).
```

- [ ] **Step 3: First commit**

```bash
git add README.md
git commit -m "chore: initial repo skeleton"
```

---

### Task 0.2: .gitignore

**Files:**
- Create: `.gitignore`

- [ ] **Step 1: Write .gitignore**

Write to `.gitignore`:

```gitignore
# Node
node_modules/
dist/
*.log

# Python
__pycache__/
*.pyc
.venv/
.pytest_cache/

# .NET
bin/
obj/

# OS
.DS_Store
Thumbs.db

# IDE
.vscode/settings.json
.idea/

# Workshop runtime
.copilot/audit.log
.env
*.local
```

- [ ] **Step 2: Commit**

```bash
git add .gitignore
git commit -m "chore: add .gitignore"
```

---

### Task 0.3: Root AGENTS.md

**Files:**
- Create: `AGENTS.md`

- [ ] **Step 1: Write root AGENTS.md**

Write to `AGENTS.md`:

```markdown
# AGENTS.md — Workshop Repo

Questo file è il "system prompt" del repository: ogni agente che lavora qui lo legge prima di iniziare.

## Scopo del repo

Repository del workshop "The Agent Strikes Back" su GitHub Copilot (2026). Contiene 4 moduli hands-on con 3 starter per linguaggio (dotnet, typescript, python).

## Stack

- .NET 8 (ASP.NET Core Minimal API)
- TypeScript 5 (Hono on Node 20)
- Python 3.11 (FastAPI)

## Convenzioni

- **Lingua**: italiano per testi rivolti ai partecipanti (README, doc, hint). Inglese per nomi file, codice, branch, commit message.
- **Naming**: kebab-case per cartelle, PascalCase per classi C#, camelCase per funzioni TS/Python.
- **Test**: ogni endpoint nella Task API ha almeno 1 test happy-path e 1 edge case.
- **Error handling**: errori restituiti come problem details (RFC 7807) o equivalente JSON `{ error, message }`.

## Vincoli

- Non modificare file in `solution/` se non si sta lavorando esplicitamente alla soluzione del modulo.
- Non aggiungere dipendenze esterne agli starter senza ragione documentata: gli starter devono restare minimali.
- Non commitare `.env`, `audit.log`, o file in `secrets/`.

## Dove trovare cosa

- `modules/Mn/README.md` — istruzioni del modulo n.
- `docs/timing-conduzione.md` — runbook minuto per minuto per gli speaker.
- `docs/glossario.md` — termini agentic spiegati.
```

- [ ] **Step 2: Commit**

```bash
git add AGENTS.md
git commit -m "feat: root AGENTS.md with repo conventions"
```

---

## Phase 1 — Devcontainer

### Task 1.1: devcontainer.json

**Files:**
- Create: `.devcontainer/devcontainer.json`

- [ ] **Step 1: Create directory and file**

Run:
```bash
mkdir -p .devcontainer/mcp
```

Write to `.devcontainer/devcontainer.json`:

```json
{
  "name": "Copilot Workshop 2026",
  "image": "mcr.microsoft.com/devcontainers/universal:2-linux",
  "features": {
    "ghcr.io/devcontainers/features/dotnet:2": { "version": "8.0" },
    "ghcr.io/devcontainers/features/node:1": { "version": "20" },
    "ghcr.io/devcontainers/features/python:1": { "version": "3.11" },
    "ghcr.io/devcontainers/features/github-cli:1": {}
  },
  "customizations": {
    "vscode": {
      "extensions": [
        "GitHub.copilot",
        "GitHub.copilot-chat",
        "ms-dotnettools.csharp",
        "ms-python.python",
        "dbaeumer.vscode-eslint"
      ],
      "settings": {
        "editor.formatOnSave": true,
        "github.copilot.chat.agent.enabled": true
      }
    }
  },
  "postCreateCommand": "bash .devcontainer/post-create.sh",
  "forwardPorts": [5000, 5001, 8000, 3000],
  "remoteUser": "codespace"
}
```

- [ ] **Step 2: Commit**

```bash
git add .devcontainer/devcontainer.json
git commit -m "feat: devcontainer with .NET, Node, Python, Copilot ext"
```

---

### Task 1.2: post-create.sh

**Files:**
- Create: `.devcontainer/post-create.sh`

- [ ] **Step 1: Write post-create script**

Write to `.devcontainer/post-create.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

echo "==> Workshop post-create setup"

# Restore .NET starters (M1-M4)
for module in M1-istruzioni M2-capacita M3-governance M4-distribuzione; do
  for path in "modules/$module/starters/dotnet" "modules/$module/solution/dotnet"; do
    if [ -f "$path/TaskApi.csproj" ] || [ -f "$path"/*.csproj 2>/dev/null ]; then
      echo "  - dotnet restore $path"
      (cd "$path" && dotnet restore --nologo) || true
    fi
  done
done

# Install TS deps
for module in M1-istruzioni M2-capacita M3-governance M4-distribuzione; do
  for path in "modules/$module/starters/typescript" "modules/$module/solution/typescript"; do
    if [ -f "$path/package.json" ]; then
      echo "  - npm install $path"
      (cd "$path" && npm install --no-audit --no-fund) || true
    fi
  done
done

# Python venvs
for module in M1-istruzioni M2-capacita M3-governance M4-distribuzione; do
  for path in "modules/$module/starters/python" "modules/$module/solution/python"; do
    if [ -f "$path/requirements.txt" ]; then
      echo "  - pip install $path"
      (cd "$path" && python -m pip install -q -r requirements.txt) || true
    fi
  done
done

# Pre-pull Context7 MCP so first invocation is fast
echo "==> Pre-pulling Context7 MCP"
npx -y @upstash/context7-mcp --help > /dev/null 2>&1 || true

echo "==> Done. Open modules/M1-istruzioni/README.md to start."
```

- [ ] **Step 2: Make executable + commit**

```bash
chmod +x .devcontainer/post-create.sh
git add .devcontainer/post-create.sh
git commit -m "feat: post-create script to restore starters and prep Context7"
```

---

### Task 1.3: Context7 MCP config

**Files:**
- Create: `.devcontainer/mcp/context7.json`

- [ ] **Step 1: Write Context7 MCP config**

Write to `.devcontainer/mcp/context7.json`:

```json
{
  "mcpServers": {
    "context7": {
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp"],
      "env": {}
    }
  }
}
```

This file documents the MCP server config. The actual wiring into Copilot Chat is shown to participants in M2 (they copy it to the right location during the hands-on, so they SEE the configuration step — that's part of the lesson).

- [ ] **Step 2: Commit**

```bash
git add .devcontainer/mcp/context7.json
git commit -m "feat: Context7 MCP config reference (used in M2)"
```

---

### Task 1.4: Verify devcontainer locally

- [ ] **Step 1: Run devcontainer CLI smoke test (if installed) or skip**

Run (optional, requires `@devcontainers/cli`):
```bash
devcontainer up --workspace-folder .
```

Expected: container builds, post-create.sh runs without fatal errors.

If `devcontainer` CLI is not installed, skip — verification will happen via Codespace test (Task 9.1).

- [ ] **Step 2: No commit (verification only)**

---

## Phase 2 — Task API starters (shared base)

The Task API has 3 endpoints in all 3 languages, with identical behavior:
- `GET /tasks` → list all tasks
- `POST /tasks` → create task with `{ "title": string }`
- `PATCH /tasks/:id` → update status `{ "status": "todo"|"done" }`

State: in-memory list of `{ id: int, title: string, status: "todo"|"done" }`.

These starters live in `modules/M1-istruzioni/starters/{lang}/` (the FIRST module). Subsequent modules copy from M1 with their additions — but we'll use git to do this cheaply in Tasks 4.x/5.x/6.x.

### Task 2.1: .NET starter (M1) — Task API

**Files:**
- Create: `modules/M1-istruzioni/starters/dotnet/TaskApi.csproj`
- Create: `modules/M1-istruzioni/starters/dotnet/Program.cs`
- Create: `modules/M1-istruzioni/starters/dotnet/Tasks/TaskItem.cs`
- Create: `modules/M1-istruzioni/starters/dotnet/Tasks/TaskStore.cs`
- Create: `modules/M1-istruzioni/starters/dotnet/Tasks/TasksEndpoints.cs`
- Test: `modules/M1-istruzioni/starters/dotnet/Tasks.Tests/Tasks.Tests.csproj`
- Test: `modules/M1-istruzioni/starters/dotnet/Tasks.Tests/TasksEndpointsTests.cs`

- [ ] **Step 1: Write the failing test first**

Run:
```bash
mkdir -p modules/M1-istruzioni/starters/dotnet/Tasks
mkdir -p modules/M1-istruzioni/starters/dotnet/Tasks.Tests
```

Write to `modules/M1-istruzioni/starters/dotnet/Tasks.Tests/Tasks.Tests.csproj`:

```xml
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <TargetFramework>net8.0</TargetFramework>
    <IsPackable>false</IsPackable>
    <Nullable>enable</Nullable>
  </PropertyGroup>
  <ItemGroup>
    <PackageReference Include="Microsoft.AspNetCore.Mvc.Testing" Version="8.0.0" />
    <PackageReference Include="xunit" Version="2.6.6" />
    <PackageReference Include="xunit.runner.visualstudio" Version="2.5.6" />
    <PackageReference Include="Microsoft.NET.Test.Sdk" Version="17.8.0" />
  </ItemGroup>
  <ItemGroup>
    <ProjectReference Include="..\TaskApi.csproj" />
  </ItemGroup>
</Project>
```

Write to `modules/M1-istruzioni/starters/dotnet/Tasks.Tests/TasksEndpointsTests.cs`:

```csharp
using System.Net;
using System.Net.Http.Json;
using Microsoft.AspNetCore.Mvc.Testing;
using Xunit;

public class TasksEndpointsTests : IClassFixture<WebApplicationFactory<Program>>
{
    private readonly HttpClient _client;

    public TasksEndpointsTests(WebApplicationFactory<Program> factory)
    {
        _client = factory.CreateClient();
    }

    [Fact]
    public async Task GetTasks_ReturnsEmptyList_Initially()
    {
        var response = await _client.GetAsync("/tasks");
        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        var tasks = await response.Content.ReadFromJsonAsync<List<TaskItem>>();
        Assert.NotNull(tasks);
        Assert.Empty(tasks);
    }

    [Fact]
    public async Task PostTask_CreatesTask_WithTodoStatus()
    {
        var response = await _client.PostAsJsonAsync("/tasks", new { title = "Test" });
        Assert.Equal(HttpStatusCode.Created, response.StatusCode);
        var created = await response.Content.ReadFromJsonAsync<TaskItem>();
        Assert.NotNull(created);
        Assert.Equal("Test", created.Title);
        Assert.Equal("todo", created.Status);
    }
}
```

- [ ] **Step 2: Run test to verify it fails**

Run:
```bash
cd modules/M1-istruzioni/starters/dotnet && dotnet test
```

Expected: FAIL (no project file found / Program/TaskItem undefined).

- [ ] **Step 3: Write the project file**

Write to `modules/M1-istruzioni/starters/dotnet/TaskApi.csproj`:

```xml
<Project Sdk="Microsoft.NET.Sdk.Web">
  <PropertyGroup>
    <TargetFramework>net8.0</TargetFramework>
    <Nullable>enable</Nullable>
    <ImplicitUsings>enable</ImplicitUsings>
  </PropertyGroup>
</Project>
```

- [ ] **Step 4: Write TaskItem record**

Write to `modules/M1-istruzioni/starters/dotnet/Tasks/TaskItem.cs`:

```csharp
namespace TaskApi.Tasks;

public record TaskItem(int Id, string Title, string Status);
```

- [ ] **Step 5: Write TaskStore (in-memory)**

Write to `modules/M1-istruzioni/starters/dotnet/Tasks/TaskStore.cs`:

```csharp
namespace TaskApi.Tasks;

public class TaskStore
{
    private readonly List<TaskItem> _tasks = new();
    private int _nextId = 1;

    public IReadOnlyList<TaskItem> All() => _tasks.AsReadOnly();

    public TaskItem Create(string title)
    {
        var task = new TaskItem(_nextId++, title, "todo");
        _tasks.Add(task);
        return task;
    }

    public TaskItem? UpdateStatus(int id, string status)
    {
        var idx = _tasks.FindIndex(t => t.Id == id);
        if (idx < 0) return null;
        var updated = _tasks[idx] with { Status = status };
        _tasks[idx] = updated;
        return updated;
    }
}
```

- [ ] **Step 6: Write endpoints + Program.cs**

Write to `modules/M1-istruzioni/starters/dotnet/Tasks/TasksEndpoints.cs`:

```csharp
namespace TaskApi.Tasks;

public static class TasksEndpoints
{
    public static void MapTasks(this WebApplication app)
    {
        var store = new TaskStore();

        app.MapGet("/tasks", () => Results.Ok(store.All()));

        app.MapPost("/tasks", (CreateTaskRequest req) =>
        {
            if (string.IsNullOrWhiteSpace(req.Title))
                return Results.BadRequest(new { error = "title required" });
            var created = store.Create(req.Title);
            return Results.Created($"/tasks/{created.Id}", created);
        });

        app.MapPatch("/tasks/{id:int}", (int id, UpdateStatusRequest req) =>
        {
            if (req.Status != "todo" && req.Status != "done")
                return Results.BadRequest(new { error = "status must be 'todo' or 'done'" });
            var updated = store.UpdateStatus(id, req.Status);
            return updated is null ? Results.NotFound() : Results.Ok(updated);
        });
    }

    public record CreateTaskRequest(string Title);
    public record UpdateStatusRequest(string Status);
}
```

Write to `modules/M1-istruzioni/starters/dotnet/Program.cs`:

```csharp
using TaskApi.Tasks;

var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();
app.MapTasks();
app.Run();

public partial class Program { }
```

- [ ] **Step 7: Run tests to verify they pass**

Run:
```bash
cd modules/M1-istruzioni/starters/dotnet && dotnet test
```

Expected: 2 tests pass.

- [ ] **Step 8: Commit**

```bash
git add modules/M1-istruzioni/starters/dotnet
git commit -m "feat(M1): .NET Task API starter with tests"
```

---

### Task 2.2: TypeScript starter (M1) — Task API

**Files:**
- Create: `modules/M1-istruzioni/starters/typescript/package.json`
- Create: `modules/M1-istruzioni/starters/typescript/tsconfig.json`
- Create: `modules/M1-istruzioni/starters/typescript/src/index.ts`
- Create: `modules/M1-istruzioni/starters/typescript/src/tasks/store.ts`
- Create: `modules/M1-istruzioni/starters/typescript/src/tasks/routes.ts`
- Test: `modules/M1-istruzioni/starters/typescript/src/tasks/routes.test.ts`

- [ ] **Step 1: Write failing test first**

Run:
```bash
mkdir -p modules/M1-istruzioni/starters/typescript/src/tasks
```

Write to `modules/M1-istruzioni/starters/typescript/src/tasks/routes.test.ts`:

```typescript
import { describe, it, expect, beforeEach } from "vitest";
import { createApp } from "../index.js";
import type { Hono } from "hono";

let app: Hono;

beforeEach(() => {
  app = createApp();
});

describe("Tasks API", () => {
  it("GET /tasks returns empty list initially", async () => {
    const res = await app.request("/tasks");
    expect(res.status).toBe(200);
    expect(await res.json()).toEqual([]);
  });

  it("POST /tasks creates task with todo status", async () => {
    const res = await app.request("/tasks", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ title: "Test" }),
    });
    expect(res.status).toBe(201);
    const body = await res.json();
    expect(body.title).toBe("Test");
    expect(body.status).toBe("todo");
  });
});
```

- [ ] **Step 2: Write package.json + tsconfig**

Write to `modules/M1-istruzioni/starters/typescript/package.json`:

```json
{
  "name": "workshop-m1-tasks-ts",
  "version": "0.0.1",
  "private": true,
  "type": "module",
  "scripts": {
    "dev": "tsx watch src/index.ts",
    "build": "tsc",
    "start": "node dist/index.js",
    "test": "vitest run"
  },
  "dependencies": {
    "hono": "^4.0.0",
    "@hono/node-server": "^1.8.0"
  },
  "devDependencies": {
    "tsx": "^4.7.0",
    "typescript": "^5.3.0",
    "vitest": "^1.3.0",
    "@types/node": "^20.10.0"
  }
}
```

Write to `modules/M1-istruzioni/starters/typescript/tsconfig.json`:

```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "ESNext",
    "moduleResolution": "Bundler",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "outDir": "dist",
    "rootDir": "src"
  },
  "include": ["src/**/*"]
}
```

- [ ] **Step 3: Verify test fails**

Run:
```bash
cd modules/M1-istruzioni/starters/typescript && npm install && npm test
```

Expected: FAIL (cannot find module `../index.js`).

- [ ] **Step 4: Write store + routes + index**

Write to `modules/M1-istruzioni/starters/typescript/src/tasks/store.ts`:

```typescript
export type TaskStatus = "todo" | "done";

export interface TaskItem {
  id: number;
  title: string;
  status: TaskStatus;
}

export class TaskStore {
  private tasks: TaskItem[] = [];
  private nextId = 1;

  all(): TaskItem[] {
    return [...this.tasks];
  }

  create(title: string): TaskItem {
    const task: TaskItem = { id: this.nextId++, title, status: "todo" };
    this.tasks.push(task);
    return task;
  }

  updateStatus(id: number, status: TaskStatus): TaskItem | null {
    const idx = this.tasks.findIndex((t) => t.id === id);
    if (idx < 0) return null;
    this.tasks[idx] = { ...this.tasks[idx], status };
    return this.tasks[idx];
  }
}
```

Write to `modules/M1-istruzioni/starters/typescript/src/tasks/routes.ts`:

```typescript
import { Hono } from "hono";
import { TaskStore, type TaskStatus } from "./store.js";

export function tasksRoutes(): Hono {
  const app = new Hono();
  const store = new TaskStore();

  app.get("/tasks", (c) => c.json(store.all()));

  app.post("/tasks", async (c) => {
    const body = await c.req.json().catch(() => ({}));
    if (!body.title || typeof body.title !== "string") {
      return c.json({ error: "title required" }, 400);
    }
    const created = store.create(body.title);
    return c.json(created, 201);
  });

  app.patch("/tasks/:id", async (c) => {
    const id = Number(c.req.param("id"));
    const body = await c.req.json().catch(() => ({}));
    if (body.status !== "todo" && body.status !== "done") {
      return c.json({ error: "status must be 'todo' or 'done'" }, 400);
    }
    const updated = store.updateStatus(id, body.status as TaskStatus);
    return updated ? c.json(updated) : c.json({ error: "not found" }, 404);
  });

  return app;
}
```

Write to `modules/M1-istruzioni/starters/typescript/src/index.ts`:

```typescript
import { Hono } from "hono";
import { serve } from "@hono/node-server";
import { tasksRoutes } from "./tasks/routes.js";

export function createApp(): Hono {
  const app = new Hono();
  app.route("/", tasksRoutes());
  return app;
}

if (import.meta.url === `file://${process.argv[1]}`) {
  const app = createApp();
  const port = Number(process.env.PORT ?? 3000);
  serve({ fetch: app.fetch, port });
  console.log(`Listening on http://localhost:${port}`);
}
```

- [ ] **Step 5: Run tests**

Run:
```bash
cd modules/M1-istruzioni/starters/typescript && npm test
```

Expected: 2 tests pass.

- [ ] **Step 6: Commit**

```bash
git add modules/M1-istruzioni/starters/typescript
git commit -m "feat(M1): TypeScript Task API starter with tests"
```

---

### Task 2.3: Python starter (M1) — Task API

**Files:**
- Create: `modules/M1-istruzioni/starters/python/requirements.txt`
- Create: `modules/M1-istruzioni/starters/python/app/__init__.py`
- Create: `modules/M1-istruzioni/starters/python/app/store.py`
- Create: `modules/M1-istruzioni/starters/python/app/main.py`
- Test: `modules/M1-istruzioni/starters/python/tests/test_tasks.py`

- [ ] **Step 1: Write failing test first**

Run:
```bash
mkdir -p modules/M1-istruzioni/starters/python/app
mkdir -p modules/M1-istruzioni/starters/python/tests
touch modules/M1-istruzioni/starters/python/app/__init__.py
touch modules/M1-istruzioni/starters/python/tests/__init__.py
```

Write to `modules/M1-istruzioni/starters/python/tests/test_tasks.py`:

```python
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)


def test_get_tasks_returns_empty_initially():
    response = client.get("/tasks")
    assert response.status_code == 200
    assert response.json() == []


def test_post_task_creates_with_todo_status():
    response = client.post("/tasks", json={"title": "Test"})
    assert response.status_code == 201
    body = response.json()
    assert body["title"] == "Test"
    assert body["status"] == "todo"
```

Write to `modules/M1-istruzioni/starters/python/requirements.txt`:

```
fastapi==0.110.0
uvicorn==0.27.0
pydantic==2.6.0
httpx==0.27.0
pytest==8.0.0
```

- [ ] **Step 2: Verify test fails**

Run:
```bash
cd modules/M1-istruzioni/starters/python && pip install -q -r requirements.txt && pytest
```

Expected: FAIL (no module `app.main`).

- [ ] **Step 3: Write store + main**

Write to `modules/M1-istruzioni/starters/python/app/store.py`:

```python
from dataclasses import dataclass, replace
from typing import Literal

Status = Literal["todo", "done"]


@dataclass(frozen=True)
class TaskItem:
    id: int
    title: str
    status: Status


class TaskStore:
    def __init__(self) -> None:
        self._tasks: list[TaskItem] = []
        self._next_id = 1

    def all(self) -> list[TaskItem]:
        return list(self._tasks)

    def create(self, title: str) -> TaskItem:
        task = TaskItem(id=self._next_id, title=title, status="todo")
        self._next_id += 1
        self._tasks.append(task)
        return task

    def update_status(self, task_id: int, status: Status) -> TaskItem | None:
        for i, t in enumerate(self._tasks):
            if t.id == task_id:
                updated = replace(t, status=status)
                self._tasks[i] = updated
                return updated
        return None
```

Write to `modules/M1-istruzioni/starters/python/app/main.py`:

```python
from fastapi import FastAPI, HTTPException
from fastapi.responses import JSONResponse
from pydantic import BaseModel
from typing import Literal
from app.store import TaskStore

app = FastAPI()
store = TaskStore()


class CreateTaskRequest(BaseModel):
    title: str


class UpdateStatusRequest(BaseModel):
    status: Literal["todo", "done"]


@app.get("/tasks")
def get_tasks() -> list[dict]:
    return [t.__dict__ for t in store.all()]


@app.post("/tasks", status_code=201)
def create_task(req: CreateTaskRequest) -> dict:
    if not req.title.strip():
        raise HTTPException(status_code=400, detail="title required")
    return store.create(req.title).__dict__


@app.patch("/tasks/{task_id}")
def update_status(task_id: int, req: UpdateStatusRequest) -> dict:
    updated = store.update_status(task_id, req.status)
    if updated is None:
        raise HTTPException(status_code=404, detail="not found")
    return updated.__dict__
```

- [ ] **Step 4: Run tests**

Run:
```bash
cd modules/M1-istruzioni/starters/python && pytest
```

Expected: 2 tests pass.

- [ ] **Step 5: Commit**

```bash
git add modules/M1-istruzioni/starters/python
git commit -m "feat(M1): Python Task API starter with tests"
```

---

### Task 2.4: Verify all 3 starters run

- [ ] **Step 1: Smoke-test each starter independently**

Run (one at a time, kill each before the next):
```bash
# .NET
cd modules/M1-istruzioni/starters/dotnet && dotnet run &
sleep 5 && curl -s http://localhost:5000/tasks && kill %1

# TypeScript
cd ../../typescript && npm run dev &
sleep 5 && curl -s http://localhost:3000/tasks && kill %1

# Python
cd ../python && uvicorn app.main:app --port 8000 &
sleep 5 && curl -s http://localhost:8000/tasks && kill %1
```

Expected: each prints `[]`.

- [ ] **Step 2: No commit (verification only)**

---

## Phase 3 — Module M1 "Istruzioni" (AGENTS.md + Skills)

### Task 3.1: M1 README

**Files:**
- Create: `modules/M1-istruzioni/README.md`

- [ ] **Step 1: Write the module README**

Write to `modules/M1-istruzioni/README.md`:

```markdown
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
```

- [ ] **Step 2: Commit**

```bash
git add modules/M1-istruzioni/README.md
git commit -m "docs(M1): README with theory, hands-on, wrap"
```

---

### Task 3.2: AGENTS.md per ogni starter M1 (3 lingue)

**Files:**
- Create: `modules/M1-istruzioni/starters/dotnet/AGENTS.md`
- Create: `modules/M1-istruzioni/starters/typescript/AGENTS.md`
- Create: `modules/M1-istruzioni/starters/python/AGENTS.md`

- [ ] **Step 1: Write .NET starter AGENTS.md**

Write to `modules/M1-istruzioni/starters/dotnet/AGENTS.md`:

```markdown
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
```

- [ ] **Step 2: Write TypeScript starter AGENTS.md**

Write to `modules/M1-istruzioni/starters/typescript/AGENTS.md`:

```markdown
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
```

- [ ] **Step 3: Write Python starter AGENTS.md**

Write to `modules/M1-istruzioni/starters/python/AGENTS.md`:

```markdown
# AGENTS.md — Task API (Python)

## Stack
- FastAPI su Python 3.11+
- Test: pytest + `fastapi.testclient.TestClient`

## Struttura
- `app/main.py` — FastAPI app + endpoint
- `app/store.py` — `TaskStore` + dataclass `TaskItem`
- `tests/test_tasks.py` — test integrazione

## Convenzioni
- **Naming endpoint**: kebab-case nei path.
- **Validazione**: usa `pydantic.BaseModel` per request body (`CreateTaskRequest`, `UpdateStatusRequest`).
- **Error handling**: `raise HTTPException(status_code=..., detail="...")` con `{ "detail": "..." }`.
- **Status code**: 200 GET, 201 POST (via `status_code=201` nel decorator), 200 PATCH, 404 not found, 400 validation.
- **Test**: ogni endpoint ha test happy + error con `TestClient(app)`.

## Vincoli
- NON usare un DB reale.
- NON aggiungere middleware (CORS, auth).
- NON cambiare `TaskItem` in classe mutable: è un `dataclass(frozen=True)`.
```

- [ ] **Step 4: Commit**

```bash
git add modules/M1-istruzioni/starters/*/AGENTS.md
git commit -m "feat(M1): AGENTS.md for each language starter"
```

---

### Task 3.3: Skill endpoint-creator (template per la solution)

**Files:**
- Create: `modules/M1-istruzioni/solution/{dotnet,typescript,python}/skills/endpoint-creator/SKILL.md`

- [ ] **Step 1: Create solution skeletons by copying starters**

Run:
```bash
for lang in dotnet typescript python; do
  mkdir -p "modules/M1-istruzioni/solution/$lang"
  cp -R "modules/M1-istruzioni/starters/$lang/." "modules/M1-istruzioni/solution/$lang/"
  mkdir -p "modules/M1-istruzioni/solution/$lang/skills/endpoint-creator"
done
```

- [ ] **Step 2: Write the shared SKILL.md content into each language folder**

Write to **all three** `modules/M1-istruzioni/solution/{dotnet,typescript,python}/skills/endpoint-creator/SKILL.md`:

```yaml
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
```

- [ ] **Step 3: Commit**

```bash
git add modules/M1-istruzioni/solution
git commit -m "feat(M1): solution folders with endpoint-creator skill"
```

---

### Task 3.4: Verifica solution M1 gira (sanity check)

- [ ] **Step 1: Run tests in each solution folder**

Run:
```bash
cd modules/M1-istruzioni/solution/dotnet && dotnet test --nologo
cd ../typescript && npm install && npm test
cd ../python && pip install -q -r requirements.txt && pytest
```

Expected: all tests pass.

- [ ] **Step 2: No commit (sanity check only)**

---

## Phase 4 — Module M2 "Capacità" (Subagents + MCP)

### Task 4.1: M2 README

**Files:**
- Create: `modules/M2-capacita/README.md`

- [ ] **Step 1: Write the M2 README**

Write to `modules/M2-capacita/README.md`:

```markdown
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
```

- [ ] **Step 2: Commit**

```bash
git add modules/M2-capacita/README.md
git commit -m "docs(M2): README with theory, hands-on, wrap"
```

---

### Task 4.2: M2 starters (copia da M1 solution + struttura agents/)

**Files:**
- Create: `modules/M2-capacita/starters/{dotnet,typescript,python}/`

- [ ] **Step 1: Copy M1 solutions as M2 starters**

Run:
```bash
for lang in dotnet typescript python; do
  mkdir -p "modules/M2-capacita/starters/$lang"
  cp -R "modules/M1-istruzioni/solution/$lang/." "modules/M2-capacita/starters/$lang/"
  mkdir -p "modules/M2-capacita/starters/$lang/agents"
done
```

- [ ] **Step 2: Commit**

```bash
git add modules/M2-capacita/starters
git commit -m "feat(M2): starters from M1 solution + agents/ dir"
```

---

### Task 4.3: code-reviewer.agent.md (in ogni starter)

**Files:**
- Create: `modules/M2-capacita/starters/{dotnet,typescript,python}/agents/code-reviewer.agent.md`

- [ ] **Step 1: Write the subagent file (same content in all 3 starters)**

Write to **all three** `modules/M2-capacita/starters/{dotnet,typescript,python}/agents/code-reviewer.agent.md`:

```markdown
---
name: code-reviewer
description: Subagent specializzato in code review. Da usare quando vuoi una revisione strutturata di un file o di una funzione su correttezza, sicurezza, conformità ad AGENTS.md, copertura test.
tools: [Read, Grep, Bash]
model: claude-sonnet-4-6
---

# Code Reviewer Subagent

Sei un code reviewer rigoroso ma costruttivo. Il tuo output è una review strutturata.

## Cosa fai

1. **Leggi AGENTS.md** del repo per conoscere le regole.
2. **Leggi il file da revisionare** e i file collegati (test, store, helper).
3. **Restituisci un output strutturato** nei seguenti blocchi:

   ### Correctness
   Bug evidenti, edge case non gestiti, race condition, off-by-one.

   ### Security
   Input non validato, leak di dati, accesso non autorizzato, dipendenze obsolete.

   ### AGENTS.md compliance
   Punti dove il codice viola le convenzioni dichiarate (naming, error format, status code). Cita la regola.

   ### Test coverage
   Casi non testati. Suggerisci quali test mancano.

   ### Suggested fixes
   Per ciascun problema identificato, una proposta di fix concreta.

## Come operi

- Non riscrivere il codice tu stesso: lascia che il main agent applichi i fix.
- Sii specifico: cita riga e colonna quando rilevante.
- Non inventare convenzioni: se AGENTS.md non dice nulla, non flaggare.
- Se il file è ben fatto, dillo. Non inventare problemi.

## Tool a disposizione
- `Read`: per aprire file.
- `Grep`: per cercare pattern.
- `Bash`: per test o lint se necessario.
```

- [ ] **Step 2: Commit**

```bash
git add modules/M2-capacita/starters/*/agents/code-reviewer.agent.md
git commit -m "feat(M2): code-reviewer subagent for each starter"
```

---

### Task 4.4: M2 solution + SOLUTION.md

**Files:**
- Create: `modules/M2-capacita/solution/{dotnet,typescript,python}/`
- Create: `modules/M2-capacita/solution/SOLUTION.md`

- [ ] **Step 1: Copy starters to solutions**

Run:
```bash
for lang in dotnet typescript python; do
  mkdir -p "modules/M2-capacita/solution/$lang"
  cp -R "modules/M2-capacita/starters/$lang/." "modules/M2-capacita/solution/$lang/"
done
```

- [ ] **Step 2: Write SOLUTION.md**

Write to `modules/M2-capacita/solution/SOLUTION.md`:

```markdown
# Soluzione attesa M2

A fine modulo dovresti vedere:

1. **Context7 attivo** in Copilot Chat: nell'elenco dei server MCP collegati c'è `context7`, e quando lo invochi vedi le docs nelle risposte.

2. **Subagent `code-reviewer` invocabile**: il file `agents/code-reviewer.agent.md` è presente nella tua starter e `@code-reviewer` parte restituendo una review nei 5 blocchi (Correctness, Security, AGENTS.md compliance, Test coverage, Suggested fixes).

3. **Composizione**: `@code-reviewer` può usare Context7. Output deve referenziare docs aggiornate quando applicabile.

## Verifica manuale
- Apri `agents/code-reviewer.agent.md` — frontmatter leggibile.
- Settings Copilot Chat → MCP servers → `context7` ✓.
```

- [ ] **Step 3: Commit**

```bash
git add modules/M2-capacita/solution
git commit -m "feat(M2): solution folders with SOLUTION.md guide"
```

---

## Phase 5 — Module M3 "Governance" (Hooks)

### Task 5.1: M3 README

**Files:**
- Create: `modules/M3-governance/README.md`

- [ ] **Step 1: Write the M3 README**

Write to `modules/M3-governance/README.md`:

```markdown
# Modulo M3 — Governance · Hooks · 14 min

> Obiettivo: configurare un **safety guard** che intercetta i tool che Copilot sta per invocare e blocca quelli pericolosi.

## Teoria (4 min)

### Cos'è un hook
Un hook è un **event handler** che intercetta il ciclo di vita di Copilot. Eventi disponibili:
- `SessionStart` — inizio sessione
- `UserPromptSubmit` — ogni prompt che invii
- `PreToolUse` — **prima** che l'agente esegua un tool (Bash, Edit, Write, ...)
- `PostToolUse` — dopo l'esecuzione
- `SubagentStart` / `SubagentStop` — ciclo di vita subagent
- `PreCompact` / `Stop` — compressione contesto / fine sessione

### Use case
- **Guardrail** — blocca azioni pericolose (PreToolUse + exit code != 0).
- **Audit** — logga cosa fa l'agente (PostToolUse).
- **Automazione** — esegui hook a fine sessione.

### Differenza chiave
Gli hook sono **dell'organizzazione**, non dell'LLM. Non si possono "prompt-injectare via". Sono enforcement vero, policy-as-code.

## Hands-on (7 min) — un solo esercizio: safety guard

Lo starter ha:
- `.copilot/policy.yml` — file di policy con pattern bloccati (preset)
- `.copilot/hooks/pre-tool-use.sh` — hook che valuta tool call vs policy

### Step 1 — Vedi il blocco in azione (2')

In Copilot Chat (Agent):
> Fai pulizia di tutti i file temporanei in `/tmp`.

L'agente prova `rm -rf /tmp/*` → l'hook blocca → l'agente riformula con `find /tmp -type f -delete`.

### Step 2 — Estendi la policy (3')

Apri `.copilot/policy.yml`. Aggiungi nella sezione `file_writes_blocked`:

```yaml
  - pattern: '\.env$'
    reason: "Mai scrivere file di environment dal codice generato"
```

Poi:
> Crea un file `.env` con credenziali demo per il database locale.

Osserva: blocco visibile.

### Step 3 — Customizza il messaggio (2')

Nell'hook `pre-tool-use.sh`, cambia il messaggio di blocco aggiungendo riga di spiegazione/suggerimento. Riprova: l'agente reagisce diversamente.

## Wrap (3')

- Hook = fiducia controllata.
- Il `policy.yml` lo copi nel repo aziendale lunedì.
- Bridge a M4: stesso pattern in `dev-guardian` del marketplace.

## Output del modulo
- `.copilot/policy.yml` riusabile.
- Hook `pre-tool-use.sh` funzionante.

Se sei bloccato: `solution/{linguaggio}/`.

➡️ Prossimo: [`../M4-distribuzione/README.md`](../M4-distribuzione/README.md)
```

- [ ] **Step 2: Commit**

```bash
git add modules/M3-governance/README.md
git commit -m "docs(M3): README with theory, hands-on, wrap"
```

---

### Task 5.2: M3 starters + policy.yml

**Files:**
- Create: `modules/M3-governance/starters/{dotnet,typescript,python}/.copilot/policy.yml`

- [ ] **Step 1: Copy M2 solutions as M3 starters**

Run:
```bash
for lang in dotnet typescript python; do
  mkdir -p "modules/M3-governance/starters/$lang"
  cp -R "modules/M2-capacita/solution/$lang/." "modules/M3-governance/starters/$lang/"
  mkdir -p "modules/M3-governance/starters/$lang/.copilot/hooks"
done
```

- [ ] **Step 2: Write policy.yml (same content in all 3 starters)**

Write to **all three** `modules/M3-governance/starters/{dotnet,typescript,python}/.copilot/policy.yml`:

```yaml
# Workshop policy file — evaluated by .copilot/hooks/pre-tool-use.sh
#
# Sections:
#   shell_blocked: regex matched against full shell command
#   file_writes_blocked: regex matched against target path of Edit/Write/MultiEdit

shell_blocked:
  - pattern: 'rm\s+-rf?'
    reason: "Distruzione ricorsiva non recuperabile"
  - pattern: 'git\s+push\s+--force(\s|$)'
    reason: "Force push può sovrascrivere lavoro altrui"
  - pattern: 'git\s+reset\s+--hard'
    reason: "Reset hard cancella modifiche non committate"
  - pattern: 'DROP\s+TABLE'
    reason: "Drop table su SQL = perdita schema"
  - pattern: 'DELETE\s+FROM\s+\w+\s*;'
    reason: "DELETE senza WHERE = cancellazione totale"

file_writes_blocked:
  - pattern: '\.key$|\.pem$'
    reason: "Mai scrivere chiavi crittografiche da codice generato"
  - pattern: 'secrets/'
    reason: "Cartella secrets/ è gestita manualmente"
  # esercizio: il partecipante aggiungerà la regola per .env qui
```

- [ ] **Step 3: Commit**

```bash
git add modules/M3-governance/starters
git commit -m "feat(M3): M3 starters with .copilot/policy.yml"
```

---

### Task 5.3: PreToolUse hook script

**Files:**
- Create: `modules/M3-governance/starters/{dotnet,typescript,python}/.copilot/hooks/pre-tool-use.sh`

- [ ] **Step 1: Write the hook (same content in all 3 starters)**

Write to **all three** `modules/M3-governance/starters/{dotnet,typescript,python}/.copilot/hooks/pre-tool-use.sh`:

```bash
#!/usr/bin/env bash
# PreToolUse hook: blocks tool calls that violate .copilot/policy.yml.
#
# Input contract: reads JSON from stdin with keys: tool, parameters
# Output: exit 0 = allow; exit 1 = block (stdout shown to agent as block reason)

set -euo pipefail

POLICY="${COPILOT_REPO_ROOT:-$PWD}/.copilot/policy.yml"
if [ ! -f "$POLICY" ]; then
  exit 0
fi

INPUT=$(cat)
TOOL=$(echo "$INPUT" | jq -r '.tool // ""')

block() {
  local reason="$1"
  echo "BLOCKED by policy.yml: $reason"
  exit 1
}

read_section() {
  # Reads patterns under a given top-level YAML key.
  # Args: $1 = section name (shell_blocked or file_writes_blocked)
  awk -v section="$1" '
    $0 ~ "^"section":$" { inside=1; next }
    /^[a-zA-Z_]+:$/ { inside=0 }
    inside && /pattern:/ {
      sub(/^[[:space:]]*-?[[:space:]]*pattern:[[:space:]]*/, "")
      gsub(/^['"'"'"]|['"'"'"]$/, "")
      print
    }
  ' "$POLICY"
}

read_reason() {
  # For a given pattern, find its 'reason:' line in the policy.
  local pattern="$1" section="$2"
  awk -v section="$section" -v p="$pattern" '
    $0 ~ "^"section":$" { inside=1; next }
    /^[a-zA-Z_]+:$/ { inside=0 }
    inside && /pattern:/ {
      cur=$0
      sub(/^[[:space:]]*-?[[:space:]]*pattern:[[:space:]]*/, "", cur)
      gsub(/^['"'"'"]|['"'"'"]$/, "", cur)
      matched = (cur == p)
    }
    inside && matched && /reason:/ {
      sub(/^[[:space:]]*reason:[[:space:]]*/, "")
      gsub(/^['"'"'"]|['"'"'"]$/, "")
      print
      exit
    }
  ' "$POLICY"
}

case "$TOOL" in
  Bash)
    CMD=$(echo "$INPUT" | jq -r '.parameters.command // ""')
    while IFS= read -r pattern; do
      [ -z "$pattern" ] && continue
      if echo "$CMD" | grep -qE "$pattern"; then
        reason=$(read_reason "$pattern" "shell_blocked")
        block "${reason:-pattern $pattern}"
      fi
    done < <(read_section shell_blocked)
    ;;
  Edit|Write|MultiEdit)
    PATH_VAL=$(echo "$INPUT" | jq -r '.parameters.file_path // .parameters.path // ""')
    while IFS= read -r pattern; do
      [ -z "$pattern" ] && continue
      if echo "$PATH_VAL" | grep -qE "$pattern"; then
        reason=$(read_reason "$pattern" "file_writes_blocked")
        block "${reason:-path matches $pattern}"
      fi
    done < <(read_section file_writes_blocked)
    ;;
esac

exit 0
```

- [ ] **Step 2: Make executable**

Run:
```bash
chmod +x modules/M3-governance/starters/*/.copilot/hooks/pre-tool-use.sh
```

- [ ] **Step 3: Smoke-test the hook**

Run:
```bash
echo '{"tool":"Bash","parameters":{"command":"rm -rf /tmp/x"}}' | \
  COPILOT_REPO_ROOT=modules/M3-governance/starters/dotnet \
  modules/M3-governance/starters/dotnet/.copilot/hooks/pre-tool-use.sh
echo "exit=$?"
```

Expected:
```
BLOCKED by policy.yml: Distruzione ricorsiva non recuperabile
exit=1
```

And the allow case:
```bash
echo '{"tool":"Bash","parameters":{"command":"ls -la"}}' | \
  COPILOT_REPO_ROOT=modules/M3-governance/starters/dotnet \
  modules/M3-governance/starters/dotnet/.copilot/hooks/pre-tool-use.sh
echo "exit=$?"
```

Expected: `exit=0`

- [ ] **Step 4: Commit**

```bash
git add modules/M3-governance/starters/*/.copilot/hooks/pre-tool-use.sh
git commit -m "feat(M3): PreToolUse hook that enforces policy.yml"
```

---

### Task 5.4: M3 solution (policy estesa + messaggio customizzato)

**Files:**
- Create: `modules/M3-governance/solution/{dotnet,typescript,python}/`
- Modify: `modules/M3-governance/solution/{dotnet,typescript,python}/.copilot/policy.yml`
- Modify: `modules/M3-governance/solution/{dotnet,typescript,python}/.copilot/hooks/pre-tool-use.sh`

- [ ] **Step 1: Copy starters to solutions**

Run:
```bash
for lang in dotnet typescript python; do
  mkdir -p "modules/M3-governance/solution/$lang"
  cp -R "modules/M3-governance/starters/$lang/." "modules/M3-governance/solution/$lang/"
done
```

- [ ] **Step 2: Extend policy.yml with the .env rule**

For each language solution, edit `modules/M3-governance/solution/{lang}/.copilot/policy.yml` and append to the `file_writes_blocked` list (before the final comment line):

```yaml
  - pattern: '\.env$'
    reason: "Mai scrivere file di environment dal codice generato"
```

- [ ] **Step 3: Customize the block message**

In each solution's `.copilot/hooks/pre-tool-use.sh`, replace the `block()` function with:

```bash
block() {
  local reason="$1"
  echo "🛑 BLOCKED by .copilot/policy.yml"
  echo "Reason: $reason"
  echo ""
  echo "Suggerimento: riformula in modo non distruttivo, oppure modifica policy.yml se sei sicuro."
  exit 1
}
```

- [ ] **Step 4: Smoke test the solution hook**

```bash
echo '{"tool":"Write","parameters":{"file_path":".env"}}' | \
  COPILOT_REPO_ROOT=modules/M3-governance/solution/dotnet \
  modules/M3-governance/solution/dotnet/.copilot/hooks/pre-tool-use.sh
echo "exit=$?"
```

Expected: block message including the custom message, exit=1.

- [ ] **Step 5: Commit**

```bash
git add modules/M3-governance/solution
git commit -m "feat(M3): solution with extended policy and custom block message"
```

---

## Phase 6 — Module M4 "Distribuzione" (Plugins & Marketplace)

### Task 6.1: M4 README

**Files:**
- Create: `modules/M4-distribuzione/README.md`

- [ ] **Step 1: Write the M4 README**

Write to `modules/M4-distribuzione/README.md`:

```markdown
# Modulo M4 — Distribuzione · Plugins & Marketplace · 14 min

> Obiettivo: vedere come un plugin **bundle-zia** skill + subagent + hook + MCP in un singolo artefatto distribuibile.

## Teoria (4 min)

### Cos'è un plugin
Bundle (skill + agent + hook + MCP config) con manifest versionato. Installabile da marketplace come unità singola.

### Marketplace
- **Awesome GitHub Copilot** — marketplace default per CLI e VS Code Chat.
- **Enterprise-managed plugins** — distribuzione interna controllata.

### Portabilità
Lo **stesso bundle** funziona su **tre superfici**: Copilot CLI, Copilot Chat in VS Code, Claude Code. Una pipeline di distribuzione.

## Hands-on (7 min)

### Step 1 — Installa un plugin reale (3')

Lo speaker mostra dal proiettore (Copilot CLI):
```
copilot plugin marketplace add https://github.com/render93/gh-copilot-dev-days-2026.git
copilot plugin install dev-guardian
```

Tu dal Codespace (VS Code Copilot Chat):
1. Apri pannello Copilot Chat
2. Tasto destro → "Manage Plugins" → "Add from URL"
3. Incolla `https://github.com/render93/gh-copilot-dev-days-2026`
4. Installa `dev-guardian`

Esplora cosa fornisce `dev-guardian`:
- 3 skill
- 1 agent `test-writer`
- 1 MCP filesystem
- 2 hook (`postToolUse`, `sessionStart`)

**Punto chiave**: l'hook `postToolUse` di dev-guardian usa lo stesso meccanismo che hai costruito in M3 (PreToolUse). Stesso pattern, applicazione diversa.

### Step 2 — Impacchetta il tuo plugin (4')

Crea `plugins/copilot-safety-guard/` con:

```
plugins/copilot-safety-guard/
├── plugin.json
├── skills/endpoint-creator/SKILL.md      (da M1)
├── agents/code-reviewer.agent.md          (da M2)
└── hooks/pre-tool-use.sh                  (da M3)
```

Crea `plugins/copilot-safety-guard/plugin.json`:
```json
{
  "name": "copilot-safety-guard",
  "version": "0.1.0",
  "description": "Plugin di workshop che bundleizza endpoint-creator skill, code-reviewer subagent e safety hook PreToolUse.",
  "components": {
    "skills": ["./skills/endpoint-creator"],
    "agents": ["./agents/code-reviewer.agent.md"],
    "hooks": {
      "preToolUse": "./hooks/pre-tool-use.sh"
    },
    "mcpServers": []
  },
  "author": "Workshop Participant",
  "license": "MIT"
}
```

Non pubblichi: vedi *come* si farebbe.

## Wrap (3')

- Plugin = unit of distribution dell'agentic dev.
- Tre superfici, stesso bundle. Eco di AGENTS.md cross-tool, scalato.

## Output del modulo
- `dev-guardian` installato e ispezionato.
- Plugin `plugins/copilot-safety-guard/` con manifest.

Se sei bloccato: `solution/{linguaggio}/`.

➡️ Ora il microfono passa al co-speaker per M5 (Spec-Driven Development).
```

- [ ] **Step 2: Commit**

```bash
git add modules/M4-distribuzione/README.md
git commit -m "docs(M4): README with theory, hands-on, wrap"
```

---

### Task 6.2: M4 starters (copia da M3 solution)

**Files:**
- Create: `modules/M4-distribuzione/starters/{dotnet,typescript,python}/`

- [ ] **Step 1: Copy M3 solutions as M4 starters**

Run:
```bash
for lang in dotnet typescript python; do
  mkdir -p "modules/M4-distribuzione/starters/$lang"
  cp -R "modules/M3-governance/solution/$lang/." "modules/M4-distribuzione/starters/$lang/"
done
```

- [ ] **Step 2: Commit**

```bash
git add modules/M4-distribuzione/starters
git commit -m "feat(M4): starters from M3 solution"
```

---

### Task 6.3: M4 solution con plugin bundle completo

**Files:**
- Create: `modules/M4-distribuzione/solution/{dotnet,typescript,python}/plugins/copilot-safety-guard/`

- [ ] **Step 1: Copy starters to solutions and create plugin folder**

Run:
```bash
for lang in dotnet typescript python; do
  mkdir -p "modules/M4-distribuzione/solution/$lang"
  cp -R "modules/M4-distribuzione/starters/$lang/." "modules/M4-distribuzione/solution/$lang/"

  base="modules/M4-distribuzione/solution/$lang/plugins/copilot-safety-guard"
  mkdir -p "$base/skills" "$base/agents" "$base/hooks"
  cp -R "modules/M4-distribuzione/solution/$lang/skills/endpoint-creator" "$base/skills/"
  cp "modules/M4-distribuzione/solution/$lang/agents/code-reviewer.agent.md" "$base/agents/"
  cp "modules/M4-distribuzione/solution/$lang/.copilot/hooks/pre-tool-use.sh" "$base/hooks/"
done
```

- [ ] **Step 2: Write plugin.json in each language solution**

Write to **all three** `modules/M4-distribuzione/solution/{dotnet,typescript,python}/plugins/copilot-safety-guard/plugin.json`:

```json
{
  "name": "copilot-safety-guard",
  "version": "0.1.0",
  "description": "Workshop plugin: endpoint-creator skill + code-reviewer subagent + safety PreToolUse hook for guarded agentic dev.",
  "components": {
    "skills": ["./skills/endpoint-creator"],
    "agents": ["./agents/code-reviewer.agent.md"],
    "hooks": {
      "preToolUse": "./hooks/pre-tool-use.sh"
    },
    "mcpServers": []
  },
  "author": "Workshop Participant",
  "license": "MIT",
  "repository": "https://github.com/<your-fork>/copilot-workshop-2026"
}
```

- [ ] **Step 3: Commit**

```bash
git add modules/M4-distribuzione/solution
git commit -m "feat(M4): solution with copilot-safety-guard plugin bundle"
```

---

## Phase 7 — Documentation

### Task 7.1: docs/00-intro.md

**Files:**
- Create: `docs/00-intro.md`

- [ ] **Step 1: Write the intro**

Run:
```bash
mkdir -p docs
```

Write to `docs/00-intro.md`:

```markdown
# Introduzione — The Agent Strikes Back

Benvenuto al workshop. In 90 minuti hands-on vedrai come gli agenti Copilot moderni si configurano, si compongono, si governano e si distribuiscono.

## La storia in una pagina

Un anno fa parlavamo del "risveglio degli agenti". Oggi gli agenti sono **strumenti di produzione**. Questo workshop ti mostra 6 primitive che hanno reso possibile la transizione:

1. **AGENTS.md** — lo standard "system prompt del repo", cross-tool.
2. **Skills** — know-how componibile, caricato on-demand.
3. **Subagents** — task delegati, contesto isolato, parallelizzabili.
4. **MCP** — tool e dati portati all'agente via protocollo standard.
5. **Hooks** — policy-as-code per il comportamento dell'agente.
6. **Plugins & Marketplace** — bundle distribuibile, cross-superficie.

Più, in chiusura, **Spec-Driven Development** come paradigma che li unisce.

## Come è organizzato il workshop

- 4 moduli hands-on (M1-M4) — ognuno con teoria, esercizio, wrap.
- 1 chiusura concettuale M5 sullo Spec-Driven Development (presentata dal co-speaker).

Ogni modulo ha:
- `README.md` — istruzioni
- `starters/{dotnet,typescript,python}/` — punto di partenza per il tuo linguaggio
- `solution/{dotnet,typescript,python}/` — stato finale del modulo (se ti blocchi)

## Setup

Apri il [Codespace](../README.md) e attendi che parta. Verifica che l'icona Copilot in basso a destra sia attiva.

## Glossario

Termini agentic spiegati in [`glossario.md`](glossario.md).

➡️ Apri [`../modules/M1-istruzioni/README.md`](../modules/M1-istruzioni/README.md) per iniziare.
```

- [ ] **Step 2: Commit**

```bash
git add docs/00-intro.md
git commit -m "docs: intro page"
```

---

### Task 7.2: docs/glossario.md

**Files:**
- Create: `docs/glossario.md`

- [ ] **Step 1: Write the glossary**

Write to `docs/glossario.md`:

```markdown
# Glossario — Termini Agentic Copilot

## Agent (in "Agent mode")
Modalità di Copilot Chat in cui l'AI può eseguire tool (Bash, Edit, Write, MCP) per portare a termine task multi-step. Diversa da "Ask mode" (solo conversazione).

## AGENTS.md
File a livello repo che descrive convenzioni, regole, contesto del progetto. Iniettato in ogni prompt della sessione agentica. Standard cross-tool.

## Hook
Event handler che intercetta il ciclo di vita Copilot (`PreToolUse`, `PostToolUse`, ecc.). Policy-as-code per gli agenti.

## MCP (Model Context Protocol)
Protocollo standard per esporre **tools** e **resources** a un agente. Un MCP server è un processo che parla questo protocollo.

## Marketplace
Registry da cui scaricare plugin. Default: "Awesome GitHub Copilot". Aziende: "Enterprise-managed plugins".

## Plugin
Bundle versionato (agent + skill + hook + MCP config) installabile come unità. Funziona in Copilot CLI, Copilot Chat (VS Code), Claude Code.

## Skill
Cartella con `SKILL.md` (frontmatter YAML + istruzioni) + script/resource. Caricata on-demand dall'agente.

## Spec-Driven Development (SDD)
Paradigma in cui una spec macchina-leggibile è la fonte di verità: l'agente genera, valida e mantiene il codice in conformità. Presentato in M5.

## Subagent
Agente "figlio" invocato dal main agent. Parte con contesto isolato. Definito in `agents/<nome>.agent.md`.
```

- [ ] **Step 2: Commit**

```bash
git add docs/glossario.md
git commit -m "docs: glossary"
```

---

### Task 7.3: docs/timing-conduzione.md (speaker runbook)

**Files:**
- Create: `docs/timing-conduzione.md`

- [ ] **Step 1: Write the runbook**

Write to `docs/timing-conduzione.md`:

```markdown
# Runbook Conduzione — 90 minuti

> Documento operativo per i 2 speaker. Cosa dire, cosa cliccare, in che minuto.

## Pre-workshop (T-15 min)

- [ ] Proietta la slide di apertura con QR code al repo
- [ ] Pre-apri 1 Codespace di prova per verificare che parta
- [ ] Apri 2 finestre del terminale: una per CLI demo, una di backup
- [ ] Pre-apri il marketplace `gh-copilot-dev-days-2026` su GitHub (tab browser)
- [ ] Co-speaker prepara la sua macchina per M5 (SDD)

---

## T+00:00 — 00:05 · Intro + setup check (5')

**Gerardo:**
> "Un anno fa raccontavamo il risveglio degli agenti Copilot. Oggi gli agenti scrivono codice in produzione. In 90 minuti vediamo le 6 primitive che hanno reso possibile la transizione, e ne tocchiamo 5 con le mani. Apri il QR code, lancia il Codespace. Chi è dentro alzi la mano."

**Co-speaker:** gira tra i banchi, aiuta chi non ha la mano alzata.

**Promessa**:
> "A fine workshop avrai un repo personale con: AGENTS.md, una skill custom, un MCP attivo, un subagent, un hook di safety, un plugin bundle. Te lo porti a casa."

---

## T+00:05 — 00:23 · M1 Istruzioni (18')

- [00:05] Teoria (5'): AGENTS.md (best practice, <200 righe, iniettato ogni prompt) + Skill (frontmatter, on-demand).
- [00:10] Step 1 (3'): chiediamo `/tasks/stats`. Tutti seguono.
- [00:13] Step 2 (5'): creiamo skill `endpoint-creator`. Rifacciamo la richiesta.
- [00:18] Step 3 (2'): diff prima/dopo.
- [00:20] Wrap (3'): AGENTS.md = chi sei, Skill = cosa sai fare bene.

**Sync point [00:23]:** *"Chi è indietro: copia da `solution/`. Si riparte tutti insieme."*

---

## T+00:23 — 00:41 · M2 Capacità (18')

- [00:23] Teoria (5'): Subagent (frontmatter, contesto isolato) + MCP.
- [00:28] Step 1 (4'): attivare Context7, vedere docs in chat.
- [00:32] Step 2 (4'): invocare `@code-reviewer`.
- [00:36] Step 3 (2'): composizione subagent + Context7.
- [00:38] Wrap (3').

**Sync point [00:41]:** *"Si chiude M2. Aprite M3."*

---

## T+00:41 — 00:55 · M3 Governance (14')

- [00:41] Teoria (4'): hook = policy-as-code. Eventi. Hook non prompt-injectable.
- [00:45] Step 1 (2'): blocco `rm -rf` visibile.
- [00:47] Step 2 (3'): estendere policy con `.env`.
- [00:50] Step 3 (2'): customizzare messaggio.
- [00:52] Wrap (3'): bridge a M4: *"stesso pattern di hook lo vedete in dev-guardian tra 10 secondi."*

**Sync point [00:55]:** transizione naturale.

---

## T+00:55 — 01:09 · M4 Distribuzione (14')

- [00:55] Teoria (4'): plugin bundle, marketplace, 3 superfici.
- [00:59] Step 1 (3'): Gerardo proietta CLI:
  ```
  copilot plugin marketplace add https://github.com/render93/gh-copilot-dev-days-2026.git
  copilot plugin install dev-guardian
  ```
  I partecipanti installano da VS Code Chat marketplace UI.
  **Frase chiave**: *"Stesso bundle, tre superfici (CLI + VS Code + Claude Code), una pipeline."*
- [01:02] Step 2 (4'): impacchettare `copilot-safety-guard`.
- [01:06] Wrap (3').

**Sync point [01:09]:** Gerardo passa il microfono.

---

## T+01:09 — 01:21 · M5 Spec-Driven Development (12')

**Co-speaker** prende la sala.

Bridge da Gerardo:
> "I 4 moduli ti hanno dato i mattoni. Ora [co-speaker] ti mostra il paradigma che li unisce."

(Contenuto da definire col co-speaker prima del workshop.)

---

## T+01:21 — 01:30 · Q&A + outro (9')

**Gerardo + co-speaker insieme**.

Domande tipiche:
- Hook in CI?
- Versionare policy.yml col repo? (sì)
- Quando MCP custom?
- Plugin private aziendali?
- SDD per legacy?

**Outro:**
> "Cosa porti a casa: il tuo fork con tutto dentro. Lunedì mattina copia il policy.yml in un repo aziendale. Grazie."

---

## Gestione guasti

Vedi tabella in §6 del design doc.

## Strumenti aperti per Gerardo
- Browser: tab repo workshop + tab marketplace
- Terminale 1: Copilot CLI loggato
- Terminale 2: backup
- VS Code: Codespace dal proiettore
```

- [ ] **Step 2: Commit**

```bash
git add docs/timing-conduzione.md
git commit -m "docs: speaker runbook with minute-by-minute timing"
```

---

### Task 7.4: docs/follow-up.md

**Files:**
- Create: `docs/follow-up.md`

- [ ] **Step 1: Write follow-up resources**

Write to `docs/follow-up.md`:

```markdown
# Follow-up — Risorse post-workshop

## Marketplace e plugin
- **[Awesome GitHub Copilot](https://github.com/github/awesome-copilot)** — marketplace ufficiale curato.
- **[render93/gh-copilot-dev-days-2026](https://github.com/render93/gh-copilot-dev-days-2026)** — il marketplace di esempio con 3 plugin (`pr-helper`, `dev-guardian`, `story-crafter`).

## Documentazione ufficiale
- **Microsoft Learn — GitHub Copilot agent mode**.
- **docs.github.com/copilot** — AGENTS.md, custom agents, skills, hooks, plugins.

## MCP
- **[Awesome MCP servers](https://github.com/punkpeye/awesome-mcp-servers)**.
- **[Context7](https://context7.com/)** — l'MCP usato in M2.

## Spec-Driven Development (M5)
- Materiali del co-speaker — *(da popolare prima del workshop)*.

## Prossimi passi suggeriti
1. **Lunedì**: copia `policy.yml` in un repo aziendale. Misura il delta di comportamento dell'agente.
2. **Settimana**: scrivi 1 AGENTS.md per un tuo repo abituale.
3. **Mese**: identifica 1 task ripetitivo del team → skill/subagent custom.
4. **Trimestre**: valuta plugin enterprise-managed.

## Feedback
Apri una issue sul repo del workshop.
```

- [ ] **Step 2: Commit**

```bash
git add docs/follow-up.md
git commit -m "docs: follow-up resources"
```

---

## Phase 8 — Polish & speaker materials

### Task 8.1: Final README

**Files:**
- Modify: `README.md`

- [ ] **Step 1: Overwrite README with final landing**

Write to `README.md`:

```markdown
# Workshop "The Agent Strikes Back" — GitHub Copilot 2026

> Workshop hands-on di 90 minuti su agenti Copilot: AGENTS.md, Skills, Subagents, MCP, Hooks, Plugins & Marketplace + intro a Spec-Driven Development.

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/<owner>/<repo>?quickstart=1)

## Per chi partecipa

1. Click su "Open in GitHub Codespaces" qui sopra.
2. Attendi ~2 min che il Codespace parta.
3. Verifica che l'icona Copilot in basso a destra sia attiva.
4. Apri `docs/00-intro.md`, poi `modules/M1-istruzioni/README.md`.

Se il Codespace non parte: vedi [setup locale](#setup-locale-fallback).

## Per gli speaker
- Runbook minuto-per-minuto: [`docs/timing-conduzione.md`](docs/timing-conduzione.md)
- Email pre-workshop: [`email-template.md`](email-template.md)

## Struttura del workshop

| Modulo | Topic | Durata | Presentato da |
|---|---|---|---|
| M1 Istruzioni | AGENTS.md + Skills | 18' | Gerardo |
| M2 Capacità | Subagents + MCP (Context7) | 18' | Gerardo |
| M3 Governance | Hooks (safety guard) | 14' | Gerardo |
| M4 Distribuzione | Plugins & Marketplace | 14' | Gerardo |
| M5 SDD | Spec-Driven Development | 12' | Co-speaker |

## Cosa ti porti a casa

- AGENTS.md letto e capito + skill `endpoint-creator`
- Context7 MCP configurato + subagent `code-reviewer`
- Hook safety guard funzionante + `policy.yml` riusabile
- Plugin bundle `copilot-safety-guard`

## Setup locale (fallback)

Se non usi Codespace, ti serve almeno **uno** tra: .NET 8 SDK, Node 20+, Python 3.11+. Più VS Code + estensione GitHub Copilot autenticata.

## Lingue
- README, docs, moduli: **italiano**.
- Codice, nomi, branch, commit: **inglese**.

## Risorse post-workshop
Vedi [`docs/follow-up.md`](docs/follow-up.md).

## Licenza
MIT.
```

- [ ] **Step 2: Commit**

```bash
git add README.md
git commit -m "docs: final landing README with Codespace badge"
```

---

### Task 8.2: Email template

**Files:**
- Create: `email-template.md`

- [ ] **Step 1: Write the email template**

Write to `email-template.md`:

```markdown
# Email pre-workshop — da inviare T-7 giorni

**Oggetto:** [Workshop Copilot 2026] Setup necessario — 5 min di lettura

---

Ciao,

ti aspettiamo al workshop **"The Agent Strikes Back"** il [data] alle [ora].

**Per partecipare hands-on:**

✅ Account GitHub.

✅ Almeno UNO di questi:
- Copilot Pro / Pro+ / Business attivo, OPPURE
- Licenza Copilot via organizzazione, OPPURE
- Studente / teacher / OSS maintainer con Copilot gratis abilitato.

⚠️ Copilot Free funziona ma con limiti stretti (~50 chat msg/mese): potresti esaurirli a metà workshop. Plan B: pairing col vicino.

✅ Browser moderno.

**NON serve installare niente in locale**: useremo GitHub Codespaces.

**Test "ready"** (5 minuti, prima del workshop):
1. Apri: [URL repo]
2. Clicca "Open in Codespace" sul README.
3. Attendi ~2 min.
4. Verifica icona Copilot attiva.
5. Problemi → rispondi a questa mail entro [data -2gg].

Ci vediamo!

Gerardo + [co-speaker]
```

- [ ] **Step 2: Commit**

```bash
git add email-template.md
git commit -m "docs: pre-workshop email template"
```

---

### Task 8.3: Dry-run checklist

**Files:**
- Create: `docs/dry-run-checklist.md`

- [ ] **Step 1: Write dry-run checklist**

Write to `docs/dry-run-checklist.md`:

```markdown
# Dry-run Checklist — T-3 giorni

I 2 speaker eseguono il workshop end-to-end come fossero partecipanti, cronometrando.

## Prerequisiti
- [ ] Codespace fresh aperto (no cache)
- [ ] Timer attivo
- [ ] Macchine con linguaggi diversi (verificare eterogeneità)

## Modulo per modulo

### Setup (5')
- [ ] Codespace parte in <3 min: ___ min effettivi
- [ ] Copilot attivo subito: sì/no
- [ ] Context7 risponde: sì/no

### M1 (18')
- [ ] Step 1 (chiedi `/tasks/stats`): output coerente con AGENTS.md? sì/no
- [ ] Step 2 (skill endpoint-creator): caricata auto? sì/no
- [ ] Step 3 (diff): visibile dal proiettore? sì/no
- [ ] **Totale M1**: ___ min

### M2 (18')
- [ ] Context7 attivo senza interventi: sì/no
- [ ] @code-reviewer parte: sì/no
- [ ] Composizione funziona: sì/no
- [ ] **Totale M2**: ___ min

### M3 (14')
- [ ] Blocco `rm -rf` visibile: sì/no
- [ ] Estensione policy `.env` blocca: sì/no
- [ ] Messaggio customizzato chiaro: sì/no
- [ ] **Totale M3**: ___ min

### M4 (14')
- [ ] CLI install marketplace: sì/no
- [ ] VS Code Chat install: sì/no
- [ ] Plugin bundle locale senza errori: sì/no
- [ ] **Totale M4**: ___ min

### M5 (12') — col co-speaker
- [ ] Bridge da M4 fluido: sì/no
- [ ] Vocabolario allineato: sì/no
- [ ] **Totale M5**: ___ min

### Q&A + outro (9')
- [ ] Tempo per 3-4 domande: sì/no

## Totale ≤ 90 min? sì/no

## Action items
-
-
-
```

- [ ] **Step 2: Commit**

```bash
git add docs/dry-run-checklist.md
git commit -m "docs: dry-run checklist for speakers"
```

---

## Phase 9 — Final verification

### Task 9.1: Push + smoke-test Codespace

- [ ] **Step 1: Create GitHub repo and push**

Run:
```bash
gh repo create copilot-workshop-2026 --public --source=. --remote=origin --push
```

Expected: repo created, URL printed.

- [ ] **Step 2: Update Codespace badge URL**

Edit `README.md` — replace `<owner>/<repo>` in the badge URL with the actual `owner/repo`. Commit + push:
```bash
git add README.md && git commit -m "docs: fix Codespace badge URL" && git push
```

- [ ] **Step 3: Open Codespace + smoke tests**

In GitHub UI: Code → Codespaces → "Create codespace on main". Wait ~2-3 min.

In the Codespace terminal:
```bash
# Starters tests
cd modules/M1-istruzioni/starters/dotnet && dotnet test --nologo
cd ../typescript && npm test
cd ../python && pytest

# Hook
echo '{"tool":"Bash","parameters":{"command":"rm -rf /tmp/x"}}' | \
  COPILOT_REPO_ROOT=$PWD/modules/M3-governance/starters/dotnet \
  modules/M3-governance/starters/dotnet/.copilot/hooks/pre-tool-use.sh
echo "exit=$?"
# Expected: BLOCKED + exit=1

# Context7
npx -y @upstash/context7-mcp --help | head -5
# Expected: help printed without errors
```

- [ ] **Step 4: Verify Copilot Chat works**

In VS Code (Codespace): bottom-right Copilot icon active, open Chat, send test message, confirm response.

- [ ] **Step 5: Fix anything broken, push**

If a smoke test fails, fix inline and push. No new commits otherwise.

---

### Task 9.2: Dry-run end-to-end

- [ ] **Step 1: Schedule dry-run**

Coordinate 90-min session with both speakers. Each follows `docs/dry-run-checklist.md`.

- [ ] **Step 2: Note timing deltas + action items**

Fill the checklist, commit a copy as `docs/dry-run-notes-<YYYY-MM-DD>.md`.

- [ ] **Step 3: Apply action items**

For each item flagged, open a small commit fixing it.

- [ ] **Step 4: Final tag**

```bash
git tag -a v1.0-workshop -m "Ready for The Agent Strikes Back workshop"
git push --tags
```

---

## Notes for the executing agent

- **TDD discipline**: Phase 2 (starters) uses failing-test → minimal-impl → passing-test. Phases 3-6 (workshop artifacts: README, AGENTS.md, skills, hooks, plugins) are content-driven — "test" is manual verification (e.g., hook smoke test).
- **Commit cadence**: every task ends with a commit. Don't batch.
- **Shared content across languages**: where same file appears in 3 starters (e.g., `policy.yml`), the plan says "write to all three" — one logical step, three file writes.
- **No premature publishing**: NEVER push `copilot-safety-guard` to a public marketplace from the workshop repo.
- **dev-guardian assumption**: the plan assumes `https://github.com/render93/gh-copilot-dev-days-2026` is publicly accessible. Fallback: another plugin from Awesome Copilot if access changes.
- **Codespace image size**: universal image with 3 SDKs is ~3-4 GB. First boot 2-3 min — accounted for in setup window.
- **jq + yq in devcontainer**: the M3 hook uses `jq`. The universal devcontainer image already has it. `yq` is NOT required — the hook uses pure awk.

