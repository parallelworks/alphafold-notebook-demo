#!/bin/bash
#===================
# Convert the Colab
# notebook to executable python code.
#
# TODO: Eventually, consider using Colab
# parameter markup information to build
# a workflow.xml file to run interations.
#==================

# Specify the name of the Colab.ipynb
colab_ipynb=$1

# Get current directory
current_dir=`pwd`

# Get basename
bn=`basename $colab_ipynb .ipynb`

# Convert notebook code to python code
jupyter nbconvert --log-level 0 --to script --output ${current_dir}/${bn} $colab_ipynb

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
