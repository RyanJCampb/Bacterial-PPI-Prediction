#!/bin/bash
#SBATCH --time=1-0:30:00
#SBATCH --gres=gpu:t4:1
#SBATCH --mem=10G
#SBATCH --account=def-jrgreen
#SBATCH --job-name=PIPR-biogrid-ecoli
#SBATCH --output=%x-%j.out

nvidia-smi

module load StdEnv/2016.4 gcc/7.3.0
module load cuda/10.0.130 cudnn/7.6
module load python/3.6

source PIPR_env/bin/activate

set CUDA_VISIBLE_DEVICES=0 & python3 pipr_rcnn.py all_sequences.fasta dataTrain.tsv dataTest.tsv
