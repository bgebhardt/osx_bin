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
brew upgrade

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
brew install tripmode # manage data on cell connection
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
#brew install waydabber/betterdisplay/betterdisplaycli # [Integration features, CLI · waydabber/BetterDisplay Wiki](https://github.com/waydabber/BetterDisplay/wiki/Integration-features,-CLI); requires xcode
brew install --cask monitorcontrol # Tool to control external monitor brightness & volume https://github.com/MonitorControl/MonitorControl
brew install --cask lunar # monitor brightness manager; replaces flux

brew install --cask displaylink # Drivers for DisplayLink docks, adapters and monitors - https://www.synaptics.com/products/displaylink-graphics

brew tap jakehilborn/jakehilborn && brew install displayplacer # macOS command line utility to configure multi-display resolutions and arrangements.-  https://github.com/jakehilborn/displayplacer

brew install --cask fastscripts
brew install --cask airbuddy # monitors bluetooth devices
brew install --cask cloudmounter # mount different cloud services
#brew install --cask expandrive # Network drive and browser for cloud storage - https://www.expandrive.com/apps/expandrive/
brew install --cask mountain-duck # Mounts servers and cloud storages as a disk on the desktop - https://mountainduck.io/

brew install --cask forklift # Finder replacement and FTP, SFTP, WebDAV and Amazon s3 client - https://binarynights.com/
brew install duck # Command-line interface for Cyberduck (a multi-protocol file transfer tool) - https://duck.sh/
brew install --cask cyberduck # Server and cloud storage browser https://cyberduck.io/

brew install --cask zoom

brew install --cask meetingbar # Shows the next meeting in the menu bar https://github.com/leits/MeetingBar
# alternative not in brew: [Meeter](https://www.bardeen.ai/meeter)

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
#brew install evernote # install with mas instead
#fantastical
brew install --cask cron # Calendar for professionals and teams https://cron.com/

# music and audio players and organizers
brew install --cask aural # Audio player inspired by Winamp https://github.com/maculateConception/aural-player
# didn't work :( brew install --cask jmc # Media organizer https://github.com/jcm93/jmc

# crashes on start - brew install --cask clementine # Music player and library organizer https://www.clementine-player.org/
# doesn't work - brew install --cask nightingale # Working tree for the community fork of Songbird https://getnightingale.com/

# video players
brew install elmedia-player # Free and open-source media player https://iina.io/
brew install --cask movist-pro # Media player https://movistprime.com/
brew install --cask iina # Free and open-source media player https://iina.io/
brew install vlc # Multimedia player https://www.videolan.org/vlc/
brew install mpv # Media player based on MPlayer and mplayer2 https://mpv.io

brew install firefox
brew install google-chrome
# brew install flash-player -- no longer available
#brew install google-earth

# brew install music-manager - no longer used

# brew install intensify-pro -- no longer available
# brew install kiwi  -- no longer available
# brew install kindle # Kindle app retired on 10-31-2023. Install via app store instead. See mas.sh
brew install send-to-kindle # Requires Rosetta 2 installed
brew install markdown-service-tools
brew install qlmarkdown # [sbarex/QLMarkdown: macOS Quick Look extension for Markdown files.](https://github.com/sbarex/QLMarkdown)
# brew install metanota. # install cask broken
brew install textexpander
brew install omnigraffle
brew install omnioutliner
brew install pdf-converter-master
brew install --cask cisdem-pdf-converter-ocr # PDF Converter with OCR capability https://www.cisdem.com/pdf-converter-ocr-mac.html # alternate conversion option that I don't really use.

# brew install --cask curiosity # SwiftUI Reddit client https://github.com/Dimillian/RedditOS # easier to just use the web version

brew install pdfpen
brew install --cask skim # PDF reader and note-taking application https://skim-app.sourceforge.io/
brew install --cask pdfsam-basic # Extracts pages, splits, merges, mixes and rotates PDF files https://pdfsam.org/
brew install slack
brew install skype
brew install soulver # Notepad with a built-in calculator https://soulver.app/
brew install --cask numi #Calculator and converter application https://numi.app/; costs $19.99; has raycast integration

