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
brew install 1password-cli # command line interface for 1password
brew install iterm2
#brew install flux
brew install omnifocus
#brew install mailplane # as of 2021 it is no longer being developed
#brew install dropbox
brew install google-drive

brew install dropshare # File sharing solution https://dropshare.app/

brew install dropzone # Productivity app https://aptonic.com/

# Onedrive cask conflicts with office
#brew install --cask onedrive # Folder synchronization with OneDrive; required you pass cask
#brew install wd-my-cloud # also WD Sync Installer.app
# Mail Plugin Manager.app - manually install this one or create cask
#brew install sizzlingkeys # bought this in the app store; install with mas
brew install timing
brew install tripmode # manage data on cell connection
brew install karabiner-elements # powerful and stable keyboard customizer

brew install rsyncui # GUI for rsync https://github.com/rsyncOSX/RsyncUI

# two apps that can change mouse/trackpad gestures (and more) especially adding middle click. Currently trying multitouch. 
# Replace or complment karabiner
brew install multitouch # Add more gestures for Trackpad and Magic Mouse https://multitouch.app/
# brew install bettertouchtool # Tool to customise input devices and automate computer systems https://folivora.ai/

brew install raycast # replacement for spotlight (and alfred or launchbar)

# Window Managers
brew install rectangle # window manager - current preferred window manager
brew install lasso-app # Window manager that allows you to snap windows into organized groups https://lassoapp.com/
brew install mosaic # Window manager for macOS https://lightpillar.com/mosaic.html

brew install alt-tab # Windows alt-tab on macOS https://alt-tab-macos.netlify.app/

# deprecated brew install autumn # Window manager for JavaScript development https://apandhi.github.io/Autumn/
#brew install phoenix # Window and app manager scriptable with JavaScript https://github.com/kasper/phoenix/ 
# phoenix seems not as easy to develop in as autumn; but has more examples and a few different features. See [Home · kasper/phoenix Wiki](https://github.com/kasper/phoenix/wiki#examples)

# tiling windows managers
# brew install amethyst # Automatic tiling window manager similar to xmonad https://ianyh.com/amethyst/ # not ready to try this out yet.
# good tutorial: [Boost your MacOS PRODUCTIVITY with Amethyst | Tiling Window Manager - YouTube](https://www.youtube.com/watch?v=7Z9-Ry4yGNc)
# another tiling windows manager but requires disabling SIP: [koekeishiya/yabai: A tiling window manager for macOS based on binary space partitioning](https://github.com/koekeishiya/yabai)

# brew install tiles # Name: Sempliva Tiles Window manager https://www.sempliva.com/tiles/
# brew install divvy # window manager; replaced by rectangle
# [Magnet – Window manager for Mac](https://magnet.crowdcafe.com/)
# [Wins - Window Manager for Mac](https://wins.cool/) - I own this one too
# [Moom · Many Tricks](https://manytricks.com/moom/) - don't own it



# app for monitor brightness and other control
brew install betterdisplay # Display management tool https://betterdisplay.pro/; current favorite
#brew install waydabber/betterdisplay/betterdisplaycli # [Integration features, CLI · waydabber/BetterDisplay Wiki](https://github.com/waydabber/BetterDisplay/wiki/Integration-features,-CLI); requires xcode
brew install monitorcontrol # Tool to control external monitor brightness & volume https://github.com/MonitorControl/MonitorControl
brew install lunar # monitor brightness manager; replaces flux
brew install deskpad # Virtual monitor for screen sharing https://github.com/Stengo/DeskPad

brew install displaylink # Drivers for DisplayLink docks, adapters and monitors - https://www.synaptics.com/products/displaylink-graphics

#brew tap jakehilborn/jakehilborn && brew install displayplacer # macOS command line utility to configure multi-display resolutions and arrangements.-  https://github.com/jakehilborn/displayplacer

brew install fastscripts
brew install airbuddy # monitors bluetooth devices
brew install cloudmounter # mount different cloud services
#brew install expandrive # Network drive and browser for cloud storage - https://www.expandrive.com/apps/expandrive/
brew install mountain-duck # Mounts servers and cloud storages as a disk on the desktop - https://mountainduck.io/

brew install forklift # Finder replacement and FTP, SFTP, WebDAV and Amazon s3 client - https://binarynights.com/
brew install duck # Command-line interface for Cyberduck (a multi-protocol file transfer tool) - https://duck.sh/
brew install cyberduck # Server and cloud storage browser https://cyberduck.io/

