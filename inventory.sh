#!/bin/bash

# script to inventory various tools installed
# redirect output into a file to save it

echo "=============================="
echo "BREW INSTALLS: "
brew list -1

echo "BREW INSTALLS (full name): "
brew list -1 --full-name

echo "=============================="
echo "PYTHON INSTALLS: "
pip list

echo "=============================="
echo "GEM INSTALLS: "
gem list

echo "=============================="
echo "NPM INSTALLS (global): "
#npm list --global # short list
npm ll --global # all details

echo "=============================="
echo "R INSTALLS: "
# for some reason this requires user interaction to complete
r -q --vanilla -e "library()"

echo "=============================="