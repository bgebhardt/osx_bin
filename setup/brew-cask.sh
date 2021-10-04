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
brew install 1password
brew install fastscripts
brew install iterm2
brew install flux
brew install omnifocus
brew install mailplane
brew install dropbox
brew install google-drive
brew install wd-my-cloud # also WD Sync Installer.app
# Mail Plugin Manager.app - manually install this one or create cask
#brew install sizzlingkeys # bought this in the app store; install with mas
brew install textmate
brew install timing
brew install rescuetime
brew install divvy
brew install tripmode # manage data on cell connection
brew install karabiner-elements # powerful and stable keyboard customizer

## Productivity/Office
brew install adium
brew install adobe-reader
brew install amadeus-pro
brew install audacity
brew install busycal
brew install busycontacts
brew install fullcontact
brew install elmedia-player
#brew install evernote # install with mas instead
#fantastical
brew install firefox
brew install google-chrome
brew install flash-player
brew install google-earth
brew install music-manager
brew install intensify-pro
brew install kiwi
brew install kindle
brew install send-to-kindle
brew install markdown-service-tools
brew install qlmarkdown
# brew install metanota. # install cask broken
brew install textexpander
brew install omnigraffle
brew install omnioutliner
brew install pdf-converter-master
brew install pdfpen
brew install slack
brew install skype
brew install soulver
brew install logitech-myharmony
brew install spotify
brew install vlc
brew install hype # web animation program
# brew install lego-mindstorms-ev3 # not currently using
brew install houdahgeo

## Utilities
brew install 1clipboard
brew install amazon-drive
brew install amazon-music # need to delete folder in Applications Support and then works
brew install bartender
brew install beamer
brew install boom
brew install brightness
brew install caffeine
brew install carbon-copy-cloner
brew install crashplan
brew install cronnix
brew install crossover
brew install daisydisk
brew install default-folder-x
brew install disk-drill
brew install disk-sensei
brew install appdelete
brew install bluesense
# disk-inventory-x
# omnidisksweeper
#dropbox-encore
#fluid
brew install forklift
brew install grandperspective
brew install growlnotify
# brew install notifyr # for some reason this prefpane not working on 10.12; claims Bluetooth 4.0 not supported
brew install little-snitch
brew install gemini
brew install macpilot
brew install macupdate-desktop
brew install mactracker
brew install rcdefaultapp
brew install plex-media-server
brew install popclip
brew install superduper
brew install supersync
# brew install wallpaper-wizard # install via mas instead
brew install iphoto-library-manager
brew install imazing
brew install handbrake # https://handbrake.fr/

## Development apps
brew install atom
brew install diffmerge
brew install aptanastudio
brew install aqua-data-studio
brew install aquamacs
brew install base
brew install codekit
brew install coderunner
brew install dash
brew install boot2docker
brew install couchbase-server-community
brew install deltawalker
brew install espresso
brew install github-desktop
brew install xquartz
brew install ngrok # sign up or login here https://ngrok.com/
#the-escapers-flux
#quicklook-json
brew install quickjson
brew install key-codes
brew install mamp
brew install navicat-for-mysql
brew install pycharm
brew install rstudio
brew install spyder # python data science IDE (like rstudio)
brew install rapidweaver
brew install virtualbox                # VirtualBox is a powerful x86 and AMD64/Intel64 virtualization product
brew install virtualbox-extension-pack # VirtualBox Extension Pack
brew install vagrant                   # Vagrant is a tool for building and distributing development environments.
brew install ngrok		# ngrok is a handy tool and service that allows you tunnel requests from the wide open Internet to your local machine when it's behind a NAT or firewall

brew install visual-studio-code
brew install powershell # install the mac version of powershell
brew install dotnet-sdk # install .NET Core SDK
brew install sts
brew install kitematic
brew install sequel-pro
brew install java
brew install pgweb # postgres web admin - see https://github.com/sosedoff/pgweb
# brew install yourkit-java-profiler # cask broken

brew install qlcolorcode         # Preview source code files with syntax highlighting
brew install qlstephen           # Preview plain text files without a file extension. Example: README, CHANGELOG, etc.
brew install qlmarkdown          # Preview Markdown files
brew install quicklook-json      # Preview JSON files
brew install qlprettypatch       # Preview .patch files
brew install quicklook-csv       # Preview CSV files
brew install betterzipql         # Preview archives
brew install webpquicklook       # Preview WebP images

#brew install facter        # cask broken # Facter gathers basic facts about systems. such as hardware, network settings, OS type and more.
#brew install sublime-text3 # cask broken # Sublime Text is a sophisticated text editor for code, markup and prose.
brew install gitup         # Visualization Tool for Git
brew install kaleidoscope  # File and Folder comparison tool

# Data science
brew install anaconda

# Games
brew install gog-galaxy
brew install steam
brew install steamcmd
brew install teamspeak-client
brew install minecraft-server
brew install minecraft
brew install battle-net

# Free Comic Book Reader
brew install yacreader

# clean up cached cask files
brew cleanup

# Remove outdated versions from the cellar.
brew cleanup
