#!/bin/bash

#SBATCH --job-name=embeddingsGCNNC
#SBATCH --output=embeddingsGCN_%A_%a.out
#SBATCH --error=embeddingsGCN_%A_%a.err
#SBATCH --array=0-149
#SBATCH --time=3-00:00:00
#SBATCH --ntasks=1
#SBATCH --mem=20G

e=100

datasets=({cora_ml,citeseer,ppi,pubmed,mit})
# dim = 5
seeds=({0..29})

num_datasets=${#datasets[@]}
num_seeds=${#seeds[@]}

dataset_id=$((SLURM_ARRAY_TASK_ID / num_seeds % num_datasets))
seed_id=$((SLURM_ARRAY_TASK_ID % num_seeds ))

dataset=${datasets[$dataset_id]}
seed=${seeds[$seed_id]}
dim=5
method=sagegcn

echo $dataset $seed

data_dir=../heat/datasets/${dataset}
edgelist=${data_dir}/edgelist.tsv
features=${data_dir}/feats.csv
labels=${data_dir}/labels.csv
embedding_dir=embeddings/${dataset}/nc_experiment/${dim}/${method}/${seed}

if [ ! -f ${embedding_dir}/embedding.csv ]
then


	module purge
	module load bluebear
	module load Python/3.6.3-iomkl-2018a
	pip install --user gensim

	args=$(echo --graph-format edgelist --graph-file ${edgelist} --attribute-file ${features} \
	--save-emb --emb-file ${embedding_dir} --method ${method} --label-file ${labels} --task none --dim ${dim} \
	--TADW-maxiter ${e} --epochs ${e}) 

	python src/main.py $args


fi
