# ColabFold

The code here is designed to take [ColabFold](https://github.com/sokrypton/ColabFold) Colab notebooks and translate them into python code suitable for automated deployment via a workflow. The ColabFold notebook is designed for single runs on Colab; here we want to run many protiens on custom resources.

This document is divided into documentaton on the downloading of the ColabFold databases, converting ColabFold notebooks, building a ColabFold container, and finally running ColabFold.

ColabFold is a community-driven update to Alphafold underpinned by [new/updated databases](https://colabfold.mmseqs.com/)
and the MSA search process is accelerated by [MMseqs2](https://github.com/soedinglab/MMseqs2). Colabfold is distributed under the MIT license. Colab Jupyter notebooks are available by clicking on the notebook links in the main ColabFold repository (e.g. `Alphafold2.ipynb`).

## Downloading ColabFold databases.

To run Colabfold locally, first the databases need to be downloaded, e.g.
```bash
# Make new directory
mkdir -p /public/apps/collabfold/databases
cd /public/apps/collabfold/databases

# Download executable binary mmseqs (used in reformatting data)
# (Note the modification to PATH - setup_databases.sh, below
# will use mmseqs.)
wget https://mmseqs.com/latest/mmseqs-linux-avx2.tar.gz; tar xvfz mmseqs-linux-avx2.tar.gz; export PATH=$(pwd)/mmseqs/bin/:$PATH

# Download script that automates download process and unpacking/reformatting for
# the databases.  There are less DB that need to be downloaded than are listed on
# the Collabfold website due to some DB being subsets of others/different versions,
# etc.  The script only needs to download two giant files.  I had to insert
# --no-check-certificate in front of the wget command on line 35 to get it to work.
# Please run this script from a node with 128 GB memory as the mmseqs
# conversion process will create index files that are optimized for the amount of
# memory. See modified script in ./colabfold in this repository.
wget https://raw.githubusercontent.com/sokrypton/ColabFold/main/setup_databases.sh
chmod +x setup_databases.sh
./setup_databases.sh database/
```

For the Colabfold databases, I think `uniref30_2202.tar.gz` is a newer version of
`uniref30_2103.tar.gz`. `uniref30_2103_taxonomy.tar.gz` is not mentioned in the
instructions at all and may be optional/specialized.  Finally, `bfd_mgy_colabfold.tar.gz`
is a subset of `colabfold_envdb_202108.tar.gz` and so it is best to simply ignore the
former while downloading the latter.

The approach I think we need to take (which is only downloading `uniref30_2202` and
`colabfold_envdb_202101` and then reformatting each with mmseqs) is basically done
in the original `setup_databases.sh` (available [here](https://raw.githubusercontent.com/sokrypton/ColabFold/main/setup_dat
abases.sh) ) except that we swap out `uniref30_2103` with `uniref30_2202`.

## Converting ColabFold notebooks

This process requires having Jupyter (nbconvert and nbformat) installed in your compute environment. There are two steps.

1. Clone the ColabFold GitHub repository:
```bash
git clone https://github.com/sokrypton/ColabFold
```
2. Use the scripts here to convert the notebook (paths in this example assume that the `ColabFold` repo is cloned into your local clone of `alphafold-notebook-demo/colabfold/`.
```bash
./convert_colab.sh ./ColabFold/Alphafold2.ipynb
```

The output file is a Python script (`.py`) based on the original Colab notebook.  Dependency installation steps and code that downloads results of Google Drive are removed.

## Building a ColabFold container/Conda environment

The dependencies removed from the Colab notebook in the previous step still need to be included somewhere. Putting them in a container or Conda environment helps keep the software
portable. However, I think the build is still sensitive to hardware in that efforts to build the container on nodes without GPU result in containers than cannot
use GPUs. For now, focus on building a Conda environment that can run Colabfold on GPUs (on a GPU node) because making changes to a local Conda environment
does not require sudo priviledges while `singularity build` does.  The `ColabFold-notebook.def` Singularity definition file builds a valid container, but if run on CPU only nodes, builds a container that cannot use GPUs.

## Building a ColabFold Conda environment

Please see `colabfold_env_build.md` for the steps necessary to build a ColabFold Conda environment.

## Running this version of ColabFold

The Python script above will still download the Alphafold coefficients (~3.5GB) at run time. If the script is running on a cluster's shared space and the Alphafold coefficients are already downloaded, the download will not be repeated (see the section on running, below, for more detail).
