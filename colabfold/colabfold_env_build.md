Activate conda
```bash
source /gs/gsfs0/hpc01/rhel8/apps/conda3/etc/profile.d/conda.sh
```

Create a local Conda environment with OpenMM.
```bash
conda create -p /gs/gsfs0/users/gstefan/work/colabfold/env -c conda-forge openmm cudatoolkit==11.2
```

Alternatively, add OpenMM to existing conda environment:
From http://docs.openmm.org/latest/userguide/application/01_getting_started.html
install OpenMM and the CUDA toolkit.  Drivers are preinstalled on GPU node.
```bash
conda install -c conda-forge openmm cuda-toolkit==11.2
python -m openmm.testInstallation
```

Add additional packages
```bash
conda install -y -q -c conda-forge -c bioconda kalign2=2.04 hhsuite=3.3.0 pdbfixer
```

Install Colabfold requirements in [repository's](https://github.com/sokrypton/ColabFold)
`pyproject.toml` (the file that specifies dependencies so the repo can be pip installed):
```bash
conda install -y -c conda-forge absl-py numpy requests tensorflow-gpu tqdm pandas appdirs dm-haiku importlib-metadata matplotlib py3Dmol
````

Finally, need to install JAX and copy over colabfold code base to run.
The JAX that is installed in above line is 3.23, which is in the (3.8,4.0]
range specified in the colabfold notebook.  So, ignore JAX for now.
Some tests to run:
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
```

When you run, you also need to have `colabfold` and `alphafold`
code bases available in the same directory that you launch the
script.  If not present, the ColabFold code will suggest that
you `pip install colabfold[alphafold]` - but whatever happens
here 1) fails in my Conda env and 2) the resulting Conda env's
tensorflow installation is broken so it cannot use GPUs. It
will also downgrade a bunch of packages and install tensorflow_cpu.

Instead, symlink to the `colabfold` and `alphafold` dirs in
the [ColabFold](https://github.com/sokrypton/ColabFold)
and [Alphafold](https://github.com/deepmind/alphafold) GitHub
repos, respectively.

Finally, to delete a local Conda environment, use the -p option:
```bash
conda env remove -p /gs/gsfs0/users/gstefan/work/colabfold/env
```
(But avoid this if you can - it can take 1 hour + to build the above!)
