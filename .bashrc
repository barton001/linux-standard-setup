# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# User specific aliases and functions
alias disks="df -h | grep -v 'tmpfs'"
alias la='ls -a'
alias l='less'

alias sshbhb='ssh -p 2222 barton01@bhbsoftware.com'
alias sshpi='ssh barton@raspberrypi'
alias sshlap='ssh barton@Brien-laptop'

alias aptana="/home/Aptana_Studio_3/AptanaStudio3"
alias transcribe="$HOME/sw/transcribe/transcribe"

if [ $UID -ne 0 ]; then
    alias yum='sudo yum'
    alias reboot='sudo reboot'
    alias shutdown='sudo shutdown now'
fi

ne() { nedit "$@" & }
sin() {
  TODAY=`date +"%b %e"`
  ls -l $@ | egrep "${TODAY} ..:|:$"
}

if [ -f $HOME/bin/sd.bash ]
then
    . $HOME/bin/sd.bash
    alias cd=sd
fi

github="https://github.com/barton001/linux-standard-setup.git"

# Allow you to edit command recalled with !nnn before it gets executed
shopt -s histverify

# Modify up and down arrow keys to act like Page-up/Page-Down, i.e. they
# find match in history to what you've typed so far
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'
