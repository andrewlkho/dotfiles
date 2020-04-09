if [[ -n "${SSH_TTY}" && -n "${SSH_AUTH_SOCK}" ]]; then
    # Symlink to the socket from ~/.local/run/ssh/ssh-agent.sock so that
    # it remains accessible to old tmux panes even when the socket changes
    # between sessions
    mkdir -p "${HOME}/.local/run/ssh"
    ln -sf "${SSH_AUTH_SOCK}" "${HOME}/.local/run/ssh/ssh-agent.sock"
    export SSH_AUTH_SOCK="${HOME}/.local/run/ssh/ssh-agent.sock"
fi

if [[ -n "${SSH_TTY}" && $(hostname -s) =~ '(data|archive)' ]]; then
    tmux -f "${XDG_CONFIG_HOME}/tmux/tmux.conf" new-session -A -s andrewlkho && logout
fi
