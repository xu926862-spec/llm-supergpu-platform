#!/bin/bash
# AutoDL instance setup script
# Run this on a freshly rented A800 80G instance
# Usage: bash setup.sh [model_config]

set -e

MODEL_CONFIG=${1:-qwen2.5-72b-a800}
REPO_DIR="/root/llm-supergpu-platform"
HF_CACHE="/root/autodl-tmp/.cache/huggingface"
MODEL_CACHE="/root/autodl-tmp/models"

echo "=== SuperGPU Platform Setup ==="
echo "Instance: $(hostname)"
echo "GPU: $(nvidia-smi --query-gpu=name --format=csv,noheader | head -1)"
echo "VRAM: $(nvidia-smi --query-gpu=memory.total --format=csv,noheader | head -1)"
echo ""

# Install Docker if not present
if ! command -v docker &>/dev/null; then
  echo "[1/4] Installing Docker..."
  curl -fsSL https://get.docker.com | sh
  systemctl start docker
else
  echo "[1/4] Docker already installed"
fi

# Install Docker Compose plugin
if ! docker compose version &>/dev/null 2>&1; then
  echo "[2/4] Installing Docker Compose..."
  apt-get install -y docker-compose-plugin
else
  echo "[2/4] Docker Compose already installed"
fi

# Clone/update the platform repo
if [[ -d "$REPO_DIR" ]]; then
  echo "[3/4] Updating repo..."
  git -C "$REPO_DIR" pull
else
  echo "[3/4] Cloning repo..."
  git clone --depth 1 https://github.com/xu926862-spec/llm-supergpu-platform "$REPO_DIR"
fi

mkdir -p "$HF_CACHE" "$MODEL_CACHE"

echo "[4/4] Starting vLLM server..."
cd "$REPO_DIR/serve/vllm"
chmod +x launch.sh

MODEL_PATH="$MODEL_CACHE" HF_CACHE="$HF_CACHE" \
  ./launch.sh "configs/${MODEL_CONFIG}.env"

echo ""
echo "=== Setup complete ==="
echo "vLLM API: http://$(curl -s ifconfig.me 2>/dev/null || echo 'YOUR_IP'):8000/v1"
echo "Gateway:  point VLLM_API_BASE to the above URL"
