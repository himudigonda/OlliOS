# backend/app/core/llm_client.py
from typing import List, Optional
from langchain_ollama import OllamaLLM
from langchain.schema import AIMessage, HumanMessage, SystemMessage
import logging
from app.core.config import AppConfig
from app.core.utils import setup_logging
import os
import base64
import json
import httpx

log = setup_logging()


class LLMClient:
    """
    Client class for interacting with the Ollama LLM using Langchain
    """

    def __init__(self, base_url=AppConfig.OLLAMA_API_BASE_URL):
        self.base_url = base_url.rstrip(
            "/api"
        )  # Remove trailing `/api` if it's there to avoid duplication
        self.llm = None
        log.debug(f"LLMClient initialized with base_url: {self.base_url}")

    def list_models(self) -> list:
        """
        Fetches the list of available models from Ollama
        """
        log.debug("Starting list_models")
        try:
            if self.llm is None:
                log.debug(
                    "LLM is None, Initializing OllamaLLM with default model (llama3)"
                )
                self.llm = OllamaLLM(
                    base_url=self.base_url,
                    model="llama3",
                    api_path="/api/generate",  # set the endpoint
                )  # Initialise with default model
            else:
                log.debug(f"LLM already initialized, model: {self.llm.model}")
            # Assuming the OllamaLLM class has a method to list models
            models = self.llm.list_models()
            formatted_models = []
            for model in models:
                formatted_models.append({"model_name": model.name})
            log.debug(f"Formatted models: {formatted_models}")
            log.debug(f"list_models returning: {formatted_models}")
            return formatted_models
        except Exception as e:
            log.error(f"Error listing models: {e}")
            log.debug(f"list_models returning empty list due to error")
            return []

    def generate_response(
        self, model_name: str, user_input: str, image_b64: str = None
    ) -> str:
        log.info(
            f"Generating response for user input: {user_input} using model: {model_name} and image_b64: {image_b64}"
        )

        try:
            if self.llm is None or self.llm.model != model_name:
                log.debug(f"Initializing LLM with model: {model_name}")
                self.llm = OllamaLLM(
                    base_url=self.base_url,
                    model=model_name,
                    api_path="/api/generate",  # set the endpoint
                )
            else:
                log.debug(f"LLM already initialized, model: {self.llm.model}")

            llm_with_image_context = self.llm
            if image_b64:
                log.debug("Binding image to LLM context")
                llm_with_image_context = self.llm.bind(images=[image_b64])

            # Ensure the correct endpoint is used
            log.debug("Invoking LLM with user input")
            # Ollama returns a stream of JSON objects. We need to process that stream
            full_response = ""

            with httpx.stream(
                "POST",
                f"{self.base_url}/api/generate",
                json={
                    "prompt": user_input,
                    "model": model_name,
                    "images": [image_b64] if image_b64 else None,
                },
                timeout=300.0,  # Increased timeout here
            ) as response:
                response.raise_for_status()
                for line in response.iter_lines():
                    if line:
                        try:
                            json_line = json.loads(line)
                            if "response" in json_line:
                                full_response += json_line["response"]
                                log.debug(f"Partial response: {json_line['response']}")
                        except json.JSONDecodeError as e:
                            log.error(f"JSONDecodeError: {e}, Line: {line}")
                            continue
            log.info(f"LLM full result: {full_response}")

            log.debug("Attempting to parse response as JSON")
            try:
                json_response = json.loads(f'{{"response": "{full_response}"}}')
                log.debug(f"Parsed JSON response: {json_response}")
                log.debug(f"generate_response returning JSON: {json_response}")
                return json_response
            except json.JSONDecodeError:
                log.error(f"Response content: {full_response}")
                error_msg = "Error generating response: invalid format: expected 'json' or a JSON schema"
                log.error(error_msg)
                log.debug(f"generate_response returning error message: {error_msg}")
                return error_msg
        except Exception as e:
            error_msg = f"Error generating response: {str(e)}"
            log.error(error_msg)
            log.debug(f"generate_response returning error message: {error_msg}")
            return error_msg
