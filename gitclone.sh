#!/bin/bash

# tools to clone from git into the bin directory.
# now using Git CLI as authentication works better

# install the gh cli in case its not there.
/opt/homebrew/bin/brew install gh

gh repo clone https://github.com/mathiasbynens/dotfiles.git ~/bin/dotfiles
gh repo clone https://github.com/barryclark/bashstrap.git ~/bin/bashstrap
gh repo clone https://github.com/facebook/PathPicker.git ~/bin/PathPicker
gh repo clone https://github.com/wickett/curl-trace.git ~/bin/curl-trace
gh repo clone https://github.com/unixorn/git-extra-commands.git ~/bin/git-extra-commands

# He took this repo down. No longer use this tool.
# [joeyh/myrepos: Multiple Repository management tool]( https://github.com/joeyh/myrepos )
#git clone https://github.com/joeyh/myrepos.git ~/bin/myrepos

echo "gitclone.sh: Installation complete."
