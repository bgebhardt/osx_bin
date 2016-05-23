## Overview
This sets up the bin directory and bash profile in the way I like it.  Special thanks to:

* [barryclark/bashstrap: A quick way to spruce up your terminal in OSX.]( https://github.com/barryclark/bashstrap )
* [mathiasbynens/dotfiles: .files, including ~/.osx — sensible hacker defaults for OS X]( https://github.com/mathiasbynens/dotfiles )
* [alebcay/awesome-shell: A curated list of awesome command-line frameworks, toolkits, guides and gizmos. Inspired by awesome-php.]( https://github.com/alebcay/awesome-shell ) - great list of shell commands

## Installation
Make sure a ~/bin directory does not exist.  It will clone the repository to your home directory.

To install run the following:

``` shell
mv ~/bin ~/bin_bak
git clone https://github.com/bgebhardt/osx_bin.git ~/bin
cp -i ~/bin/.bash_profile ~/
cp -i ~/bin/.bashrc ~/
```

Now clone in the tools you need. Some are refrenced by osx_bin
```
~/bin/gitclone.sh
chmod a+x ~/bin/bashstrap/z.sh # need to make sure this is executable
```

> Add all tools cloned directly from git. (Note these are also in the .gitignore).  The proper way would be with [submodules](https://git-scm.com/book/en/v2/Git-Tools-Submodules), but I'm lazy at the moment.


## Install other tools
Install common brew tools.
```
~/.bin/brew.sh 
```
> This will take quite a while.
