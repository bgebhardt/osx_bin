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

# 
# [adobe/helix-onedrive-cli: Command-line tools for onedrive integration](https://github.com/adobe/helix-onedrive-cli)

# onedrive cli for personal one drive
# [lionello/onedrive-cli: Command line interface for OneDrive](https://github.com/lionello/onedrive-cli)
npm -g install @lionello/onedrive-cli

# ONEDRIVE RELATED

# [onedrive-link - npm](https://www.npmjs.com/package/onedrive-link?activeTab=readme)
# The tool will spit out a direct download link that can be used with curl, wget, or any other tool that expects a "direct" download link.
# not sure what this actually helps with
npm -g install onedrive-link

# [@lionello/onedrive-cli - npm](https://www.npmjs.com/package/@lionello/onedrive-cli)
# Cross-platform command line interface for OneDrive (Personal)
# remember to login first. See FAQ in README
npm -g install @lionello/onedrive-cli

#[adobe/helix-onedrive-cli: Command-line tools for onedrive integration](https://github.com/adobe/helix-onedrive-cli)
# Alertnate CLI
npm -g install @adobe/helix-onedrive-cli