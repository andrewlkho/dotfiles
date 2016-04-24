# If secure keyring is non-empty then we want gpg-agent to be running
if [[ -s ${HOME}/.gnupg/secring.gpg ]]; then
    if [[ -a ${HOME}/.gpg-agent-info ]]; then
        . ${HOME}/.gpg-agent-info
        export GPG_AGENT_INFO
    fi

    # If the socket doesn't exist then we need to start the agent
    if [[ ! -S ${GPG_AGENT_INFO%:[^:]*:[^:]*} ]]; then
        eval $( gpg-agent --daemon --write-env-file "${HOME}/.gpg-agent-info" )
    fi
fi
