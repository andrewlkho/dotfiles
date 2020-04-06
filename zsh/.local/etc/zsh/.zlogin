if [[ $(hostname -s) == 'data' ]]; then
    tmux -f "${XDG_CONFIG_HOME}/tmux/tmux.conf" new-session -A -s andrewlkho && logout
fi
