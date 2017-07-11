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
brew install aircrack-ng
brew install bfg
brew install binutils
brew install binwalk
brew install cifer
brew install dex2jar
brew install dns2tcp
brew install fcrackzip
brew install foremost
brew install hashpump
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

# Install other useful binaries.
brew install ack
brew install dark-mode
#brew install exiv2
brew install git
brew install git-lfs
brew install imagemagick --with-webp
brew install lua
brew install lynx
brew install p7zip
brew install pigz
brew install pv
brew install rename
brew install rhino
brew install speedtest_cli
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

# other brew items I added 05-22-2016
# TODO: remove dupes from this list
brew install ansible
brew install asciidoc
brew install boot2docker
brew install cairo
brew install cask
brew install chromedriver
brew install colordiff
brew install coreutils
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
brew install groovy
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
brew install rsync
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
brew install vagrant-completion
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

# cloud tools
brew install heroku
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
 
brew install docker-machine     # installs Docker, then configures the Docker client to talk to them
brew install docker-compose     # tool for defining and running multi-container applications with Docker
brew install docker-swarm       # Turn a pool of Docker hosts into a single, virtual host

# 10-19-16
brew install mas # Install App Store command line tools https://github.com/mas-cli/mas
brew install reattach-to-user-namespace # work around for tmux-related pastboard problems (helps mas) https://github.com/ChrisJohnsen/tmux-MacOSX-pasteboard

# kafka cli, etc.
brew install kafka

brew install spark

# install node
brew install node
brew install npm

# install pandoc to convert markdown to various formats
brew install pandoc

# Recall what you did on the last working day. Psst! or be nosy and find what someone else in your team did ;-)
# https://github.com/kamranahmedse/git-standup
brew install git-standup

# Remove outdated versions from the cellar.
brew cleanup
