# If I am logged on to a console on a Mac then this is a local machine not 
# server so setup gpg-agent and propagate across sessions via ~/.zshrc-ssh
if [[ ! -n $SSH_TTY && `uname -s` == "Darwin" ]]; then
    if [[ -a $HOME/.zshrc-ssh ]]; then
        . $HOME/.zshrc-ssh
        export GPG_AGENT_INFO SSH_AUTH_SOCK SSH_AGENT_PID
    fi
    kill -0 $SSH_AGENT_PID &> /dev/null
    if [[ $? -eq 1 ]]; then
        eval $( gpg-agent \
            --daemon \
            --enable-ssh-support \
            --write-env-file=$HOME/.zshrc-ssh )
    fi
fi

# If this is my server (the only machine I forward an SSH agent to) then make
# sure the socket is correctly setup with a link in ~/.ssh-agent-sock
if [[ `hostname -s` == "sebastian" && -n $SSH_AUTH_SOCK ]]; then
    if [[ $SSH_AUTH_SOCK == /tmp/* ]]; then
        ln -sf $SSH_AUTH_SOCK $HOME/.ssh-agent-sock
        export SSH_AUTH_SOCK=$HOME/.ssh-agent-sock
    fi
fi
