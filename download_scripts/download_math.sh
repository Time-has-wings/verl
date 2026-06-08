base_dir="$(cd "$(dirname "$0")/.." && pwd)"
datasets_dir="${base_dir}/data"
logs_dir="${base_dir}/download_scripts/logs"
mkdir -p "${datasets_dir}" "${logs_dir}"

log_file="${logs_dir}/download_math_$(date +'%Y%m%d_%H%M%S').log"

export HF_DEBUG=1
unset HF_ENDPOINT
export HTTP_PROXY=http://127.0.0.1:18080
export HTTPS_PROXY=http://127.0.0.1:18080

# hf download \
#     --repo-type dataset openai/gsm8k \
#     --local-dir "${datasets_dir}/gsm8k" 2>&1 | tee "${log_file}"

python ${base_dir}/examples/data_preprocess/math_dataset.py  --local_save_dir ${datasets_dir}/math