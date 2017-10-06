# I sometimes put homebrew here
path[1,0]=( ${HOME}/homebrew/{,s}bin(N) )

if hash brew 2>/dev/null; then
    export HOMEBREW_NO_ANALYTICS=1
    export HOMEBREW_NO_INSECURE_REDIRECT=1
fi
