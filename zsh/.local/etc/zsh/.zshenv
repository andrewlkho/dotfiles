typeset -U path
path=(
    ${HOME}/.local/bin
    /Library/TeX/texbin
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

export PAGER="less"
export LESSHISTFILE="-"
if hash src-hilite-lesspipe.sh 2>/dev/null; then
    export LESSOPEN="| src-hilite-lesspipe.sh %s"
    export LESS=" -iR"
else
    export LESS=" -i"
fi
