# backend/app/api/endpoints.py
from fastapi import APIRouter, HTTPException, Query, UploadFile, File, Form
from app.api.models import TextQuery, TextResponse, ErrorResponse
from app.services.model_service import ModelService
from typing import List, Dict, Optional
from app.core.utils import setup_logging, create_temp_dir
import os
import shutil
import base64

log = setup_logging()

router = APIRouter()
model_service = ModelService()


@router.get("/list_models", response_model=List[Dict])
async def list_models():
    """
    Endpoint to fetch the list of available models.
    """
    try:
        models = model_service.get_models()
        return models
    except Exception as e:
        log.error(f"Error fetching models: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))


@router.post(
    "/generate_text",
    response_model=TextResponse,
    responses={400: {"model": ErrorResponse}},
)
async def generate_text(
    model_name: str = Form(...),
    user_input: str = Form(""),
    file: Optional[UploadFile] = File(None),
):
    """
    Endpoint to handle text generation queries, with optional image or document.
    """
    log.info(
        f"Received POST request with query: {user_input} and model: {model_name} and file: {file}"
    )
    temp_dir = None  # Initialize temp_dir to None
    try:
        file_path = None
        if file:
            temp_dir = create_temp_dir()
            file_path = os.path.join(temp_dir, file.filename)
            with open(file_path, "wb") as f:
                f.write(await file.read())
                log.info(f"File {file.filename} saved to {file_path}")

        # Call the Ollama integration to get the response
        response = model_service.llm_client.generate_response(
            model_name, user_input, file_path
        )
        log.info(f"Generated response: {response}")
        return {"response": response}
    except Exception as e:
        log.error(f"Error processing request: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        if temp_dir:
            shutil.rmtree(temp_dir)  # Clean up temp dir
            log.info(f"Cleaned up temp directory {temp_dir}")
