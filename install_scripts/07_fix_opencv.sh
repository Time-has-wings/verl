#!/bin/bash
# ============================================================
# OpenCV 修复脚本
# 用法: bash 07_fix_opencv.sh
# 说明: 安装 opencv-python 并用 opencv-fixer 自动修复兼容性问题
# ============================================================

set -euo pipefail

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
echo " OpenCV 修复"
echo "============================================"
echo ""

echo "[1/2] 安装 opencv-python ..."
pip install opencv-python
echo "      opencv-python 安装完成"

echo ""
echo "[2/2] 安装 opencv-fixer 并自动修复..."
pip install opencv-fixer
python -c "from opencv_fixer import AutoFix; AutoFix()"
echo "      opencv 修复完成"

echo ""
echo "==== 07_fix_opencv.sh 完成 ===="
