#!/bin/bash

# Check if the batch number argument is provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 <batch_number>"
    exit 1
fi

# Get the batch number from the argument
BATCH=$1

# Unzip genomes
python unzip_batch.py \
      -b batches/reference_genomes_${BATCH}.txt \
      -s /projects/mjolnir1/people/jpl786/completer \
      -o /projects/mjolnir1/people/jpl786/completer

# Create DRAM directory structure
git clone https://github.com/alberdilab/dram.git
mv dram dram_${BATCH}
mv ncbi_dataset/data/*/*.fna dram_${BATCH}/input
rm -rf ncbi_dataset

# Rename genomes
python rename_genomes.py \
      -d dram_${BATCH}/input 

# Create a screen session and run commands
screen -dmS dram_${BATCH}

screen -S "dram_${BATCH}" -p 0 -X stuff "cd completer/dram_${BATCH}\n"
screen -S "dram_${BATCH}" -p 0 -X stuff "module purge && module load snakemake/7.20.0 mamba/1.3.1\n"
screen -S "dram_${BATCH}" -p 0 -X stuff "snakemake -j 20 --cluster 'sbatch -o logs/{params.jobname}-slurm-%j.out --mem {resources.mem_gb}G --time {resources.time} -c {threads} --job-name={params.jobname} -v' --use-conda --conda-frontend mamba --conda-prefix conda --latency-wait 600\n"