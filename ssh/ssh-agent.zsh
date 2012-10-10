# Setup ssh-agent and propagate across sessions via ~/.zshrc-ssh
if [[ -a $HOME/.ssh/id_rsa ]]; then
    [[ -a $HOME/.zshrc-ssh ]] && . $HOME/.zshrc-ssh
    if [[ ! -S $SSH_AUTH_SOCK && ! (`uname -s` == 'Darwin' && `uname -r | cut -d . -f 1` -ge 9) ]]; then
        local EXPORT_SSH
        killall ssh-agent >& /dev/null
        EXPORT_SSH=$( ssh-agent | awk -F '; ' '/SSH/ { print $1 }' | sed -e 'N; s/\n/ /' -e 's/^/export /' )
        echo $EXPORT_SSH > $HOME/.zshrc-ssh
        eval $EXPORT_SSH
        unset EXPORT_SSH
        ssh-add $HOME/.ssh/id_rsa*
    fi
fi