brew install zoom

brew install meetingbar # Shows the next meeting in the menu bar https://github.com/leits/MeetingBar
# alternative not in brew: [Meeter](https://www.bardeen.ai/meeter)

# retired top installs
# brew install rescuetime # no longer using
# brew install textmate # replaced by visual code


## Productivity/Office

brew install libreoffice # Free cross-platform office suite, fresh version https://www.libreoffice.org/

#brew install adium
# brew install adobe-reader -- no longer available; install manually
brew install amadeus-pro
brew install audacity

brew install busycal # 09-13-2025 I'm using them again;  I no longer use these
brew install busycontacts # 09-13-2025 I'm using them again;  I no longer use these

# cli CardDav and CalDav clients
brew install vdirsyncer # Synchronize calendars and contactsSynchronize calendars and contacts https://github.com/pimutils/vdirsyncer
brew install khard # Console carddav client https://github.com/lucc/khard



# brew install fantastical # I no longer use these
# brew install fullcontact -- no longer available
#brew install evernote # install with mas instead
#fantastical
brew install clay # Private rolodex to remember people better https://clay.earth/

brew install cron # Calendar for professionals and teams https://cron.com/

# music and audio players and organizers
# brew install aural # Audio player inspired by Winamp https://github.com/maculateConception/aural-player deprecated
# didn't work :( brew install jmc # Media organizer https://github.com/jcm93/jmc

# crashes on start - brew install clementine # Music player and library organizer https://www.clementine-player.org/
# doesn't work - brew install nightingale # Working tree for the community fork of Songbird https://getnightingale.com/

# video players
brew install elmedia-player # Free and open-source media player https://iina.io/
brew install movist-pro # Media player https://movistprime.com/
brew install iina # Free and open-source media player https://iina.io/
brew install vlc # Multimedia player https://www.videolan.org/vlc/
#brew install mpv # Media player based on MPlayer and mplayer2 https://mpv.io

brew install brave-browser # Web browser focusing on privacy https://brave.com/
brew install comet # Web browser with integrated AI assistant https://www.perplexity.ai/comet

#brew install firefox
#brew install google-chrome
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
brew install cisdem-pdf-converter-ocr # PDF Converter with OCR capability https://www.cisdem.com/pdf-converter-ocr-mac.html # alternate conversion option that I don't really use.

brew install mactex # TeX distribution for macOS https://www.tug.org/mactex/; requires 4 GB of disk space

# brew install curiosity # SwiftUI Reddit client https://github.com/Dimillian/RedditOS # easier to just use the web version

# deprecated brew install pdfpen
brew install skim # PDF reader and note-taking application https://skim-app.sourceforge.io/
brew install pdfsam-basic # Extracts pages, splits, merges, mixes and rotates PDF files https://pdfsam.org/
brew install slack
# deprecated brew install skype # use teams now.
brew install soulver # Notepad with a built-in calculator https://soulver.app/
brew install soulver-cli # Standalone cli for the Soulver calculation engine https://github.com/soulverteam/Soulver-CLI
brew install numi #Calculator and converter application https://numi.app/; costs $19.99; has raycast integration

brew install rocket # Emoji picker optimized for blind people https://matthewpalmer.net/rocket/
# [TextPal — Super-fast emoji picker for macOS](https://www.textpal.app/) is an alternate but not installable by brew

brew install sf-symbols # Apple's icon set for developers https://developer.apple.com/sf-symbols/

# brew install logitech-myharmony #  -- no longer available
brew install spotify
brew install hype # web animation program
# brew install lego-mindstorms-ev3 # not currently using
# brew install houdahgeo -- no longer available
brew install wallpaper-wizard # desktop picture app
brew install topnotch # Utility to hide the notch - https://topnotch.app/

brew install mathpix-snipping-tool # Scanner app for math and science https://mathpix.com/ 

# Markdown viewers
brew install marked
brew install mweb-pro

brew install coteditor # Plain-text editor for web pages, program source codes and more https://coteditor.com/; its scriptable

# Clipboard managers
brew install maccy # Clipboard manager https://maccy.app/ # current favorite
# deprecated brew install 1clipboard # Clipboard managing app https://1clipboard.io/
brew install pastebot # Workflow application to improve productivity https://tapbots.com/pastebot/

# brew install clop # Image, video and clipboard optimiser https://lowtechguys.com/clop/ will automatically optimize images and videos copied to the clipboard # TODO try this out


