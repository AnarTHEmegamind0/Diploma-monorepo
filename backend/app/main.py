"""
FastAPI application entry point.
Image-Based Product Recognition and Automated Audit Decision System.
"""

from contextlib import asynccontextmanager
from pathlib import Path

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles

from .config import settings
from .database import database
from .routes import (
    detection,
    audit,
    products,
    auth,
    auditors,
    groups,
    tradeshops,
    categories,
    campaigns,
    surveys,
    audit_submit,
    mobile,
)


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Application startup and shutdown events."""
    # Startup
    await database.connect()
    print("Application started")
    yield
    # Shutdown
    await database.disconnect()
    print("Application stopped")


app = FastAPI(
    title="Inventory Audit System",
    description="Image-Based Product Recognition and Automated Audit Decision API",
    version="1.0.0",
    lifespan=lifespan,
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Mount static files for uploads
uploads_path = Path(settings.UPLOAD_DIR)
uploads_path.mkdir(parents=True, exist_ok=True)
app.mount("/uploads", StaticFiles(directory=str(uploads_path)), name="uploads")

# Include routers
app.include_router(auth.router, prefix="/api/auth", tags=["Authentication"])
app.include_router(auditors.router, prefix="/api/auditors", tags=["Auditors"])
app.include_router(groups.router, prefix="/api/groups", tags=["Groups"])
app.include_router(tradeshops.router, prefix="/api/tradeshops", tags=["Tradeshops"])
app.include_router(categories.router, prefix="/api/categories", tags=["Categories"])
app.include_router(campaigns.router, prefix="/api/campaigns", tags=["Campaigns"])
app.include_router(surveys.router, prefix="/api/surveys", tags=["Surveys"])
app.include_router(audit_submit.router, prefix="/api/audit-submit", tags=["Audit Submit"])
app.include_router(mobile.router, prefix="/api/mobile", tags=["Mobile App"])
app.include_router(detection.router, prefix="/api/detection", tags=["Detection"])
app.include_router(audit.router, prefix="/api/audit", tags=["Audit"])
app.include_router(products.router, prefix="/api/products", tags=["Products"])


@app.get("/")
async def root():
    return {
        "message": "Inventory Audit System API",
        "version": "1.0.0",
        "docs": "/docs",
    }


@app.get("/health")
async def health_check():
    return {"status": "healthy"}


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(
        "backend.app.main:app",
        host=settings.API_HOST,
        port=settings.API_PORT,
        reload=settings.API_DEBUG,
    )
