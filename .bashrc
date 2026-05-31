# Fig pre block. Keep at the top of this file.
[[ -f "$HOME/.fig/shell/bashrc.pre.bash" ]] && builtin source "$HOME/.fig/shell/bashrc.pre.bash"

# *** NOTE: this file is no longer used. Edit .bash_profile instead. (I'm not sure why.) ***

# only print in interactive shells.
if [[ $- == *i* ]]; then echo "sourcing .bashrc..."; fi

# Nothing to see here — Everything's in .bash_profile
[ -n "$PS1" ] && source ~/.bash_profile


# Fig post block. Keep at the bottom of this file.
[[ -f "$HOME/.fig/shell/bashrc.post.bash" ]] && builtin source "$HOME/.fig/shell/bashrc.post.bash"