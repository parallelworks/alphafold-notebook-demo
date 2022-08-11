#!/bin/bash
#=============================
# Set up the working environment
# in the Alphafold container
# by mounting all the databases, etc.
# but not actually running alphafold.
#
# This allows explicitly testing
# the databases, e.g.
# hhsearch -i <input.fasta> -d <database>
#===============================

singularity exec --nv -o /gs/gsfs0/users/gstefan/work/alphafold/alphafold_overlay.img --bind /gs/gsfs0/users/gstefan/work/alphafold/input:/gs/gsfs0/users/gstefan/work/alphafold/mnt/fasta_path_0:ro,/public/apps/alphafold/databases/uniref90:/gs/gsfs0/users/gstefan/work/alphafold/mnt/uniref90_database_path:ro,/public/apps/alphafold/databases/mgnify:/gs/gsfs0/users/gstefan/work/alphafold/mnt/mgnify_database_path:ro,/public/apps/alphafold:/gs/gsfs0/users/gstefan/work/alphafold/mnt/data_dir:ro,/public/apps/alphafold/databases/pdb_mmcif:/gs/gsfs0/users/gstefan/work/alphafold/mnt/template_mmcif_dir:ro,/public/apps/alphafold/databases/pdb_mmcif:/gs/gsfs0/users/gstefan/work/alphafold/mnt/obsolete_pdbs_path:ro,/public/apps/alphafold/databases/pdb70:/gs/gsfs0/users/gstefan/work/alphafold/mnt/pdb70_database_path:ro,/public/apps/alphafold/databases/uniclust30/uniclust30_2018_08:/gs/gsfs0/users/gstefan/work/alphafold/mnt/uniclust30_database_path:ro,/public/apps/alphafold/databases/bfd:/gs/gsfs0/users/gstefan/work/alphafold/mnt/bfd_database_path:ro --env="NVIDIA_VISIBLE_DEVICES=all" --env="TF_FORCE_UNIFIED_MEMORY=1" --env="XLA_PYTHON_CLIENT_MEM_FRACTION=4.0" --env="OPENMM_CPU_THREADS=16" --env="MAX_CPUS=16" /gs/gsfs0/users/gstefan/work/alphafold/alphafold.sif /bin/bash
