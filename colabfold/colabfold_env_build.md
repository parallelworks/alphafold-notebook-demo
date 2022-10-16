# Build ColabFold Conda environment

These instructions step through building a Conda environment
that allows users to run ColabFold.  Building a Conda
environment is possible without sudo whereas `singularity build`
requires sudo - this makes it difficult for users to build
their own singularity containers in a cluster environment.
Furthermore, Singularity is more difficult to install than
Conda and/or may not be present on a cluster.

## Step 1: Set up Conda environment

Activate conda
```bash
source /gs/gsfs0/hpc01/rhel8/apps/conda3/etc/profile.d/conda.sh
```

Create a local Conda environment with OpenMM.
```bash
conda create -p /gs/gsfs0/users/gstefan/work/colabfold/env -c conda-forge openmm cudatoolkit==11.2
```

Activate the new environment.
```bash
conda activate /gs/gsfs0/users/gstefan/work/colabfold/env
```

Alternatively, add OpenMM to existing conda environment
by first activating the envinronment and running an install
based on http://docs.openmm.org/latest/userguide/application/01_getting_started.html
Install both OpenMM and the CUDA toolkit.  Drivers are preinstalled on GPU node.
```bash
conda install -c conda-forge openmm cuda-toolkit==11.2
python -m openmm.testInstallation
```

## Step 2: Dependencies

Add additional packages
```bash
conda install -y -q -c conda-forge -c bioconda kalign2=2.04 hhsuite=3.3.0 pdbfixer
```

Install Colabfold requirements in [repository's](https://github.com/sokrypton/ColabFold)
`pyproject.toml` (the file that specifies dependencies so the repo can be pip installed):
```bash
conda install -y -c conda-forge absl-py numpy requests tensorflow-gpu tqdm pandas appdirs dm-haiku importlib-metadata matplotlib py3Dmol
````

The JAX that is installed in above line is 3.23, which is in the (3.8,4.0]
range specified in the colabfold notebook.  So, ignore a separate JAX
install for now (contrary to the ColabFold notebook code).
Some manual tests to run:
```bash
python -m openmm.testInstallation
python
> import tensorflow as tf
> tf.config.list_physical_devices('GPU')
> tf.test.is_built_with_cuda
> tf.config.experimental.list_physical_devices()
```

Dependencies that were not listed:
```bash
conda install -c conda-forge biopython
conda install -c conda-forge dm-tree
```
WORKING HERE: STILL FAILING AT:
```bash
File "/gs/gsfs0/users/gstefan/work/colabfold/tmp/alphafold/model/features.py", line 22, in <module>
    import ml_collections
    ModuleNotFoundError: No module named 'ml_collections'
```
To find the proper package to install, it if often helpful
to `grep <missing_module> <python_file_that_uses_it>`


## Step 3: ColabFold and Alphafold code bases and test runs

When you run, you also need to have `colabfold` and `alphafold`
code bases available in the same directory that you launch the
script.  If not present, the ColabFold code will suggest that
you `pip install colabfold[alphafold]` - but whatever happens
during that process
1. fails to run to completion in my tests with the Conda env above and
2. the resulting Conda env's tensorflow installation is broken so it cannot use GPUs.
This `pip install` will also downgrade a bunch of packages
and install tensorflow_cpu.

Instead, symlink to the `colabfold` and `alphafold` dirs in
the [ColabFold](https://github.com/sokrypton/ColabFold)
and [Alphafold](https://github.com/deepmind/alphafold) GitHub
repos, respectively. Ensure these symlinks are in the location
where you intend to run Alphafold.  E.g.
```bash
siloed_run_dir = /gs/gsfs0/users/gstefan/work/colabfold/tmp

# Make a siloed run dir
mkdir -p $siloed_run_dir

# Change in to that dir
cd $siloed_run_dir

# Make symbolic links to code bases and run scripts
# (you could also copy files/directories)
ln -sv /gs/gsfs0/users/gstefan/pw/workflows/ColabFold/colabfold ./
ln -sv /gs/gsfs0/users/gstefan/pw/workflows/alphafold/alphafold ./
ln -sv /gs/gsfs0/users/gstefan/pw/workflows/alphafold-notebook-demo/colabfold/AlphaFold2.py ./
ln -sv /gs/gsfs0/users/gstefan/pw/workflows/alphafold-notebook-demo/colabfold/test_tensorflow.py ./

# Run a TensorFlow test
python test_tensorflow.py

# Run ColabFold with default inputs
python AlphaFold2.py
```

## Step 4: Clean up

Finally, to delete a local Conda environment, use the -p option:
```bash
conda env remove -p /gs/gsfs0/users/gstefan/work/colabfold/env
```
(But avoid this if you can - it can take 1 hour + to build the above!)
