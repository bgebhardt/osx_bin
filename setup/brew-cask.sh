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
## TODO: need to filtuer out which ones are from the App Store now too
## TODO: figure out which versions of apps I have licenses for and load those.

## Top Must Installs
1password
fastscripts
iterm2
flux
omnifocus
mailplane
dropbox
google-drive
wd-my-cloud # also WD Sync Installer.app
# Mail Plugin Manager.app - manually install this one or create cask
sizzlingkeys
textmate
timing

## Productivity/Office
adium
adobe-reader
amadeus-pro
audacity
busycal
busycontacts
fullcontact
elmedia-player
evernote
#fantastical
firefox
google-chrome
google-earth
intensify-pro
kiwi
kindle
send-to-kindle
markdown-service-tools
qlmarkdown
metanota
textexpander
omnigraffle
omnioutliner
pdf-converter-master
pdfpen
slack
skype
soulver
logitech-myharmony
spotify
vlc


## Utilities
1clipboard
amazon-drive
amazon-music
bartender
beamer
boom
brightness
caffeine
carbon-copy-cloner
crashplan
cronnix
crossover
daisydisk
default-folder-x
disk-drill
disk-sensei
# disk-inventory-x
# omnidisksweeper
divvy
#dropbox-encore
#fluid
forklift
grandperspective
growlnotify
little-snitch
gemini
macpilot
macupdate-desktop
mactracker
rcdefaultapp
plex-media-server
popclip
superduper
supersync
wallpaper-wizard
iphoto-library-manager
imazing


## Development apps
atom
diffmerge
aptanastudio
aqua-data-studio
aquamacs
base
codekit
coderunner
dash
boot2docker
couchbase-server-community
deltawalker
espresso
github-desktop
#the-escapers-flux
#quicklook-json
quickjson
key-codes
mamp
navicat-for-mysql
pycharm
rstudio
rapidweaver
virtualbox                # VirtualBox is a powerful x86 and AMD64/Intel64 virtualization product
virtualbox-extension-pack # VirtualBox Extension Pack
vagrant                   # Vagrant is a tool for building and distributing development environments.

visual-studio-code
sts
kitematic
sequel-pro
xquartz
java
java7
yourkit-java-profiler

- qlcolorcode         # Preview source code files with syntax highlighting
- qlstephen           # Preview plain text files without a file extension. Example: README, CHANGELOG, etc.
- qlmarkdown          # Preview Markdown files
- quicklook-json      # Preview JSON files
- qlprettypatch       # Preview .patch files
- quicklook-csv       # Preview CSV files
- betterzipql         # Preview archives
- webpquicklook       # Preview WebP images

- facter        # Facter gathers basic facts about systems. such as hardware, network settings, OS type and more.
- sublime-text3 # Sublime Text is a sophisticated text editor for code, markup and prose.
- gitup         # Visualization Tool for Git
- kaleidoscope  # File and Folder comparison tool



# Games
gog-galaxy
steam
steamcmd
teamspeak-client
minecraft-server
minecraft
battle-net


# clean up cached cask files
brew cask cleanup

# Remove outdated versions from the cellar.
brew cleanup
