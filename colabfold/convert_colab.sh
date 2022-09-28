#!/bin/bash
#===================
# Convert the Colab
# notebook to executable python code.
#
# TODO: Eventually, consider using Colab
# parameter markup information to build
# a workflow.xml file to run interations.
# A nice Colab tutorial with an interactive
# demo of the different input types is here:
# https://colab.research.google.com/notebooks/io.ipynb
#==================

# Specify the name of the Colab.ipynb
colab_ipynb=$1

# Get current directory
current_dir=`pwd`

# Get basename
bn=`basename $colab_ipynb .ipynb`

# Convert notebook code to python code
# Drop the cell with the title "Install dependencies"
# Unfortunately, this preprocessor only grabs contents
# of cells and not whole cells!  WORKING HERE
jupyter nbconvert --log-level 0 --to script --output ${current_dir}/${bn}.tmp --RegexRemovePreprocessor.patterns="Install.dependencies" $colab_ipynb

# Additional things that we can remove:
# 1) google.colab's files tool for uploading data to notebook
# 2) Google Drive usage
grep -iv drive ${current_dir}/${bn}.tmp.py | grep -iv uploaded | grep -iv google.colab | grep -iv gauth | grep -iv GoogleCredentials | grep -iv auth.authenticate_user > ${current_dir}/${bn}.py


#===========================
# Working here to PoC conversion
# to workflow.xml

# Print out each parameter name in the input Colab notebook
grep \#\@param $colab_ipynb

# Many params have types and default values associated with them.
# This is enough information to define workflow.xml parameter
# types.

# The issue is that some types will want to be more fully automated
# than others. E.g. we want to launch many Alphafold instances but with
# just one variable different. Hard to push that into the form, so
# instead, we can run the workflow with the PW API.
