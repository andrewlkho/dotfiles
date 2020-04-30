#!/bin/sh

# Description: View the currently selected file in the adjacent tmux pane
# Requires: tmux window setup as per my nnnt() in nnn.zsh
# Author: Andrew Ho

tmux respawn-pane -k -t '{right}' "less '${2}/${1}' && tmux select-pane -t '{top-left}'"
tmux select-pane -t '{right}'
