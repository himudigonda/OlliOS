#!/bin/bash

# --- Define Base Directories ---
FRONTEND_BASE="./FrontEnd/OlliOS/OlliOS"
BACKEND_BASE="./BackEnd"

# --- Define Frontend Directories to Create ---
declare -a frontend_dirs=(
    "$FRONTEND_BASE/Components"
    "$FRONTEND_BASE/Extensions"
    "$FRONTEND_BASE/Models"
    "$FRONTEND_BASE/Services"
    "$FRONTEND_BASE/Utilities"
    "$FRONTEND_BASE/ViewModels"
    "$FRONTEND_BASE/Views"
)

# --- Define Backend Directories to Create ---
declare -a backend_dirs=(
    "$BACKEND_BASE/app/api"
    "$BACKEND_BASE/app/core"
    "$BACKEND_BASE/app/services"
)

# --- Define Frontend Files to Create ---
declare -a frontend_files=(
    "$FRONTEND_BASE/Components/ChatBubble.swift"
    "$FRONTEND_BASE/Components/MenuRow.swift"
    "$FRONTEND_BASE/Components/SettingsRow.swift"
    "$FRONTEND_BASE/Extensions/UI.swift"
    "$FRONTEND_BASE/Models/AppIcon.swift"
    "$FRONTEND_BASE/Models/ChatMessage.swift"
    "$FRONTEND_BASE/Models/Model.swift"
    "$FRONTEND_BASE/Models/Preference.swift"
    "$FRONTEND_BASE/Models/Response.swift"
    "$FRONTEND_BASE/Services/ApiService.swift"
    "$FRONTEND_BASE/Services/DataService.swift"
    "$FRONTEND_BASE/Services/ModelService.swift"
    "$FRONTEND_BASE/Utilities/Constants.swift"
    "$FRONTEND_BASE/Utilities/Extensions.swift"
    "$FRONTEND_BASE/ViewModels/ChatViewModel.swift"
    "$FRONTEND_BASE/ViewModels/SettingsViewModel.swift"
    "$FRONTEND_BASE/Views/ChatView.swift"
    "$FRONTEND_BASE/Views/SearchBar.swift"
    "$FRONTEND_BASE/Views/SettingsPage.swift"
)

# --- Define Backend Files to Create ---
declare -a backend_files=(
    "$BACKEND_BASE/app/api/endpoints.py"
    "$BACKEND_BASE/app/api/models.py"
    "$BACKEND_BASE/app/core/config.py"
    "$BACKEND_BASE/app/core/llm_client.py"
    "$BACKEND_BASE/app/core/utils.py"
    "$BACKEND_BASE/app/services/model_service.py"
    "$BACKEND_BASE/app/main.py"
    "$BACKEND_BASE/app/startup.py"
)

# --- Function to Create Directories ---
create_dirs() {
  local dirs_array=("$@")
  for dir in "${dirs_array[@]}"; do
    if [ ! -d "$dir" ]; then
      mkdir -p "$dir"
      echo "Created directory: $dir"
    else
      echo "Directory already exists: $dir"
    fi
  done
}

# --- Function to Create Files ---
create_files() {
    local files_array=("$@")
  for file in "${files_array[@]}"; do
    if [ ! -f "$file" ]; then
      touch "$file"
      echo "Created file: $file"
    else
        echo "File already exists: $file"
    fi
  done
}

# --- Create Frontend Directories ---
echo "Creating frontend directories..."
create_dirs "${frontend_dirs[@]}"

# --- Create Backend Directories ---
echo "Creating backend directories..."
create_dirs "${backend_dirs[@]}"

# --- Create Frontend Files ---
echo "Creating frontend files..."
create_files "${frontend_files[@]}"

# --- Create Backend Files ---
echo "Creating backend files..."
create_files "${backend_files[@]}"

echo "Setup complete!"
