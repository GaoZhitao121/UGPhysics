import os
import json
import random
import argparse
from collections import defaultdict

# 学科列表
SUB_LIST = [
    'Electrodynamics',
    'Thermodynamics', 'GeometricalOptics',
    'Relativity', 'ClassicalElectromagnetism',
    'ClassicalMechanics',
    'WaveOptics',
    'QuantumMechanics',
    'TheoreticalMechanics',
    'AtomicPhysics',
    'SemiconductorPhysics',
    'Solid-StatePhysics',
    'StatisticalMechanics'
]

def read_jsonl(path):
    data = []
    if os.path.exists(path):
        with open(path, 'r', encoding='utf-8') as f:
            for line in f:
                if line.strip():
                    data.append(json.loads(line))
    return data

def write_jsonl(data, path):
    with open(path, 'w', encoding='utf-8') as f:
        for item in data:
            f.write(json.dumps(item, ensure_ascii=False) + '\n')

def main(args):
    random.seed(42)  # 固定种子，保证结果可复现

    src_root = args.src_dir
    total_target = args.total_samples

    print(f"⚠️ WARNING: This will OVERWRITE original jsonl files in '{src_root}'")
    print(f"Plan: Sample {total_target} items while maintaining subject distribution.\n")

    # 1. 扫描原始数据
    subject_data_pool = {}
    total_original_count = 0

    print("--- Scanning Source Data ---")
    for sub in SUB_LIST:
        sub_dir = os.path.join(src_root, sub)
        en_path = os.path.join(sub_dir, "en.jsonl")
        zh_path = os.path.join(sub_dir, "zh.jsonl")

        data = read_jsonl(en_path) + read_jsonl(zh_path)
        subject_data_pool[sub] = data
        count = len(data)
        total_original_count += count
        print(f"  {sub}: {count} items")

    print(f"Total Original Items: {total_original_count}\n")

    # 2. 按比例采样并直接写回原目录
    print("--- Sampling & Overwriting ---")
    current_sample_sum = 0

    for sub in SUB_LIST:
        original_count = len(subject_data_pool[sub])

        if total_original_count > 0:
            ratio = original_count / total_original_count
            num_to_sample = int(total_target * ratio)
        else:
            num_to_sample = 0

        if original_count > 0 and num_to_sample == 0:
            num_to_sample = 1

        sampled_data = random.sample(
            subject_data_pool[sub],
            min(num_to_sample, original_count)
        )

        sub_dir = os.path.join(src_root, sub)
        en_path = os.path.join(sub_dir, "en.jsonl")
        zh_path = os.path.join(sub_dir, "zh.jsonl")

        # 直接覆盖原文件
        write_jsonl(sampled_data, en_path)
        write_jsonl([], zh_path)

        print(f"  {sub}: Overwritten with {len(sampled_data)} samples (Ratio: {ratio:.2%})")
        current_sample_sum += len(sampled_data)

    print("\n" + "=" * 30)
    print(f"Done! Actual Total Sampled: {current_sample_sum}")
    print("Original dataset has been overwritten.")
    print("=" * 30)

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument(
        '--src_dir',
        type=str,
        default='data',
        help="原始数据目录（将被直接覆盖）"
    )
    parser.add_argument(
        '--total_samples',
        type=int,
        default=1000,
        help="总共要采样的数量"
    )
    args = parser.parse_args()
    main(args)
