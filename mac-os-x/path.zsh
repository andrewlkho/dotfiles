if [[ `uname -s` == 'Darwin' ]]; then
    # MacTeX puts a symlink to the binaries here
    path[1,0]=( /Library/TeX/bin(N) )

    # Some useful utilities
    alias airport='/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport'
    alias mergepdf='/System/Library/Automator/Combine\ PDF\ Pages.action/Contents/Resources/join.py'
fi