brew install cakebrew # GUI app for Homebrew https://github.com/brunophilipe/Cakebrew

#notetaking
# Notion notetaking apps - cross platform
brew install notion # Notion note taking; doesn't support offline notes well
brew install simplenote # [Create a Simplenote Account](https://app.simplenote.com/signup/) supports offline notes

# I replaced joplin with obsidian 
#brew install joplin # Note taking and to-do application with synchronization capabilities https://joplinapp.org/
#brew install joplin-cli
# brew install curio # Note-taking and organizing app https://zengobi.com/curio/

brew install tagspaces # Offline, open-source, document manager with tagging support https://www.tagspaces.org/
brew install obsidian # Knowledge base that works on top of a local folder of plain text Markdown files https://obsidian.md/

# Zotera is good complement to obsidian. It can more easily tag and organize PDF's, images, files, etc.
# see [Best tools for organizing PDFs in Obsidian - YouTube](https://www.youtube.com/watch?v=VqOc9OsMX_s)
brew install zotero # Collect, organize, cite, and share research sources https://www.zotero.org/ 

brew install tableflip # App to edit markdown files in place https://tableflipapp.com/

brew install figma # Collaborative team software https://www.figma.com/
brew install gimp # Free and open-source image editor https://www.gimp.org/

brew install imageoptim # Tool to optimise images to a smaller size https://imageoptim.com/mac

# Gmail desktop apps
# brew install kiwi-for-gmail # no longer using
brew install mimestream # new preferred Gmail desktop client
# consider also Mailplane

# Email
# mailmate
brew install --cask superhuman # paid Email client https://superhuman.com/

## Utilities
# brew install amazon-drive -- no longer available
# brew install amazon-music # need to delete folder in Applications Support and then works -- no longer supported
brew install bartender # paid Menu bar icon organiser https://www.macbartender.com/

#brew install jordanbaird-ice # free Menu bar manager https://github.com/jordanbaird/Ice # alternate free menu bar manager to consider
# trying free ice as bartender 6 is unstable.
brew install --cask jordanbaird-ice@beta # install this version for Tahoe compatiblity

brew install boom
#brew install brightness

brew install stats # Name: Stats - System monitor for the menu bar https://github.com/exelban/stats
# alternative not as good as stats though
# brew install iglance # System monitor for the status bar - https://github.com/iglance/iGlance

brew install menubar-stats # System monitor with temperature & fans plugins https://seense.com/menubarstats/
brew install hot # Name: Hot - System monitor for the menu bar [macmade/Hot: Hot is macOS menu bar application that displays the CPU speed limit due to thermal issues.](https://github.com/macmade/Hot)
# clock - no cask; same software maker [seense | The Clock for macOS](https://seense.com/the_clock/)

brew install --cask smartreporter-free # Drive failure monitoring tool - https://www.corecode.io/smartreporter/

brew install command-tab-plus #Keyboard-centric application and window switcher https://noteifyapp.com/command-tab-plus/
# quick expose - no cask; same software maker [Quick Exposé: A New Way to Use Mission Control and App Exposé on macOS • MacPlus Software](https://noteifyapp.com/quick-expose/)

# Apps to force the mac to stay awake; not go into sleep
#brew install caffeine # retired this one for one of the 2 below
brew install keepingyouawake #Name: KeepingYouAwake - Tool to prevent the system from going into sleep mode https://keepingyouawake.app/
# amphetimine is more feature reach but can't be installed by brew

brew install espanso # Name: Espanso - Cross-platform Text Expander written in Rust https://espanso.org/; replace Typinator??
brew install keyboard-maestro # Name: Keyboard Maestro - Workflow app for macOS https://www.keyboardmaestro.com/main/
brew install typinator # Text expander https://www.ergonis.com/products/typinator/

brew install raindropio # All-in-one bookmark manager https://raindrop.io/

brew install carbon-copy-cloner
# brew install crashplan -- no longer available
brew install cronnix
#brew install crossover
brew install daisydisk
brew install default-folder-x # Utility to enhance the Open and Save dialogs in applications - https://www.stclairsoft.com/DefaultFolderX/
brew install app-tamer # CPU management application - https://www.stclairsoft.com/AppTamer/
brew install disk-drill

#brew install sensei # Monitors the computer system and optimises its performance https://cindori.com/sensei # likely nice but paid product

brew install monit # Manage and monitor processes, files, directories, and devices as a widge https://mmonit.com/monit/

