if hash fzf &>/dev/null; then
    export FZF_DEFAULT_OPTS="--layout=reverse --border --inline-info
    --color=fg:#4C566A,bg:#2E3440,fg+:#D8DEE9,bg+:#2E3440,hl:#81A1C1,hl+:#81A1C1
    --color=gutter:#2E3440,info:#B48DAC,prompt:#A3BE8C,pointer:#B48DAC
    --color=marker:#A3BE8C"

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
