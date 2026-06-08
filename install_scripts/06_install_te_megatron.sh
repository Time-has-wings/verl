#!/bin/bash
# ============================================================
# TransformerEngine & Megatron-LM 安装
# 用法: bash 06_install_te_megatron.sh
# 环境变量: USE_MEGATRON=0 可跳过
# 注意: TransformerEngine 编译耗时较长，请耐心等待
# ============================================================

set -euo pipefail

USE_MEGATRON=${USE_MEGATRON:-1}
export MAX_JOBS=32

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

# ---- Git 代理临时设置 ----
SAVED_HTTP_PROXY=$(git config --global --get http.proxy 2>/dev/null || true)
SAVED_HTTPS_PROXY=$(git config --global --get https.proxy 2>/dev/null || true)
echo "保存原始 git 代理: http=$SAVED_HTTP_PROXY, https=$SAVED_HTTPS_PROXY"
git config --global http.proxy http://127.0.0.1:17897
git config --global https.proxy http://127.0.0.1:17897
echo "已设置 git 代理为 127.0.0.1:17897"

# 无论脚本如何退出（正常/异常/提前退出），都恢复原始代理
restore_git_proxy() {
    if [ -n "$SAVED_HTTP_PROXY" ]; then
        git config --global http.proxy "$SAVED_HTTP_PROXY"
    else
        git config --global --unset http.proxy 2>/dev/null || true
    fi
    if [ -n "$SAVED_HTTPS_PROXY" ]; then
        git config --global https.proxy "$SAVED_HTTPS_PROXY"
    else
        git config --global --unset https.proxy 2>/dev/null || true
    fi
    echo "已恢复原始 git 代理"
}
trap restore_git_proxy EXIT

echo "============================================"
echo " TransformerEngine & Megatron-LM 安装"
echo "============================================"
echo ""

if [ $USE_MEGATRON -ne 1 ]; then
    echo "[跳过] USE_MEGATRON=0，不安装 TransformerEngine / Megatron"
    echo "==== 06_install_te_megatron.sh 完成 ===="
    exit 0
fi

echo "注意: TransformerEngine 编译耗时较长，请耐心等待..."
echo ""

pip install cmake ninja

echo "[1/3] 安装 onnxscript==0.3.1 ..."
pip install "onnxscript==0.3.1"

echo ""
echo "[2/3] 安装 TransformerEngine@v2.6 ..."
# 原始写法: 缺少 --no-build-isolation，pip 会在隔离环境中使用 pyproject.toml 声明的 torch 版本编译，
# 导致 .so 链接的 PyTorch ABI 与当前安装的 PyTorch 不一致，出现 undefined symbol 错误。
# NVTE_FRAMEWORK=pytorch pip3 install --no-deps git+https://github.com/NVIDIA/TransformerEngine.git@v2.6
pip uninstall transformer_engine -y
NVTE_FRAMEWORK=pytorch pip3 install --no-deps --no-build-isolation git+https://github.com/NVIDIA/TransformerEngine.git@v2.6
echo "      TransformerEngine 安装完成"

echo ""
echo "[3/3] 安装 Megatron-LM@core_v0.13.1 ..."
pip3 install --no-deps git+https://github.com/NVIDIA/Megatron-LM.git@core_v0.13.1
echo "      Megatron-LM 安装完成"

echo ""
echo "==== 06_install_te_megatron.sh 完成 ===="
