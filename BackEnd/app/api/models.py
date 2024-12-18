# backend/app/api/models.py
from pydantic import BaseModel
import json


class TextQuery(BaseModel):
    """Request model for text queries."""

    user_input: str

    def __str__(self):
        return json.dumps(self.dict())


class TextResponse(BaseModel):
    """Response model for text generation."""

    response: str

    def __str__(self):
        return json.dumps(self.dict())


class ErrorResponse(BaseModel):
    """Error response model."""

    detail: str

    def __str__(self):
        return json.dumps(self.dict())
