# backend/app/core/llm_client.py
import requests
import json
import logging
from app.core.config import AppConfig
from app.core.utils import setup_logging
import os

log = setup_logging()


class LLMClient:
    """
    Client class for interacting with the Ollama LLM
    """

    def __init__(self, base_url=AppConfig.OLLAMA_API_BASE_URL):
        self.base_url = base_url

    def list_models(self) -> list:
        """
        Fetches the list of available models from Ollama
        """
        url = f"{self.base_url}/tags"
        try:
            response = requests.get(url)
            response.raise_for_status()  # Raise HTTPError for bad responses (4xx or 5xx)
            data = response.json()
            log.debug(f"Ollama list response: {data}")

            # Check for data and format response appropriately
            if data and "models" in data:
                formatted_models = []
                for model in data["models"]:
                    formatted_models.append(
                        {
                            "model_name": model["name"],
                        }
                    )
                log.debug(f"Formatted models: {formatted_models}")
                return formatted_models
            else:
                log.warning("No models found in Ollama response")
                return []
        except requests.exceptions.RequestException as e:
            log.error(f"Error listing models: {e}")
            return []

    def generate_response(
        self, model_name: str, user_input: str, file_path: str = None
    ) -> str:
        """
        Generates response from the Ollama API given a model and user input.
        Now supports file_path for multi-modal models.
        """
        log.info(
            f"Generating response for user input: {user_input} using model: {model_name} and file: {file_path}"
        )

        url = f"{self.base_url}/chat"
        messages = [{"role": "user", "content": user_input}]

        # Prepare the payload with image data if file_path exists
        payload = {
            "model": model_name,
            "messages": messages,
            "stream": True,
        }

        if file_path:
            with open(file_path, "rb") as file:
                image_data = file.read()
                base64_image = base64.b64encode(image_data).decode("utf-8")
                messages.append(
                    {"role": "user", "content": base64_image, "image": True}
                )
                payload["messages"] = messages

        log.debug(f"Ollama payload: {json.dumps(payload)}")

        try:
            response = requests.post(
                url,
                json=payload,
                headers={"Content-Type": "application/json"},
                stream=True,
            )
            response.raise_for_status()  # Raise HTTPError for bad responses (4xx or 5xx)

            full_response = ""
            for line in response.iter_lines():
                if line:
                    try:
                        json_response = json.loads(line)
                        if "message" in json_response:
                            content = json_response["message"].get("content", "")
                            full_response += content
                    except json.JSONDecodeError as e:
                        log.error(f"Error parsing JSON: {e}")
                        continue

            log.info(f"LLM result: {full_response.strip()}")
            return full_response.strip()
        except requests.exceptions.RequestException as e:
            error_msg = f"Error generating response: {str(e)}"
            log.error(error_msg)
            return error_msg
