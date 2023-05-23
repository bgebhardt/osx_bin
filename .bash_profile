# Fig pre block. Keep at the top of this file.
[[ -f "$HOME/.fig/shell/bash_profile.pre.bash" ]] && builtin source "$HOME/.fig/shell/bash_profile.pre.bash"
#!/bin/bash

# copy this file to you home directory.

echo "sourcing bash_profile..."

# moved my bash settings to my bin directory which is checked into git.
source ~/bin/bash_profile_bin

# set up homebrew environment
eval "$(/opt/homebrew/bin/brew shellenv)"

# export PATH="/opt/homebrew/sbin:$PATH"

test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash"

# Fig post block. Keep at the bottom of this file.
[[ -f "$HOME/.fig/shell/bash_profile.post.bash" ]] && builtin source "$HOME/.fig/shell/bash_profile.post.bash"