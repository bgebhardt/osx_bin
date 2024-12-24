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

brew install mas # Install App Store command line tools https://github.com/mas-cli/mas

# install apps

## TODO: add brew install cask before each cask
## TODO: need to filtuer out which ones are from the App Store now too
## TODO: figure out which versions of apps I have licenses for and load those.

## Top Must Installs
brew install --cask 1password
brew install --cask fastscripts
brew install --cask iterm2
brew install --cask warp # Rust-based terminal app; couldn't get it to work though
brew install --cask omnifocus
brew install --cask obsidian # Knowledge base that works on top of a local folder of plain text Markdown files https://obsidian.md/
# brew install --cask google-drive -- add this back?
brew install --cask timing
brew install --cask pdf-expert
brew install --cask skim # PDF reader and note-taking application https://skim-app.sourceforge.io/
brew install --cask microsoft-office # requires admin password to install
brew install --cask microsoft-edge
brew install --cask microsoft-teams
brew install onedrive # Folder synchronization with OneDrive https://github.com/abraunegg/onedrive
brew install --cask visual-studio-code
brew install --cask github

brew install --cask omnioutliner
brew install --cask soulver
brew install --cask quicken
brew install --cask idrive # close backup

# Login items
brew install --cask bartender
#brew install --cask alfred # spotlight replacement # use raycast now instead
brew install --cask raycast # spotlight replacement, deciding between it an alfred
brew install --cask popchar
brew install --cask rectangle
brew install --cask lunar
brew install --cask karabiner-elements
brew install --cask default-folder-x
brew install --cask betterdisplay
brew install --cask shottr # free screen shot tool; preferred over Monosnap

# todo: decide between these two
brew install --cask typinator # Tool to automate the insertion of frequently used text and graphics https://www.ergonis.com/products/typinator/
brew install --cask rocket-typist # Text expander for common phrases https://witt-software.com/rockettypist/

brew install mackup # Keep your Mac's application settings in sync https://github.com/lra/mackup
# [lra/mackup: Keep your application settings in sync (OS X/Linux)](https://github.com/lra/mackup)

# install mas applications
# Read more about this at https://github.com/mas-cli/mas
#mas install 823766827 # OneDrive (17.3.6518)
mas install 456624497 # Brightness Slider
mas install 803453959 # Slack (2.0.3)
#mas install 1499181666 #  OwlOCR - Screenshot to Text (5.0.7)
mas install 6462355119 # OwlOCR - Screenshot to Text (6.0.6)
mas install 1607635845 # Velja (1.10.1) - browser picker: Open links in a specific browser or a matching native app. Easily switch between browsers


# Remove outdated versions from the cellar.
brew cleanup

# retired minimums
#brew install --cask sizzlingkeys
#brew install --cask textmate
#brew install --cask dropbox
# brew install --cask wd-my-cloud # also WD Sync Installer.app
# Mail Plugin Manager.app - manually install this one or create cask
#brew install --cask divvy
#brew install --cask brightness
#brew install --cask textexpander
#brew install --cask flux
