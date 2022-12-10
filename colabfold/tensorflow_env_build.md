# Notes on installing and benchmarking TensorFlow

This file describes an example of a Conda environment
build that was used to successfully run a simple TF script
in a terminal session on a GPU node.

```bash
# Get an interactive session on GPU node.
srun -n 1 -p gpu --gpus-per-node=1 --mem=60GB --pty /bin/bash

# Start up Conda on GPU node
source /gs/gsfs0/hpc01/rhel8/apps/conda3/etc/profile.d/conda.sh

# Create a local environment (takes a few mins)
# (I was able to use the conda-forge version in the past, but
# that does not work right now - probably due to issues with
# recently updated CUDA drivers so I used the slightly older
# version in the Anaconda channel.)
conda create -p /gs/gsfs0/users/gstefan/pw/tf -c anaconda cudatoolkit cudnn tensorflow-gpu

# Activate environment
conda activate /gs/gsfs0/users/gstefan/pw/tf

# Test tensorflow
# Note that you need to have test_tensorflow.py, from this
# repository, in the same directory as executing this
# command.
python -m test_tensorflow.py

# Head-to-head CPU (10 min) vs GPU (2 min)
python -m test_tensorflow_short.py
```

This same Conda environment can be made compatible with Jupyter notebooks
(e.g. running `test_tensorflow.ipynb` which is a duplicate of `test_tensorflow.py`
only in notebook format) with adding the following packages so this
environment can be selectied from the `Kernel` drop down menu:

```bash
conda activate /gs/gsfs0/users/gstefan/pw/tf
conda install -y requests ipykernel
conda install -y -c anaconda jinja2
```

Finally, as a way to document this environment, this repository
also contains the output of `conda list -e > requirements.txt`
so one can rebuild this environment with `conda create --name <env> --file requirements.txt`.
