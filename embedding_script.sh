#!/bin/bash



days=3
hrs=00
mem=20G

e=100

# nc experiments
for dataset in cora_ml citeseer ppi pubmed mit
do
	for dim in 5 10 25 50
	do
		for method in abrw attrpure node2vec tadw
		do
			for seed in {0..29}
			do

				data_dir=../heat/datasets/${dataset}
				edgelist=${data_dir}/edgelist.tsv
				features=${data_dir}/feats.csv
				labels=${data_dir}/labels.csv
				embedding_dir=embeddings/${dataset}/nc_experiment/${dim}/${method}/${seed}/

				modules=$(echo \
				module purge\; \
				module load bluebear\; \
				module load apps/python3/3.5.2\; \
				module load apps/keras/2.0.8-python-3.5.2
				)

				slurm_options=$(echo \
				--job-name=performEmbeddingsNC-${dataset}-${dim}-${seed}-${method}\
				--time=${days}-${hrs}:00:00 \
				--mem=${mem} \
				--output=performEmbeddingsNC-${dataset}-${dim}-${seed}-${method}.out \
				--error=performEmbeddingsNC-${dataset}-${dim}-${seed}-${method}.err
				)

				cmd=$(echo python src/main.py --graph-format edgelist --graph-file ${edgelist} --attribute-file ${features} \
				--save-emb --emb-file ${embedding_dir} --method ${method} --label-file ${labels} --task none --dim ${dim} \
				--TADW-maxiter ${e} --epochs ${e} )

				echo ${cmd}

			done
		done
	done
done

