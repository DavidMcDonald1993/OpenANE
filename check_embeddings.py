import pandas as pd 
import os
import itertools

from pandas.errors import EmptyDataError

def main():

    datasets = ["cora_ml", "citeseer", "ppi", "pubmed", "mit"]
    dims = ["5", "10", "25", "50"]
    methods = ["abrw", "attrpure", "deepwalk", "tadw", "aane", "sagegcn"]
    seeds = [str(x) for x in range(30)]
    exps = ["nc_experiment", "lp_experiment"]

    for dataset, dim, method, seed, exp in itertools.product(
        datasets, dims, methods, seeds, exps
    ):
        embedding_directory = os.path.join(
            "embeddings", dataset, exp, dim, method, seed
        )

        filename = os.path.join(embedding_directory, "embedding.csv.gz")

        try:
            df = pd.read_csv(filename)
        except EmptyDataError:
            print (filename, "is empty removing it")
            os.remove(filename)
        except IOError:
            print (filename, "does not exist")




if __name__ == "__main__":
    main()