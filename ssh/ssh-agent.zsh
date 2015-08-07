# If I am logged on to a console on a Mac then this is a local machine not 
# server so setup ssh-agent and propagate across sessions via ~/.zshrc-ssh
if [[ ! -n $SSH_TTY && `uname -s` == "Darwin" ]]; then
    if [[ -a $HOME/.zshrc-ssh ]]; then
        . $HOME/.zshrc-ssh
    fi
    kill -0 $SSH_AGENT_PID &> /dev/null
    if [[ $? -eq 1 && $( ps -o comm= -p ${SSH_AGENT_PID} ) == "ssh-agent" ]]; then
        local EXPORT_SSH
        EXPORT_SSH=$( ssh-agent | head -n 2 )
        echo $EXPORT_SSH > $HOME/.zshrc-ssh
        eval $EXPORT_SSH
        unset EXPORT_SSH
        ssh-add $HOME/.ssh/id_rsa
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
