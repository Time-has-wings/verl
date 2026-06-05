#!/bin/bash
set -ex

LOG_DIR="$(cd "$(dirname "$0")" && pwd)/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/$(basename "$0" .sh)_$(date +%Y%m%d_%H%M%S).log"
exec > >(tee -a "$LOG_FILE") 2>&1

# ============================================================
# 00_conda_env.sh  创建 conda 环境 + 安装 CUDA / Rust 依赖
# ============================================================
# 前置条件: conda 已安装且可用
# 用法:     bash 00_conda_env.sh
# 说明:     跳过 micromamba 安装，直接使用系统已有 conda
# ============================================================

# 激活 conda（如果 conda 不在 PATH 中，取消注释下一行并改路径）
source /jizhicfs/johnnyslin/anaconda3/etc/profile.d/conda.sh

# ============================================================
# 配置 conda 环境前缀路径（按需修改）
# ============================================================
ENV_PREFIX="/tmp/linguangming/slime-workspace/lgm_verl"

# 1.1 创建 slime 环境（已存在则跳过）
if [ -d "$ENV_PREFIX" ]; then
    echo "环境已存在: $ENV_PREFIX，跳过创建"
else
    conda create -p "$ENV_PREFIX" python=3.12
fi

# 激活环境（后续 pip/conda install 都在这个环境里）
conda activate "$ENV_PREFIX"

echo "==== 00_conda_env.sh 完成 ===="
echo "后续步骤请先执行: conda activate $ENV_PREFIX"
