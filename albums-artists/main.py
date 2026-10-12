from fastapi import FastAPI, HTTPException, Depends
from pydantic import BaseModel
from typing import List
import asyncpg
import os

app = FastAPI()

# Database configuration
DATABASE_URL = os.getenv("DB_URL", "postgresql://user:password@postgres:5432/albums")

pool = None

async def get_db():
    global pool
    if not pool:
        pool = await asyncpg.create_pool(DATABASE_URL)
    return pool

class Album(BaseModel):
    title: str
    artist: str
    year: int

@app.on_event("startup")
async def startup():
    conn = await asyncpg.connect(DATABASE_URL)
    await conn.execute('''
        CREATE TABLE IF NOT EXISTS albums (
            id SERIAL PRIMARY KEY,
            title TEXT NOT NULL,
            artist TEXT NOT NULL,
            year INT NOT NULL
        )
    ''')
    await conn.close()

@app.post("/albums/", response_model=Album)
async def create_album(album: Album):
    async with (await get_db()).acquire() as conn:
        await conn.execute(
            "INSERT INTO albums(title, artist, year) VALUES($1, $2, $3)",
            album.title, album.artist, album.year
        )
    return album

@app.get("/albums/", response_model=List[Album])
async def get_albums():
    async with (await get_db()).acquire() as conn:
        records = await conn.fetch("SELECT * FROM albums")
    return [dict(record) for record in records]