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
brew install --cask 1password
brew install --cask fastscripts
brew install --cask iterm2
brew install --cask omnifocus
# brew install --cask google-drive -- add this back?
brew install --cask timing
brew install --cask pdf-expert
brew install --cask microsoft-office # requires admin password to install
brew install --cask microsoft-edge
brew install --cask visual-studio-code
brew install --cask github

brew install --cask omnioutliner
brew install --cask soulver
brew install --cask quicken

# Login items
brew install --cask bartender
brew install --cask caffeine
brew install --cask alfred
brew install --cask popchar
brew install --cask rectangle
brew install --cask typinator
brew install --cask lunar
brew install --cask karabiner-elements
brew install --cask default-folder-x


# clean up cached cask files
brew cask cleanup

# install mas applications
# Read more about this at https://github.com/mas-cli/mas
mas install 823766827 # OneDrive (17.3.6518)
mas install 456624497 # Brightness Slider
mas install 803453959 # Slack (2.0.3)
mas install 540348655 # Monosnap - screenshot editor   (5.1.7)
mas install 1499181666 #  OwlOCR - Screenshot to Text (5.0.7)



# Remove outdated versions from the cellar.
brew cleanup

# retired minimums
#brew install --cask sizzlingkeys
#brew install --cask textmate
#brew install --cask mailplane
#brew install --cask dropbox
# brew install --cask wd-my-cloud # also WD Sync Installer.app
# Mail Plugin Manager.app - manually install this one or create cask
#brew install --cask divvy
#brew install --cask brightness
#brew install --cask textexpander
#brew install --cask flux
