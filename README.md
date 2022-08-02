# alphafold-notebook-demo
Demonstration workflow with Alphafold in a Jupyter notebook

WORKING HERE: Testing setup run env
srun -n 1 -c 8 -p gpu --pty --mem=20GB --time=01:00:00 /bin/bash
conda create -y -p /gs/gsfs0/users/gstefan/work/alphafold/run -c conda-forge absl-py==0.13.0
conda create -p /gs/gsfs0/users/gstefan/work/alphafold/env --clone /gs/gsfs0/users/gstefan/work/alphafold/run
source /gs/gsfs0/hpc01/rhel8/apps/conda3/etc/profile.d/conda.sh

# Command to start container, but this fails due to some
# strange subprocess issue that doesn't allow singularity
# see the overlay.  Can cut and paste the built run script,
# however, so only a minor tweak is needed...
./run_singularity.py --cpus 8 --use-gpu --data-dir /public/apps/alphafold/databases --fasta-paths /gs/gsfs0/users/gstefan/work/alphafold/inputs/1UBQ.fasta --db-preset reduced_dbs


# Setup ALphafold and TensorFlow

These instructions are built on the work of David Chin
starting with this [blog post](https://linuxfollies.blogspot.com/2021/09/alphafold-2-on-singularity-slurm.html)
and this [GitHub repository](https://github.com/prehensilecode/alphafold_singularity).

Once we have verified that Singularity can run on
a GPU worker node and [containers can access the GPU card](https://blog.roboflow.com/use-the-gpu-in-docker/), e.g.:
```bash
# These commands are a list of **interactive** commands
# executed in a terminal and they will **not** work if they
# are cut and pasted into a single session and are run
# "all at once".  These commands cause the execution
# to transition through several different compute environments!

# Get on a GPU node
srun -n 1 -p gpu --pty /bin/bash

# Ensure you are in a writeable place
cd ~

# Get access to Singularity on the GPU node
module load singularity

# Test a base image container pull
singularity pull nvidia-cuda.sif docker://nvidia/cuda:11.0-cudnn8-runtime-ubuntu18.04

# Start a shell in the container
singularity shell nvidia-cuda.sif

# Test access to GPU inside the container
nvidia-smi
```

Now we are ready to build the containers we want to use.  If a public
container is already available, you have the option of using it;
building is not always required.  For Alphafold:
```bash
# Get on a worker node - does not need to be a GPU node for build!
# However, building or pulling containers requires quite a bit of
# memory, so ensure you request more memory than the default.
srun -n 1 --pty --mem=20G /bin/bash

# Grab container definition file
git clone https://github.com/prehensilecode/alphafold_singularity

# Change into a working directory and build
# Build only works with --fakeroot or sudo
cd alphafold_singularity
singularity build --fakeroot alphafold.sif Singularity.def

# An alternative is to use a public Alphafold container:
singularity pull catgumag_alphafold_y2022m07d20.sif docker://catgumag/alphafold

```
