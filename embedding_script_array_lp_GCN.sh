#!/bin/bash

#SBATCH --job-name=embeddingsGCNLP
#SBATCH --output=embeddingsGCNLP_%A_%a.out
#SBATCH --error=embeddingsGCNLP_%A_%a.err
#SBATCH --array=0-149
#SBATCH --time=3-00:00:00
#SBATCH --ntasks=1
#SBATCH --mem=20G

e=100

datasets=({cora_ml,citeseer,ppi,pubmed,mit})
seeds=({0..29})

num_datasets=${#datasets[@]}
num_seeds=${#seeds[@]}

dataset_id=$((SLURM_ARRAY_TASK_ID / num_seeds % num_datasets))
seed_id=$((SLURM_ARRAY_TASK_ID % num_seeds ))

dataset=${datasets[$dataset_id]}
seed=${seeds[$seed_id]}
dim=50
method=sagegcn

echo $dataset $seed

data_dir=../heat/datasets/${dataset}
training_dir=$(printf "../heat/edgelists/${dataset}/seed=%03d/training_edges" ${seed})
edgelist=${training_dir}/edgelist.tsv
features=${data_dir}/feats.csv
labels=${data_dir}/labels.csv
embedding_dir=embeddings/${dataset}/lp_experiment/${dim}/${method}/${seed}

if [ ! -f ${embedding_dir}/embedding.csv ]
then


	module purge
	module load bluebear
	module load TensorFlow/1.10.1-foss-2018b-Python-3.6.6
	pip install --user gensim

	args=$(echo --graph-format edgelist --graph-file ${edgelist} --attribute-file ${features} \
	--save-emb --emb-file ${embedding_dir} --method ${method} --label-file ${labels} --task none --dim ${dim} \
	--TADW-maxiter ${e} --epochs ${e}) 
	python src/main.py $args


fi
