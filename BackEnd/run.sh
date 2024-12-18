#!/bin/bash

# Run the FastAPI server with uvicorn
uvicorn app.main:app --reload --host 192.168.0.3 --port 8000
