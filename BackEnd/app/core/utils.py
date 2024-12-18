# backend/app/core/utils.py
import logging
import json
import os
import uuid


def setup_logging(level=logging.DEBUG):
    """
    Initializes the logging
    """
    logging.basicConfig(
        level=level,
        format="%(asctime)s - %(levelname)s - %(message)s",
        datefmt="%Y-%m-%d %H:%M:%S",
    )
    return logging.getLogger()


def load_json_from_file(filepath):
    """
    Loads JSON data from a file.
    Handles the case of missing files, or invalid JSON format.
    """
    try:
        with open(filepath, "r") as f:
            return json.load(f)
    except FileNotFoundError:
        logging.error(f"File not found: {filepath}")
        return None
    except json.JSONDecodeError:
        logging.error(f"Error decoding JSON from: {filepath}")
        return None
    except Exception as e:
        logging.error(f"Error loading JSON from file {filepath}: {e}")
        return None


def create_temp_dir():
    """
    Creates a temporary directory using a UUID
    """
    from app.core.config import AppConfig

    temp_dir = os.path.join(AppConfig.TEMP_UPLOAD_DIR, str(uuid.uuid4()))
    os.makedirs(temp_dir, exist_ok=True)
    return temp_dir
