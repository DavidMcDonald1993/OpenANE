import pandas as pd 
import os
import itertools

from pandas.errors import EmptyDataError

def main():

    datasets = [os.path.join("synthetic_scale_free", 
        "{:02d}".format(x)) for x in range(30)]
    dims = ["2", "5", "10", "25", "50"]
    methods = ["line"]
    seeds = ["0"]
    exps = ["recon_experiment", "lp_experiment"]

    for dataset, dim, method, seed, exp in itertools.product(
        datasets, dims, methods, seeds, exps
    ):
        embedding_directory = os.path.join(
            "embeddings", dataset, exp, dim, method, seed
        )

        filename = os.path.join(embedding_directory, "embedding.csv.gz")

        try:
            pd.read_csv(filename)
        except EmptyDataError:
            print (filename, "is empty removing it")
            os.remove(filename)
        except IOError:
            print (filename, "does not exist")




if __name__ == "__main__":
    main()