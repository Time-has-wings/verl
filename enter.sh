#!/usr/bin/env bash
set -e

# REMOTE_HOST="29.162.234.163" # 这个机器目前闲置
REMOTE_HOST="28.59.80.224" # 这个机器目前闲置
REMOTE_DIR="/apdcephfs_zwfy10_303541817/share_303541817/lgm/verl-workspace/verl"
CONDA_SH="/apdcephfs_zwfy10_303541817/share_303541817/lgm/software/miniconda3-clean/etc/profile.d/conda.sh"
CONDA_ENV="lgm-verl"

ssh -t "$REMOTE_HOST" "bash -lc '
RC=\$(mktemp /tmp/lgm_rc.XXXXXX)
cat > \"\$RC\" <<EOF
[ -f ~/.bashrc ] && source ~/.bashrc
source \"$CONDA_SH\"
conda activate \"$CONDA_ENV\"
cd \"$REMOTE_DIR\"
rm -f \"\$RC\"

echo
echo \"[OK] 已进入远程机器: \\\$(hostname)\"
echo \"[OK] 当前目录: \\\$(pwd)\"
echo \"[OK] 当前环境: \\\$CONDA_DEFAULT_ENV\"
echo \"[OK] python: \\\$(which python)\"
echo
EOF

exec bash --rcfile \"\$RC\"
'"
