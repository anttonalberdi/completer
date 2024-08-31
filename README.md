# COMPLETER

Software for correcting completeness biases in metagenome-assembled genome functional inference.

## Development

### 1. GTDB reference genome fetching

The GTDB database was searched on the 31st of August 2024 for reference genomes using the following advanced search string:

`("GTDB Taxonomy" CONTAINS "Bacteria" AND "CheckM2 Completeness" > "99" AND "CheckM2 Contamination" < "1" AND "GTDB Representative of Species" IS TRUE)`

- GTDB taxonomy contains Bacteria
- CheckM2 completeness is larger than 99%
- CheckM2 contamination is lower than 1%
- Is a GTDB representative species

The search returned 27942 entries: `development/gtdb-adv-search.tsv`.
The genomes were downloaded using the shell script generated by the GTDB search engine: `development/gtdb-adv-search-genomes.sh`.

### 2. GTDB reference genome annotation

Using the python script `development/split_references.py` 28 batches of 1000 genomes were generated.

```py
python development/split_references.py \
      -i development/reference_genomes.txt \
      -o development/batches
```

Using the shell script `development/annotate_genomes.sh` genomes were annotated in batches using DRAM. The shell script clones the DRAM snakemake repository (https://github.com/alberdilab/dram.git), unzips the genomes, simplifies file names, and runs annotation in a screen session.

```sh
sh annotate_genomes.sh 4
```
