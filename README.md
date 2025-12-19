## Overview
This sets up the bin directory and bash profile in the way I like it.  Special thanks to:

* [barryclark/bashstrap: A quick way to spruce up your terminal in OSX.]( https://github.com/barryclark/bashstrap )
* [mathiasbynens/dotfiles: .files, including ~/.osx — sensible hacker defaults for OS X]( https://github.com/mathiasbynens/dotfiles )
* [alebcay/awesome-shell: A curated list of awesome command-line frameworks, toolkits, guides and gizmos. Inspired by awesome-php.]( https://github.com/alebcay/awesome-shell ) - great list of shell commands

# Minimum Install: Bare Minimum to get up and running

**brew**

Install brew from [Homebrew — The missing package manager for OS X]( http://brew.sh/ )

```shell
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

## Installation of base bin and setting up your bash shell
Make sure a ~/bin directory does not exist.  It will clone the repository to your home directory.

``` shell
mv ~/bin ~/bin_bak
git clone https://github.com/bgebhardt/osx_bin.git ~/bin
cp -i ~/bin/.bash_profile ~/
cp -i ~/bin/.bashrc ~/
```

In Terminal set your profile to Homebrew for the colors to work.

To finish setting up bash install run the following:

Set up "gh" and login to your git account. Fun this and follow the prompts to login.
``` shell
brew install gh
gh auth login
```

Run `brew install gh` to Add better GitHub support to git on the command-line
Run `brew install hub` to Add GitHub support to git on the command-line (https://hub.github.com/)


Now clone in the tools you need. Some are referenced by osx_bin
``` shell
~/bin/gitclone.sh
chmod a+x ~/bin/bashstrap/z.sh # need to make sure this is executable
```

> Add all tools cloned directly from git. (Note these are also in the .gitignore).  The proper way would be with [submodules](https://git-scm.com/book/en/v2/Git-Tools-Submodules), but I'm lazy at the moment.


In iTerm2 select iTerm2>Install Shell Integration  (see https://iterm2.com/documentation-shell-integration.html)

**cask** for installing key mac apps

You can install a minimum set of my favorite apps by running:
``` shell
~/bin/setup/brew-cask-minimum.sh 
```

# Set up a new computer from scratch

If Setting up a new Computer from scratch refer to the [README](setup/README.md) in the setup directory.

# Complete Install

To install everything else make sure you have the prerequisites and then you can run the scripts in the install section.

## Prerequisites

**Python**

Install Python with brew.  (Also installed by brew.sh.)
And upgrade pip while you're at it
```shell
brew install python
pip install --upgrade pip 
pip install Pygments
```

You can also install Python from its downloadable installer at [Download Python at Python.org]( https://www.python.org/downloads/ )

**Java**

Preferred approach is to use cask

```shell
brew cask install java
```

Install Java from here: [Download Java for Mac OS X]( http://www.java.com/en/download/mac_download.jsp )

> [How do I install Java for my Mac?]( https://www.java.com/en/download/help/mac_install.xml )

**JDK**

You also need the Java Development Kit (JDK) at [Java SE Development Kit 8 - Downloads]( http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html )

TODO: document installation with Cask

## Install other tools
Install common brew tools.
```
~/bin/setup/homebrew/brew.sh 
```
> This will take quite a while.  This may also fail if brew hits your maximum github API requests.  Wait for an hour and try again.

Install Apple Store apps I use via the very cool mas CLI for App Store.  Requires mas be installed with brew (done by brew.sh)
```
~/bin/setup/mas.sh 
```
> This will take quite a while.

Install common python packages and tools.
```
~/bin/setup/python.sh 
```
> This will take quite a while.

Install common node npm packages and tools.
```
~/bin/setup/npm.sh 
```
> This will take quite a while.


## Install and Configure Development Tools

### PyCharm CE

1.  Install PyCharm CE edition
1. Import settings in your Dropbox

### Visual Studio Code

Install [Visual Studio Code Settings Sync]( https://marketplace.visualstudio.com/items?itemName=Shan.code-settings-sync ) from the Visual Studio Marketplace.  Use token and gist id from you password store.


### Eclipse and STS

TBD

**TODO**

* create a setup script for r.  Currently just have a list of all R modules I have installed.
* create python virtualenv setups