brew install --cask rocket # Emoji picker optimized for blind people https://matthewpalmer.net/rocket/
# [TextPal — Super-fast emoji picker for macOS](https://www.textpal.app/) is an alternate but not installable by brew

# brew install logitech-myharmony #  -- no longer available
brew install spotify
brew install hype # web animation program
# brew install lego-mindstorms-ev3 # not currently using
# brew install houdahgeo -- no longer available
brew install wallpaper-wizard # desktop picture app
brew install --cask topnotch # Utility to hide the notch - https://topnotch.app/

brew install --cask mathpix-snipping-tool # Scanner app for math and science https://mathpix.com/ 

# Markdown viewers
brew install marked
brew install mweb-pro

brew install --cask coteditor # Plain-text editor for web pages, program source codes and more https://coteditor.com/; its scriptable

# Clipboard managers
brew install --cask maccy # Clipboard manager https://maccy.app/ # current favorite
brew install --cask 1clipboard # Clipboard managing app https://1clipboard.io/
brew install --cask pastebot # Workflow application to improve productivity https://tapbots.com/pastebot/


brew install --cask cakebrew # GUI app for Homebrew https://github.com/brunophilipe/Cakebrew

#notetaking
# Notion notetaking apps - cross platform
brew install --cask notion # Notion note taking; doesn't support offline notes well
brew install --cask simplenote # [Create a Simplenote Account](https://app.simplenote.com/signup/) supports offline notes

# I replaced joplin with obsidian 
#brew install --cask joplin # Note taking and to-do application with synchronization capabilities https://joplinapp.org/
#brew install joplin-cli
# brew install --cask curio # Note-taking and organizing app https://zengobi.com/curio/

brew install --cask tagspaces # Offline, open-source, document manager with tagging support https://www.tagspaces.org/
brew install --cask obsidian # Knowledge base that works on top of a local folder of plain text Markdown files https://obsidian.md/

# Zotera is good complement to obsidian. It can more easily tag and organize PDF's, images, files, etc.
# see [Best tools for organizing PDFs in Obsidian - YouTube](https://www.youtube.com/watch?v=VqOc9OsMX_s)
brew install --cask zotero # Collect, organize, cite, and share research sources https://www.zotero.org/ 

brew install --cask tableflip # App to edit markdown files in place https://tableflipapp.com/

brew install --cask figma # Collaborative team software https://www.figma.com/
brew install --cask gimp # Free and open-source image editor https://www.gimp.org/

# Gmail desktop apps
# brew install --cask kiwi-for-gmail # no longer using
brew install --cask mimestream # new preferred Gmail desktop client
# consider also Mailplane

## Utilities
# brew install amazon-drive -- no longer available
# brew install amazon-music # need to delete folder in Applications Support and then works -- no longer supported
brew install bartender
brew install boom
brew install brightness

brew install --cask stats # Name: Stats - System monitor for the menu bar https://github.com/exelban/stats
# alternative not as good as stats though
# brew install --cask iglance # System monitor for the status bar - https://github.com/iglance/iGlance

brew install --cask menubar-stats # System monitor with temperature & fans plugins https://seense.com/menubarstats/
# clock - no cask; same software maker [seense | The Clock for macOS](https://seense.com/the_clock/)

brew install --cask command-tab-plus #Keyboard-centric application and window switcher https://noteifyapp.com/command-tab-plus/
# quick expose - no cask; same software maker [Quick Exposé: A New Way to Use Mission Control and App Exposé on macOS • MacPlus Software](https://noteifyapp.com/quick-expose/)

# Apps to force the mac to stay awake; not go into sleep
#brew install caffeine # retired this one for one of the 2 below
brew install --cask keepingyouawake #Name: KeepingYouAwake - Tool to prevent the system from going into sleep mode https://keepingyouawake.app/
# amphetimine is more feature reach but can't be installed by brew

brew install --cask espanso # Name: Espanso - Cross-platform Text Expander written in Rust https://espanso.org/; replace Typinator??

brew install --cask raindropio # All-in-one bookmark manager https://raindrop.io/

