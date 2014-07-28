alias ls='ls -lp'
alias ack='ack-grep --all --no-color --smart-case --sort-files --pager="less -x4SF"'

# OS X specific
[[ $(uname -s) == 'Darwin' ]] && alias airport='/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport'
# Usage: mergepdf -o output.pdf 1.pdf 2.pdf...
[[ $(uname -s) == 'Darwin' ]] && alias mergepdf='/System/Library/Automator/Combine\ PDF\ Pages.action/Contents/Resources/join.py'
