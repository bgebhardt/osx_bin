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
brew install --cask 1password/tap/1password-cli
brew install iterm2
brew install flux
brew install omnifocus
#brew install mailplane # as of 2021 it is no longer being developed
#brew install dropbox
brew install google-drive
#brew install wd-my-cloud # also WD Sync Installer.app
# Mail Plugin Manager.app - manually install this one or create cask
#brew install sizzlingkeys # bought this in the app store; install with mas
brew install timing
#brew install tripmode # manage data on cell connection
brew install karabiner-elements # powerful and stable keyboard customizer
#brew install --cask raycast # replacement for spotlight (and alfred or launchbar)

# Window Managers
brew install --cask rectangle # window manager - current preferred window manager
# brew install --cask tiles # Name: Sempliva Tiles Window manager https://www.sempliva.com/tiles/
# brew install divvy # window manager; replaced by rectangle
# [Magnet – Window manager for Mac](https://magnet.crowdcafe.com/)
Moom
# [Wins - Window Manager for Mac](https://wins.cool/) - I own this one too
# [Moom · Many Tricks](https://manytricks.com/moom/) - don't own it



# app for monitor brightness and other control
brew install --cask betterdisplay # Display management tool https://betterdisplay.pro/; current favorite
brew install --cask monitorcontrol # Tool to control external monitor brightness & volume https://github.com/MonitorControl/MonitorControl
brew install --cask lunar # monitor brightness manager; replaces flux

brew install --cask fastscripts
brew install --cask airbuddy # monitors bluetooth devices
brew install --cask cloudmounter # mount different cloud services
#brew install --cask expandrive # Network drive and browser for cloud storage - https://www.expandrive.com/apps/expandrive/
brew install --cask mountain-duck # Mounts servers and cloud storages as a disk on the desktop - https://mountainduck.io/

brew install --cask zoom

# retired top installs
# brew install rescuetime # no longer using
# brew install textmate # replaced by visual code



## Productivity/Office

#brew install adium
# brew install adobe-reader -- no longer available; install manually
brew install amadeus-pro
brew install audacity
#brew install busycal # I no longer use these
#brew install busycontacts # I no longer use these
# brew install fullcontact -- no longer available
brew install elmedia-player
#brew install evernote # install with mas instead
#fantastical
brew install firefox
brew install google-chrome
# brew install flash-player -- no longer available
#brew install google-earth
brew install music-manager
# brew install intensify-pro -- no longer available
# brew install kiwi  -- no longer available
brew install kindle
brew install send-to-kindle # Requires Rosetta 2 installed
brew install markdown-service-tools
brew install qlmarkdown # [sbarex/QLMarkdown: macOS Quick Look extension for Markdown files.](https://github.com/sbarex/QLMarkdown)
# brew install metanota. # install cask broken
brew install textexpander
brew install omnigraffle
brew install omnioutliner
brew install pdf-converter-master
brew install pdfpen
brew install slack
brew install skype
brew install soulver # Notepad with a built-in calculator https://soulver.app/
brew install --cask numi #Calculator and converter application https://numi.app/; costs $19.99; has raycast integration

# brew install logitech-myharmony #  -- no longer available
brew install spotify
brew install vlc
brew install hype # web animation program
# brew install lego-mindstorms-ev3 # not currently using
# brew install houdahgeo -- no longer available
brew install wallpaper-wizard # desktop picture app

# Markdown viewers
brew install marked
brew install mweb-pro

brew install --cask coteditor # Plain-text editor for web pages, program source codes and more https://coteditor.com/; its scriptable

#notetaking
# Notion notetaking apps - cross platform
brew install --cask notion # Notion note taking; doesn't support offline notes well
brew install --cask simplenote # [Create a Simplenote Account](https://app.simplenote.com/signup/) supports offline notes
brew install --cask joplin # Note taking and to-do application with synchronization capabilities https://joplinapp.org/
brew install joplin-cli

brew install --cask tableflip # App to edit markdown files in place https://tableflipapp.com/


brew install --cask topnotch # Utility to hide the notch - https://topnotch.app/

# Gmail desktop apps
# brew install --cask kiwi-for-gmail # no longer using
brew install --cask mimestream # new preferred Gmail desktop client

## Utilities
brew install 1clipboard
# brew install amazon-drive -- no longer available
# brew install amazon-music # need to delete folder in Applications Support and then works -- no longer supported
brew install bartender
brew install boom
brew install brightness

brew install --cask stats # Name: Stats - System monitor for the menu bar https://github.com/exelban/stats

# Apps to force the mac to stay awake; not go into sleep
#brew install caffeine # retired this one for one of the 2 below
brew install --cask keepingyouawake #Name: KeepingYouAwake - Tool to prevent the system from going into sleep mode https://keepingyouawake.app/
# amphetimine is more feature reach but can't be installed by brew

brew install --cask espanso # Name: Espanso - Cross-platform Text Expander written in Rust https://espanso.org/; replace Typinator??

