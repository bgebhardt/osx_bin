#!/usr/bin/env bash

# My brew.sh of all the brew tools I install by default. (05-22-2016)
# Inpsired by dotfiles at https://github.com/mathiasbynens/dotfiles.git

# Install command-line tools using Homebrew.

# Make sure we’re using the latest Homebrew.
brew update

# Upgrade any already-installed formulae.
brew upgrade

# Install GNU core utilities (those that come with OS X are outdated).
# Don’t forget to add `$(brew --prefix coreutils)/libexec/gnubin` to `$PATH`.
brew install coreutils
#ln -s /usr/local/bin/gsha256sum /usr/local/bin/sha256sum

# Install some other useful utilities like `sponge`.
brew install moreutils
# Install GNU `find`, `locate`, `updatedb`, and `xargs`, `g`-prefixed.
brew install findutils
# Install GNU `sed`, overwriting the built-in `sed`.
brew install gnu-sed --with-default-names
# Install Bash 4.
# Note: don’t forget to add `/usr/local/bin/bash` to `/etc/shells` before
# running `chsh`.
brew install bash
brew tap homebrew/versions
brew install bash-completion2

# TODO: 05-22-2016 decide whether to enable this
# Switch to using brew-installed bash as default shell
# if ! fgrep -q '/usr/local/bin/bash' /etc/shells; then
#   echo '/usr/local/bin/bash' | sudo tee -a /etc/shells;
#   chsh -s /usr/local/bin/bash;
# fi;

# Install `wget` with IRI support.
brew install wget --with-iri

# Install RingoJS and Narwhal.
# Note that the order in which these are installed is important;
# see http://git.io/brew-narwhal-ringo.
brew install ringojs
#brew install narwhal - 05-22-2016: removed

# Install more recent versions of some OS X tools.
brew install vim --override-system-vi
brew install homebrew/dupes/grep
# brew install homebrew/dupes/openssh # keep default ssh as it is integrated with Keychain
brew install homebrew/dupes/screen
brew install homebrew/php/php56 --with-gmp

# Install font tools.
brew tap bramstein/webfonttools
brew install sfnt2woff
brew install sfnt2woff-zopfli
brew install woff2

# Install some CTF tools; see https://github.com/ctfs/write-ups.
#brew install aircrack-ng # gets flagged as a malicious file so removing.
brew install bfg
brew install binutils
brew install binwalk
brew install cifer
brew install dex2jar
brew install dns2tcp
brew install fcrackzip
brew install foremost
brew install hydra
brew install john
brew install knock
brew install netpbm
brew install nmap
brew install pngcheck
brew install socat
brew install sqlmap
brew install tcpflow
brew install tcpreplay
brew install tcptrace
brew install ucspi-tcp # `tcpserver` etc.
brew install xpdf
brew install xz

brew install arp-scan # ARP scanning and fingerprinting tool https://github.com/royhills/arp-scan

brew install dos2unix # Convert text between DOS, UNIX, and Mac formats https://waterlan.home.xs4all.nl/dos2unix.html

# Install other useful binaries.
brew install ack
brew install dark-mode
#brew install exiv2
brew install git
brew install git-lfs
brew install bfg # Remove large files or passwords from Git history like git-filter-branch https://rtyley.github.io/bfg-repo-cleaner/
# see docs here [Removing sensitive data from a repository - GitHub Docs](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/removing-sensitive-data-from-a-repository)
brew install imagemagick
brew install lua
brew install lynx
brew install p7zip
brew install pigz
brew install pv
brew install rename
brew install rhino
brew install speedtest_cli # Command-line interface for https://speedtest.net bandwidth tests https://github.com/sivel/speedtest-cli
brew install ssh-copy-id
brew install testssl
brew install tree
brew install vbindiff
brew install webkit2png
brew install zopfli

# install python and update pip
brew install python
pip install --upgrade pip
pip install Pygments

brew install pyenv # Python version management https://github.com/pyenv/pyenv great for installing multiple versions of python
brew install pyenv-virtualenv # pyenv plugin to manage virtualenv

