# Building an Alphafold Singularity container

The `Alphafold.def` (a close copy/rename of `Singularity.def`) definition file and the `run_singularity_container.sh`
launch script are liscensed under Apache 2.0
based on the work of the original Alphafold authors and [David Chin at Drexel University](https://github.com/prehensilecode/alphafold_singularity.git).

## Changes in `Singularity.def` -> `Alphafold.def`

This container is for the original Alphafold application.
Here, I have only added `-DHAVE_AVX2=1` to the HHSUITE `cmake`
command so that the resulting binaries are compatible with
Intel and AMD CPUS according to this
[post](https://github.com/soedinglab/hh-suite/issues/282).
I do not know if there are performance implications due 
to this change. `build_singularity_container.sh` automates the steps
for including the Alphafold source code and building
the container.

## ColabFold.def and ColabFold-notebook.def

At first, copied `Alphafold.def` to `ColabFold.def`
and adjusted to match the dependencies in the
[ColabFold Alphafold2 notebook](https://github.com/sokrypton/ColabFold/blob/main/AlphaFold2.ipynb).  This is a separate container to make clear the differences between Alphafold and Colabfold. This
Singularity definition file is a work in progress any may
not work.

However, it is increasingly important to include Jupyter notebooks
in the container so users can interactively test the compute
environment, so a runtime-only container is not sufficient.
I branched from the `ColabFold.def` image definition to start
from a different base image since it appears that many of the
dependencies in the new base image are already satisfied. I
also solved some issues that were preventing `ColabFold.def`
images from completing build.

## Changes to `run_singularity.py`

Here, the path of the Alphafold container used by this
launch script was changed. The commands that automate the
setting of `output_dir` were removed to allow the user
explicit access to this option because it is useful when
using precomputed MSAS. The default output directory is
still sent to `/tmp` on the worker node.

Another change was to add the MAX_CPUS environment variable
which, based on the work of [Diego Alvarez at the University of Magallanes](https://github.com/dialvarezs/alphafold.git) one path for setting the number of CPUs used by
`hhsearch`, `hhblits`, and `jackhmmer` (all in
`/app/alphafold/alphafold/data/tools` in the container). Passing
this environment variable to those tools is not yet implemented
and will require rebuilding the container or an overlay.

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
  --output_dir=/gs/gsfs0/users/gstefan/work/alphafold/output
  --max_template_date=2022-07-22
  --use_precomputed_msas=True
```

Notes

1. In order to run this Python container launch script,
you will need to install the packages in `requirements.txt`
in your Python environment. More detailed instructions for this
are in the top-level `README.md` since these packages are also
required for the workflow.

2. The optional `--output_dir` flag for `run_singularity_container.py`
**must list a directory that already exists**.  If this flag
is not included, the output files are written to the default
location, `/tmp`, which is only on the worker node and not avaiable
on other computers.

3. The optional `--use_precomputed_msas=True` flag allows
Alphafold to skip directly to the GPU intensive step of
predicting the folding with the machine learning model.
Alphafold will look for **existing** files in `--output_dir`.
For example, if running with `all0174_0.fasta`, as in the
example above, Alphafold will look in
`/gs/gsfs0/users/gstefan/work/alphafold/output/all0174_0/msas`
for the following three files: `uniref90_hits.sto`,
`mgnify_hits.sto`, and `bfd_uniclust_hits.a3m` and also
possibly `pdb_hits.hhr`.

4. The protein basename (`all0174_0`) is used to keep protein
output files separate from each other within the main `output_dir`.
The directory with this protein basename is created if
`--use_precomputed_msas=False` as is the `msas` subdirectory and
its contents.  Otherwise, Alphafold will get the MSAS from the
existing output directory.

## Future plans

In the future, I would like to:

1. Update the base image from ubuntu
18 to 20 (or 22 when available) and CUDA runtime from 11.1 to 11.2
as in the work of [Diego Alvarez at the University of Magallanes](https://github.com/dialvarezs/alphafold.git).
2. Merge in the specification of how many CPU can be used with
the MSAS tools (hhblits, hhsearch, and jackhmmer).

3. Test scaling of Alphafold: Alphafold can run multiple protiens
at the same time on the same node. This gives users who want to run large 
batches of proteins some options in terms of how they want to run
Alphafold - many separate instances of Alphafold (i.e. with only
one entry in `--fasta_paths`) or Alphafold instances that are running
several proteins at the same time (i.e. multiple entries in
`--fasta_paths`). I don't know which will be more efficient.  It could
go either way, for example, running fully separate instances is probably
more GPU efficient and the kernel buffer cache could help reduce
bandwidth and I/O bottlenecks if there are multiple instances all
accessing the same database. Also, it may be easier to keep track of
runs if all protiens are in isolated jobs.  The drawback is that
this approach is likely RAM inefficient (all jobs will allocate the
full amount of RAM). On the other hand, there could be some
RAM and I/O efficiencies internal to the Alphafold code that make
things run faster when multiple proteins are run in the same instance
than the aforementioned potential accelerators for only one protein in
each instance.
