# alphafold-notebook-demo

Demonstration workflow with Alphafold in a Jupyter notebook

## Setup

The following components are necessary for setting up this workflow:
1. An Alphafold Singularity container.  Please see instructions in `./container` for how to build an Alphafold container. Currently, it is assumed that this container is available at a **hard coded path** in `./container/run_singularity_container.py` in this line of code:
```bash
singularity_image = Client.load('/public/apps/alphafold/alphafold.sif')
```

2. A Conda (or pip) environment that has the `absl-py` and `spython` packages to launch the container. This workflow also uses `parsl` (but it is not required for using the container itself). For a cluster with Conda in a module, here is an example for how to create a local environment:
```bash
module load conda3
source /gs/gsfs0/hpc01/rhel8/apps/conda3/etc/profile.d/conda.sh
conda create -y -p /gs/gsfs0/users/gstefan/work/alphafold/env -c conda-forge absl-py==0.13.0 spython=0.1.16 parsl
conda activate /gs/gsfs0/users/gstefan/work/alphafold/env
```
where `/gs/gsfs0/users/gstefan/` is your home directory.

3. Pull this workflow code into your PW environment.
**TODO: Add instructions here.**

4. Run the workflow from PW.
**TODO: Add instructions here.**

## Interactive runs

For the purposes of testing Alphafold, it is possible to
start interactive Alphafold runs (i.e. manually launch the
application for an instance).  Instructions for launching
an interactive run are in `./container`.

## Batch runs

When you want to run many proteins with Alphafold, there are
two options:
1. the workflow form (under construction) can be used to launch a batch run or
2. `main.ipynb`, the Jupyter notebook that contains the workflow code.

When users opt for the first option (the workflow form), the form simply
grabs the code out of `main.ipynb` and executes it.  Users can use
`main.ipynb` as a template for more complicated Alphafold workflows
and/or directly modify some of the Alphafold options that are not
available in the workflow form. Jupyter notebooks (`*.ipynb` files)
can be opened, edited, and run on the platform by double clicking on
the file in the file browser pane.
