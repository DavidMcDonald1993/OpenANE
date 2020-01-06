#!/bin/bash

#SBATCH --job-name=GCNembeddings
#SBATCH --output=GCNembeddings_%A_%a.out
#SBATCH --error=GCNembeddings_%A_%a.err
#SBATCH --array=0-1199
#SBATCH --time=10-00:00:00
#SBATCH --ntasks=1
#SBATCH --mem=20G

e=100

datasets=({cora_ml,citeseer,ppi,pubmed,mit})
dims=(5 10 25 50)
seeds=({0..29})
methods=(sagegcn)
exps=(nc_experiment lp_experiment)

num_datasets=${#datasets[@]}
num_dims=${#dims[@]}
num_seeds=${#seeds[@]}
num_methods=${#methods[@]}
num_exps=${#exps[@]}

dataset_id=$((SLURM_ARRAY_TASK_ID / (num_exps * num_methods * num_seeds * num_dims) % num_datasets))
dim_id=$((SLURM_ARRAY_TASK_ID / (num_exps * num_methods * num_seeds) % num_dims))
seed_id=$((SLURM_ARRAY_TASK_ID / (num_exps * num_methods) % num_seeds))
method_id=$((SLURM_ARRAY_TASK_ID / num_exps % num_methods))
exp_id=$((SLURM_ARRAY_TASK_ID % num_exps))

dataset=${datasets[$dataset_id]}
dim=${dims[$dim_id]}
seed=${seeds[$seed_id]}
method=${methods[$method_id]}
exp=${exps[$exp_id]}

echo $dataset $dim $seed $method $exp

data_dir=../heat/datasets/${dataset}
if [ $exp == "nc_experiment" ]
then
	edgelist=${data_dir}/edgelist.tsv
else
	training_dir=$(printf "../heat/edgelists/${dataset}/seed=%03d/training_edges" ${seed})
	edgelist=${training_dir}/edgelist.tsv
fi
features=${data_dir}/feats.csv
labels=${data_dir}/labels.csv
embedding_dir=embeddings/${dataset}/${exp}/${dim}/${method}/${seed}

echo embedding directory is $embedding_dir

if [ ! -f ${embedding_dir}/embedding.csv.gz ]
then


	module purge
	module load bluebear
	module load TensorFlow/1.10.1-foss-2018b-Python-3.6.6
	pip install --user gensim

	args=$(echo --graph-format edgelist --graph-file ${edgelist} \
	--attribute-file ${features} \
	--save-emb --emb-file ${embedding_dir} --method ${method} \
	--label-file ${labels} --task none --dim ${dim} \
	--TADW-maxiter ${e} --epochs ${e}) 

	python src/main.py $args

	gzip ${embedding_dir}/embedding.csv

fi
