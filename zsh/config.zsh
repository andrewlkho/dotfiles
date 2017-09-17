# Set default path.  Other topics can prepend to this if needed with
# path[1,0]=( /foo(N) )
typeset -U path
path=( ${HOME}/bin(N)
       /usr/local/{,s}bin(N)
       /usr/{,s}bin(N)
       /{,s}bin(N)
     )

export EDITOR='vim'
export PAGER='less'
export LANG=$( locale -a | grep -i 'en_gb.utf-\?8' )
export LC_COLLATE="C" LC_NUMERIC="C"
setopt NOBEEP

# History setup
setopt SHARE_HISTORY
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
export HISTFILE=~/.zsh_history
export HISTSIZE=10000
export SAVEHIST=10000

bindkey -v
bindkey '^r' history-incremental-search-backward
