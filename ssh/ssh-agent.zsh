# If this is my server (the only machine I forward an SSH agent to) then make
# sure the socket is correctly setup with a link in ~/.ssh-agent-sock
if [[ `hostname -s` == "sebastian" && -n $SSH_AUTH_SOCK ]]; then
    if [[ $SSH_AUTH_SOCK == /tmp/* ]]; then
        ln -sf $SSH_AUTH_SOCK $HOME/.ssh-agent-sock
        export SSH_AUTH_SOCK=$HOME/.ssh-agent-sock
    fi
fi