brew install carbon-copy-cloner
# brew install crashplan -- no longer available
brew install cronnix
#brew install crossover
brew install daisydisk
brew install default-folder-x # Utility to enhance the Open and Save dialogs in applications - https://www.stclairsoft.com/DefaultFolderX/
brew install --cask app-tamer # CPU management application - https://www.stclairsoft.com/AppTamer/
brew install disk-drill
# brew install disk-sensei -- no longer available
brew install appdelete
brew install bluesense # Detect the presence of your Bluetooth device https://apps.inspira.io/bluesense/

# disk-inventory-x
# omnidisksweeper
#dropbox-encore
#fluid
brew install grandperspective
# brew install growlnotify -- no longer used
# brew install notifyr # for some reason this prefpane not working on 10.12; claims Bluetooth 4.0 not supported
brew install little-snitch
brew install macpilot
# brew install macupdate-desktop -- no longer available
brew install mactracker
# brew install rcdefaultapp -- no longer available

brew install plex-media-server
brew install --cask plexamp # Music player focusing on visuals https://plexamp.com/ (free version started on 07-30-2023)

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
brew install --cask timemachineeditor # Utility to change the default backup interval of Time Machine
brew install --cask space-saver # Delete local Time Machine backups
brew install --cask launchcontrol # Create, manage and debug system- and user services (launchctl GUI)
brew install --cask powerphotos # powerphotos for managing photo libraries
# brew install iphoto-library-manager # replaced with powerphotos
brew install --cask itsycal # Menu bar calendar https://www.mowglii.com/itsycal/

brew install --cask swish # Control windows and applications right from your trackpad - https://highlyopinionated.co/swish/
brew install --cask paletro # Command palette in any application - https://appmakes.io/paletro
brew install --cask mission-control-plus # Manage your windows in Mission Control - https://fadel.io/MissionControlPlus
brew install --cask batteries # Track all your devices' batteries - https://www.fadel.io/batteries/

# Bring System-level Arrange Window features to Mac - [Wins - Window Manager for Mac](https://wins.cool/) - bought but no longer using.

# free ebook reader and management software
brew install --cask calibre # [calibre - E-book management](https://calibre-ebook.com/)
brew install --cask fbreader # Name: FBReader book reader https://fbreader.org/macos/

# ended up not liking adobe digital editions. FBReader is slighty better, but still lookng for best epub reader
#brew install --cask adobe-digital-editions # Name: Adobe Digital Editions https://www.adobe.com/solutions/ebook/digital-editions.html

brew install --cask xmind # Mind mapping and brainstorming tool https://www.xmind.net/

# duplicate finders
brew install --cask photosweeper-x # Tool to eliminate similar or duplicate photos https://overmacs.com/; preferred photo
brew install gemini
# cisdem duplicate finder - [[OFFICIAL] Cisdem Duplicate Finder | Best Duplicate File Finder to Find and Remove Duplicates](https://www.cisdem.com/duplicate-finder.html); bought in https://bundlehunt.com/my-account/downloads/all

# brew install synergy-core # Synergy, the keyboard and mouse sharing tool # have to install via the websites installer for it to work well. - https://symless.com/synergy/download

# terminals - other than iTerm; I'm sticking with iTerm though.
#brew install --cask kitty #GPU-based terminal emulator https://github.com/kovidgoyal/kitty
#brew install --cask alacritty # Name: Alacritty GPU-accelerated terminal emulator (Mac and Windows) https://github.com/alacritty/alacritty/
brew install --cask warp # Rust-based terminal app; couldn't get it to work though

brew install --cask hammerspoon # Name: Hammerspoon - Desktop automation application - https://www.hammerspoon.org/
brew install --cask phoenix # Window and app manager scriptable with JavaScript https://github.com/kasper/phoenix/ (alternative to hammerspoon automation)

brew install --cask aldente # Menu bar tool to limit maximum charging percentage https://github.com/davidwernhart/AlDente

brew install --cask hookmark # Link and retrieve key information https://hookproductivity.com/
# install the hook cli with sudo gem install hookapp Run hook clip <file> for exmpale. See [Hook CLI - BrettTerpstra.com](https://brettterpstra.com/projects/hook-cli/) for more docs.

brew install --cask qr-journal # Allows users with an iSight (or compatible) camera to read QR codes https://www.joshjacob.com/mac-development/qrjournal.php

brew install --cask tnefs-enough # Read and extract files from Microsoft TNEF files https://www.joshjacob.com/mac-development/tnef.php

