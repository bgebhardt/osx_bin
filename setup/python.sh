#!/usr/bin/env bash

# python.sh - installed Python packages I use.
# Inpsired by dotfiles at https://github.com/mathiasbynens/dotfiles.git

# upgrade pip
pip install --upgrade pip
pip3 install --upgrade pip

# data science related
pip install pandas matplotlib fake-factory delorean xlwt
pip install libgraphite

# install for python3 too  TODO: clean this duplication
pip3 install pandas matplotlib fake-factory delorean xlwt
pip3 install libgraphite

# add azure sdk
pip install azure
pip3 install azure

# install git library (used by git-extra-commands)
pip install gitpython
pip3 install gitpython

# install virtualenv
pip install virtualenv
pip3 install virtualenv

# * [python-diamond/Diamond: Diamond is a python daemon that collects system metrics and publishes them to Graphite (and others). It is capable of collecting cpu, memory, network, i/o, load and disk metrics. Additionally, it features an API for implementing custom collectors for gathering metrics from almost any source.]( https://github.com/python-diamond/Diamond )
pip install diamond
pip3 install diamond

# install bpython - alternative interface to the Python interpreter for Unix-like operating systems
pip install bpython
pip3 install bpython

# install IPython - provides a rich toolkit to help you make the most out of using Python interactively
pip install ipython
pip3 install ipython

# install Jupyter notebook
pip install jupyter
pip3 install jupyter

# ninja 2 IDE requirements
pip install MacFSEvents
pip3 install MacFSEvents
pip3 install PyQt5
