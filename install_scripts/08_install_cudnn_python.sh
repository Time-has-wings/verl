#!/bin/bash
# ============================================================
# cuDNN Python 包安装 (nvidia-cudnn-cu12)
# 用法: bash 08_install_cudnn_python.sh
# 环境变量: USE_MEGATRON=0 可跳过
# 说明: 避免被其他包覆盖 cuDNN 版本
# ============================================================

set -euo pipefail

USE_MEGATRON=${USE_MEGATRON:-1}

# ---- 日志设置 ----
LOG_DIR="$(cd "$(dirname "$0")" && pwd)/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/$(basename "$0" .sh)_$(date +%Y%m%d_%H%M%S).log"
exec > >(tee -a "$LOG_FILE") 2>&1

# ---- CUDA 环境变量 ----
export CUDA_HOME=/apdcephfs_zwfy10_303541817/share_303541817/lgm/verl-workspace/verl-cuda
export PATH=${CUDA_HOME}/bin:$PATH
export LD_LIBRARY_PATH=${CUDA_HOME}/lib64:$LD_LIBRARY_PATH

echo "============================================"
echo " cuDNN Python 包安装"
echo "============================================"
echo ""

if [ $USE_MEGATRON -ne 1 ]; then
    echo "[跳过] USE_MEGATRON=0，不安装 nvidia-cudnn-cu12"
    echo "==== 08_install_cudnn_python.sh 完成 ===="
    exit 0
fi

echo "[1/1] 安装 nvidia-cudnn-cu12==9.10.2.21 ..."
pip install nvidia-cudnn-cu12==9.10.2.21
echo "      nvidia-cudnn-cu12 安装完成"

echo ""
echo "==== 08_install_cudnn_python.sh 完成 ===="
