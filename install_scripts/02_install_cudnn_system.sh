#!/bin/bash
# ============================================================
# cuDNN 9.10.2 自定义路径安装脚本 (for CUDA 12, TencentOS 3.2 / CentOS 8)
# 安装目录: /tmp/linguangming/verl-workspace/verl-cuda
# 用法: bash 02_install_cudnn_system.sh
# 前置: 01_install_cuda.sh 必须先执行
# ============================================================

set -euo pipefail

# ---- 日志设置 ----
LOG_DIR="$(cd "$(dirname "$0")" && pwd)/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/$(basename "$0" .sh)_$(date +%Y%m%d_%H%M%S).log"
exec > >(tee -a "$LOG_FILE") 2>&1

CUDNN_VERSION="9.10.2"
CUDNN_FULL_VERSION="9.10.2.21"
CUDA_MAJOR="12"
TARFILE="cudnn-linux-x86_64-${CUDNN_FULL_VERSION}_cuda${CUDA_MAJOR}-archive.tar.xz"
DOWNLOAD_URL="https://developer.download.nvidia.com/compute/cudnn/redist/cudnn/linux-x86_64/${TARFILE}"

# cuDNN 的头文件和库将被复制到这个目录（与 CUDA 安装目录一致）
CUDA_INSTALL_DIR="/apdcephfs_zwfy10_303541817/share_303541817/lgm/verl-workspace/verl-cuda"
CUDNN_EXTRACT_DIR="/tmp/cudnn-extract"

echo "============================================"
echo " cuDNN ${CUDNN_FULL_VERSION} 自定义路径安装"
echo "============================================"
echo " 目标目录:  ${CUDA_INSTALL_DIR}"
echo " 下载地址:  ${DOWNLOAD_URL}"
echo "============================================"
echo ""

# ---- 检查 CUDA 目录是否存在 ----
if [ ! -d "${CUDA_INSTALL_DIR}" ]; then
    echo "[错误] CUDA 安装目录不存在: ${CUDA_INSTALL_DIR}"
    echo "       请先运行 01_install_cuda.sh 安装 CUDA"
    exit 1
fi

# ---- 检查是否已经安装 ----
if [ -f "${CUDA_INSTALL_DIR}/include/cudnn.h" ]; then
    echo "[警告] ${CUDA_INSTALL_DIR}/include/cudnn.h 已存在，可能已经安装过了"
    echo "       如需重新安装，请先手动删除相关文件"
    exit 1
fi

# ---- 第 1 步：下载 tar 包 ----
if [ -f "${TARFILE}" ]; then
    echo "[跳过] ${TARFILE} 已存在，使用本地文件"
else
    echo "[1/4] 下载 cuDNN tar 包..."
    wget -q --show-progress "${DOWNLOAD_URL}" -O "${TARFILE}"
    echo "      下载完成: ${TARFILE}"
fi

# ---- 第 2 步：解压到临时目录 ----
echo "[2/4] 解压到临时目录 ${CUDNN_EXTRACT_DIR}..."
rm -rf "${CUDNN_EXTRACT_DIR}"
mkdir -p "${CUDNN_EXTRACT_DIR}"
tar -xf "${TARFILE}" -C "${CUDNN_EXTRACT_DIR}"

# ---- 第 3 步：复制头文件和库到 CUDA 目录 ----
echo "[3/4] 复制头文件 -> ${CUDA_INSTALL_DIR}/include/"
cp "${CUDNN_EXTRACT_DIR}"/cudnn-linux-*/include/cudnn*.h "${CUDA_INSTALL_DIR}/include/"

echo "      复制库文件 -> ${CUDA_INSTALL_DIR}/lib64/"
cp "${CUDNN_EXTRACT_DIR}"/cudnn-linux-*/lib/libcudnn*.so* "${CUDA_INSTALL_DIR}/lib64/"

# ---- 第 4 步：创建符号链接 ----
echo "[4/4] 创建符号链接..."
CUDNN_LIB_DIR="${CUDA_INSTALL_DIR}/lib64"
for so_file in "${CUDNN_LIB_DIR}"/libcudnn_*.so.*; do
    if [ -f "${so_file}" ]; then
        base=$(basename "${so_file}")
        # 去掉末尾的版本号，如 libcudnn_ops_infer.so.9.10.2 -> libcudnn_ops_infer.so.9
        link_name=$(echo "${base}" | sed 's|\(.*\)\.[0-9]\+\.[0-9]\+\.[0-9]\+$|\1|')
        if [ "${base}" != "${link_name}" ] && [ ! -f "${CUDNN_LIB_DIR}/${link_name}" ]; then
            ln -sf "${base}" "${CUDNN_LIB_DIR}/${link_name}"
            echo "      ${link_name} -> ${base}"
        fi
    fi
done
ldconfig "${CUDNN_LIB_DIR}"

# ---- 清理临时文件 ----
rm -rf "${CUDNN_EXTRACT_DIR}"

echo ""
echo "============================================"
echo " cuDNN 安装完成！"
echo "============================================"
echo " 头文件: ${CUDA_INSTALL_DIR}/include/cudnn*.h"
echo " 库文件: ${CUDA_INSTALL_DIR}/lib64/libcudnn*.so"
echo ""
echo " 验证安装:"
echo "   cat ${CUDA_INSTALL_DIR}/include/cudnn.h | grep CUDNN_MAJOR"
echo "============================================"
