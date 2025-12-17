#!/bin/bash

# Define paths
COMFY_BASE="/ComfyUI"
MODELS_BASE="$COMFY_BASE/models"
WORKSPACE_BASE="/workspace"

echo "--- Starting Custom Linker ---"

# Function to link specific model subfolders
link_model_folder() {
  # e.g., "checkpoints", "loras", "vae"
  FOLDER_NAME=$1

  # Path inside the ephemeral container (e.g., /ComfyUI/models/loras)
  CONTAINER_PATH="$MODELS_BASE/$FOLDER_NAME"

  # Path on your persistent disk (e.g., /workspace/loras)
  PERSISTENT_PATH="$WORKSPACE_BASE/$FOLDER_NAME"

  echo "Processing $FOLDER_NAME..."

  # 1. Ensure the container path exists (sanity check)
  if [ ! -d "$CONTAINER_PATH" ]; then
    mkdir -p "$CONTAINER_PATH"
  fi

  # 2. Check if the user already has this folder in /workspace
  if [ -d "$PERSISTENT_PATH" ]; then
    echo "  Found existing $FOLDER_NAME in workspace. Linking..."
    rm -rf "$CONTAINER_PATH"
    ln -s "$PERSISTENT_PATH" "$CONTAINER_PATH"

  # 3. If not in workspace, move the container's default folder there so it becomes persistent
  else
    echo "  No $FOLDER_NAME in workspace. Creating it..."
    mv "$CONTAINER_PATH" "$PERSISTENT_PATH"
    ln -s "$PERSISTENT_PATH" "$CONTAINER_PATH"
  fi
}

# Link the standard model folders
# Add or remove lines here depending on what folders you keep in root
link_model_folder "diffusion_models"
link_model_folder "loras"
link_model_folder "vae"
link_model_folder "text_encoders"

# Also handle Input/Output folders so images persist
# These sit at the root of ComfyUI, not in models/
echo "Processing input/output..."

# Output
if [ -d "/workspace/output" ]; then
  rm -rf /ComfyUI/output && ln -s /workspace/output /ComfyUI/output
else
  mv /ComfyUI/output /workspace/output && ln -s /workspace/output /ComfyUI/output
fi

# Input
if [ -d "/workspace/input" ]; then
  rm -rf /ComfyUI/input && ln -s /workspace/input /ComfyUI/input
else
  mv /ComfyUI/input /workspace/input && ln -s /workspace/input /ComfyUI/input
fi

echo "--- Launching ComfyUI ---"
cd /ComfyUI
python main.py --listen 0.0.0.0 --port 8188
