The Singularity.def definition file is liscensed under Apache 2.0
based on the work of David Chin at Drexel University:
https://github.com/prehensilecode/alphafold_singularity.git

## Changes

Here, I have only added `-DHAVE_AVX2=1` to the HHSUITE `cmake`
command so that the resulting binaries are compatible with
Intel and AMD CPUS.

## Future plans

In the future, I would like to update the base image from ubuntu
18 to 20 (or 22 when available) and CUDA runtime form 11.1 to 11.2
as in the work of Diego Alvarez at the University of Magallanes:
https://github.com/dialvarezs/alphafold.git