# new monitor to run on my 3rd monitor
brew install xrg # System monitor https://gaucho.software/Products/XRG/

# brew install disk-sensei -- no longer available
# brew install appdelete # was disabled in brew for some reason
brew install appcleaner # Application uninstaller https://freemacsoft.net/appcleaner/

# brew install bluesense # Detect the presence of your Bluetooth device https://apps.inspira.io/bluesense/ paid app I tried but don't use.

# disk-inventory-x
# omnidisksweeper
#dropbox-encore
#fluid
brew install grandperspective
# brew install growlnotify -- no longer used
# brew install notifyr # for some reason this prefpane not working on 10.12; claims Bluetooth 4.0 not supported
brew install little-snitch
#brew install macpilot
# brew install macupdate-desktop -- no longer available
brew install mactracker
# brew install rcdefaultapp -- no longer available

brew install plex-media-server
brew install plexamp # Music player focusing on visuals https://plexamp.com/ (free version started on 07-30-2023)

brew install popclip
brew install superduper
# brew install supersync
# brew install wallpaper-wizard # install via mas instead
brew install imazing
brew install handbrake # https://handbrake.fr/
brew install discord
brew install downie # [Downie - YouTube Video Downloader for macOS](https://software.charliemonroe.net/downie/)
brew install permute # [Permute - Media Converter for macOS](https://software.charliemonroe.net/permute/)
brew install betterzip
brew install onyx # free multifunction utility for system maintence
brew install screens # Control any computer from your Mac from anywhere in the world
brew install reflector # wireless screen mirroring
brew install airparrot # Streaming and Mirroring for Windows and macOS
brew install beamer # streaming from Mac
brew install timemachineeditor # Utility to change the default backup interval of Time Machine
brew install space-saver # Delete local Time Machine backups
brew install launchcontrol # Create, manage and debug system- and user services (launchctl GUI)
brew install powerphotos # powerphotos for managing photo libraries
brew install metaimage # Image metadata and geographical tag viewer & editor https://neededapps.com/metaimage/
# brew install iphoto-library-manager # replaced with powerphotos
brew install itsycal # Menu bar calendar https://www.mowglii.com/itsycal/

brew install swish # Control windows and applications right from your trackpad - https://highlyopinionated.co/swish/
brew install paletro # Command palette in any application - https://appmakes.io/paletro
brew install mission-control-plus # Manage your windows in Mission Control - https://fadel.io/MissionControlPlus
brew install batteries # Track all your devices' batteries - https://www.fadel.io/batteries/

# Bring System-level Arrange Window features to Mac - [Wins - Window Manager for Mac](https://wins.cool/) - bought but no longer using.

# free ebook reader and management software
brew install calibre # [calibre - E-book management](https://calibre-ebook.com/)
brew install fbreader # Name: FBReader book reader https://fbreader.org/macos/

# ended up not liking adobe digital editions. FBReader is slighty better, but still lookng for best epub reader
#brew install adobe-digital-editions # Name: Adobe Digital Editions https://www.adobe.com/solutions/ebook/digital-editions.html

brew install xmind # Mind mapping and brainstorming tool https://www.xmind.net/
brew install freeplane # Freeplane is a free mind mapping software written in Java - https://www.freeplane.org/

# duplicate finders
brew install photosweeper-x # Tool to eliminate similar or duplicate photos https://overmacs.com/; preferred photo
brew install gemini
# cisdem duplicate finder - [[OFFICIAL] Cisdem Duplicate Finder | Best Duplicate File Finder to Find and Remove Duplicates](https://www.cisdem.com/duplicate-finder.html); bought in https://bundlehunt.com/my-account/downloads/all

# brew install synergy-core # Synergy, the keyboard and mouse sharing tool # have to install via the websites installer for it to work well. - https://symless.com/synergy/download

brew install --cask rustdesk # Remote desktop software https://rustdesk.com/; open source alternative to TeamViewer and AnyDesk

# terminals - other than iTerm; I'm sticking with iTerm though.
#brew install kitty #GPU-based terminal emulator https://github.com/kovidgoyal/kitty
#brew install alacritty # Name: Alacritty GPU-accelerated terminal emulator (Mac and Windows) https://github.com/alacritty/alacritty/
brew install warp # Rust-based terminal app; couldn't get it to work though
brew install ghostty # Name: Ghostty - Terminal emulator with a modern design https://ghostty.com/

