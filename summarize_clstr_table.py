#!/usr/bin/env python3
## How many clusters have more than one organisms as it's members
import sys
import pandas as pd
import logging


def main():
    clstr_table = sys.argv[1]
    output = sys.argv[2]

    clstr_df = pd.read_table(clstr_table, header=0)
    clstr_df["organism"] = clstr_df["id"].apply(lambda x: x.split(":")[2].split("_")[0])

    summ_df = clstr_df.groupby("clstr").agg(
        num_organisms=("organism", pd.Series.nunique), organism_list=("organism", set)
    )

    close_strains = set()
    for row in summ_df.query("num_organisms > 1").itertuples(index=False):
        close_strains.update(row.organism_list)

    logging.info(
        f"There are {len(close_strains)} strains in the community for which another strain exists with an identical V3-V4 region"
    )

    summ_df["organism_list"] = summ_df["organism_list"].apply(
        lambda x: "; ".join(set(x))
    )
    summ_df = summ_df.sort_values("num_organisms", ascending=False)

    summ_df.to_csv(output)


if __name__ == "__main__":
    logging.basicConfig(
        level=logging.INFO, format="%(asctime)s\t[%(levelname)s]:\t%(message)s",
    )
    main()
