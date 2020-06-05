#!/bin/bash

#SBATCH --job-name=LINESYNTHETIC
#SBATCH --output=LINESYNTHETIC_%A_%a.out
#SBATCH --error=LINESYNTHETIC_%A_%a.err
#SBATCH --array=0-239
#SBATCH --time=3-00:00:00
#SBATCH --ntasks=1
#SBATCH --mem=1G

e=1000

datasets=({00..29})
dims=(10 20 50 100)
seeds=(0)
methods=(line)
exps=(recon_experiment lp_experiment)

num_datasets=${#datasets[@]}
num_dims=${#dims[@]}
num_seeds=${#seeds[@]}
num_methods=${#methods[@]}
num_exps=${#exps[@]}

dataset_id=$((SLURM_ARRAY_TASK_ID / (num_exps * num_methods * num_seeds * num_dims) % num_datasets))
dim_id=$((SLURM_ARRAY_TASK_ID / (num_exps * num_methods * num_seeds) % num_dims))
seed_id=$((SLURM_ARRAY_TASK_ID / (num_exps * num_methods) % num_seeds ))
method_id=$((SLURM_ARRAY_TASK_ID / num_exps % num_methods ))
exp_id=$((SLURM_ARRAY_TASK_ID % num_exps ))

dataset=synthetic_scale_free/${datasets[$dataset_id]}
dim=${dims[$dim_id]}
seed=${seeds[$seed_id]}
method=${methods[$method_id]}
exp=${exps[$exp_id]}

if [ $exp == "recon_experiment" ]
then 
	edgelist=../HEADNET/datasets/${dataset}/edgelist.tsv.gz
else
	edgelist=$(printf ../HEADNET/edgelists/${dataset}/seed=%03d/training_edges/edgelist.tsv ${seed})
fi 
echo edgelist is $edgelist
embedding_dir=embeddings/${dataset}/${exp}/${dim}/${method}/${seed}

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
