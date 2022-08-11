# Building an Alphafold Singularity container

The `Singularity.def` definition file and the `run_singularity_container.sh`
launch script are liscensed under Apache 2.0
based on the work of the original Alphafold authors and [David Chin at Drexel University](https://github.com/prehensilecode/alphafold_singularity.git).

## Changes in `Singularity.def`

Here, I have only added `-DHAVE_AVX2=1` to the HHSUITE `cmake`
command so that the resulting binaries are compatible with
Intel and AMD CPUS according to this
[post](https://github.com/soedinglab/hh-suite/issues/282).
I do not know if there are performance implications due 
to this change. `build_singularity_container.sh` automates the steps
for including the Alphafold source code and building
the container.

## Changes to `run_singularity.py`

Here, I only changed the path of the Alphafold container
used by this launch script.  I also tried to modify
the default output directory, but this did not work
and output is still sent to `/tmp` on the worker node.

An example interactive session that uses this launcher is
(where `\` is line continuation for readability):
```bash
# Start up interactive session on a worker node
srun -n 1 -c 16 -p gpu --pty --mem=120GB --time=12:00:00 /bin/bash

# Load the conda environment
module load conda3
source /gs/gsfs0/hpc01/rhel8/apps/conda3/etc/profile.d/conda.sh
conda activate /gs/gsfs0/users/gstefan/work/alphafold/env

# Run the container
python run_singularity.py --data_dir=/public/apps/alphafold/databases \
  --fasta_paths=/gs/gsfs0/users/gstefan/work/alphafold/input/all0174_0.fasta \
  --max_template_date=2022-07-22
```

Note that in order to run this Python container launch script,
you will need to install the packages in `requirements.txt`
in your Python environment. More detailed instructions for this
are in the top-level `README.md` since these packages are also
required for the workflow.

## Future plans

In the future, I would like to update the base image from ubuntu
18 to 20 (or 22 when available) and CUDA runtime form 11.1 to 11.2
as in the work of [Diego Alvarez at the University of Magallanes](https://github.com/dialvarezs/alphafold.git).
