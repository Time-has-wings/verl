#!/bin/bash
# ============================================================
# verl editable 安装 (no-deps)
# 用法: bash 10_install_verl.sh
# ============================================================

set -euo pipefail

# ---- 日志设置 ----
LOG_DIR="$(cd "$(dirname "$0")" && pwd)/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/$(basename "$0" .sh)_$(date +%Y%m%d_%H%M%S).log"
exec > >(tee -a "$LOG_FILE") 2>&1

# ---- CUDA 环境变量 ----
export CUDA_HOME=/home/pkuhetu/lgm/WorkSpace/verl-workspce/verl-cuda
export PATH=${CUDA_HOME}/bin:$PATH
export LD_LIBRARY_PATH=${CUDA_HOME}/lib64:$LD_LIBRARY_PATH

export PIP_CONFIG_FILE=/dev/null
export PIP_CACHE_DIR=/tmp/linguangming/pip_cache
mkdir -p "$PIP_CACHE_DIR"
export PIP_PROXY=http://127.0.0.1:17897

# ---- verl 源码目录 ----
VERL_DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo "============================================"
echo " verl editable 安装"
echo " VERL_DIR=$VERL_DIR"
echo "============================================"
echo ""

echo "[1/1] pip install --no-deps -e verl..."
cd "$VERL_DIR"
# pip install --no-deps -e ./
pip install -e ".[mcore]" --no-build-isolation

echo ""
echo "==== 10_install_verl.sh 完成 ===="
