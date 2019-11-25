#!/bin/bash
for dataset in cora_ml citeseer ppi pubmed mit
do
	for dim in 5 10 25 50
	do
		for method in line
		do
			for seed in {0..29}
			do
                for exp in recon_experiment lp_experiment
                do

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

