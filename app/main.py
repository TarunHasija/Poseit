# main.py
from contextlib import asynccontextmanager
from fastapi import FastAPI
from app.core.config import settings
from app.core.database import engine, Base
from app.api.routes.auth import router
from app.api.routes.poses import router as poses_router
from app.repositories.db.pose_repo import PoseImage  # noqa: F401 - register ORM model

# ── 1. Lifespan: runs on startup & shutdown ──────────────────────────────────
@asynccontextmanager
async def lifespan(app: FastAPI):
    # STARTUP
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)   # creates tables if not exist
    print("✅ Database connected")
    
    yield                                                # app runs here
    
    # SHUTDOWN
    await engine.dispose()                              # close all DB connections
    print("🛑 Database disconnected")

# ── 2. App instance ──────────────────────────────────────────────────────────
app = FastAPI(
    title=settings.APP_NAME,
    debug=settings.DEBUG,
    lifespan=lifespan
)

app.include_router(router)
app.include_router(poses_router)
# # ── 3. Routers ───────────────────────────────────────────────────────────────
# from app.api.auth import router as auth_router
# # from app.api.users import router as user_router  ← add more as you build

# app.include_router(auth_router, prefix="/api")
# # app.include_router(user_router, prefix="/api")

# ── 4. Health check ──────────────────────────────────────────────────────────
@app.get("/")
async def root():
    return {"message": f"{settings.APP_NAME} is running"}
