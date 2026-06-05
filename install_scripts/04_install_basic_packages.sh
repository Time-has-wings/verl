#!/bin/bash
# ============================================================
# 基础 Python 包安装 (transformers, accelerate, datasets, ray 等)
# 用法: bash 04_install_basic_packages.sh
# ============================================================

set -euo pipefail

export MAX_JOBS=32

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
echo " 基础 Python 包安装"
echo "============================================"
echo ""

echo "[1/3] 安装核心 ML 依赖..."
pip install "transformers[hf_xet]>=4.51.0" accelerate datasets peft hf-transfer \
    "numpy<2.0.0" "pyarrow>=15.0.0" pandas "tensordict>=0.8.0,<=0.10.0,!=0.9.0" torchdata \
    ray[default] codetiming hydra-core pylatexenc qwen-vl-utils wandb dill pybind11 liger-kernel mathruler \
    pytest py-spy pre-commit ruff tensorboard

echo ""
echo "[2/3] 安装网络 / 系统工具依赖..."
pip install "nvidia-ml-py>=12.560.30" "fastapi[standard]>=0.115.0" "optree>=0.13.0" "pydantic>=2.9" "grpcio>=1.62.1"

echo ""
echo "[3/3] 提示信息:"
echo "  pyext 已停止维护且无法在 Python 3.12 下工作"
echo "  如需用于 prime code rewarding，请用 patched fork 手动安装:"
echo "    pip install git+https://github.com/ShaohonChen/PyExt.git@py311support"

echo ""
echo "==== 04_install_basic_packages.sh 完成 ===="
