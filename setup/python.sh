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
pip install jupyterthemes
pip3 install jupyterthemes

# [ideonate/nb2xls: Convert Jupyter notebook to Excel spreadsheet](https://github.com/ideonate/nb2xls)
pip install nb2xls
pip3 install nb2xls

# Tools for diffing and merging of Jupyter notebooks
# https://github.com/jupyter/nbdime
pip install nbdime
pip3 install nbdime

# ninja 2 IDE requirements
pip install MacFSEvents
pip3 install MacFSEvents
pip3 install SIP
# download PyQt4 from https://www.riverbankcomputing.com/software/pyqt/download
# pip3 install PyQt5 # not used

# mkdocs
pip install mkdocs
pip install mkdocs-material==0.2.4

# install [Beautiful Soup: We called him Tortoise because he taught us.](https://www.crummy.com/software/BeautifulSoup/)
pip install beautifulsoup4
pip3 install beautifulsoup4

# install [dateutil - powerful extensions to datetime — dateutil 2.8.0 documentation](https://dateutil.readthedocs.io/en/stable/)
pip install python-dateutil
pip3 install python-dateutil