brew install hammerspoon # Name: Hammerspoon - Desktop automation application - https://www.hammerspoon.org/
brew install phoenix # Window and app manager scriptable with JavaScript https://github.com/kasper/phoenix/ (alternative to hammerspoon automation)

# Battery monitoring software
brew install aldente # Menu bar tool to limit maximum charging percentage https://github.com/davidwernhart/AlDente
brew install coconutbattery # Tool to show live information about the batteries in various devices https://www.coconut-flavour.com/coconutbattery/
# Battery Health 2 in mac app store
# MenuBar stats

brew install hookmark # Link and retrieve key information https://hookproductivity.com/
# install the hook cli with sudo gem install hookapp Run hook clip <file> for exmpale. See [Hook CLI - BrettTerpstra.com](https://brettterpstra.com/projects/hook-cli/) for more docs.

brew install qr-journal # Allows users with an iSight (or compatible) camera to read QR codes https://www.joshjacob.com/mac-development/qrjournal.php

# deprecated brew install tnefs-enough # Read and extract files from Microsoft TNEF files https://www.joshjacob.com/mac-development/tnef.php

# Reference: [5 Ways to Turn Any Website Into a Desktop Mac App](https://www.makeuseof.com/tag/website-desktop-mac-app/)
brew install fluid # Tool to turn a website into a desktop app - free app - https://fluidapp.com/
#brew install unite # Turn websites into apps https://bzgapps.com/unite # need to upgrade to version 4 if I want to use.

brew install obs # Open-source software for live streaming and screen recording https://obsproject.com/

# brew install camo-studio # Use your phone as a high-quality webcam with image tuning controls https://reincubate.com/camo/
# don't have a need for this but saving for reference

brew install descript # Audio and video editor https://www.descript.com/ # innovative video editor that uses text to edit video

brew install netspot # WiFi site survey software and WiFi scanner https://www.netspotapp.com/ # never upgraded my license. But unlicensed is someone useful.
# brew install inssider # Defeat slow wifi https://www.metageek.com/products/inssider/ # doesn't work on Ventura :( 

brew install breaktimer # Tool to manage periodic breaks https://breaktimer.app/

# per app sound control apps that require more permissions than I'm willing to give. And are both paid apps.
# brew install sound-control # Per-app audio controls https://staticz.com/soundcontrol/ # paid app that didn't work well for me
# brew install soundsource # Sound and audio controller https://rogueamoeba.com/soundsource/


## Development apps
brew install devutils # developer toolbox https://devutils.app/
# deprecated brew install atom
# deprecated brew install aptanastudio
# brew install aqua-data-studio # disabled as I use it rarely and it's 1 GB of space
brew install aquamacs
brew install base
brew install codekit
brew install coderunner
brew install dash
#brew install boot2docker
# brew install couchbase-server-community # commented out as it uses lots of disk space
brew install espresso
brew install github-release
brew install xquartz
brew install ngrok # sign up or login here https://ngrok.com/
#the-escapers-flux
#quicklook-json
brew install quickjson
brew install key-codes

brew install docker # Docker containerization platform https://www.docker.com/

# need to manually download version 9.1.1 of rapidweaver
#brew install rapidweaver # Web design software https://www.realmacsoftware.com/rapidweaver/

brew install expressions # regular expression app, paid
brew install latest # [Latest](https://max.codes/latest/) software update checker
brew install cisdem-document-reader # Document reader to open and view Windows-based files
brew install macpilot # Graphical user interface for the command terminal
brew install network-radar # Tool to scan and monitor the network
brew install remote-wake-up # Wake up devices with a click of a button
brew install colorwell # Color picker and color palette generator
#brew install fig # auto-complete for shell # I now use the Warp terminal instead # fig retired in September 2024
#brew install background-music # [kyleneideck/BackgroundMusic: Background Music, a macOS audio utility: automatically pause your music, set individual apps' volumes and record system audio.](https://github.com/kyleneideck/BackgroundMusic#download) # doesn't work quite right.
brew install devtoys # Utilities designed to make common development tasks easier https://github.com/DevToys-app/DevToys

#brew install phoenix-code # Code editor https://phcode.io/ interesting web site development tool. Not using it but saving here just in case.

#brew install anaconda # Distribution of the Python and R programming languages for scientific computing https://www.anaconda.com/
# brew install --cask miniconda # Anaconda alternative for Python and R programming languages https://docs.conda.io/en/latest/miniconda.html

