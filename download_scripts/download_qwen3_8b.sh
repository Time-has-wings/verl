#!/usr/bin/env bash
# Download Qwen3-8B model from HuggingFace
set -xeuo pipefail

base_dir="$(cd "$(dirname "$0")/.." && pwd)"
models_dir="${base_dir}/models"
logs_dir="${base_dir}/download_scripts/logs"
mkdir -p "${models_dir}" "${logs_dir}"

log_file="${logs_dir}/download_qwen3_8b_$(date +'%Y%m%d_%H%M%S').log"

export HF_DEBUG=1
unset HF_ENDPOINT

# Use huggingface-cli for model download
# --local-dir places the model at a predictable path so training scripts
# can reference it directly instead of relying on the HF cache.
huggingface-cli download \
    Qwen/Qwen3-8B \
    --local-dir "${models_dir}/Qwen3-8B" \
    --local-dir-use-symlinks False \
    2>&1 | tee "${log_file}"
