if [[ $(hostname -s) == 'data' ]]; then
    tmux new-session -A -s andrewlkho && logout
fi