# Reference: [5 Ways to Turn Any Website Into a Desktop Mac App](https://www.makeuseof.com/tag/website-desktop-mac-app/)
brew install --cask fluid # Tool to turn a website into a desktop app - free app - https://fluidapp.com/
#brew install --cask unite # Turn websites into apps https://bzgapps.com/unite # need to upgrade to version 4 if I want to use.

brew install --cask obs # Open-source software for live streaming and screen recording https://obsproject.com/

# brew install --cask camo-studio # Use your phone as a high-quality webcam with image tuning controls https://reincubate.com/camo/
# don't have a need for this but saving for reference

brew install --cask descript # Audio and video editor https://www.descript.com/ # innovative video editor that uses text to edit video

brew install --cask netspot # WiFi site survey software and WiFi scanner https://www.netspotapp.com/ # never upgraded my license. But unlicensed is someone useful.
# brew install --cask inssider # Defeat slow wifi https://www.metageek.com/products/inssider/ # doesn't work on Ventura :( 

brew install --cask breaktimer # Tool to manage periodic breaks https://breaktimer.app/

# per app sound control apps that require more permissions than I'm willing to give. And are both paid apps.
# brew install --cask sound-control # Per-app audio controls https://staticz.com/soundcontrol/ # paid app that didn't work well for me
# brew install --cask soundsource # Sound and audio controller https://rogueamoeba.com/soundsource/


## Development apps
brew install devutils # developer toolbox https://devutils.app/
brew install atom
brew install aptanastudio
# brew install aqua-data-studio # disabled as I use it rarely and it's 1 GB of space
brew install aquamacs
brew install base
brew install codekit
brew install coderunner
brew install dash
brew install boot2docker
# brew install couchbase-server-community # commented out as it uses lots of disk space
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
brew install --cask fig # auto-complete for shell # I now use the Warp terminal instead
#brew install --cask background-music # [kyleneideck/BackgroundMusic: Background Music, a macOS audio utility: automatically pause your music, set individual apps' volumes and record system audio.](https://github.com/kyleneideck/BackgroundMusic#download) # doesn't work quite right.

brew install --cask anaconda # Distribution of the Python and R programming languages for scientific computing https://www.anaconda.com/

# diff tools
# nice article comparing diff tools - [The 5 Best Mac File Comparison Tools and Diff Tools](https://www.makeuseof.com/tag/mac-file-comparison-tools/)
# delta walker is the best for me right now and I own it
brew install --cask deltawalker # diff tool https://www.deltawalker.com/ # paid app, find/replace with regex; cli; undo/redo; export diffs
brew install --cask meld # Visual diff and merge tool https://yousseb.github.io/meld/ # 3-way compare, text editor, syntax highlighting, regex
brew install --cask diffmerge # [SourceGear | DiffMerge](https://www.sourcegear.com/diffmerge/) # taks drag and drop!
# brew install --cask beyond-compare # Compare files and folders https://www.scootersoftware.com/ paid app # compare with remote servers (OneDrive, Google, ...); Table compare; scripting
# brew install kaleidoscope  # File and Folder comparison tool # paid app so removing

brew install --cask mark-text # Simple and elegant markdown editor - https://github.com/marktext/marktext; on Windows too!

brew install --cask powershell # Command-line shell and scripting language https://github.com/PowerShell/PowerShell

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

# see [Quick Look plugins for software development | mixable Blog](https://mixable.blog/quick-look-plugins-for-software-development/) for more info
# Note: some of the plugins might not work instantly after brew install ... when you are on macOS Catalina or later. In this case, it is possible to download the plugin manually and copy the .qlgenerator file to ~/Library/QuickLook. This requires to run qlmanage -r (or a system restart) to enable the plugin.
brew install qlcolorcode         # Preview source code files with syntax highlighting
brew install qlstephen           # Preview plain text files without a file extension. Example: README, CHANGELOG, etc.
brew install quicklook-json      # Preview JSON files
brew install qlprettypatch       # Preview .patch files
brew install quicklook-csv       # Preview CSV files
brew install betterzipql         # Preview archives
brew install webpquicklook       # Preview WebP images
# brew install qlmarkdown # [sbarex/QLMarkdown: macOS Quick Look extension for Markdown files.](https://github.com/sbarex/QLMarkdown) duplicated line from above.

