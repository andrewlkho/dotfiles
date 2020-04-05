if hash fzf &>/dev/null; then
    export FZF_DEFAULT_OPTS="--layout=reverse --border=sharp"
    export FZF_CTRL_T_COMMAND="command find -L \"${HOME}\" -mindepth 1 \\( -path '*/\\.*' -o -fstype 'sysfs' -o -fstype 'devfs' -o -fstype 'devtmpfs' -o -fstype 'proc' \\) -prune \
        -o -path \"${HOME}/Library\" -prune \
        -o -type f -print \
        -o -type d -print \
        -o -type l -print 2> /dev/null"

    source "${ZDOTDIR}/lib/fzf-keybindings"
fi