# other brew items I added 05-22-2016
# TODO: remove dupes from this list
brew install ansible
brew install asciidoc
#brew install boot2docker
brew install cairo
brew install cask
brew install chromedriver
brew install colordiff
brew install couchdb
brew install csshx
brew install dependency-check
brew install diffutils
brew install docbook
brew install docker
brew install elasticsearch
brew install emacs
brew install erlang
brew install flow
brew install fontconfig
brew install fpp
brew install freetype
brew install gawk
brew install gcc
brew install gdbm
brew install gettext
brew install git
brew install git-extras
brew install gh # gitbug cli - https://cli.github.com/
brew install glib
brew install gmp
brew install gnu-sed
brew install gnu-tar
brew install gnu-which
brew install gradle
brew install grails
brew install graphicsmagick
brew install graphviz
brew install grep
#brew install groovy # 09-14-2023: removed as I don't use this and it wouldn't update.
brew install gzip
brew install htop-osx
brew install httpie
brew install hub # github command line wrapper
brew install icdiff
brew install icu4c
brew install isl
brew install jpeg
brew install jq
brew install Caskroom/cask/kdiff3
brew install less
brew install libevent
brew install libffi
brew install libmpc
brew install libpng
brew install libtiff
brew install libtool
brew install libyaml
brew install logstash
brew install lynx
brew install memcached
brew install mongodb
brew install moreutils
brew install mpfr
brew install mr
brew install multimarkdown
brew install multitail
brew install mysql
brew install node
brew install nspr
# brew install openssl # disabling as default  Mac OS ssh has keychain support
brew install pandoc
brew install pcre
brew install pixman
brew install pkg-config
brew install qt
brew install r
# brew install homebrew/science/r-gui  # no longer using this
brew install readline
brew install redis
brew install rsync # Utility that provides fast incremental file transfer https://rsync.samba.org/
brew install rsync-time-backup # Time Machine-style backup for the terminal using rsync https://github.com/laurent22/rsync-time-backup
brew install rclone # Rsync for cloud storage https://rclone.org/
brew install --cask kapitainsky-rclone-browser # GUI for rclone https://github.com/kapitainsky/RcloneBrowser
brew install duck # Command-line interface for Cyberduck (a multi-protocol file transfer tool) https://duck.sh/ (can be scripted)
brew install fswatch # Monitor a directory for changes and run a shell command https://github.com/emcrisostomo/fswatch
brew install sbt
brew install scala
brew install shellcheck
brew install spark
brew install spidermonkey
brew install sqlite
brew install ssh-copy-id
brew install sslscan
brew install subversion
brew install tig
brew install tree
brew install the_silver_searcher # fast source code searching with "ag"
brew install unixodbc
brew install vim
brew install wdiff
brew install wget
brew install wxmac
brew install xz
brew install z
brew install zsh
brew install zsh-completions
brew install zsh-history-substring-search
brew install zsh-lovers
brew install zsh-syntax-highlighting
brew install tcpstat
brew install tcptrack # trouble downloading from tcptrace.org
brew install ssldump
brew install fetchmail
brew install procmail

brew install tldr # Simplified and community-driven man pages - https://tldr.sh/
brew install starship # Cross-shell prompt for astronauts - https://starship.rs

brew install rich-cli # Command-line toolbox for fancy output in the terminal https://github.com/textualize/rich-cli

# cloud tools
# brew install heroku - as of 2018 we no longer use heroku
brew install azure-cli


# 09-04-2016 added to make EmptyEpsilon work
# https://github.com/oznogon/EmptyEpsilon/issues/7
brew install sfml

# 10-09-2016 added...

# Development tools (no longer in brew)
#brew install eclipse-jee       # Eclipse IDE for Java EE Developers # potenitally can install as a cask now
#brew install sts              # Spring Tool Suite
#brew install intellij-idea-ce # IntelliJ IDEA Community Edition
#brew install intellij-idea    # IntelliJ IDEA Enterprise Edition

brew install gradle           # Build system based on the Groovy language
brew install groovy           # Groovy: a Java-based scripting language
brew install maven             # Java-based project management
brew install maven-completion  # maven-bash-completion

brew install jenkins            # CI Server
brew install sonar              # Static Code Analysis Tool
 
#brew install docker-machine     # installs Docker, then configures the Docker client to talk to them
#brew install docker-compose     # tool for defining and running multi-container applications with Docker
#brew install docker-swarm       # Turn a pool of Docker hosts into a single, virtual host

