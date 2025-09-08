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

# Favorites

brew install zoxide # A smarter cd command for navigating your filesystem.
brew install eza # A modern replacement for `ls` with more features and better defaults.
brew install bat # A cat clone with syntax highlighting and Git integration.
brew install fzf # A general-purpose command-line fuzzy finder.
brew install television # General purpose fuzzy finder TUI https://github.com/alexpasmantier/television
brew install delta # A viewer for git and diff output.
brew install diffoscope # In-depth comparison of files, archives, and directories can output in friendly HTML https://diffoscope.org

brew install fd # Simple, fast and user-friendly alternative to find - https://github.com/sharkdp/fd
brew install fselect # Find files with SQL-like queries https://github.com/jhspetersson/fselect https://github.com/jhspetersson/fselect/blob/master/docs/usage.md
brew install tldr # Simplified and community-driven man pages - https://tldr.sh/
brew install btop # A resource monitor that shows usage and stats for processor, memory, disks, network & processes.
brew install jq # Lightweight and flexible command-line JSON processor https://stedolan.github.io/jq/
brew install jql # JSON query language CLI tool https://github.com/yamafaktory/jql
brew install sq # Data wrangler with jq-like query language https://sq.io
brew install nao1215/tap/sqly # sqly - execute SQL against CSV, TSV, LTSV, JSON, and even Microsoft Excel™ files brew install https://github.com/nao1215/sqly
brew install less # Pager program similar to more (1) but with support for windows and binary files https://www.greenwoodsoftware.com/less/

brew tap Hyde46/hoard
brew install hoard # Hoard is a command-line tool that helps you manage your dotfiles and other configuration files. https://github.com/Hyde46/hoard

# File Management

brew install rmlint # Tool to find and remove duplicate files and other lint from your filesystem. https://rmlint.readthedocs.io/
brew install rsync # Utility that provides fast incremental file transfer https://rsync.samba.org/
brew install rsync-time-backup # Time Machine-style backup for the terminal using rsync https://github.com/laurent22/rsync-time-backup
brew install rclone # Rsync for cloud storage https://rclone.org/
brew install --cask kapitainsky-rclone-browser # GUI for rclone https://github.com/kapitainsky/RcloneBrowser
brew install duck # Command-line interface for Cyberduck (a multi-protocol file transfer tool) https://duck.sh/ (can be scripted)
brew install fswatch # Monitor a directory for changes and run a shell command https://github.com/emcrisostomo/fswatch

# Additional Tools

brew install ripgrep # command is "rg" A line-oriented search tool that recursively searches your current directory for a regex pattern. https://github.com/BurntSushi/ripgrep
brew install ripgrep-all # command is "rga" ripgrep-all is a wrapper around ripgrep that adds support for searching inside binary files, PDFs, and other file formats. https://github.com/phiresky/ripgrep-all, https://phiresky.github.io/blog/2019/rga--ripgrep-for-zip-targz-docx-odt-epub-jpg/

brew install yadm # A tool for managing dotfiles.
brew install direnv # An environment switcher for the shell.
brew install thefuck # Corrects errors in previous console commands.
#brew install wget # A network utility to retrieve files from the web.
# Terminal multiplexer - https://tmux.github.io/
# [Tmux Cheat Sheet & Quick Reference](https://tmuxcheatsheet.com/)
brew install tmux # A terminal multiplexer that allows multiple terminal sessions to be accessed simultaneously.
brew install tree # A recursive directory listing command that produces a depth-indented listing of files. Use exa instead.

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
#brew install narwhal # 05-22-2016: removed

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
brew install vbindiff
brew install webkit2png
brew install zopfli

# install python and update pip
brew install python
pip install --upgrade pip
pip install Pygments

brew install pyenv # Python version management https://github.com/pyenv/pyenv great for installing multiple versions of python
brew install pyenv-virtualenv # pyenv plugin to manage virtualenv

brew install uv # Extremely fast Python package installer and resolver, written in Rust https://docs.astral.sh/uv/


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
brew install docker # Docker is a platform for developing, shipping, and running applications in containers. https://www.docker.com/
brew install docker-compose # Docker Compose is a tool for defining and running multi-container Docker applications.
# Compose is a Docker plugin. For Docker to find the plugin, add "cliPluginsExtraDirs" to ~/.docker/config.json:
#   "cliPluginsExtraDirs": [
#       "/opt/homebrew/lib/docker/cli-plugins"
#   ]

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
brew install httpie # HTTP client for the terminal https://httpie.org/
brew install atac # Simple API client (Postman-like) in your terminal https://atac.julien-cpsn.com/
brew install monolith # CLI tool for saving complete web pages as a single HTML file https://github.com/Y2Z/monolith

brew install hub # github command line wrapper
brew install icdiff # Improved colored diff https://www.jefftk.com/icdiff
brew install icu4c
brew install isl
brew install jpeg
brew install Caskroom/cask/kdiff3
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
brew install sbt
brew install scala
brew install shellcheck
brew install spark
brew install spidermonkey
brew install sqlite
brew install sslscan
brew install subversion
brew install tig
brew install the_silver_searcher # fast source code searching with "ag"
brew install unixodbc
brew install vim
brew install wdiff
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

