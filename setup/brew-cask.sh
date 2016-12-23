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

## TODO: need to filter out which ones are from the App Store now too
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
#brew cask install sizzlingkeys # bought this in the app store; install with mas
brew cask install textmate
brew cask install timing
brew cask install rescuetime
brew cask install divvy
brew cask install tripmode # manage data on cell connection

## Productivity/Office
brew cask install adium
brew cask install adobe-reader
brew cask install amadeus-pro
brew cask install audacity
brew cask install busycal
brew cask install busycontacts
brew cask install fullcontact
brew cask install elmedia-player
#brew cask install evernote # install with mas instead
#fantastical
brew cask install firefox
brew cask install google-chrome
brew cask install flash-player
brew cask install google-earth
brew cask install music-manager
brew cask install intensify-pro
brew cask install kiwi
brew cask install kindle
brew cask install send-to-kindle
brew cask install markdown-service-tools
brew cask install qlmarkdown
# brew cask install metanota. # install cask broken
brew cask install textexpander
brew cask install omnigraffle
#brew cask install omnioutliner # install cask broken - bad download url
brew cask install pdf-converter-master
brew cask install pdfpen
brew cask install slack
brew cask install skype
brew cask install soulver
brew cask install logitech-myharmony
brew cask install spotify
brew cask install vlc
brew cask install hype # web animation program
# brew cask install lego-mindstorms-ev3 # not currently using
brew cask install houdahgeo

## Utilities
brew cask install 1clipboard
brew cask install amazon-drive
brew cask install amazon-music # need to delete folder in Applications Support and then works
brew cask install bartender
brew cask install beamer
brew cask install boom
brew cask install brightness
brew cask install caffeine
brew cask install carbon-copy-cloner
brew cask install crashplan
brew cask install cronnix
brew cask install crossover
brew cask install daisydisk
brew cask install default-folder-x
brew cask install disk-drill
brew cask install disk-sensei
brew cask install appdelete
brew cask install bluesense
# disk-inventory-x
# omnidisksweeper
#dropbox-encore
#fluid
brew cask install forklift
brew cask install grandperspective
brew cask install growlnotify
# brew cask install notifyr # for some reason this prefpane not working on 10.12; claims Bluetooth 4.0 not supported
brew cask install little-snitch
brew cask install gemini
brew cask install macpilot
brew cask install macupdate-desktop
brew cask install mactracker
brew cask install rcdefaultapp
brew cask install plex-media-server
brew cask install popclip
brew cask install superduper
brew cask install supersync
# brew cask install wallpaper-wizard # install via mas instead
brew cask install iphoto-library-manager
brew cask install imazing

## Development apps
brew cask install atom
brew cask install diffmerge
brew cask install aptanastudio
brew cask install aqua-data-studio
brew cask install aquamacs
brew cask install base
brew cask install codekit
brew cask install coderunner
brew cask install dash
brew cask install boot2docker
brew cask install couchbase-server-community
brew cask install deltawalker
brew cask install espresso
brew cask install github-desktop
brew cask install xquartz
#the-escapers-flux
#quicklook-json
brew cask install quickjson
brew cask install key-codes
brew cask install mamp
brew cask install navicat-for-mysql
brew cask install pycharm
brew cask install rstudio
brew cask install spyder # python data science IDE (like rstudio)
brew cask install rapidweaver
brew cask install virtualbox                # VirtualBox is a powerful x86 and AMD64/Intel64 virtualization product
brew cask install virtualbox-extension-pack # VirtualBox Extension Pack
brew cask install vagrant                   # Vagrant is a tool for building and distributing development environments.

brew cask install visual-studio-code
brew cask install sts
brew cask install kitematic
brew cask install sequel-pro
brew cask install java
# brew cask install yourkit-java-profiler # cask broken

brew cask install qlcolorcode         # Preview source code files with syntax highlighting
brew cask install qlstephen           # Preview plain text files without a file extension. Example: README, CHANGELOG, etc.
brew cask install qlmarkdown          # Preview Markdown files
brew cask install quicklook-json      # Preview JSON files
brew cask install qlprettypatch       # Preview .patch files
brew cask install quicklook-csv       # Preview CSV files
brew cask install betterzipql         # Preview archives
brew cask install webpquicklook       # Preview WebP images

#brew cask install facter        # cask broken # Facter gathers basic facts about systems. such as hardware, network settings, OS type and more.
#brew cask install sublime-text3 # cask broken # Sublime Text is a sophisticated text editor for code, markup and prose.
brew cask install gitup         # Visualization Tool for Git
brew cask install kaleidoscope  # File and Folder comparison tool


# Games
brew cask install gog-galaxy
brew cask install steam
brew cask install steamcmd
brew cask install teamspeak-client
brew cask install minecraft-server
brew cask install minecraft
brew cask install battle-net


# clean up cached cask files
brew cask cleanup

# Remove outdated versions from the cellar.
brew cleanup
