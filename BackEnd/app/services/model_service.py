import logging
from app.core.llm_client import LLMClient
from app.core.config import AppConfig
from app.core.utils import setup_logging, load_json_from_file
import subprocess
import json

log = setup_logging()


class ModelService:
    """
    Service class for handling model-related operations
    """

    def __init__(self, llm_client: LLMClient = LLMClient()):
        self.llm_client = llm_client
        self.cache_file = AppConfig.MODELS_CACHE_FILE

    def get_models(self) -> list:
        """
        Returns the list of available models. Attempts to read from cache,
        if there's an error it will fetch the data again.
        """
        cached_models = load_json_from_file(self.cache_file)
        if cached_models:
            log.info("Loaded models from cache")
            return cached_models

        return self.fetch_and_cache_models()

    def fetch_and_cache_models(self) -> list:
        """
        Fetches the list of models from Ollama and saves them.
        """
        try:
            output = subprocess.check_output(["ollama", "list"], text=True).strip()
            models = []

            for line in output.split("\n")[1:]:  # Skip the header row
                if not line.strip():
                    continue
                parts = line.split()
                if len(parts) >= 2:  # Ensure the required parts exist
                    models.append({"name": parts[0], "id": parts[1]})

            # Write to cache
            with open(self.cache_file, "w") as f:
                json.dump(models, f)
            log.info("Models successfully fetched and cached.")
            return models
        except Exception as e:
            log.error(f"Error fetching models: {e}")
            return []
