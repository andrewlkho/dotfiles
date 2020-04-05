typeset -U path
path=(
    ${HOME}/.local/bin
    /usr/local/{,s}bin
    /usr/{,s}bin
    /{,s}bin
)
path=($^path(N))

typeset -U fpath
fpath=(
    "${XDG_CONFIG_HOME}/zsh/functions"
    $fpath
)
fpath=($^fpath(N))

export EDITOR="vim"
export LANG=$( locale -a | grep -i 'en_gb.utf-*8' )
export MANPAGER="less -i"
export PAGER="less -i"
