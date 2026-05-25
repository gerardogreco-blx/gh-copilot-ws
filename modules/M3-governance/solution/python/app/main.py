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


class ReplaceTaskRequest(BaseModel):
    title: str
    status: Literal["todo", "done"]


@app.put("/tasks/{task_id}")
def replace_task(task_id: int, req: ReplaceTaskRequest) -> dict:
    if not req.title.strip():
        raise HTTPException(status_code=400, detail="title required")
    replaced = store.replace(task_id, req.title, req.status)
    if replaced is None:
        raise HTTPException(status_code=404, detail="not found")
    return replaced.__dict__


@app.delete("/tasks/{task_id}", status_code=204)
def delete_task(task_id: int) -> None:
    if not store.delete(task_id):
        raise HTTPException(status_code=404, detail="not found")
