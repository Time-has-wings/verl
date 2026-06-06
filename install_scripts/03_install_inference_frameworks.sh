#!/bin/bash
# ============================================================
# 推理框架安装 (sglang / vllm)
# PyTorch 作为传递依赖由 sglang/vllm 自动拉取
# 用法: bash 03_install_inference_frameworks.sh
# 环境变量: USE_SGLANG=0 可跳过 sglang 安装
# ============================================================

set -euo pipefail

USE_SGLANG=${USE_SGLANG:-1}

# ---- 日志设置 ----
LOG_DIR="$(cd "$(dirname "$0")" && pwd)/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/$(basename "$0" .sh)_$(date +%Y%m%d_%H%M%S).log"
exec > >(tee -a "$LOG_FILE") 2>&1

# ---- CUDA 环境变量 ----
export CUDA_HOME=/tmp/linguangming/verl-workspace/verl-cuda
export PATH=${CUDA_HOME}/bin:$PATH
export LD_LIBRARY_PATH=${CUDA_HOME}/lib64:$LD_LIBRARY_PATH

echo "============================================"
echo " 推理框架 & PyTorch 安装"
echo "============================================"
echo ""

if [ $USE_SGLANG -eq 1 ]; then
    echo "[1/2] 安装 sglang[all]==0.5.2 ..."
    pip install "sglang[all]==0.5.2" --no-cache-dir --no-build-isolation
    pip install torch-memory-saver --no-cache-dir
    echo "      sglang 安装完成"
else
    echo "[跳过] sglang (USE_SGLANG=0)"
fi

echo "[2/2] 安装 vllm==0.11.0 ..."
pip install --no-cache-dir "vllm==0.11.0"
echo "      vllm 安装完成"

echo ""
echo "PyTorch 版本确认:"
python -c "import torch; print(f'  PyTorch {torch.__version__}')"
echo ""
echo "==== 03_install_inference_frameworks.sh 完成 ===="
