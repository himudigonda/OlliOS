# backend/app/main.py
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.api.endpoints import router
from app.core.config import AppConfig
from app.core.utils import setup_logging
from app.startup import startup_event
import logging

# Initialize logging
log = setup_logging(logging.INFO)


app = FastAPI(
    title="OllamiOS Backend",
    description="A FastAPI server for handling LLM-based text generation.",
    version="1.0.0",
)

# CORS configuration to allow requests from the frontend
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allow all origins (adjust in production)
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routes
app.include_router(router)


@app.get("/")
async def root():
    """
    Root endpoint to verify that the server is running.
    """
    log.info("GET request received at root endpoint")
    return {"message": "Welcome to the OllamiOS Backend!"}


app.add_event_handler("startup", startup_event)
