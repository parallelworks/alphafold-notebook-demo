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

# Build
sudo singularity build alphafold.sif ../Alphafold.def
