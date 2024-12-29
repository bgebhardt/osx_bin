# a file containing all my aliases -- Bryan (3/18/2002)

# key aliases

# Enable aliases to be sudo’ed
alias sudo='sudo '

# eza ls and tree replacement
alias ls="eza"
alias tree="eza -T"

# zoxide replacement for cd
alias cd=z

# old LS configs, replaced with color eza
# Color LS
# colorflag="-G"
# alias ls="command ls ${colorflag}"
# alias l="ls -lF ${colorflag}" # all files, in long format
# alias la="ls -laF ${colorflag}" # all files inc dotfiles, in long format
# alias lsd='ls -lF ${colorflag} | grep "^d"' # only directories

# Quicker navigation
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."

alias rm="rm -i"
# the remove script will move the file to the Trash (like the finder does)
#  (added 4/14/03)
# commented out this script as it didn't seem to be working quite right.
#alias rm="~/bin/rm -i"

alias mv="mv -i"
alias cp="cp -i"
alias t=telnet
#alias l="ls -l"
alias so=source
alias more=less

# causes less to not clear the screen (at least in most terminals)
alias less="less -X"

alias ftp=ncftp

# make nano default to not wrap lines
alias nano="nano --nowrap"

# make pico nano
alias pico=nano

alias odd1="od --width=8 -t d1"

# Open specified files in Markdown Pro for markdown editing
# "s ." will open the current directory in Sublime
alias md='open -a "Markdown Pro"'


# dirs -l is faster than pwd in C-shell
#alias pwd="dirs -l"

# useful stuff for reading and converting hex values.
#  currently don't have hex2bin.  Ask jim for it.  :)
alias hexchardump="od -v -A n -t xC #\!*"
#alias hex2bin=/staff/jim/bin/hex2bin (reimplement this)

# xterm alias
alias xterm="xterm -bg black -fg yellow -sl 1000 +sb"

## TO DO:  more on complete for ssh and telnet to common hosts

# set the title for an xterm
# doesn't work in warp terminal to commenting out
#alias title='echo "]0;\!*"'

# cvs-related aliases
#alias shortstat='cvs status \!* | grep "File:"'
#alias smallstat='cvs status \!* | grep "File:" | grep -v "Up-to-date"'
#alias smstattofile='cvs status \!* | grep "File:" | grep -v "Up-to-date" > cvs-stat-temp'

# cmd line printing-related
#alias enscript="enscript -P sfo-prn301 -2Gr -h"

# make an alias for setting an xterm's window title to the current host
#if $?term then
#  if ($term == "xterm") then
#    	alias sethost	'echo "]0;"$HOST"\!*"'
#  endif
#endif

# make an alias for setting an xterm's window title to the remote host
#if $?remotehost then # <== this if doesn't work!
#   if $?term then
#     if ($term == "xterm") then
#	alias setremotehost	'echo "]0;"$REMOTEHOST"\!*"'
#     endif
#   endif
#endif

# set the bye command to also set the window title if it is an xterm.
#if $?remotehost then # <== this if doesn't work!
#  if $?term then
#    if ($term == "xterm") then
#    	alias bye	'setremotehost; exit'
#    else
#	alias bye 	exit
#   endif
#  endif
#endif

# ps with grep.  Shows headers of ps without the grep.
#alias psg="/usr/ucb/ps -axlgww | egrep 'PPID|\!*' | grep -v grep"
alias psg="ps -axlgww | egrep 'PPID|\!*' | grep -v grep"

# ps with grep that returns the process id
alias psg_pid='ps -axc | grep "\!*" | grep -v "grep" | cut -d" " -f3'

# shorthand for the find command
alias find.="find . -name \!* "

# aliases to scripts that will list finder windows and cd to any of them.
# added 3/25/03
alias finder_cd='cd "`~/bin/finder_win_path.sh \!*`"'
alias finder_wins="'osascript ~/bin/list_finder_windows.scpt'"

