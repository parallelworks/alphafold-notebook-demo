#!/bin/bash
#===============================
# Script to setup Alphafold
# container
#===============================

#SBATCH -p gpu
#SBATCH --mem=20GB
#SBATCH -n 1

# Select working directory
export ALPHAFOLD_WORK="/gs/gsfs0/users/gstefan/work/alphafold"
cd $ALPHAFOLD_WORK

# Pull containers
singularity pull ubuntu.sif docker://library/ubuntu:latest
singularity pull alphafold.sif docker://catgumag/alphafold

# Test GPU access
singularity shell --nv alphafold.sif nvidia-smi

