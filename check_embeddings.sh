#!/bin/bash
for dataset in cora_ml citeseer ppi pubmed mit
do
	for dim in 5 10 25 50
	do
		for method in abrw attrpure deepwalk tadw aane sagegcn
		do
			for seed in {0..29}
			do
                for exp in nc_experiment lp_experiment
                do

                    data_dir=../heat/datasets/${dataset}
                    edgelist=${data_dir}/edgelist.tsv
                    features=${data_dir}/feats.csv
                    labels=${data_dir}/labels.csv
                    embedding_dir=embeddings/${dataset}/${exp}/${dim}/${method}/${seed}
                    embedding_f=${embedding_dir}/embedding.csv

                    if [ -f ${embedding_f}.gz ]
					then
						continue
					elif [ -f ${embedding_f} ]
					then 
						gzip $embedding_f 
					else
						echo no embedding at ${embedding_f}
				fi
                done
            done
        done
    done
done

