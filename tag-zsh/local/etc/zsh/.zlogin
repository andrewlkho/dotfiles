# If on a remote terminal and tmux has been configured then attach to a running
# session if one exists, otherwise create a new one.  If local then only open a
# new/existing tmux session if one is not already connected to (macOS
# Terminal.app spawns a new login shell for each tab but I only want tmux in the
# first tab).

if [[ -n "${SSH_TTY}" ]]; then
    if [[ -a "${XDG_CONFIG_HOME}/tmux/tmux.conf" ]]; then
        if [[ -n "${SSH_AUTH_SOCK}" ]]; then
            # Symlink to the socket so that it remains accessible to old tmux
            # panes even when the socket changes between sessions
            mkdir -p "${XDG_RUNTIME_DIR}/ssh"
            ln -sf "${SSH_AUTH_SOCK}" "${XDG_RUNTIME_DIR}/ssh/ssh-agent.sock"
            export SSH_AUTH_SOCK="${XDG_RUNTIME_DIR}/ssh/ssh-agent.sock"
        fi

        tmux new-session -AD -s "${USER}" && exit
    fi
else
    if [[ -z "$(tmux list-clients -t "${USER}" 2>/dev/null)" ]]; then
        tmux new-session -AD -s "${USER}" && exit
    fi
fi
