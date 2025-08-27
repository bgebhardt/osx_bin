#!/bin/bash

# copy this file to you home directory.

source ~/bin/bash_profile_bin

# Check if the shell is interactive
if [[ $- == *i* ]]; then
    echo "This is an interactive shell"

    # moved my bash settings to my bin directory which is checked into git.
    # checking for warp
    if [[ $TERM_PROGRAM != "WarpTerminal" ]]; then  #TODO: split bash_profile_bin into multiple - one for item, one for warp
        source ~/bin/bash_profile_iterm
    else
        source ~/bin/bash_profile_warp
    fi

    echo "** ready **"

fi

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/bryan/.lmstudio/bin"

# Created by `pipx` on 2025-04-14 02:36:57
export PATH="$PATH:/Users/bryan/.local/bin"

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/opt/homebrew/Caskroom/miniconda/base/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/opt/homebrew/Caskroom/miniconda/base/etc/profile.d/conda.sh" ]; then
        . "/opt/homebrew/Caskroom/miniconda/base/etc/profile.d/conda.sh"
    else
        export PATH="/opt/homebrew/Caskroom/miniconda/base/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

# see [ajeetdsouza/zoxide: A smarter cd command. Supports all major shells.](https://github.com/ajeetdsouza/zoxide)
# this must be at the end of this file (zoxide requires it)
# Moved to .bash_profile so its more likely always at the end.

# Disable zoxide doctor warnings - the hook works fine with bash-preexec
export _ZO_DOCTOR=0

echo "zoxide init..."
eval "$(zoxide init bash)"