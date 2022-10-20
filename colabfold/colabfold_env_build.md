# Build ColabFold Conda environment

These instructions step through building a Conda environment
that allows users to run ColabFold.  Building a Conda
environment is possible without sudo whereas `singularity build`
requires sudo - this makes it difficult for users to build
their own singularity containers in a cluster environment.
Furthermore, Singularity is more difficult to install than
Conda and/or may not be present on a cluster.

**Note:** The installation of ColabFold seems to autodetect
what hardware is being used to install it - this means that
you must run this installation on the same node type as you
run ColabFold. Also, the Conda environment created in this
process is paried to the node type that you used to create
the Conda environment.  For the following steps, I called
up an interactive GPU instance with:
```bash
srun -n 1 --pty --mem=160GB --time=4:00:00 -p gpu --gres=gpu:1 /bin/bash
```
and ran the installation and tests on this node. Installation
probably doesn't need this much RAM, but as there are many
Conda packages and a network of dependencies needs to be
resolved, aim for at least 50GB. ColabFold [batch database searches
have a firm requirement for at least 128GB of RAM](https://colabfold.mmseqs.com)).

The `--gres=gpu:1` option is essential because that tells SLURM
to allocate a GPU which in turn sets the CUDA_VISIBLE_DEVICES
environment variable that controls which GPU on the node ColabFold
uses. It is especially important to set the variable when running
multiple ColabFold jobs on the same node. Without `--gres=gpu:1`,
all jobs will try to use the same (first listed) GPU and this slows
down all jobs.

## Step 1: Set up Conda environment

Activate conda
```bash
source /gs/gsfs0/hpc01/rhel8/apps/conda3/etc/profile.d/conda.sh
```

Since `pip install tensorflow-anything` [does not install CUDA or cuDNN](https://stackoverflow.com/questions/52624703/difference-between-installation-libraries-of-tensorflow-gpu-vs-cpu) the GPU can't be used unless we explicitly require CUDA and cuDNN
in the environment.  Also go with ColabFold's suggestion of using Python 3.7. I think ColabFold installs specify
tensorflow-cpu so that it doesn't break if CUDA is not available, but tensorflow-cpu can still use GPU if the hardware,
drivers, and libraries are in place. TensorFlow itself installed this way is broken (does not use GPU with test_tensorflow.py)
but amazingly ColabFold does use the GPUs!
```bash
conda create -p /gs/gsfs0/users/gstefan/work/colabfold/colabfold -c conda-forge cudatoolkit==11.2 cudnn python=3.7
conda activate /gs/gsfs0/users/gstefan/work/colabfold/colabfold
```

Then follow the rest of the `pip` + `conda` instructions for a [local install of ColabFold](https://github.com/sokrypton/ColabFold). They are:
```bash
pip install "colabfold[alphafold] @ git+https://github.com/sokrypton/ColabFold"
pip install -q "jax[cuda]>=0.3.8,<0.4" -f https://storage.googleapis.com/jax-releases/jax_cuda_releases.html
conda install -c conda-forge -c bioconda kalign2=2.04 hhsuite=3.3.0
conda install -c conda-forge openmm=7.5.1 pdbfixer
```

# Step 2: Test installation

As mentioned above, direct usage of TensorFlow in this environment runs but the TensorFlow installation cannot detect the GPUs.  OpenMM can the GPUs, however. The version of OpenMM specified here is old, so to test it you need to use the [older instructions](http://docs.openmm.org/7.5.0/userguide/application.html#installing-openmm):
```bash
python -m simtk.testInstallation
```

To run the ColabFold/Alphafold2.py script based on the original ColabFold/Alphafold2.ipynb,
```bash
python -m AlphaFold2.py
```

ColabFold provides built-in batch functionality with:
```bash
colabfold_batch <directory_with_fasta_files> <result_dir>
```

# Alternative: manual install

If you want to manually build your own Conda environment
instead of depending on pip install used above (which
means that although Colabfold works with GPUs, you cannot
use GPU with TensorFlow in that environment for reasons
that are unknown to me), then use the following steps
instead of the ones above.  Note that there are **still
errors** when using ColabFold with this method (is_training
is somehow not recognized by model.RunModel()), but
TensorFlow works in this environment.

Create a local Conda environment with OpenMM.
```bash
conda create -p /gs/gsfs0/users/gstefan/work/colabfold/env -c conda-forge openmm cudatoolkit==11.2
```

Activate the new environment.
```bash
conda activate /gs/gsfs0/users/gstefan/work/colabfold/env
python -m openmm.testInstallation
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

Alphafold dependencies are listed separately and also need to be installed:
```bash
conda install -c conda-forge biopython chex dm-tree immutabledict ml-collections protobuf
```

## Step 3: ColabFold and Alphafold code bases and test runs

When you run, you also need to have `colabfold` and `alphafold` code
bases available in the same directory that you launch the
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
python -m test_tensorflow.py

# Run ColabFold with default inputs
python -m AlphaFold2.py
```

At this point, ColabFold's AlphaFold2.py script runs in this environment
but it fails for two reasons:
1. get_commit() in colabfold/batch.py cannot detect version or commit information -> easy solution, comment this out.
2. is_training is not recognized by model.RunModel() I think this may be due to fact that in the instructions above
   the packages are not truly installed, only implicitly available in the env due to the presence of their directories
      in the current working dir (`./`).

## Step 4: Clean up

Finally, to delete a local Conda environment, use the -p option:
```bash
conda env remove -p /gs/gsfs0/users/gstefan/work/colabfold/env
```

