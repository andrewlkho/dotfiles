setopt NOBEEP
bindkey -v
bindkey '^r' history-incremental-search-backward

typeset -U path
path=(
    ${HOME}/.local/bin
    /opt/local/{,s}bin
    /usr/local/{,s}bin
    /usr/{,s}bin
    /{,s}bin
    "${path[@]}"
)

export EDITOR="vim"
export VISUAL="vim"
export LESS="--ignore-case"

HISTFILE="${XDG_DATA_HOME}/zsh/history"
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_SPACE
setopt INC_APPEND_HISTORY


# Prompt #######################################################################

setopt PROMPT_SUBST
zmodload zsh/datetime
autoload -U add-zsh-hook
add-zsh-hook preexec _prompt_preexec
add-zsh-hook precmd _prompt_precmd

_prompt_preexec() {
    CMD_STARTTIME=${EPOCHSECONDS}
}

_prompt_precmd() {
    local ELAPSED=$(( ${EPOCHSECONDS} - ${CMD_STARTTIME:-${EPOCHSECONDS}} ))
    if [[ ${ELAPSED} -gt 5 ]]; then
        print -Pn "\n%F{yellow}Duration: "
        (( ${ELAPSED} / 86400 > 0 )) && print -n "$(( ${ELAPSED} / 86400 ))d "
        (( ${ELAPSED} / 3600 % 24 )) && print -n "$(( ${ELAPSED} / 3600 % 24 ))h "
        (( ${ELAPSED} / 60 % 60 )) && print -n "$(( ${ELAPSED} / 60 % 60 ))m "
        print "$(( ${ELAPSED} % 60 ))s"
    fi
    unset CMD_STARTTIME
}

_prompt_host() {
    if [[ -n "${SSH_TTY}" ]]; then
        print -Pn "%F{magenta}[%n@%m] "
    fi
}

_prompt_pwd() {
    print -Pn "%F{blue}%~"
    if [[ "$(git rev-parse --is-inside-work-tree 2> /dev/null)" == "true" ]]; then
        if [[ -n "$(git status --porcelain=v1 2>/dev/null)" ]]; then
            print -Pn "%F{red}*"
        fi
    fi
    print -n " "
}

# Single quotes to ensure re-evaluation each time the prompt is displayed
PROMPT='$(_prompt_host)$(_prompt_pwd)'\
'%1(j.%F{yellow}[%j] .)'\
'%(?.%F{green}.%F{red})%# %f'


# Aliases and functions ########################################################

if ls -N &> /dev/null; then
    alias ls="ls -lFN"
else
    alias ls="ls -lF"
fi

# Allow aliases to be used with sudo
alias sudo="sudo "

if [[ $(uname -s) == "Darwin" ]]; then
    alias airport="/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport"
fi

function pwgen() {
    if [[ ! -d "${XDG_CACHE_HOME}/pwgen" ]]; then
        mkdir -p "${XDG_CACHE_HOME}"
        git clone https://github.com/andrewlkho/pwgen-xkcd.git "${XDG_CACHE_HOME}/pwgen"
        curl --silent \
            --output "${XDG_CACHE_HOME}/pwgen/eff_large_wordlist.txt" \
            https://www.eff.org/files/2016/07/18/eff_large_wordlist.txt
    fi
    "${XDG_CACHE_HOME}/pwgen/pwgen.py" $* \
        "${XDG_CACHE_HOME}/pwgen/eff_large_wordlist.txt"
}

if [ -e "${XDG_CACHE_HOME}/visidata/_venv/bin/vd" ]; then
    alias vd="${XDG_CACHE_HOME}/visidata/_venv/bin/vd"
fi

function newsboat() {
    if [[ ! -a "${XDG_DATA_HOME}/newsboat/passwd" ]]; then
        echo "Please create ${XDG_DATA_HOME}/newsboat/passwd" 1>&2
        echo "The first line should be FreshRSS password, second line Zotero API key" 1>&2
    else
        cd ~/git/dotfiles.git/tag-newsboat
        docker compose run --rm newsboat
    fi
}


# Package-specific #############################################################

export VIMINIT="source ${XDG_CONFIG_HOME}/vim/vimrc"

export VIRTUAL_ENV_DISABLE_PROMPT=1

if [ -n "$(whence R)" ]; then
    export R_PROFILE_USER="${XDG_CONFIG_HOME}/R/Rprofile"
    export R_ENVIRON_USER="${XDG_CONFIG_HOME}/R/Renviron"
    alias R="R --no-save --no-restore --quiet"
fi

if [ -n "$(whence rcup)" ]; then
    export RCRC="${XDG_CONFIG_HOME}/rcm/rcrc"
fi

if [ -L "${XDG_CONFIG_HOME}/gnupg/gpg.conf" ]; then
    export GNUPGHOME="${XDG_CONFIG_HOME}/gnupg"
fi

if [ -n "$(whence pipx)" ]; then
    export PIPX_HOME="${XDG_DATA_HOME}/pipx"
fi
