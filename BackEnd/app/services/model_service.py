# backend/app/services/model_service.py
import logging
from app.core.llm_client import LLMClient
from app.core.config import AppConfig
from app.core.utils import setup_logging, load_json_from_file
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
        Fetches the list of available models from Ollama API
        and saves them to the cache.
        """

        log.info("Fetching models from Ollama API")
        models = self.llm_client.list_models()

        if models:
            log.info("Caching fetched models")
            self._save_models_cache(models)
        return models

    def _save_models_cache(self, models: list):
        """
        Saves the formatted list of models to the cache file
        """
        try:
            with open(self.cache_file, "w") as f:
                json.dump(models, f, indent=4)
            log.info(f"Saved models to cache file at {self.cache_file}")
        except Exception as e:
            log.error(f"Error saving models to cache: {e}")