# diff tools
# nice article comparing diff tools - [The 5 Best Mac File Comparison Tools and Diff Tools](https://www.makeuseof.com/tag/mac-file-comparison-tools/)
# delta walker is the best for me right now and I own it
brew install deltawalker # diff tool https://www.deltawalker.com/ # paid app, find/replace with regex; cli; undo/redo; export diffs
# deprecated - brew install meld # Visual diff and merge tool https://yousseb.github.io/meld/ # 3-way compare, text editor, syntax highlighting, regex
brew install dehesselle-meld # Visual diff and merge tool https://gitlab.com/dehesselle/meld_macos
brew install diffmerge # [SourceGear | DiffMerge](https://www.sourcegear.com/diffmerge/) # takes drag and drop! But giving errors when opening now for some reason
brew install direqual # Advanced directory compare utility https://naarakstudio.com/direqual/
brew install --cask visualdiffer # Visual file comparison tool https://visualdiffer.com/ free

# paid app
# brew install beyond-compare # Compare files and folders https://www.scootersoftware.com/ paid app # compare with remote servers (OneDrive, Google, ...); Table compare; scripting
# brew install kaleidoscope  # File and Folder comparison tool # paid app so removing

brew install mark-text # Simple and elegant markdown editor - https://github.com/marktext/marktext; on Windows too!

brew install powershell # Command-line shell and scripting language https://github.com/PowerShell/PowerShell

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
#brew install betterzipql         # Preview archives
brew install webpquicklook       # Preview WebP images
# deprecated # brew install qlmarkdown # [sbarex/QLMarkdown: macOS Quick Look extension for Markdown files.](https://github.com/sbarex/QLMarkdown) duplicated line from above.

#brew install facter        # cask broken # Facter gathers basic facts about systems. such as hardware, network settings, OS type and more.
#brew install sublime-text3 # cask broken # Sublime Text is a sophisticated text editor for code, markup and prose.
brew install gitup         # Visualization Tool for Git

# Data science
#brew install anaconda

# Social and Messaging

brew install telegram-a # Web client for Telegram messenger - https://web.telegram.org/a/get
brew install beeper # Universal chat app powered by Matrix - https://www.beeper.com/

brew install whatsapp # Native desktop client for WhatsApp https://www.whatsapp.com/
brew install signal # Signal is a secure messaging app for simple private communication with friends. https://signal.org/


# Games
#brew install gog-galaxy # disabling because it doesn't install well
brew install steam
brew install epic-games
brew install ea # Name: EA App Electronic Arts game launcher

brew install steamcmd
brew install teamspeak-client
# brew install minecraft-server -- no longer available
brew install minecraft
brew install prismlauncher # Minecraft launcher https://prismlauncher.org/
brew install battle-net
brew install playcover-community # Sideload iOS apps and games https://github.com/PlayCover/PlayCover never worked
#brew install bluestacks # Mobile gaming platform https://www.bluestacks.com/ play android games on mac/PC; doesn't work on M1 macs; only provdes a manual installer
# Try also [LDPlayer - Lightweight & Fast Android Emulator for PC](https://www.ldplayer.net/); no brew install # 11-12-2023 does not work

brew install porting-kit # Install games and apps compiled for Microsoft Windows https://portingkit.com/

#brew install android-studio # Tools for building Android applications https://developer.android.com/studio/ (can emulate games but didn't really work)

brew install android-file-transfer # Transfer files from and to an Android smartphone https://www.android.com/filetransfer/

brew install genymotion # Android emulator https://www.genymotion.com/
brew cask install android-platform-tools # Android SDK component https://developer.android.com/tools/releases/platform-tools

# [Heroic-Games-Launcher/HeroicGamesLauncher: A Native GOG and Epic Games Launcher for Linux, Windows and Mac.](https://github.com/Heroic-Games-Launcher/HeroicGamesLauncher#macos)
brew install heroic
# xattr -d com.apple.quarantine /Applications/Heroic.app # run this to fix the app is damaged error.

brew install onecast

brew install crossover # Tool to run Windows software https://www.codeweavers.com/products/crossover-mac/

# new best wine wrapper app
# Kegworks [Sikarugir-App/Sikarugir: A user-friendly tool used to make wine wrapped ports of Windows software for macOS.](https://github.com/Sikarugir-App/Sikarugir)
brew upgrade
brew install --cask --no-quarantine Sikarugir-App/sikarugir/sikarugir
# deprecated brew install whisky # Wine wrapper built with SwiftUI https://getwhisky.app/

