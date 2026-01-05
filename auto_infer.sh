#!/bin/bash

# ================= 配置区域 =================
MODELS=(
    "/root/codespace/gaozhitao/PSP/experiments/Qwen2.5_7B_KTO_staggered_wo_a_0104/models/psp_round_1"
    "/root/codespace/gaozhitao/PSP/experiments/Qwen2.5_7B_KTO_staggered_wo_a_0104/models/psp_round_2"
    "/root/codespace/gaozhitao/PSP/experiments/Qwen2.5_7B_KTO_staggered_wo_a_0104/models/psp_round_3"
    "/root/codespace/gaozhitao/PSP/experiments/Qwen2.5_7B_KTO_staggered_wo_a_0104/models/psp_round_4"
    "/root/codespace/gaozhitao/PSP/experiments/Qwen2.5_7B_KTO_staggered_wo_a_0104/models/psp_round_5"
    "/root/codespace/gaozhitao/PSP/experiments/Qwen2.5_7B_KTO_staggered_wo_c_0104/models/psp_round_1"
    "/root/codespace/gaozhitao/PSP/experiments/Qwen2.5_7B_KTO_staggered_wo_c_0104/models/psp_round_2"
    "/root/codespace/gaozhitao/PSP/experiments/Qwen2.5_7B_KTO_staggered_wo_c_0104/models/psp_round_3"
    "/root/codespace/gaozhitao/PSP/experiments/Qwen2.5_7B_KTO_staggered_wo_c_0104/models/psp_round_4"
    "/root/codespace/gaozhitao/PSP/experiments/Qwen2.5_7B_KTO_staggered_wo_c_0104/models/psp_round_5"
    "/root/codespace/gaozhitao/PSP/experiments/Qwen2.5_7B_KTO_staggered_wo_q_0104/models/psp_round_1"
    "/root/codespace/gaozhitao/PSP/experiments/Qwen2.5_7B_KTO_staggered_wo_q_0104/models/psp_round_2"
    "/root/codespace/gaozhitao/PSP/experiments/Qwen2.5_7B_KTO_staggered_wo_q_0104/models/psp_round_3"
    "/root/codespace/gaozhitao/PSP/experiments/Qwen2.5_7B_KTO_staggered_wo_q_0104/models/psp_round_4"
    "/root/codespace/gaozhitao/PSP/experiments/Qwen2.5_7B_KTO_staggered_wo_q_0104/models/psp_round_5"
)

GPU_ID=2
SYSTEM_PROMPT='Please reason step by step, and put your final answer within \boxed{}.'
# ============================================

for MODEL_PATH in "${MODELS[@]}"; do
    # 解析名称用于日志输出
    ROUND_NAME=$(basename "$MODEL_PATH")
    EXP_NAME=$(basename "$(dirname "$(dirname "$MODEL_PATH")")")
    LOG_NAME="infer_${EXP_NAME}_${ROUND_NAME}.log"

    echo "========================================================="
    echo "正在测评模型: $EXP_NAME - $ROUND_NAME"
    echo "使用 GPU: $GPU_ID"
    echo "日志文件: $LOG_NAME"
    echo "开始时间: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "========================================================="

    # 执行推理命令
    # 注意：这里去掉了 nohup 和 &，因为我们需要它在前台运行，结束后再跑下一个
    CUDA_VISIBLE_DEVICES=$GPU_ID python codes/generate_open.py \
        --model "$MODEL_PATH" \
        --system "$SYSTEM_PROMPT" \
        --subject "all" \
        --tensor_parallel_size 1 \
        > "$LOG_NAME" 2>&1

    # 检查上一个命令的退出状态
    if [ $? -eq 0 ]; then
        echo "成功：$EXP_NAME - $ROUND_NAME 测评完成。"
    else
        echo "失败：$EXP_NAME - $ROUND_NAME 在运行过程中出错，请检查日志 $LOG_NAME"
    fi

    # 稍微等待几秒，确保显存彻底释放
    sleep 5
    echo "---------------------------------------------------------"
done

echo "所有模型已全部测评完毕！"

# nohup bash auto_infer.sh > total_inference_progress.log 2>&1 &