# ColabFold

[ColabFold](https://github.com/sokrypton/ColabFold) is a community-driven
update to Alphafold underpinned by [new/updated databases](https://colabfold.mmseqs.com/)
and the MSA search process is accelerated by [MMseqs2](https://github.com/soedinglab/MMseqs2).

Colabfold is distributed under the MIT license.

Colab Jupyter notebooks are available by clicking on the notebook
links in the main ColabFold repository (e.g. `Alphafold2.ipynb`).

To run Colabfold locally, first the databases need to be downloaded, e.g.
```bash
# Make new directory
mkdir -p /public/apps/collabfold/databases
cd /public/apps/collabfold/databases

# Download executable binary mmseqs (used in reformatting data)
# (Note the modification to PATH - setup_databases.sh, below
# will use mmseqs.)
wget https://mmseqs.com/latest/mmseqs-linux-avx2.tar.gz; tar xvfz mmseqs-linux-avx2.tar.gz; export PATH=$(pwd)/mmseqs/bin/:
$PATH

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