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
