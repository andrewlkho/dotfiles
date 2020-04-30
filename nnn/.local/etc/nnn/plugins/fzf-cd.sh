#!/bin/sh

# Description: Change directory to fzf-selected directory (only searches
# for directories and excludes ~/Library for speed)
# Requires: fzf
# Author: Andrew Ho

if [ -z "$( command -v "fzf")" ]; then
    echo "fzf is not installed: brew install fzf"
    read -r
    exit 1
else
    DIR="$(find -L "${HOME}" -path "${HOME}/Library" -prune -o -type d -print \
        2>/dev/null | fzf)"
    echo "0${DIR}/" > "${NNN_PIPE}"
fi
