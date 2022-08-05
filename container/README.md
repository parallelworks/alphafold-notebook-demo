# Building an Alphafold Singularity container

The `Singularity.def` definition file and the `run_singularity.sh`
launch script is liscensed under Apache 2.0
based on the work of [David Chin at Drexel University](https://github.com/prehensilecode/alphafold_singularity.git).

## Changes in `Singularity.def`

Here, I have only added `-DHAVE_AVX2=1` to the HHSUITE `cmake`
command so that the resulting binaries are compatible with
Intel and AMD CPUS according to this
[post](https://github.com/soedinglab/hh-suite/issues/282).
I do not know if there are performance implications due 
to this change. `build_container.sh` automates the steps
for including the Alphafold source code and building
the container.

## Changes to `run_singularity.py`

Here, I only changed the path of the Alphafold container
used by this launch script.  I also tried to modify
the default output directory, but this did not work
and output is still sent to `/tmp` on the worker node.
An example invocation of this launcher is (where `\` is
line continuation for readability):
```bash
python run_singularity.py --data_dir=/public/apps/alphafold/databases \
  --fasta_paths=/gs/gsfs0/users/gstefan/work/alphafold/input/all0174_0.fasta \
  --max_template_date=2022-07-22
```

## Future plans

In the future, I would like to update the base image from ubuntu
18 to 20 (or 22 when available) and CUDA runtime form 11.1 to 11.2
as in the work of [Diego Alvarez at the University of Magallanes](https://github.com/dialvarezs/alphafold.git).