brew install carbon-copy-cloner
# brew install crashplan -- no longer available
brew install cronnix
#brew install crossover
brew install daisydisk
brew install default-folder-x
brew install disk-drill
# brew install disk-sensei -- no longer available
brew install appdelete
brew install bluesense
# disk-inventory-x
# omnidisksweeper
#dropbox-encore
#fluid
brew install forklift
brew install grandperspective
# brew install growlnotify -- no longer used
# brew install notifyr # for some reason this prefpane not working on 10.12; claims Bluetooth 4.0 not supported
brew install little-snitch
brew install macpilot
# brew install macupdate-desktop -- no longer available
brew install mactracker
# brew install rcdefaultapp -- no longer available
brew install plex-media-server
brew install popclip
brew install superduper
# brew install supersync
# brew install wallpaper-wizard # install via mas instead
brew install imazing
brew install handbrake # https://handbrake.fr/
brew install discord
brew install downie # [Downie - YouTube Video Downloader for macOS](https://software.charliemonroe.net/downie/)
brew install --cask permute # [Permute - Media Converter for macOS](https://software.charliemonroe.net/permute/)
brew install betterzip
brew install cask onyx # fee multifunction utility for system maintence
brew install --cask screens # Control any computer from your Mac from anywhere in the world
brew install --cask reflector # wireless screen mirroring
brew install --cask airparrot # Streaming and Mirroring for Windows and macOS
brew install beamer # streaming from Mac
brew install --cask calibre # [calibre - E-book management](https://calibre-ebook.com/)
brew install --cask timemachineeditor # Utility to change the default backup interval of Time Machine
brew install --cask space-saver # Delete local Time Machine backups
brew install --cask launchcontrol # Create, manage and debug system- and user services (launchctl GUI)
brew install --cask powerphotos # powerphotos for managing photo libraries
# brew install iphoto-library-manager # replaced with powerphotos
brew install --cask itsycal # Menu bar calendar https://www.mowglii.com/itsycal/

# duplicate finders
brew install --cask photosweeper-x # Tool to eliminate similar or duplicate photos https://overmacs.com/; preferred photo
brew install gemini
# cisdem duplicate finder - [[OFFICIAL] Cisdem Duplicate Finder | Best Duplicate File Finder to Find and Remove Duplicates](https://www.cisdem.com/duplicate-finder.html); bought in https://bundlehunt.com/my-account/downloads/all

# brew install synergy-core # Synergy, the keyboard and mouse sharing tool # have to install via the websites installer for it to work well. - https://symless.com/synergy/download

# terminals - other than iTerm; I'm sticking with iTerm though.
#brew install --cask kitty #GPU-based terminal emulator https://github.com/kovidgoyal/kitty
#brew install --cask alacritty # Name: Alacritty GPU-accelerated terminal emulator (Mac and Windows) https://github.com/alacritty/alacritty/
# brew install --cask warp # Rust-based terminal app; couldn't get it to work though

brew install --cask hammerspoon # Name: Hammerspoon - Desktop automation application - https://www.hammerspoon.org/

## Development apps
brew install devutils # developer toolbox https://devutils.app/
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
# brew install couchbase-server-community # commented out as it uses lots of disk space
brew install deltawalker
brew install espresso
brew install github-release
brew install xquartz
brew install ngrok # sign up or login here https://ngrok.com/
#the-escapers-flux
#quicklook-json
brew install quickjson
brew install key-codes
brew install rapidweaver
brew install --cask expressions # regular expression app, paid
brew install --cask latest # [Latest](https://max.codes/latest/) software update checker
brew install --cask cisdem-document-reader # Document reader to open and view Windows-based files
brew install --cask macpilot # Graphical user interface for the command terminal
brew install --cask network-radar # Tool to scan and monitor the network
brew install --cask remote-wake-up # Wake up devices with a click of a button
brew install --cask colorwell # Color picker and color palette generator
brew install --cask fig # auto-complete for shell
#brew install --cask background-music # [kyleneideck/BackgroundMusic: Background Music, a macOS audio utility: automatically pause your music, set individual apps' volumes and record system audio.](https://github.com/kyleneideck/BackgroundMusic#download) # doesn't work quite right.

brew install --cask mark-text # Simple and elegant markdown editor - https://github.com/marktext/marktext; on Windows too!

## Bigger or less used development tools (disabled for now)

# brew install mamp
# brew install navicat-for-mysql
#brew install pycharm
#brew install rstudio
#brew install spyder # python data science IDE (like rstudio)
#brew install virtualbox                # VirtualBox is a powerful x86 and AMD64/Intel64 virtualization product
#brew install virtualbox-extension-pack # VirtualBox Extension Pack
#brew install vagrant                   # Vagrant is a tool for building and distributing development environments.
#brew install ngrok		# ngrok is a handy tool and service that allows you tunnel requests from the wide open Internet to your local machine when it's behind a NAT or firewall

brew install visual-studio-code
#brew install powershell # install the mac version of powershell
#brew install dotnet-sdk # install .NET Core SDK
#brew install sts
#brew install kitematic
#brew install sequel-pro
#brew install java
#brew install pgweb # postgres web admin - see https://github.com/sosedoff/pgweb
# brew install yourkit-java-profiler # cask broken

brew install qlcolorcode         # Preview source code files with syntax highlighting
brew install qlstephen           # Preview plain text files without a file extension. Example: README, CHANGELOG, etc.
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
#brew install anaconda

# Games
brew install gog-galaxy
brew install steam
brew install epic-games
brew install steamcmd
brew install teamspeak-client
# brew install minecraft-server -- no longer available
brew install minecraft
brew install battle-net
brew install heroic
brew install --cask onecast

# Free Comic Book Reader
brew install yacreader

# All-in-one live streaming software
brew install --cask streamlabs-obs

# clean up cached cask files
brew cleanup

# Remove outdated versions from the cellar.
brew cleanup
