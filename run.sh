#!/bin/bash

work="/gs/gsfs0/users/gstefan/work/alphafold"

singularity exec --nv \
    --overlay ${work}/alphafold_overlay.img \
    --bind ${work}/input:${work}/alphafold/mnt/fasta_path_0:ro,/public/apps/alphafold/databases/uniref90:/gs/gsfs0/users/gstefan/work/alphafold/mnt/uniref90_database_path:ro,/public/apps/alphafold/databases/mgnify:/gs/gsfs0/users/gstefan/work/alphafold/mnt/mgnify_database_path:ro,/public/apps/alphafold:/gs/gsfs0/users/gstefan/work/alphafold/mnt/data_dir:ro,/public/apps/alphafold/databases/pdb_mmcif:/gs/gsfs0/users/gstefan/work/alphafold/mnt/template_mmcif_dir:ro,/public/apps/alphafold/databases/pdb_mmcif:/gs/gsfs0/users/gstefan/work/alphafold/mnt/obsolete_pdbs_path:ro,/public/apps/alphafold/databases/pdb70:/gs/gsfs0/users/gstefan/work/alphafold/mnt/pdb70_database_path:ro,/public/apps/alphafold/databases/uniclust30/uniclust30_2018_08:/gs/gsfs0/users/gstefan/work/alphafold/mnt/uniclust30_database_path:ro,/public/apps/alphafold/databases/bfd:/gs/gsfs0/users/gstefan/work/alphafold/mnt/bfd_database_path:ro \
    --env="NVIDIA_VISIBLE_DEVICES=all" \
    --env="TF_FORCE_UNIFIED_MEMORY=1" \
    --env="XLA_PYTHON_CLIENT_MEM_FRACTION=4.0" \
    --env="OPENMM_CPU_THREADS=16" \
    --env="MAX_CPUS=16" \
    /gs/gsfs0/users/gstefan/work/alphafold/alphafold.sif \
    /app/alphafold/run_alphafold.py \
    --fasta_paths=/gs/gsfs0/users/gstefan/work/alphafold/mnt/fasta_path_0/all0174_0.fasta \
    --uniref90_database_path=/gs/gsfs0/users/gstefan/work/alphafold/mnt/uniref90_database_path/uniref90.fasta \
    --mgnify_database_path=/gs/gsfs0/users/gstefan/work/alphafold/mnt/mgnify_database_path/mgy_clusters_2018_12.fa \
    --data_dir=/gs/gsfs0/users/gstefan/work/alphafold/mnt/data_dir/databases \
    --template_mmcif_dir=/gs/gsfs0/users/gstefan/work/alphafold/mnt/template_mmcif_dir/mmcif_files \
    --obsolete_pdbs_path=/gs/gsfs0/users/gstefan/work/alphafold/mnt/obsolete_pdbs_path/obsolete.dat \
    --pdb70_database_path=/gs/gsfs0/users/gstefan/work/alphafold/mnt/pdb70_database_path/pdb70 \
    --uniclust30_database_path=/gs/gsfs0/users/gstefan/work/alphafold/mnt/uniclust30_database_path/uniclust30_2018_08 \
    --bfd_database_path=/gs/gsfs0/users/gstefan/work/alphafold/mnt/bfd_database_path/bfd_metaclust_clu_complete_id30_c90_final_seq.sorted_opt \
    --output_dir=/gs/gsfs0/users/gstefan/work/alphafold/mnt/output/results \
    --max_template_date=2022-07-26 \
    --db_preset=full_dbs \
    --model_preset=monomer \
    --benchmark=False \
    --use_precomputed_msas=False \
    --num_multimer_predictions_per_model=5 \
    --run_relax=True \
    --use_gpu_relax=True
