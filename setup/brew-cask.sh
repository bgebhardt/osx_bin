#!/usr/bin/env bash

# My brew-cask.sh of all the brew cask applications I install.
# Casks are an easy way to install many mac applications.
# see https://caskroom.github.io
# Inpsired by dotfiles at https://github.com/mathiasbynens/dotfiles.git
# Some ideas also inspired by https://www.danholloran.me/2016/01/12/quickly-install-applications-on-your-mac-with-homebrew-and-cask/
# How to search for potential cask-able applications on your machine
# brew cask search > cask-install.sh

# Make sure we’re using the latest Homebrew.
brew update

# Upgrade any already-installed formulae.
brew upgrade --all

# install cask
brew install cask

# install apps

## TODO: add brew install cask before each cask

## Productivity/Office
adium
adobe-reader
amadeus-pro
audacity


## Utilities
1clipboard
1password
amazon-drive
amazon-music
carbon-copy-cloner
bartender
beamer
crossover

## Development apps
aptanastudio
aqua-data-studio
aquamacs
codekit
coderunner
daisydisk
dash
boot2docker
couchbase-server-community





# clean up cached cask files
brew cask cleanup

# Remove outdated versions from the cellar.
brew cleanup
