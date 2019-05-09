# If I am:
# 1. not on an SSH connection
# 2. in the `portal` tmux socket
# 3. the '0' window is active
# then launch a default-socket tmux session
if  [[ ! -n $SSH_TTY ]]; then
    if [[ $TMUX =~ '/portal' ]]; then
        if [[ $( tmux list-windows | grep -c '^0:.*(active)$') == 1 ]]; then
            tmux rename-window "foobar-three"
            tmux -L default new-session -A -s foobar-three
        fi
    fi
fi
