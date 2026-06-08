#!/bin/bash
# ============================================================
# CUDA 12.8.1 自定义路径安装脚本 (TencentOS 3.2 / CentOS 8, runfile)
# 安装目录: /tmp/linguangming/verl-workspace/verl-cuda
# 用法: bash install-cuda.sh
# ============================================================

set -euo pipefail

# ---- 安装目录，可通过命令行参数或环境变量指定 ----
CUDA_INSTALL_DIR="/home/pkuhetu/lgm/WorkSpace/verl-workspce/verl-cuda"
CUDA_VERSION="12.8.1"
DRIVER_VERSION="570.124.06"
RUNFILE="cuda_${CUDA_VERSION}_${DRIVER_VERSION}_linux.run"
DOWNLOAD_URL="https://developer.download.nvidia.com/compute/cuda/${CUDA_VERSION}/local_installers/${RUNFILE}"

echo "============================================"
echo " CUDA ${CUDA_VERSION} 自定义路径安装"
echo "============================================"
echo " 安装目录: ${CUDA_INSTALL_DIR}"
echo " 下载地址: ${DOWNLOAD_URL}"
echo "============================================"
echo ""

# ---- 检查是否已经安装 ----
if [ -f "${CUDA_INSTALL_DIR}/bin/nvcc" ]; then
    echo "[警告] ${CUDA_INSTALL_DIR}/bin/nvcc 已存在，可能已经安装过了"
    echo "       如需重新安装，请先删除该目录: rm -rf ${CUDA_INSTALL_DIR}"
    exit 1
fi

# ---- 第 1 步：下载 runfile ----
if [ -f "${RUNFILE}" ]; then
    echo "[跳过] ${RUNFILE} 已存在，使用本地文件"
else
    echo "[1/3] 下载 CUDA runfile 安装器..."
    wget -q --show-progress "${DOWNLOAD_URL}" -O "${RUNFILE}"
    echo "      下载完成: ${RUNFILE}"
fi

# ---- 第 2 步：赋予执行权限 ----
echo "[2/3] 赋予执行权限..."
chmod +x "${RUNFILE}"

# ---- 第 3 步：静默安装到自定义目录 ----
# 参数说明:
#   --toolkit              只安装 CUDA Toolkit，不安装驱动
#   --toolkitpath=<dir>    指定安装目录
#   --no-drm               不安装 DRM 内核模块
#   --silent               静默模式，不弹 GUI 交互界面
#   --override             跳过编译器版本等兼容性检查
echo "[3/3] 开始安装到 ${CUDA_INSTALL_DIR}（跳过驱动）..."

./"${RUNFILE}" \
    --toolkit \
    --toolkitpath="${CUDA_INSTALL_DIR}" \
    --no-drm \
    --silent \
    --override

echo "      安装完成"

export CUDA_HOME=${CUDA_INSTALL_DIR}
export PATH=${CUDA_INSTALL_DIR}/bin:$PATH
export LD_LIBRARY_PATH=${CUDA_INSTALL_DIR}/lib64:$LD_LIBRARY_PATH
which nvcc
nvcc --version