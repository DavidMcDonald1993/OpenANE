#!/bin/bash

#SBATCH --job-name=LINEembeddingsREALWORLD
#SBATCH --output=LINEembeddingsREALWORLD_%A_%a.out
#SBATCH --error=LINEembeddingsREALWORLD_%A_%a.err
#SBATCH --array=0-1499
#SBATCH --time=3-00:00:00
#SBATCH --ntasks=1
#SBATCH --mem=25G

e=1000

datasets=(cora_ml citeseer pubmed wiki_vote email)
dims=(2 5 10 25 50)
seeds=({00..29})
methods=(line)
exps=(lp_experiment recon_experiment)

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

dataset=${datasets[$dataset_id]}
dim=${dims[$dim_id]}
seed=${seeds[$seed_id]}
method=${methods[$method_id]}
exp=${exps[$exp_id]}

if [ $exp == "recon_experiment" ]
then 
	edgelist=../HEDNet/datasets/${dataset}/edgelist.tsv
else
	edgelist=$(printf ../HEDNet/edgelists/${dataset}/seed=%03d/training_edges/edgelist.tsv ${seed})
fi 
echo edgelist is $edgelist
embedding_dir=embeddings/${dataset}/${exp}/${dim}/${method}/${seed}

if [ ! -f ${embedding_dir}/embedding.csv.gz ]
then

	echo ${embedding_dir}/embedding.csv.gz does not exist

	module purge
	module load bluebear

	if [ ! -f ${embedding_dir}/embedding.csv ]
	then


		module load Python/3.6.3-iomkl-2018a
		pip install --user gensim tensorflow

		args=$(echo --graph-format edgelist --graph-file ${edgelist} \
		--save-emb --emb-file ${embedding_dir} --method ${method} \
		--task none --dim ${dim} \
		--LINE-order 2 --LINE-negative-ratio 10 --epochs ${e}) 

		python src/main.py $args

	fi

	echo "embedding complete -- compressing"

	gzip ${embedding_dir}/embedding.csv

fi