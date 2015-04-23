setopt PROMPT_SUBST

# print the current directory, highlighting the git top level directory
_prompt_pwd() {
    local pwd=$( print -Pn "%~" )
    if [[ $( git rev-parse --is-inside-work-tree 2> /dev/null ) == "true" ]]; then
        local git_tld=$( basename $( git rev-parse --show-toplevel ) )
        print -Pn "%F{blue}${pwd/${git_tld}/"%F{166}${git_tld}%F{blue}"}%f"
    else
        print -Pn "%F{blue}${pwd}%f"
    fi
}

# print info about the current git branch
_prompt_git_info() {
    if [[ $( git rev-parse --is-inside-work-tree 2> /dev/null ) == "true" ]]; then
        echo -n " ⟶  "
        echo -n "$( git symbolic-ref HEAD | cut -d'/' -f 3 )"
        [[ -n $( git status --porcelain --ignore-submodules ) ]] && print -Pn "%F{red}*%f"
        (( $( git rev-list --left-only --count HEAD...@'{u}' ) > 0 )) && print -Pn " %F{cyan}⇡%f"
    fi
}

# print exec time of previous command if > 5s
_prompt_cmd_exec_time() {
    elapsed=$(( ${EPOCHSECONDS} - ${cmd_starttime:-${EPOCHSECONDS}} ))
    if (( ${elapsed} > 5 )); then
        echo -n " "
        (( ${elapsed} / 86400 > 0 )) && echo -n "$(( ${elapsed} / 86400 ))d "
        (( ${elapsed} / 3600 % 24 )) && echo -n "$(( ${elapsed} / 3600 % 24 ))h "
        (( ${elapsed} / 60 % 60 )) && echo -n "$(( ${elapsed} / 60 % 60 ))m "
        echo "$(( ${elapsed} % 60 ))s"
    fi
}

# preexec is executed just after a command has been read and is about to be executed
_prompt_preexec() {
    cmd_starttime=${EPOCHSECONDS}
}

# precmd is executed before each prompt
_prompt_precmd() {
    print -P "\n`_prompt_pwd``_prompt_git_info` %n@%m%F{yellow}`_prompt_cmd_exec_time`%f"
    unset cmd_starttime
}

_prompt_setup() {
    zmodload zsh/datetime
    autoload -U add-zsh-hook

    add-zsh-hook preexec _prompt_preexec
    add-zsh-hook precmd _prompt_precmd

    PROMPT="%(?.%F{green}.%F{red})❯%f "
}

_prompt_setup
