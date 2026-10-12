from fastapi import FastAPI
from pydantic import BaseModel
import asyncpg
import os

app = FastAPI()

DATABASE_URL = os.getenv("DB_URL", "postgresql://user:password@postgres:5432/social")

class Like(BaseModel):
    review_id: int

class Comment(BaseModel):
    review_id: int
    text: str

@app.on_event("startup")
async def startup():
    conn = await asyncpg.connect(DATABASE_URL)
    await conn.execute('''
        CREATE TABLE IF NOT EXISTS likes (
            id SERIAL PRIMARY KEY,
            review_id INT NOT NULL
        )
    ''')
    await conn.execute('''
        CREATE TABLE IF NOT EXISTS comments (
            id SERIAL PRIMARY KEY,
            review_id INT NOT NULL,
            text TEXT NOT NULL
        )
    ''')
    await conn.close()

@app.post("/likes/")
async def add_like(like: Like):
    async with await asyncpg.create_pool(DATABASE_URL) as pool:
        async with pool.acquire() as conn:
            await conn.execute(
                "INSERT INTO likes(review_id) VALUES($1)",
                like.review_id
            )
    return {"status": "like added"}

@app.post("/comments/")
async def add_comment(comment: Comment):
    async with await asyncpg.create_pool(DATABASE_URL) as pool:
        async with pool.acquire() as conn:
            await conn.execute(
                "INSERT INTO comments(review_id, text) VALUES($1, $2)",
                comment.review_id, comment.text
            )
    return {"status": "comment added"}