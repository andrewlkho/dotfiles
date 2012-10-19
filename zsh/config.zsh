# Try a bunch of directories that I might want in my path.  Stuff towards the
# end of this list will be earlier in $PATH.
typeset -U path
local TESTDIR
for TESTDIR in /bin /sbin \
               /usr/bin /usr/sbin \
               /usr/local/bin /usr/local/sbin \
               /usr/local/apache/bin \
               /usr/local/mysql/bin \
               `find -L /usr/local/texlive -maxdepth 3 -mindepth 3 -name universal-darwin 2> /dev/null` \
               $HOME/bin
do
    [[ -d ${TESTDIR} ]] && path=( ${TESTDIR} $path )
done
unset TESTDIR

# Load functions
fpath=($ZSH/zsh/functions $fpath)
autoload -U $ZSH/zsh/functions/*(:t)

export EDITOR='vim'
export PAGER='less'
export LANG=$( locale -a | grep -i 'en_gb.utf-\?8' )
export LC_ALL=$( locale -a | grep -i 'en_gb.utf-\?8' )
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
