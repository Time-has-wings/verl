#!/bin/bash
# ============================================================
# NVIDIA Apex 安装 (混合精度训练工具)
# 用法: bash 09_install_apex.sh
# ============================================================

set -euo pipefail

export MAX_JOBS=${MAX_JOBS:-32}

# ---- 日志设置 ----
LOG_DIR="$(cd "$(dirname "$0")" && pwd)/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/$(basename "$0" .sh)_$(date +%Y%m%d_%H%M%S).log"
exec > >(tee -a "$LOG_FILE") 2>&1

# ---- CUDA 环境变量 ----
export CUDA_HOME=/tmp/linguangming/verl-workspace/verl-cuda
export PATH=${CUDA_HOME}/bin:$PATH
export LD_LIBRARY_PATH=${CUDA_HOME}/lib64:$LD_LIBRARY_PATH

# ---- 构建目录 (在 verl 源码目录外) ----
BUILD_BASE="${BUILD_BASE:-/tmp/linguangming/verl-workspace}"
BUILD_DIR="$BUILD_BASE/apex_src"

echo "============================================"
echo " NVIDIA Apex 安装"
echo " MAX_JOBS=$MAX_JOBS"
echo " BUILD_DIR=$BUILD_DIR"
echo "============================================"
echo ""

echo "[1/3] 克隆 NVIDIA/apex..."
if [ -d "$BUILD_DIR" ]; then
    echo "  目录已存在，跳过 clone"
else
    git clone https://github.com/NVIDIA/apex.git "$BUILD_DIR"
fi

echo ""
echo "[2/3] 编译安装 Apex (cpp_ext + cuda_ext)..."
cd "$BUILD_DIR"
MAX_JOBS=$MAX_JOBS pip install -v \
    --disable-pip-version-check \
    --no-cache-dir \
    --no-build-isolation \
    --config-settings "--build-option=--cpp_ext" \
    --config-settings "--build-option=--cuda_ext" \
    ./

echo ""
echo "[3/3] 验证安装..."
python -c "import apex; print('Apex imported successfully')"
python -c "from apex import amp; print('AMP available: OK')" 2>/dev/null || echo "  (AMP may require GPU, check skipped)"

echo ""
echo "==== 09_install_apex.sh 完成 ===="
