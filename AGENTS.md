# AGENTS.md — Workshop Repo

Questo file è il "system prompt" del repository: ogni agente che lavora qui lo legge prima di iniziare.

## Scopo del repo

Repository del workshop "The Agent Strikes Back" su GitHub Copilot (2026). Contiene 4 moduli hands-on con 3 starter per linguaggio (dotnet, typescript, python).

## Stack

- .NET 10 (ASP.NET Core Minimal API)
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
