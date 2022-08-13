#!/bin/bash
#SBATCH --partition=gpu           # Partition name
#SBATCH --job-name=test           # Job name
#SBATCH --nodes=1                 # Number of nodes to be allocated
#SBATCH --ntasks=1                # Number of threads
#SBATCH --gpus=1                  # Number of GPUs
#SBATCH --mem=60gb                # Job memory
#SBATCH --time=12:00:00           # Time limit
#SBATCH --output=/gs/gsfs0/users/gstefan/work/alphafold/tmp/af-%j.out     # Standard output and error | %j -> slurm job number

# print pwd, job and hostname info
pwd
echo "Job" $SLURM_JOB_NAME
echo "ID" $SLURM_JOBID
hostname

# Set up the environment
source /gs/gsfs0/hpc01/rhel8/apps/conda3/etc/profile.d/conda.sh
conda activate /gs/gsfs0/users/gstefan/work/alphafold/env
echo "conda alphafold environment activated"
echo "running AF2 singularity container"

# move to AF working directory
cd /gs/gsfs0/users/gstefan/pw/workflows/alphafold-notebook-demo/container

# run AF
# Note that the following two files already exist:
# /gs/gsfs0/users/gstefan/work/alphafold/input/paired_seq.fasta (cut and paste from email)
# /gs/gsfs0/users/gstefan/work/alphafold/output/paired_seq/msas/test_aa5a8.a3m (email attachment)
python run_singularity_container.py \
     --data_dir=/public/apps/alphafold/databases \
     --fasta_paths=/gs/gsfs0/users/gstefan/work/alphafold/input/paired_seq.fasta \
     --max_template_date=2022-07-22 \
     --output_dir=/gs/gsfs0/users/gstefan/work/alphafold/output \
     --use_precomputed_msas=True

echo "finito"

#  --use_gpu=True \
#  --run_relax=True \