# 10-19-16
brew install mas # Install App Store command line tools https://github.com/mas-cli/mas
brew install reattach-to-user-namespace # work around for tmux-related pastboard problems (helps mas) https://github.com/ChrisJohnsen/tmux-MacOSX-pasteboard

brew install duti # Select default apps for documents and URL schemes on macOS - https://github.com/moretension/duti/

# kubernetes tools
brew install kubernetes-cli

# [kubectx: a tool to switch between Kubernetes contexts](https://ahmet.im/blog/kubectx/)
brew install kubectx

# kafka cli, etc.
brew install kafka

brew install spark

# install node
brew install node
brew install npm

# install go
brew install go

# install pandoc to convert markdown to various formats
brew install pandoc

# Recall what you did on the last working day. Psst! or be nosy and find what someone else in your team did ;-)
# https://github.com/kamranahmedse/git-standup
brew install git-standup

# install handbrake as bin/HandBrakeCLI command line - https://handbrake.fr/
brew install handbrake

# switch audio allows switching sound outputs from the command line
brew install switchaudio-osx

# data science
brew install jupyter
brew install nbdime # diffing and merging of Jupyter Notebooks
# brew install ipykernel # kernel needed to run jupyter notebooks

brew install pipx # Execute binaries from Python packages in isolated environments https://pipx.pypa.io

# groups bandwidth by process.
# [raboof/nethogs: Linux 'net top' tool](https://github.com/raboof/nethogs)
brew install nethogs

# Terminal based graphical activity monitor inspired by gtop and vtop - https://github.com/xxxserxxx/gotop
brew install gotop

# [imsnif/bandwhich: Terminal bandwidth utilization tool](https://github.com/imsnif/bandwhich)
brew install bandwhich

# network scanner
brew install nmap

# Simple, fast and user-friendly alternative to find - https://github.com/sharkdp/fd
brew install fd

# Cmdline tool - Monitors sleep, wakeup, and idleness of a Mac - https://www.bernhard-baehr.de/
brew install sleepwatcher

brew install wifi-password # Show the current WiFi network password https://github.com/rauchg/wifi-password
brew install youtube-dl # Download YouTube videos from the command-line https://youtube-dl.org/
brew install pwgen # Password generator https://pwgen.sourceforge.io/
brew install mplayer # UNIX movie player https://mplayerhq.hu/
brew install asciinema # Record and share terminal sessions https://asciinema.org

brew install diff-pdf # Visually compare two PDF files https://vslavik.github.io/diff-pdf/
brew install pdfgrep # Search PDFs for strings matching a regular expression https://pdfgrep.org/
brew install poppler # PDF rendering library (based on the xpdf-3.0 code base) https://poppler.freedesktop.org/
brew install jpdfbookmarks # Create and edit bookmarks on existing PDF files https://sourceforge.net/projects/jpdfbookmarks/

# brew install pdftk-java # Port of pdftk in java; pdftk provides lots of pdf cli tools. https://gitlab.com/pdftk-java/pdftk
# looks like it requires java 11 which I don't have installed.
# Trying the non-java original - brew install pdftk-java instead [PDFtk Server Manual](https://www.pdflabs.com/docs/pdftk-man-page/)

# Terminal multiplexer - https://tmux.github.io/
# [Tmux Cheat Sheet & Quick Reference](https://tmuxcheatsheet.com/)
brew install tmux

brew install ncdu # NCurses Disk Usage https://dev.yorhel.nl/ncdu

brew install cmatrix # Console Matrix (like the movie Marix) https://github.com/abishekvashok/cmatrix/

brew install blueutil # Get/set bluetooth power and discoverable state [toy/blueutil: CLI for bluetooth on OSX: power, discoverable state, list, inquire devices, connect, info, …](https://github.com/toy/blueutil)

brew install tesseract # OCR (Optical Character Recognition) engine https://github.com/tesseract-ocr/

brew install s-search # Web search from the terminal https://github.com/zquestz/s

brew install shfmt # Autoformat shell script source code https://github.com/mvdan/sh
brew install shellcheck # Static analysis and linting tool for sh/bash scripts https://www.shellcheck.net/

# Remove outdated versions from the cellar.
brew cleanup
