# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
# __conda_setup="$('/rds/general/user/alh08/home/anaconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
# if [ $? -eq 0 ]; then
#     eval "$__conda_setup"
# else
#     if [ -f "/rds/general/user/alh08/home/anaconda3/etc/profile.d/conda.sh" ]; then
#         . "/rds/general/user/alh08/home/anaconda3/etc/profile.d/conda.sh"
#     else
#         export PATH="/rds/general/user/alh08/home/anaconda3/bin:$PATH"
#     fi
# fi
# unset __conda_setup
# <<< conda initialize <<<

# Much faster conda loading
if [ -f "${HOME}/anaconda3/etc/profile.d/conda.sh" ]; then
    . "${HOME}/anaconda3/etc/profile.d/conda.sh"
else
    export PATH="${HOME}/anaconda3/bin:$PATH"
fi

export EDITOR=vim
export VISUAL=vim
# Hat tip https://github.com/sapegin/dotfiles/ for colours
export PS1="\n$(tput setaf 4)\w\n\`if [ \$? = 0 ]; then echo \"$(tput setaf 2)\"; else echo \"$(tput setaf 1)\"; fi\`❯$(tput sgr0) "

set -o vi
alias ls="ls -lp"
bind -m vi-insert "\C-l":clear-screen
