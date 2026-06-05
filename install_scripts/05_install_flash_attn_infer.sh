#!/bin/bash
# ============================================================
# FlashAttention & FlashInfer 安装
# 用法: bash 05_install_flash_attn_infer.sh
# 注意: 需要先安装 PyTorch (03_install_inference_frameworks.sh)
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
echo " FlashAttention & FlashInfer 安装"
echo "============================================"
echo ""

echo "[1/2] 安装 flash-attn 2.8.1 (cxx11abi=False)..."
wget -nv https://github.com/Dao-AILab/flash-attention/releases/download/v2.8.1/flash_attn-2.8.1+cu12torch2.8cxx11abiFALSE-cp312-cp312-linux_x86_64.whl
pip install --no-cache-dir flash_attn-2.8.1+cu12torch2.8cxx11abiFALSE-cp312-cp312-linux_x86_64.whl
echo "      flash-attn 安装完成"

echo ""
echo "[2/2] 安装 flashinfer-python==0.3.1 ..."
pip install --no-cache-dir flashinfer-python==0.3.1
echo "      flashinfer 安装完成"

echo ""
echo "验证:"
python -c "import flash_attn; print(f'  flash-attn: OK')" 2>/dev/null || echo "  [警告] flash-attn import 失败"
python -c "import flashinfer; print(f'  flashinfer: OK')" 2>/dev/null || echo "  [警告] flashinfer import 失败"

echo ""
echo "==== 05_install_flash_attn_infer.sh 完成 ===="