# deprecated; go to website to install brew install vmware-fusion #Create, manage, and run virtual machines https://www.vmware.com/products/fusion.html

brew install drivethrurpg # DriveThruRPG app for Mac - https://www.drivethrurpg.com/product/295095/DriveThruRPG-Mac-App
# Sync DriveThruRPG libraries to compatible devices - https://www.drivethrurpg.com/library_client.php

# Free Comic Book Reader
brew install yacreader

# All-in-one live streaming software
#brew install streamlabs-obs

brew install aerial # Apple TV Aerial screensaver https://github.com/JohnCoates/Aerial

brew install netnewswire # Free and open-source RSS reader - https://netnewswire.com/

# VNC viewers and servers
# Real VNC is the easiest, but Apple Sharing doesn't support secure connections. Would require paid server for better security
# other solutions seem to work best with their own VNC server running on the remote machine.
brew install vnc-viewer # Remote desktop application focusing on security https://www.realvnc.com/
#brew install tiger-vnc # VNC viewer and server https://tigervnc.org/ # has a lot of dependencies so commenting out for now.
#brew install tigervnc-viewer # Multi-platform VNC client and server https://tigervnc.org/
#brew install turbovnc-viewer # Remote display system https://www.turbovnc.org/
# brew install jollysfastvnc # nice but is paid software

brew install keyboardcleantool # Blocks all Keyboard and TouchBar input to clean keyboard https://folivora.ai/keyboardcleantool

brew install sloth # [Sloth - Mac app that shows all open files and sockets |](https://sveinbjorn.org/sloth)
brew install alt-tab # [AltTab - Windows alt-tab on macOS](https://alt-tab-macos.netlify.app/)
brew install find-any-file # File finder https://apps.tempel.org/FindAnyFile/

#brew install stellarium # Tool to render realistic skies in real time on the screen https://stellarium.org/

# bundlehunt.com - 2024 Award Winning New Year Bundle purchase
brew install tg-pro # Temperature monitoring, fan control and diagnostics https://www.tunabellysoftware.com/tgpro/
brew install lingon-x # Automator software to start apps, run scripts or commands and more https://www.peterborgapps.com/lingon/
brew install time-out # Customizable timing of breaks https://www.dejal.com/timeout/
brew install blocs # Visual web design software https://blocsapp.com/

brew install local # WordPress local development tool by Flywheel https://localwp.com/
brew install wp-cli # Command line interface for WordPress https://wp-cli.org/
brew install wp-cli-completion # Bash completion for Wpcli https://github.com/wp-cli/wp-cli


brew install transnomino # Batch rename utility https://www.transnomino.com/


brew install horos # Medical image viewer https://horosproject.org/

# Recoll - full-text search tool for Unix/Linux systemsa
# https://github.com/nailuoGG/homebrew-recoll
# https://www.recoll.org/pages/recoll-macos.html
brew tap nailuoGG/recoll
brew install recoll

brew install microsoft-azure-storage-explorer # Explorer for Azure Storage https://azure.microsoft.com/en-us/features/storage-explorer/

# AI

# ai coding tools
npm install -g @anthropic-ai/claude-code # Command-line interface for Claude AI

# AI model serving and interactions

# [LLM: A CLI utility and Python library for interacting with Large Language Models](https://llm.datasette.io/en/stable/index.html)
pipx install llm
pipx install mlx-lm # MLX-LM is a Python library for running LLMs on macOS using the MLX framework; it provides a Python interface to the MLX framework, allowing you to run LLMs on macOS with ease.
# [Run LLMs on macOS using llm-mlx and Apple’s MLX framework](https://simonwillison.net/2025/Feb/15/llm-mlx/)
llm install llm-mlx # Install the llm-mlx model for use with the llm CLI utility; this workes with mlx-lm and llm
llm install llm-gpt4all # providing 17 models from the GPT4All project [Other models - LLM](https://llm.datasette.io/en/stable/other-models.html)

# [mlx-lm·PyPI](https://pypi.org/project/mlx-lm/)

brew install ollama # local LLM - Create, run, and share large language models (LLMs) https://ollama.com/
# To run as service: 
# To start ollama now and restart at login:
#   brew services start ollama
# Or, if you don't want/need a background service you can just run:
#   /opt/homebrew/opt/ollama/bin/ollama serve

# Local AI clients
brew install ollama-app # Get up and running with large language models locally https://ollama.com/
brew install ollamac # Mac native AI chat client https://ollama.com/
brew install lm-studio # Discover, download, and run local LLMs https://lmstudio.ai/
# has a command line. See docs for how to install: [lms — LM Studio's CLI | LM Studio Docs](https://lmstudio.ai/docs/lms)

