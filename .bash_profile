# Fig pre block. Keep at the top of this file.
[[ -f "$HOME/.fig/shell/bash_profile.pre.bash" ]] && builtin source "$HOME/.fig/shell/bash_profile.pre.bash"
#!/bin/bash

# copy this file to you home directory.

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

fi

# this must be at the end of this file (zoxide requires it)
source ~/bin/bash_profile_bin

echo "** ready **"

# RETIRED - I no longer use fig
# Fig post block. Keep at the bottom of this file.
#[[ -f "$HOME/.fig/shell/bash_profile.post.bash" ]] && builtin source "$HOME/.fig/shell/bash_profile.post.bash"