#brew install starship # Cross-shell prompt for astronauts - https://starship.rs

brew install rich-cli # Command-line toolbox for fancy output in the terminal https://github.com/textualize/rich-cli

# cloud tools
# brew install heroku - as of 2018 we no longer use heroku
brew install azure-cli
brew install doctl 

# The official command line interface for DigitalOcean

# IONOS CLI is a command line interface for IONOS Cloud and IONOS Managed Kubernetes
brew tap ionos-cloud/homebrew-ionos-cloud
brew install ionosctl

# S3 stroage commands
brew install s3cmd # Command-line tool for the Amazon S3 service https://s3tools.org/s3cmd
brew install s4cmd # Super S3 command-line tool https://github.com/bloomreach/s4cmd (adds multi-threading, parallel uploads, path handling, and more)

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
brew install node # Node.js is a JavaScript runtime built on Chrome's V8 JavaScript engine. https://nodejs.org/en/
brew install npm # npm is a package manager for JavaScript and the world's largest software registry. https://www.npmjs.com/ 
brew install nvm # Node Version Manager - a version manager for Node.js, designed to be installed per-user, and invoked per-shell.
brew install pnpm # pnpm is a fast, disk space-efficient package manager https://pnpm.io/

brew install oven-sh/bun/bun # Bun is a fast all-in-one JavaScript runtime - https://bun.sh/

# install go
brew install go

# install pandoc to convert markdown to various formats
brew install pandoc

brew install davep/homebrew/hike # Hike is a Markdown browser for the terminal. https://terminaltrove.com/hike/ https://github.com/davep/hike 

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

# ai coding tools
npm install -g @anthropic-ai/claude-code # Command-line interface for Claude AI

brew install pipx # Execute binaries from Python packages in isolated environments https://pipx.pypa.io
pipx ensurepath # need to run this after installing pipx to add it to the PATH
brew install poetry # Python dependency management and packaging made easy https://python-poetry.org/

# resource usage tools

# cli resource usage tools
brew install htop-osx # Improved top (interactive process viewer) https://hisham.hm/htop/
brew install btop # A resource monitor that shows usage and stats for processor, memory, disks, network & processes. [aristocratos/btop: A monitor of resources](https://github.com/aristocratos/btop)
brew install glances # Cross-platform system monitoring tool https://nicolargo.github.io/glances/
brew install iftop # Display bandwidth usage on an interface
brew install nload # Network traffic and bandwidth usage monitor
brew install nethogs # Monitor network traffic per process

# groups bandwidth by process.
# [raboof/nethogs: Linux 'net top' tool](https://github.com/raboof/nethogs)
brew install nethogs

# Terminal based graphical activity monitor inspired by gtop and vtop - https://github.com/xxxserxxx/gotop
brew install gotop

# [imsnif/bandwhich: Terminal bandwidth utilization tool](https://github.com/imsnif/bandwhich)
brew install bandwhich

# network scanner
brew install nmap

brew install gping # Ping, but with a graph https://github.com/orf/gping

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

brew install ncdu # NCurses Disk Usage https://dev.yorhel.nl/ncdu

brew install cmatrix # Console Matrix (like the movie Marix) https://github.com/abishekvashok/cmatrix/
brew install sontek/snowmachine/snowmachine # Snowmachine is a command-line tool that generates a snow effect in the terminal. https://github.com/sontek/snowmachine

brew install blueutil # Get/set bluetooth power and discoverable state [toy/blueutil: CLI for bluetooth on OSX: power, discoverable state, list, inquire devices, connect, info, …](https://github.com/toy/blueutil)

brew install tesseract # OCR (Optical Character Recognition) engine https://github.com/tesseract-ocr/

brew install s-search # Web search from the terminal https://github.com/zquestz/s

brew install shfmt # Autoformat shell script source code https://github.com/mvdan/sh
brew install shellcheck # Static analysis and linting tool for sh/bash scripts https://www.shellcheck.net/

#brew install corelocationcli # CoreLocationCLI is a command-line tool that provides location information from CoreLocation. https://github.com/fulldecent/corelocationcli

# [GitHub - ebullient/ttrpg-convert-cli: Utility to convert JSON data (for content you own) from 5etools or pf2etools into Obsidian-friendly Markdown.](https://github.com/ebullient/ttrpg-convert-cli/tree/main)
brew tap ebullient/tap
brew install ttrpg-convert-cli


#brew install trash # Move files to the trash instead of deleting them permanently; not needed as this command is built into macOS now.
brew install midnight-commander # Midnight Commander is a visual file manager, similar to Norton Commander. https://midnight-commander.org/

brew install harfbuzz # An OpenType text shaping engine https://harfbuzz.github.io/

# Remove outdated versions from the cellar.
brew cleanup
