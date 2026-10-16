#!/bin/bash
# LoRA fine-tuning with LLaMA-Factory / transformers
# Requires: pip install peft transformers datasets accelerate deepspeed

set -e

BASE_MODEL=${BASE_MODEL:-Qwen/Qwen2.5-7B-Instruct}
DATASET=${DATASET:-./data/train.jsonl}
OUTPUT_DIR=${OUTPUT_DIR:-./output/lora-$(date +%Y%m%d-%H%M)}
LORA_RANK=${LORA_RANK:-64}
LORA_ALPHA=${LORA_ALPHA:-128}
MAX_SEQ_LEN=${MAX_SEQ_LEN:-4096}
EPOCHS=${EPOCHS:-3}
BATCH_SIZE=${BATCH_SIZE:-1}
GRAD_ACCUM=${GRAD_ACCUM:-8}
LR=${LR:-2e-4}
NUM_GPUS=${NUM_GPUS:-1}

echo "=== LoRA Fine-tuning ==="
echo "Base model:  $BASE_MODEL"
echo "Dataset:     $DATASET"
echo "Output:      $OUTPUT_DIR"
echo "LoRA rank:   $LORA_RANK"
echo "GPUs:        $NUM_GPUS"
echo ""

mkdir -p "$OUTPUT_DIR"

torchrun --nproc_per_node="$NUM_GPUS" \
  -m src.train \
  --model_name_or_path "$BASE_MODEL" \
  --data_path "$DATASET" \
  --output_dir "$OUTPUT_DIR" \
  --num_train_epochs "$EPOCHS" \
  --per_device_train_batch_size "$BATCH_SIZE" \
  --gradient_accumulation_steps "$GRAD_ACCUM" \
  --learning_rate "$LR" \
  --max_seq_length "$MAX_SEQ_LEN" \
  --lora_r "$LORA_RANK" \
  --lora_alpha "$LORA_ALPHA" \
  --lora_target_modules q_proj,v_proj,k_proj,o_proj,gate_proj,up_proj,down_proj \
  --bf16 true \
  --deepspeed ../deepspeed/ds_config_zero3.json \
  --save_strategy epoch \
  --logging_steps 10 \
  --report_to none
