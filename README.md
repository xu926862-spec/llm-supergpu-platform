# llm-supergpu-platform

Complete GPU serving and training stack for vLLM, Triton/TensorRT, DeepSpeed multi-node, and tuning scripts.

## Architecture

```
┌─────────────────────────────────────────────────────┐
│                  LiteLLM Gateway :4000               │
│   /v1/chat/completions  ←  OpenClaw / any client    │
└───────────┬────────────────────────┬────────────────┘
            │                        │
    ┌───────▼──────┐        ┌────────▼────────┐
    │  vLLM :8000  │        │  Bailian / DS   │
    │ Qwen2.5-72B  │        │  DeepSeek API   │
    │ (A800 80G)   │        │  (fallback)     │
    └──────────────┘        └─────────────────┘
```

## Quick Start

### 1. Start vLLM (on rented GPU / AutoDL)

```bash
cd serve/vllm
./launch.sh configs/qwen2.5-72b-a800.env
```

### 2. Start API Gateway (local machine)

```bash
cd gateway
cp .env.example .env
# Edit .env — fill in API keys and vLLM server IP
docker compose up -d
```

Gateway runs at `http://localhost:4000/v1` — OpenAI-compatible endpoint.

### 3. AutoDL one-liner setup

SSH into the rented instance, then:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/xu926862-spec/llm-supergpu-platform/main/deploy/autodl/setup.sh)
```

### 4. Connect OpenClaw

Set any agent's model provider base URL to `http://localhost:4000/v1` with key `sk-supergpu`.

## Directory Structure

```
serve/
  vllm/               # vLLM Docker Compose + per-model configs
    configs/          # .env files per model (72B, 7B ...)
gateway/
  litellm-config.yaml # Unified proxy: local vLLM + Bailian + DeepSeek + Claude
  docker-compose.yml
train/
  deepspeed/          # ZeRO-3 configs for multi-node training
  finetune/           # LoRA fine-tuning scripts
deploy/
  autodl/             # AutoDL instance bootstrap script
scripts/
  health-check.sh     # Check all services + GPU status
```

## Supported Models

| Model | Provider | VRAM |
|-------|----------|------|
| Qwen2.5-72B-Instruct | Local vLLM | 80G (int8) |
| Qwen2.5-7B-Instruct | Local vLLM | 16G |
| qwen-plus / qwen-max | Bailian 百炼 | — |
| qwen3-235b-a22b | Bailian 百炼 | — |
| deepseek-chat | DeepSeek API | — |
| claude-sonnet | Anthropic | — |

## GPU Rental Cost (AutoDL)

| GPU | VRAM | Price | Use case |
|-----|------|-------|----------|
| A800 80G | 80 GB | ¥5.59/h | Qwen2.5-72B int8 |
| A100 40G | 40 GB | ¥3.x/h | Qwen2.5-7B / 14B |
| 4090 24G | 24 GB | ¥2.x/h | Small models / inference |