#brew install facter        # cask broken # Facter gathers basic facts about systems. such as hardware, network settings, OS type and more.
#brew install sublime-text3 # cask broken # Sublime Text is a sophisticated text editor for code, markup and prose.
brew install gitup         # Visualization Tool for Git

# Data science
#brew install anaconda

# Social and Messaging

brew install --cask telegram-a # Web client for Telegram messenger - https://web.telegram.org/a/get
brew install --cask beeper # Universal chat app powered by Matrix - https://www.beeper.com/ (I'm on the waitlist)


# Games
#brew install gog-galaxy # disabling because it doesn't install well
brew install steam
brew install epic-games
brew install steamcmd
brew install teamspeak-client
# brew install minecraft-server -- no longer available
brew install minecraft
brew install --cask prismlauncher # Minecraft launcher https://prismlauncher.org/
brew install battle-net
brew install --cask playcover-community # Sideload iOS apps and games https://github.com/PlayCover/PlayCover never worked
#brew install --cask bluestacks # Mobile gaming platform https://www.bluestacks.com/ play android games on mac/PC; doesn't work on M1 macs; only provdes a manual installer
# Try also [LDPlayer - Lightweight & Fast Android Emulator for PC](https://www.ldplayer.net/); no brew install # 11-12-2023 does not work

#brew install --cask android-studio # Tools for building Android applications https://developer.android.com/studio/ (can emulate games but didn't really work)

# [Heroic-Games-Launcher/HeroicGamesLauncher: A Native GOG and Epic Games Launcher for Linux, Windows and Mac.](https://github.com/Heroic-Games-Launcher/HeroicGamesLauncher#macos)
brew install heroic
# xattr -d com.apple.quarantine /Applications/Heroic.app # run this to fix the app is damaged error.

brew install --cask onecast

brew install --cask crossover # Tool to run Windows software https://www.codeweavers.com/products/crossover-mac/

# Free Comic Book Reader
brew install yacreader

# All-in-one live streaming software
brew install --cask streamlabs-obs

brew install --cask aerial # Apple TV Aerial screensaver https://github.com/JohnCoates/Aerial

brew install --cask netnewswire # Free and open-source RSS reader - https://netnewswire.com/

# VNC viewers and servers
# Real VNC is the easiest, but Apple Sharing doesn't support secure connections. Would require paid server for better security
# other solutions seem to work best with their own VNC server running on the remote machine.
brew install --cask vnc-viewer # Remote desktop application focusing on security https://www.realvnc.com/
#brew install tiger-vnc # VNC viewer and server https://tigervnc.org/ # has a lot of dependencies so commenting out for now.
#brew install --cask tigervnc-viewer # Multi-platform VNC client and server https://tigervnc.org/
#brew install --cask turbovnc-viewer # Remote display system https://www.turbovnc.org/
# brew install --cask jollysfastvnc # nice but is paid software

brew install --cask keyboardcleantool # Blocks all Keyboard and TouchBar input to clean keyboard https://folivora.ai/keyboardcleantool

brew install --cask sloth # [Sloth - Mac app that shows all open files and sockets |](https://sveinbjorn.org/sloth)
brew install --cask alt-tab # [AltTab - Windows alt-tab on macOS](https://alt-tab-macos.netlify.app/)
brew install --cask find-any-file # File finder https://apps.tempel.org/FindAnyFile/

#brew install --cask stellarium # Tool to render realistic skies in real time on the screen https://stellarium.org/

# bundlehunt.com - 2024 Award Winning New Year Bundle purchase
brew install --cask tg-pro # Temperature monitoring, fan control and diagnostics https://www.tunabellysoftware.com/tgpro/
brew install --cask lingon-x # Automator software to start apps, run scripts or commands and more https://www.peterborgapps.com/lingon/
brew install --cask time-out # Customizable timing of breaks https://www.dejal.com/timeout/
brew install --cask blocs # Visual web design software https://blocsapp.com/


brew install --cask transnomino # Batch rename utility https://www.transnomino.com/




# Remove outdated versions from the cellar.
brew cleanup
