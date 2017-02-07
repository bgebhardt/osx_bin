#!/usr/bin/env bash

# Minimum apps to install with cask right away
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
brew install mas # Install App Store command line tools https://github.com/mas-cli/mas

# install apps

## TODO: add brew install cask before each cask
## TODO: need to filtuer out which ones are from the App Store now too
## TODO: figure out which versions of apps I have licenses for and load those.

## Top Must Installs
brew cask install 1password
brew cask install fastscripts
brew cask install iterm2
brew cask install flux
brew cask install omnifocus
brew cask install mailplane
brew cask install dropbox
brew cask install google-drive
brew cask install wd-my-cloud # also WD Sync Installer.app
# Mail Plugin Manager.app - manually install this one or create cask
brew cask install sizzlingkeys
brew cask install textmate
brew cask install timing
brew cask install divvy
brew cask install brightness
brew cask install textexpander
brew cask install bartender

# clean up cached cask files
brew cask cleanup

# install mas applications
mas install 823766827 # OneDrive (17.3.6518)
mas install 456624497 # Brightness Slider
mas install 803453959 # Slack (2.0.3)


# Remove outdated versions from the cellar.
brew cleanup
