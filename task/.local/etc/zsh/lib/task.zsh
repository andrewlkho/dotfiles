export TASKRC="${XDG_CONFIG_HOME}/task/taskrc"

tls() {
    task "$@" \( status:pending or status:waiting \) export |
        "${XDG_CONFIG_HOME}/task/scripts/taskprint.py"
}

alias tt='task rc.verbose=nothing \
    "(scheduled.before:tomorrow or due.before:tomorrow or +today) and \
    status:pending" export | "${XDG_CONFIG_HOME}/task/scripts/taskprint.py"'

_fzf_complete_task() {
    if [[ "$@" =~ "task *$" ]]; then
        _fzf_complete --ansi --no-hscroll --color='fg+:#EBDBB2' -- "$@" < <(
            task rc.verbose=nothing status:pending or status:waiting export |
                "${XDG_CONFIG_HOME}/task/scripts/oneline.py"
            )
    else
        eval "zle ${fzf_default_completion:-expand-or-complete}"
    fi
}

_fzf_complete_task_post() {
    awk '{print $1}'
}
