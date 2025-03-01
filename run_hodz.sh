#!/bin/bash
#SBATCH --job-name=hodz  # Job name
#SBATCH --array=0-199         # Job array range for lhid
#SBATCH --nodes=1               # Number of nodes
#SBATCH --ntasks=16            # Number of tasks
#SBATCH --time=1:00:00         # Time limit
#SBATCH --partition=shared        # Partition name
#SBATCH --account=phy240043   # Account name
#SBATCH --output=/anvil/scratch/x-mho1/jobout/%x_%A_%a.out  # Output file for each array task
#SBATCH --error=/anvil/scratch/x-mho1/jobout/%x_%A_%a.out   # Error file for each array task

# SLURM_ARRAY_TASK_ID=150
echo "SLURM_ARRAY_TASK_ID=$SLURM_ARRAY_TASK_ID"
baseoffset=0

module restore cmass
conda activate cmass
lhid=$((SLURM_ARRAY_TASK_ID + baseoffset))

# Command to run for each lhid
cd /home/x-mho1/git/ltu-cmass

# Loop through offsets and process files
for offset in $(seq 0 200 1800); do
    loff=$((lhid + offset))
    python matts_tests/run_hodz.py $loff
done