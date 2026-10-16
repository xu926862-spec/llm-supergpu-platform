#!/bin/bash
# Check all services are up

VLLM_URL=${VLLM_URL:-http://localhost:8000}
GATEWAY_URL=${GATEWAY_URL:-http://localhost:4000}

check() {
  local name=$1
  local url=$2
  if curl -sf "$url/health" >/dev/null 2>&1 || curl -sf "$url/v1/models" >/dev/null 2>&1; then
    echo "  [OK] $name ($url)"
  else
    echo "  [FAIL] $name ($url)"
  fi
}

echo "=== Service Health Check ==="
check "vLLM (72B)" "$VLLM_URL"
check "LiteLLM Gateway" "$GATEWAY_URL"
echo ""

echo "=== GPU Status ==="
nvidia-smi --query-gpu=name,memory.used,memory.total,utilization.gpu \
  --format=csv,noheader,nounits | \
  awk -F, '{printf "  GPU: %s | VRAM: %s/%s MB | Util: %s%%\n", $1,$2,$3,$4}'
