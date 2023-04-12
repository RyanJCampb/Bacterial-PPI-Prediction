#!/bin/bash
#SBATCH --time=1-40:00:00
#SBATCH --gres=gpu:t4:1
#SBATCH --mem=125G
#SBATCH --account=def-jrgreen
#SBATCH --job-name=PIPR-biogrid-human-ecoli-tl
#SBATCH --output=%x-%j.out

nvidia-smi

module load StdEnv/2016.4 gcc/7.3.0
module load cuda/10.0.130 cudnn/7.6
module load python/3.6

source ../PIPR_env/bin/activate

# Base model
mkdir -p pretrained_model
cp -r ../embeddings/ pretrained_model/
cd pretrained_model
for i in {0..4}; do
	CUDA_VISIBLE_DEVICES=0 &
	python3 ../../pipr_rcnn.py \
		--save_model \
		~/scratch/DATA/HUMAN_C2/BIOGRID_DATA/PIPR_DATA/Homo_sapiens_4-4-215_ID_9606_PIPR_sequences.fasta \
		~/scratch/DATA/HUMAN_C2/BIOGRID_DATA/CV_SET/Homo_sapiens_4-4-215_ID_9606/Homo_sapiens_4-4-215_ID_9606_train-"$i".tsv \
		~/scratch/DATA/HUMAN_C2/BIOGRID_DATA/CV_SET/Homo_sapiens_4-4-215_ID_9606/Homo_sapiens_4-4-215_ID_9606_test-"$i".tsv
done
cd ..

# TL
mkdir -p tl_model
cp -r ../embeddings/ tl_model/
cd tl_model
for i in {0..4}; do
	CUDA_VISIBLE_DEVICES=0 &
	python3 ../../pipr_rcnn.py \
		--load_model ../pretrained_model/Models/Homo_sapiens_4-4-215_ID_9606_train-"$i"_PIPR.model \
		--trainable_layers 5 \
		--save_model \
		--transfer_learning \
		~/scratch/DATA/BIOGRID_DATA/PIPR_DATA/Escherichia_coli_K12_MG1655_4-4-215_ID_511145_PIPR_sequences.fasta \
		~/scratch/DATA/BIOGRID_DATA/CV_SET/Escherichia_coli_K12_MG1655_4-4-215_ID_511145_PIPR/Escherichia_coli_K12_MG1655_4-4-215_ID_511145_PIPR_train-"$i".tsv \
		~/scratch/DATA/BIOGRID_DATA/CV_SET/Escherichia_coli_K12_MG1655_4-4-215_ID_511145_PIPR/Escherichia_coli_K12_MG1655_4-4-215_ID_511145_PIPR_test-"$i".tsv
done
cd ..

# Finetuned Model
mkdir -p finetuned_model
cp -r ../embeddings/ finetuned_model/
cd finetuned_model
for i in {0..4}; do
	CUDA_VISIBLE_DEVICES=0 &
	python3 ../../pipr_rcnn.py \
		--load_model ../tl_model/Models/Escherichia_coli_K12_MG1655_4-4-215_ID_511145_PIPR_train-"$i"_PIPR.model \
		--learning_rate 1e-5 \
		--save_model \
		--transfer_learning \
		~/scratch/DATA/BIOGRID_DATA/PIPR_DATA/Escherichia_coli_K12_MG1655_4-4-215_ID_511145_PIPR_sequences.fasta \
		~/scratch/DATA/BIOGRID_DATA/CV_SET/Escherichia_coli_K12_MG1655_4-4-215_ID_511145_PIPR/Escherichia_coli_K12_MG1655_4-4-215_ID_511145_PIPR_train-"$i".tsv \
		~/scratch/DATA/BIOGRID_DATA/CV_SET/Escherichia_coli_K12_MG1655_4-4-215_ID_511145_PIPR/Escherichia_coli_K12_MG1655_4-4-215_ID_511145_PIPR_test-"$i".tsv
done
cd ..
