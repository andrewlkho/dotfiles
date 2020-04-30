export NNN_BMS="a:${HOME}/Documents/andrewonntserver;d:${HOME}/Desktop;t:${HOME}/Dropbox/Tarandy;u:${HOME}/Documents/unison"
export NNN_OPTS="AdoR"
export NNN_PLUG='c:fzf-cd.sh;l:-less.sh;t:trash.sh'

nnn_show_selection() {
    # Print out the current nnn selection.  It only updates if the selection
    # file has changed which avoids annoying blinking tmux panes if the screen
    # is cleared but exactly the same contents printed.  This function is
    # roughly equivalent to the watch command.

    FILE="${XDG_CONFIG_HOME}/nnn/.selection"
    LAST=""
    clear

    while true; do
        if [[ -f "${FILE}" ]]; then
            if [[ "$(cat "${FILE}" )" != "${LAST}" ]]; then
                clear
                LAST="$(cat "${FILE}")"
                echo "$(tr -s "\000" "\n" < "${FILE}")"
            fi
        else
            if [[ -n "${LAST}" ]]; then
                clear
                LAST=""
            fi
        fi
        sleep 1
    done
}

nnnt() {
    # Set up nnn tmux window the way I like it: left pane is nnn with a small
    # pane at the bottom to show current selection, right pane is for preview

    if [[ "$( tmux list-panes | wc -l )" -gt 1 ]]; then
        echo "Error: current window has more than one pane" >&2
    else
        tmux split-window -h ''
        tmux set-option -p -t '{right}' remain-on-exit on
        tmux select-pane -t '{left}'
        tmux split-window -l 7 -v 'zsh -i -c nnn_show_selection'
        tmux select-pane -t '{top-left}'
        tmux send-keys 'nnn' C-m
    fi
}
