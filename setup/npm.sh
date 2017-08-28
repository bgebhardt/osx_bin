#!/usr/bin/env bash

# npm.sh - globally installed npm packages I use.
# Inpsired by dotfiles at https://github.com/mathiasbynens/dotfiles.git

# update npm
npm -g install npm

# front end development related libraries (javascript, react)
npm -g install bower
npm -g install eslint
npm -g install git-open
npm -g install grunt-cli
npm -g install http-server
npm -g install jshint
npm -g install nestor
npm -g install reapp

# install azure command line interface
npm -g install azure-cli

# convert markdown to confluence markup - https://www.npmjs.com/package/markdown2confluence
# doesn't work as well as pandoc for conversions.
#npm -g install markdown2confluence