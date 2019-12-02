#!/bin/bash

#SBATCH --job-name=LINEembeddingsRECONSYNTHETIC
#SBATCH --output=LINEembeddingsRECONSYNTHETIC_%A_%a.out
#SBATCH --error=LINEembeddingsRECONSYNTHETIC_%A_%a.err
#SBATCH --array=0-149
#SBATCH --time=10:00:00
#SBATCH --ntasks=1
#SBATCH --mem=20G

e=1000

datasets=({00..29})
dims=(2 5 10 25 50)
seeds=(0)
methods=(line)

num_datasets=${#datasets[@]}
num_dims=${#dims[@]}
num_seeds=${#seeds[@]}
num_methods=${#methods[@]}

dataset_id=$((SLURM_ARRAY_TASK_ID / (num_methods * num_seeds * num_dims) % num_datasets))
dim_id=$((SLURM_ARRAY_TASK_ID / (num_methods * num_seeds) % num_dims))
seed_id=$((SLURM_ARRAY_TASK_ID / num_methods % num_seeds ))
method_id=$((SLURM_ARRAY_TASK_ID % (num_methods) ))

dataset=synthetic_scale_free/${datasets[$dataset_id]}
dim=${dims[$dim_id]}
seed=${seeds[$seed_id]}
method=${methods[$method_id]}

data_dir=../HEDNet/datasets/${dataset}
edgelist=${data_dir}/edgelist.tsv
embedding_dir=embeddings/${dataset}/recon_experiment/${dim}/${method}/${seed}

if [ ! -f ${embedding_dir}/embedding.csv.gz ]
then

	module purge
	module load bluebear
	module load Python/3.6.3-iomkl-2018a
	pip install --user gensim tensorflow

	args=$(echo --graph-format edgelist --graph-file ${edgelist} \
	--save-emb --emb-file ${embedding_dir} --method ${method} \
	--task none --dim ${dim} \
	--LINE-order 2 --LINE-negative-ratio 10 --epochs ${e}) 

	python src/main.py $args
	gzip ${embedding_dir}/embedding.csv

fi
