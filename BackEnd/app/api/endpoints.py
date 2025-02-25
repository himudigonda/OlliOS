# backend/app/api/endpoints.py
from fastapi import APIRouter, HTTPException, Query, UploadFile, File, Form, Request
from app.api.models import TextQuery, TextResponse, ErrorResponse
from app.services.model_service import ModelService
from typing import List, Dict, Optional
from app.core.utils import setup_logging, create_temp_dir
import os
import shutil
import base64
from PIL import Image
from io import BytesIO
import csv


log = setup_logging()

router = APIRouter()
model_service = ModelService()


@router.get("/list_models", response_model=List[Dict])
async def list_models():
    """
    Fetches available models and returns a formatted JSON list.
    """
    try:
        models = model_service.get_models()
        return [{"model_name": model["name"]} for model in models if "name" in model]
    except Exception as e:
        log.error(f"Error fetching models: {e}")
        raise HTTPException(status_code=500, detail="Failed to fetch model list.")


@router.post(
    "/generate_text",
    response_model=TextResponse,
    responses={400: {"model": ErrorResponse}},
)
async def generate_text(
    request: Request,
    model_name: str = Form(...),
    user_input: str = Form(""),
    chat_id: str = Form(...),
    file: Optional[UploadFile] = File(None),
):
    """
    Endpoint to handle text generation queries, with optional image or document.
    """
    log.info(
        f"Received POST request with query: {user_input} and model: {model_name} and file: {file} and chat_id: {chat_id}"
    )
    temp_dir = None  # Initialize temp_dir to None
    try:
        log.debug(f"Request object: {request.__dict__}")  # Log the request details
        file_path = None
        if file:
            temp_dir = create_temp_dir()
            file_path = os.path.join(temp_dir, file.filename)
            with open(file_path, "wb") as f:
                f.write(await file.read())
                log.info(f"File {file.filename} saved to {file_path}")

        # Convert image to base64 if file_path exists
        image_b64 = None
        if file_path:
            pil_image = Image.open(file_path)
            buffered = BytesIO()
            pil_image.save(buffered, format="JPEG")
            image_b64 = base64.b64encode(buffered.getvalue()).decode("utf-8")

        # Call the Ollama integration to get the response
        response = model_service.llm_client.generate_response(
            model_name, user_input, image_b64
        )
        log.info(f"Generated response: {response}")
        return {"response": response, "chat_id": chat_id}
    except Exception as e:
        log.error(f"Error processing request: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        if temp_dir:
            shutil.rmtree(temp_dir)  # Clean up temp dir
            log.info(f"Cleaned up temp directory {temp_dir}")
