from fastapi import FastAPI, Depends
from pydantic import BaseModel
from typing import List
import asyncpg
import os

app = FastAPI()

DATABASE_URL = os.getenv("DB_URL", "postgresql://user:password@postgres:5432/reviews")

class Review(BaseModel):
    album_id: int
    rating: int
    comment: str

@app.on_event("startup")
async def startup():
    conn = await asyncpg.connect(DATABASE_URL)
    await conn.execute('''
        CREATE TABLE IF NOT EXISTS reviews (
            id SERIAL PRIMARY KEY,
            album_id INT NOT NULL,
            rating INT CHECK (rating BETWEEN 1 AND 5),
            comment TEXT
        )
    ''')
    await conn.close()

@app.post("/reviews/")
async def create_review(review: Review):
    async with await asyncpg.create_pool(DATABASE_URL) as pool:
        async with pool.acquire() as conn:
            await conn.execute(
                "INSERT INTO reviews(album_id, rating, comment) VALUES($1, $2, $3)",
                review.album_id, review.rating, review.comment
            )
    return {"status": "review created"}

@app.get("/reviews/{album_id}", response_model=List[Review])
async def get_reviews(album_id: int):
    async with await asyncpg.create_pool(DATABASE_URL) as pool:
        async with pool.acquire() as conn:
            records = await conn.fetch(
                "SELECT * FROM reviews WHERE album_id = $1", 
                album_id
            )
    return [dict(record) for record in records]