# dos, unix, and mac text file translation aliases.
# NOT TESTED.  DON'T SEEM TO WORK.
#alias dos2mac=tr "\r\n" "\r"
#alias mac2dos=tr "\r" "\r\n"
#alias dos2unix="tr -d '\r'"
alias mac2unix='tr \"\\r\" \"\\n\"'
alias unix2mac='tr \"\\n\" \"\\r\"'
#alias unix2dos=tr "\n" "\r\n"

# alias to fix a quicken file
# For reference here's the output of GetFileInfo on the file.
#% GetFileInfo stmt.qfx
#file: "stmt.qfx"
#type: "WBCN"
#creator: "INTU"
#attributes: avbstclinmed
#created: 04/27/2003 17:05:20
#modified: 04/27/2003 17:05:22
alias fix_quicken_file="/Developer/Tools/SetFile -c INTU -t WBCN \!*"

# wget alias to grab a web page
alias my_wget="wget -E -k -K -p"

# simple alias to get to the IP.  Could be made MUCH better!
alias print_ips="ifconfig -a inet | grep -A 1 en.:"

# running top without memory checking to reduce it's CPU usage from ~15% to ~1%
# see macosxhints:
# http://www.macosxhints.com/article.php?story=20040213045335693
alias ttop="'top -ocpu -R -F -s 2 -n30'"

# TextMate aliases
# added 11-30-07
alias matedir="mate . &"
alias materail="mate app config lib db public test vendor/plugins &"

# -------------
# Machine aliases
alias csua="sshfast bryang@csua.berkeley.edu"
alias ziggy="sshfast bryang@anybrowser.org"
# automatically include X forwarding.
#alias winkops1="ssh -X bryan@winkops1.wink.com"

# function to do an ssh
# tip found here: http://my.brandeis.edu/bboard/q-and-a-fetch-msg?msg_id=00046x
vsn () { if [ $# = 1 ]; then ssh "vsnuser@$1"; fi }

# alias to copy pwd to the clipboard
alias ppwd="pwd | pbcopy"

alias p="pwd"
alias pc="ppwd"

alias h="history"

# git related aliases
# function inspired by http://stackoverflow.com/questions/7131670/make-bash-alias-that-takes-parameter. 11-20-2015
# call it passing in `pwd` to do current directory (need to make this better)
function git-pull-all-func { find $1 -type d -name .git | xargs -n 1 dirname | sort | while read line; do echo $line && cd $line && git pull .; done; }
alias git-pull-all=git-pull-all-func

# recommended curl output from https://github.com/wickett/curl-trace
alias curl-trace='curl -w "@/Users/bgebhardt/bin/curl-trace/templates/.curl-format" -o /dev/null -s'

alias maven="mvn"

# Git aliases
# You must install Git first
alias gs='git status'
alias ga='git add ' # requires passing in the file(s)
alias gd='git diff' # requires passing in the file(s)
alias gc='git commit'
alias gp='git push'
alias gf='git fetch'
alias gi='git info'
alias grm='git rm $(git ls-files --deleted)'
alias git_url='git remote show origin | grep Fetch' # will get the repo's url, can pass to pbcopy

# Colored up cat!
# You must install Pygments first - "sudo easy_install Pygments"
alias c='pygmentize -O style=monokai -f console256 -g'

# pycharm alias.  More info on how to work with pycharm from the cmd line
# https://www.jetbrains.com/help/pycharm/2016.3/working-with-pycharm-features-from-command-line.html#d473342e17
alias pycharm='/Applications/PyCharm.app/Contents/MacOS/pycharm'

# postgres convienence commands
alias pgstart='pg_ctl -D /usr/local/var/postgres -l /usr/local/var/postgres/server.log start'
alias pgstop='pg_ctl -D /usr/local/var/postgres stop'

# https://github.com/github/hub
# Wrap git automatically by adding the following to ~/.bash_profile:
eval "$(hub alias -s)"
