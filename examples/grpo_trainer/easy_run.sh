#!/usr/bin/env bash
# GRPO | Qwen3-8B | Megatron training | NVIDIA GPUs
#
# INFER_BACKEND controls rollout backend: vllm | sglang | trtllm.

set -xeuo pipefail

# set verl_home
export VERL_HOME="/home/pkuhetu/lgm/WorkSpace/verl-workspce/verl"

# set log
logs_dir="${VERL_HOME}/logs"
mkdir -p "${logs_dir}"
script_name="$(basename "$0" .sh)"
log_file="${logs_dir}/${script_name}_$(date +'%Y%m%d_%H%M%S').log"
exec > >(tee -a "${log_file}") 2>&1

# set CUDA environment variables (adjust if your CUDA is in a different location)
export CUDA_HOME=/home/pkuhetu/lgm/WorkSpace/verl-workspce/verl-cuda
export PATH=${CUDA_HOME}/bin:$PATH
export LD_LIBRARY_PATH=${CUDA_HOME}/lib64:$LD_LIBRARY_PATH

export CUDA_DEVICE_MAX_CONNECTIONS=1

########################### user-adjustable ###########################
INFER_BACKEND=${INFER_BACKEND:-vllm}

export HF_HUB_OFFLINE=1
MODEL_PATH=${MODEL_PATH:-${VERL_HOME}/models/Qwen2.5-0.5B}
NNODES=${NNODES:-1}
NGPUS_PER_NODE=${NGPUS_PER_NODE:-8}

train_batch_size=${TRAIN_BATCH_SIZE:-32} # 每一从训练集取32个prompt
ppo_mini_batch_size=${PPO_MINI_BATCH_SIZE:-16}
max_prompt_length=${MAX_PROMPT_LENGTH:-512}
max_response_length=${MAX_RESPONSE_LENGTH:-1024}
ppo_max_token_len_per_gpu=${PPO_MAX_TOKEN_LEN_PER_GPU:-2048} # 每个micro-batch的token数

actor_lr=${ACTOR_LR:-1e-6}
kl_loss_coef=${KL_LOSS_COEF:-0.001}
entropy_coeff=${ENTROPY_COEFF:-0}

actor_tp=${ACTOR_TP:-2}
actor_pp=${ACTOR_PP:-2}

rollout_tp=${ROLLOUT_TP:-2}
rollout_gpu_mem_util=${ROLLOUT_GPU_MEM_UTIL:-0.6}
rollout_n=${ROLLOUT_N:-4} # 每条prompt生成4个rollout样本

total_epochs=${TOTAL_EPOCHS:-15}
save_freq=${SAVE_FREQ:-20}
test_freq=${TEST_FREQ:-5}

project_name=${PROJECT_NAME:-verl_grpo_gsm8k_math}
experiment_name=${EXPERIMENT_NAME:-qwen3_8b_${INFER_BACKEND}_megatron}
########################### end user-adjustable ###########################

########################### parameter arrays ###########################

DATA=(
    algorithm.adv_estimator=grpo
    algorithm.use_kl_in_reward=False
    data.train_files="['$VERL_HOME/data/gsm8k/train.parquet', '$VERL_HOME/data/math/train.parquet']"
    data.val_files="['$VERL_HOME/data/gsm8k/test.parquet', '$VERL_HOME/data/math/test.parquet']"
    data.train_batch_size=${train_batch_size}
    data.max_prompt_length=${max_prompt_length}
    data.max_response_length=${max_response_length}
    data.filter_overlong_prompts=True
    data.truncation='error'
    data.val_max_samples=100 # eval阶段只评估100条样本以节省时间
)

MODEL=(
    actor_rollout_ref.model.path="$MODEL_PATH"
    actor_rollout_ref.model.use_remove_padding=True
)

ACTOR=(
    actor_rollout_ref.actor.optim.lr=${actor_lr}
    actor_rollout_ref.actor.ppo_mini_batch_size=${ppo_mini_batch_size}
    actor_rollout_ref.actor.use_dynamic_bsz=True
    actor_rollout_ref.actor.ppo_max_token_len_per_gpu=${ppo_max_token_len_per_gpu}
    actor_rollout_ref.actor.use_kl_loss=True
    actor_rollout_ref.actor.kl_loss_coef=${kl_loss_coef}
    actor_rollout_ref.actor.kl_loss_type=low_var_kl
    actor_rollout_ref.actor.entropy_coeff=${entropy_coeff}
    actor_rollout_ref.actor.megatron.tensor_model_parallel_size=${actor_tp}
    actor_rollout_ref.actor.megatron.pipeline_model_parallel_size=${actor_pp}
)

ROLLOUT=(
    actor_rollout_ref.rollout.name=${INFER_BACKEND}
    actor_rollout_ref.rollout.tensor_model_parallel_size=${rollout_tp}
    actor_rollout_ref.rollout.gpu_memory_utilization=${rollout_gpu_mem_util}
    actor_rollout_ref.rollout.n=${rollout_n}
    actor_rollout_ref.rollout.log_prob_use_dynamic_bsz=True
    actor_rollout_ref.rollout.log_prob_max_token_len_per_gpu=${ppo_max_token_len_per_gpu}
)

REF=(
    actor_rollout_ref.ref.log_prob_use_dynamic_bsz=True
    actor_rollout_ref.ref.log_prob_max_token_len_per_gpu=${ppo_max_token_len_per_gpu}
    actor_rollout_ref.ref.megatron.tensor_model_parallel_size=${actor_tp}
    actor_rollout_ref.ref.megatron.pipeline_model_parallel_size=${actor_pp}
)

TRAINER=(
    trainer.balance_batch=True
    # trainer.logger='["console","wandb"]'
    trainer.logger='["console"]'
    trainer.project_name=${project_name}
    trainer.experiment_name=${experiment_name}
    trainer.n_gpus_per_node=${NGPUS_PER_NODE}
    trainer.nnodes=${NNODES}
    trainer.save_freq=${save_freq}
    trainer.test_freq=${test_freq}
    trainer.total_epochs=${total_epochs}
    trainer.total_training_steps=20 # 仅训练20步以验证流程。这会覆盖total_epochs的设置，使其失效.
    trainer.val_before_train=False # 关掉训练前eval
)

EXTRA=(
    model_engine=megatron
)

########################### launch ###########################
python3 -m verl.trainer.main_ppo \
    "${DATA[@]}" \
    "${MODEL[@]}" \
    "${ACTOR[@]}" \
    "${ROLLOUT[@]}" \
    "${REF[@]}" \
    "${TRAINER[@]}" \
    "${EXTRA[@]}" \
    "$@"