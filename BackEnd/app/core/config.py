# backend/app/core/config.py
import os
from dotenv import load_dotenv

load_dotenv()


class AppConfig:
    """
    Application-wide configuration settings
    """

    API_HOST = os.getenv("API_HOST", "192.168.0.3")
    API_PORT = int(os.getenv("API_PORT", 8000))
    OLLAMA_API_BASE_URL = os.getenv("OLLAMA_API_BASE_URL", "http://localhost:11434/api")
    MODELS_CACHE_FILE = "models_cache.json"  # Path within the app directory
    TEMP_UPLOAD_DIR = "temp_uploads"  # Directory to store uploaded files
