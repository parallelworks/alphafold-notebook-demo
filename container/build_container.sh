#!/bin/bash
#===============================
# This script clones some git
# repositories and builds an
# Alphafold Singularity container.
# All work is done locally, no
# commits are made.
#
# These steps are based on the
# instructions provided in:
# https://github.com/prehensilecode/alphafold_singularity/blob/main/README.md
#==============================

# Clone the Alphafold repository
#git clone https://github.com/deepmind/alphafold.git alphafold-2.x.x

# Instead of cloning the Alphafold repository
# (which is not necessarily a release, it is
# only a snapshot of the code), get an
# official release
wget https://github.com/deepmind/alphafold/archive/refs/tags/v2.2.2.tar.gz
tar -xvzf v2.2.2.tar.gz

# Change into the top level of the Alphafold source tree
cd alphafold-2.2.2

# Copy code that includes the Singularity build
# instructions. Alphafold supports Docker build
# instructions, i.e. a Dockerfile, but here we need
# to use Singularity.def, which is translated
# from the Dockerfile with Singularity-specific
# build instructions.
git clone https://github.com/prehensilecode/alphafold_singularity singularity

# Build
# (Note that before building, you'll need to install
# the requirements.txt
# from prehensilecode/alphafold_singularity in your
# build environment first, e.g.
# module load conda3
# source /gs/gsfs0/.../etc/profile.d/conda.sh
# conda create env -p $HOME/alphafold_run --file requirements.txt
# conda activate $HOME/alphafold_run
# That step is not scripted here since the
# corresponding Conda environment may
# already exist and only needs to be created once.
sudo singularity build alphafold.sif singularity/Singularity.def
