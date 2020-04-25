if hash fzf &>/dev/null; then
    export FZF_DEFAULT_OPTS="--layout=reverse --border --inline-info \
        --color='hl:#D79921,fg+:#B8BB26,bg+:#282828,hl+:#FABD2F,info:#928374,pointer:#B8BB26'"
    export FZF_CTRL_T_COMMAND="command find -L \"${HOME}\" -mindepth 1 \
        \\( -path '*/\\.*' \
            -o -fstype 'sysfs' -o -fstype 'devfs' -o -fstype 'devtmpfs' -o -fstype 'proc' \
            -o -path \"${HOME}/Library\" \
        \\) -prune \
        -o -type f -print \
        -o -type d -print \
        -o -type l -print 2> /dev/null"
    export FZF_ALT_C_COMMAND="command find -L \"${HOME}\" -mindepth 1 \
        \\( -path '*/\\.*' \
            -o -fstype 'sysfs' -o -fstype 'devfs' -o -fstype 'devtmpfs' -o -fstype 'proc' \
            -o -path \"${HOME}/Library\" \
        \\) -prune \
        -o -type d -print 2> /dev/null"

    source "${ZDOTDIR}/lib/fzf-keybindings"
    source "${ZDOTDIR}/lib/fzf-completion"
fi
