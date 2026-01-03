## 🫵🏻 Test your own model

#### Download Data
```bash
huggingface-cli download UGPhysics/ugphysics \
  --repo-type dataset \
  --local-dir ./data \
  --local-dir-use-symlinks False
```

#### Export Your Key
```bash
export OPENAI_BASE_URL=your_base_url
export OPENAI_API_KEY=your_key
```

#### Inference

For closed-source LLMs, please replace `${MODEL}` and `${SUBJECT}` by the LLM and subject you want to test.
```bash
python codes/infer_close.py --model ${MODEL} --subject ${SUBJECT}
```

For open-source LLMs, we will use `vllm` to accelerate inference.

```bash
python codes/generate_open.py --model ${MODEL} --system ${SYS_PROMPT} --subject ${SUBJECT} --tensor_parallel_size 8
```
where `SYS_PROMPT` is the system prompt, e.g., "Please reason step by step, and put your final answer within \\boxed{}.".



#### Evaluate
Remember to export your keys as mentioned above. 
```bash
python codes/eval.py --model_path ${MODEL} --subject ${SUBJECT} 
```



For open-source LLMs, we will use vllm to accelerate inference.
```bash
CUDA_VISIBLE_DEVICES=0 python codes/generate_open.py     --model "/root/codespace/gaozhitao/PSP/experiments/Qwen2.5_7B_KTO_wo_staggered_0101/models/psp_round_1"     --system 'Please reason step by step, and put your final answer within \boxed{}.'     --subject "all"     --tensor_parallel_size 1
```
Evaluate
```bash
nohup python codes/eval.py   --model_path "/root/codespace/gaozhitao/PSP_Phys_bmk_eval/UGPhysics/results/Qwen2.5_7B_R1_10_1000_1204_wo_warmup_psp_round_2"   --subject "all"   > eval_Qwen2.5_7B_R1_10_1000_1204_wo_warmup_psp_round_2.log 2>&1 &

```