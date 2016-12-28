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

# install virtualenv
pip install virtualenv
pip3 install virtualenv
