# backend/app/startup.py
import logging
from app.services.model_service import ModelService
from app.core.utils import setup_logging
from app.core.config import AppConfig
import os

log = setup_logging()
model_service = ModelService()


async def startup_event():
    """
    Executes when the FastAPI app starts
    Fetches the list of available models from Ollama API and caches it
    Creates a temporary directory for the app
    """
    log.info("Application startup event started")
    model_service.fetch_and_cache_models()

    # Create temporary directory if it doesn't exist
    if not os.path.exists(AppConfig.TEMP_UPLOAD_DIR):
        os.makedirs(AppConfig.TEMP_UPLOAD_DIR, exist_ok=True)
        log.info(f"Created temporary directory: {AppConfig.TEMP_UPLOAD_DIR}")

    log.info("Application startup event completed")
