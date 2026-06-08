#!/usr/bin/env bash
# Download Qwen2.5-0.5B model from HuggingFace
set -xeuo pipefail

base_dir="$(cd "$(dirname "$0")/.." && pwd)"
models_dir="${base_dir}/models"
logs_dir="${base_dir}/download_scripts/logs"
mkdir -p "${models_dir}" "${logs_dir}"

log_file="${logs_dir}/download_qwen2.5_0.5b_$(date +'%Y%m%d_%H%M%S').log"

export HF_DEBUG=1
unset HF_ENDPOINT
export HTTP_PROXY=http://127.0.0.1:18080
export HTTPS_PROXY=http://127.0.0.1:18080

# Use huggingface-cli for model download
# --local-dir places the model at a predictable path so training scripts
# can reference it directly instead of relying on the HF cache.
hf download \
    Qwen/Qwen2.5-0.5B \
    --local-dir "${models_dir}/Qwen2.5-0.5B" \
    2>&1 | tee "${log_file}"

hf download Qwen/Qwen2.5-0.5B --local-dir "./Qwen2.5-0.5B"