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
export CUDA_HOME=/home/pkuhetu/lgm/WorkSpace/verl-workspce/verl-cuda
export PATH=${CUDA_HOME}/bin:$PATH
export LD_LIBRARY_PATH=${CUDA_HOME}/lib64:$LD_LIBRARY_PATH

echo "============================================"
echo " 推理框架 & PyTorch 安装"
echo "============================================"
echo ""

export PIP_CONFIG_FILE=/dev/null
export PIP_CACHE_DIR=/tmp/linguangming/pip_cache
mkdir -p "$PIP_CACHE_DIR"
export PIP_PROXY=http://127.0.0.1:17897

mkdir -p "/tmp/linguangming/wheels"

if [ $USE_SGLANG -eq 1 ]; then
    echo "[1/2] 安装 sglang[all]==0.5.2 ..."
    # pip install "sglang[all]==0.5.2" --no-build-isolation --find-links /tmp/linguangming/wheels
    python -m pip install \
        /tmp/linguangming/wheels/sgl_kernel-0.3.9.post2-cp310-abi3-manylinux2014_x86_64.whl \
        /tmp/linguangming/wheels/torch-2.8.0-cp312-cp312-manylinux_2_28_x86_64.whl \
        /tmp/linguangming/wheels/triton-3.4.0-cp312-cp312-manylinux_2_27_x86_64.manylinux_2_28_x86_64.whl \
        /tmp/linguangming/wheels/nvidia_cublas_cu12-12.8.4.1-py3-none-manylinux_2_27_x86_64.whl \
        /tmp/linguangming/wheels/nvidia_cuda_nvrtc_cu12-12.8.93-py3-none-manylinux2010_x86_64.manylinux_2_12_x86_64.whl \
        /tmp/linguangming/wheels/nvidia_cudnn_cu12-9.10.2.21-py3-none-manylinux_2_27_x86_64.whl \
        /tmp/linguangming/wheels/nvidia_cufft_cu12-11.3.3.83-py3-none-manylinux2014_x86_64.manylinux_2_17_x86_64.whl \
        /tmp/linguangming/wheels/nvidia_cusolver_cu12-11.7.3.90-py3-none-manylinux_2_27_x86_64.whl \
        /tmp/linguangming/wheels/nvidia_cusparse_cu12-12.5.8.93-py3-none-manylinux2014_x86_64.manylinux_2_17_x86_64.whl \
        /tmp/linguangming/wheels/nvidia_cusparselt_cu12-0.7.1-py3-none-manylinux2014_x86_64.whl \
        /tmp/linguangming/wheels/nvidia_nccl_cu12-2.27.3-py3-none-manylinux2014_x86_64.manylinux_2_17_x86_64.whl \
        "sglang[all]==0.5.2" \
        --no-build-isolation \
        --find-links /tmp/linguangming/wheels
    pip install torch-memory-saver
    echo "      sglang 安装完成"
else
    echo "[跳过] sglang (USE_SGLANG=0)"
fi

echo "[2/2] 安装 vllm==0.11.0 ..."
pip install "vllm==0.11.0"
echo "      vllm 安装完成"

echo ""
echo "PyTorch 版本确认:"
python -c "import torch; print(f'  PyTorch {torch.__version__}')"
echo ""
echo "==== 03_install_inference_frameworks.sh 完成 ===="
