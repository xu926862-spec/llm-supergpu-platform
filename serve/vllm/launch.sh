#!/bin/bash
# Quick launch: ./launch.sh [config_env_file]
# Example: ./launch.sh configs/qwen2.5-72b-a800.env

set -e

CONFIG=${1:-configs/qwen2.5-72b-a800.env}
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

if [[ ! -f "$SCRIPT_DIR/$CONFIG" ]]; then
  echo "Config not found: $CONFIG"
  echo "Available configs:"
  ls "$SCRIPT_DIR/configs/"
  exit 1
fi

echo "Loading config: $CONFIG"
set -a && source "$SCRIPT_DIR/$CONFIG" && set +a

cd "$SCRIPT_DIR"
docker compose --env-file "$SCRIPT_DIR/$CONFIG" up -d

echo ""
echo "vLLM server starting..."
echo "  API endpoint: http://localhost:${HOST_PORT:-8000}/v1"
echo "  Model: ${SERVED_NAME:-qwen2.5-72b}"
echo ""
echo "Test with:"
echo "  curl http://localhost:${HOST_PORT:-8000}/v1/models"
