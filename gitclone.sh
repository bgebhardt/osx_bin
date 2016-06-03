#!/bin/bash

# tools to clone from git into the bin directory.

git clone https://github.com/mathiasbynens/dotfiles.git ~/bin/dotfiles
git clone https://github.com/barryclark/bashstrap.git ~/bin/bashstrap
git clone https://github.com/facebook/PathPicker.git ~/bin/PathPicker
git clone https://github.com/wickett/curl-trace.git ~/bin/curl-trace
git clone https://github.com/unixorn/git-extra-commands.git ~/bin/git-extra-commands

[joeyh/myrepos: Multiple Repository management tool]( https://github.com/joeyh/myrepos )
git clone https://github.com/joeyh/myrepos.git ~/bin/myrepos

echo "gitclone.sh: Installation complete."
