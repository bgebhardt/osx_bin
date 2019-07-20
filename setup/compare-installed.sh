#!/usr/bin/env bash

# Script to compare installed items to what's in these setup scripts

# brew

# list installed
brew list -1 | sort >| installed-brew.txt 

# list from set up file
grep -v "#" | grep "brew install" brew.sh  | awk '{print $3}' | sort | diff --context=1 installed-brew.txt -
