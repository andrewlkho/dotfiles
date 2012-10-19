setopt PROMPT_SUBST

git_repo() {
    echo $( pwd | awk 'match($0, /[^\/]+\.git/) { print substr($0, RSTART, RLENGTH-4) }' )
}

git_branch() {
    echo $( /usr/bin/git symbolic-ref HEAD | cut -d'/' -f 3 )
}

is_dirty() {
    [[ -n $( /usr/bin/git status -s ) ]] && echo "*"
}

is_unpushed() {
    [[ -n $( /usr/bin/git cherry -v @{upstream} 2>/dev/null ) ]] && echo "↑"
}

git_prompt() {
    # This works because I name all of my git directories *.git (and is faster
    # than parsing git status)
    if [[ $PWD =~ "\.git" ]]; then
        echo $(git_repo)" → "$(git_branch)$(is_unpushed)$(is_dirty)" | "
    else
        echo ""
    fi
}

export PS1='[%m] $(git_prompt)%1~ %# '
export PS2='[%m] $(git_prompt)%1~ > '
