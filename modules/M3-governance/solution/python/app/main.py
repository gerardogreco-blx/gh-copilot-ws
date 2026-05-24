from fastapi import FastAPI, HTTPException
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