brew install gollama # Go manage your Ollama models https://smcleod.net

brew install claude # Name: Claude Anthropic's official Claude AI desktop app
brew install chatgpt # Name: ChatGPT OpenAI's official ChatGPT desktop app
brew install gemini # Name: Gemini Google AI's official Gemini desktop app

brew install janus # AI chat client https://janusai.com/ suports local and remote LLMs
#brew install gpt4all # AI chat client https://gpt4all.com/

brew install context # [Context - Native macOS Client for Model Context Protocol](https://www.contextmcp.app/)

brew install superwhisper # Dictation tool including LLM reformatting https://superwhisper.com/
brew install wispr-flow # Voice-to-text dictation with AI-powered auto-editing https://wisprflow.ai/

brew install boltai # AI chat client https://boltai.com/
# from app store install OllmaSpring and Enchanted ai chat apps for Ollama

brew install quickwhisper # Audio transcription tool https://quickwhisper.app/

brew install cursor # Write, edit, and chat about your code with AI https://www.cursor.com/
brew install kiro # AI-powered code editor from Amazon https://kiro.ai/
brew install codex # OpenAI's coding agent that runs in your terminal https://github.com/openai/

brew install opencode # AI coding agent, built for the terminal # https://opencode.ai

brew install repo-prompt # Prompt generation tool https://repoprompt.com/

# AI image generation
brew install stability-matrix # Stable Diffusion GUI for MacOS https://stability.ai/stability-matrix
brew install diffusionbee # Name: Diffusion Bee - Stable Diffusion GUI for MacOS https://diffusionbee.com/
brew install draw-things # Name: Draw Things - Stable Diffusion GUI for MacOS https://drawthings.app/
brew install comfyui # Name: ComfyUI - Stable Diffusion GUI for MacOS https://comfyui.org/

brew install screenpipe # Name: ScreenPipe - Library to build personalized AI powered by what you've seen, said, or heard [screenpipe | computer use AI SDK](https://screenpi.pe/onboarding)

# AI camera control https://www.obsbot.com/ Configuration and firmware update utility for OBSBOT Tiny and Meet series
brew install obsbot-center 

# apps added 12-23-2024 after audit
brew install kdiff3 # File comparison and merge tool https://kdiff3.sourceforge.io/
brew install github # GitHub Desktop https://desktop.github.com/
brew install quicken # Personal finance manager https://www.quicken.com/mac
brew install popchar # Character map and font viewer https://www.ergonis.com/products/popcharx/
brew install shottr # Screenshot and screen recording tool https://shottr.com/
brew install pdf-expert # PDF editor https://pdfexpert.com/
brew install kapitainsky-rclone-browser # Rclone browser https://martins.ninja/RcloneBrowser/

brew install customshortcuts # Customise menu item keyboard shortcuts https://www.houdah.com/customShortcuts/
# [CustomShortcuts 1.0 - Free Tool to Customize Menu Shortcuts](https://blog.houdah.com/2020/06/customshortcuts-1-0-free-tool-to-customize-menu-shortcuts/)
# [Free Video Tutorial: Tip - Custom Shortcuts for macOS - Apple Mac, iPad & iPhone Tutorials from ScreenCastsOnline](https://www.screencastsonline.com/tutorials/utility-apps/tip-customshortcuts-for-macos)

brew install keyclu # Find shortcuts for any installed application https://sergii.tatarenkov.name/keyclu/support/
# works with customshortcuts

brew install skint # Check status of key security settings and features - https://eclecticlight.co/lockrattler-systhist/

brew install overview # Create live window previews for any application https://williampierce.io/overview/


brew install dataflare # Data visualization tool https://dataflare.app/

brew install yoink # Drag and drop shelf for files and snippets https://yoinkapp.com/

brew install idrive # Cloud backup service https://www.idrive.com/mac-backup

brew install mdrp # Mac DVDRipper Pro - Utility to rip and copy DVD content - https://www.macdvdripperpro.com/

# installed by brew install office?
# microsoft-auto-update
# microsoft-edge
# microsoft-teams

# installed at one pint but re-evaluating
#1password-cli
#alfred
#bettertouchtool
#fig
#google-chrome
#idrive

# stellarium
# streamlabs

# Remove outdated versions from the cellar.
brew cleanup
