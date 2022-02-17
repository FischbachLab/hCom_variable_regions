# How-to ?

## Extracting ribosomal RNA

Download all genomes of interest in a folder called `fasta`. Make a directory called `rrna` - this is where all your outputs from barrnap will be stored. Execute the following command. I'm assuming that all genomes have the same extension `*.fna`.

```{bash}
ls fasta/*fna | parallel -j 2 --joblog SCv1_2.barrnap.joblog "bash run_barrnap.sh {} {/.} rrna" &> SCv1_2.barrnap.log
mkdir no_16S
mv *.16S_atleast_1000_nucl.list no_16S/
```

### BARRNAP output

The above script will use `barrnap` to generate 2 files: 1 `fasta` and 1 `gff v3`. Both files contain information about the ribosomal RNAs in the genome, including the `5S`, `16S` and `23S`.

Run the following command pointing it to the output directory to filter the barrnap output such that all 16S across all outputs are combined into one file and the sequences that are less than 1000 bases are removed.

```{bash}
ls rrna/*fna | parallel -j 4 --joblog SCv1_2.extract16S.joblog --plus "bash extract_16S.sh {/..} {} input"
```

This will produce a file `*.16S_rrna.fna` in `input` directory for each genome in the `rrna` directory.

## Setting up for v_xtractor?

- Create new sub-directories for input and output. `mkdir -p input output`

- Move your 16S fasta file (`prefix.16S_rrna.fna`) into the `input` directory. If there are multiple fasta file you may combine them into one or keep them separate, just make sure all fasta files have the same extension.

- Download v_extractor: `aws s3 sync s3://maf-users/Sunit_Jain/scratch/v_xtractor/V-Xtractor-master V-Xtractor-master`

- Download hmmer-3.0: `aws s3 sync s3://maf-users/Sunit_Jain/scratch/v_xtractor/hmmer-3.0 hmmer-3.0`

- Start a new perl container in interactive mode.

```{bash}
docker container run --rm -it --workdir `pwd` --volume `pwd`:`pwd` perl:latest bash
```

- Install hmmer-3.0.

```{bash}
cd hmmer-3.0
./configure
make install
cd ..
which hmmscan
```

- Install parallel.

```{bash}
wget https://ftpmirror.gnu.org/parallel/parallel-latest.tar.bz2
tar xjvf parallel-latest.tar.bz2
cd parallel-*/
./configure
make install
cd ..
which parallel
rm -rf parallel-latest.tar.bz2
```

## Run V-Xtractor

```{bash}
cd V-Xtractor-master/
```

### For V4 region

```{bash}
ls ../input/*.fna | parallel -j 2 --joblog v4.joblog --plus  "perl vxtractor.pl -a -i long -r V4 -h HMMs/bacteria -o ../output/{/..}.16s_rrna_v4.fna -c ../output/{/..}.16s_rrna_v4.csv {}"
```

### For V3-V4 region

```{bash}
ls ../input/*.fna | parallel -j 2 --joblog v3v4.joblog --plus  "perl vxtractor.pl -a -i long -r .V3-V4. -h HMMs/bacteria -o ../output/{/..}.16s_rrna_v3v4.fna -c ../output/{/..}.16s_rrna_v3v4.csv {}"
```

### Concnatnate all variable regions

```{bash}
cd ..
cat output/*fna > SCv1_2.v3v4.fna
```

Exit out of the docker image.

```{bash}
exit
```

## Cluster the variable regions

### CD-hit

```{bash}
docker container run --rm \
    --volume $PWD:$PWD \
    --workdir $PWD \
    quay.io/biocontainers/cd-hit:4.8.1--h2e03b76_5 \
        cd-hit-est \
            -i SCv1_2.v3v4.fna \
            -o SCv1_2.v3v4-est.c099 \
            -c 0.99 \
            -M 0 \
            -T 0 \
            -d 0 \
            -p 1
```

### Convert the *.clstr file to a table

```{bash}
perl clstr2txt.pl SCv1_2.v3v4-est.c099.clstr > SCv1_2.v3v4-est.c099.clstr.tsv
python summarize_clstr_table.py SCv1_2.v3v4-est.c099.clstr.tsv SCv1_2.v3v4-est.c099.clstr.summary.csv
```

## Clean-up

remove all nonessential files and folders

```{bash}
rm -rf parallel-latest.tar.bz2  V-Xtractor-master/ hmmer-3.0/ parallel-*
tar cvzf fasta.tar.gz fasta/
tar cvzf rrna.tar.gz rrna/
tar cvzf input.tar.gz input/
tar cvzf output.tar.gz output/
rm -rf fasta input output rrna
```

## Backup

```{bash}
cd ..
aws s3 sync SCv1_2 s3://maf-users/Sunit_Jain/Alice/hCom_v3_v4/SCv1_2
```
