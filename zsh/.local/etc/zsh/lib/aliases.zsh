alias ls='ls -lF'
alias less='less -i'
alias d='dirs -v'
alias dg='dirs -v | grep -i'

if [[ $(uname -s) == 'Darwin' ]]; then
    path=(/Library/TeX/texbin(N) $path)

    alias airport='/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport'
    alias mergepdf='/System/Library/Automator/Combine\ PDF\ Pages.action/Contents/Resources/join.py'
fi
