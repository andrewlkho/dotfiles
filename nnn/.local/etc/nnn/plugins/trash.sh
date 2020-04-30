#!/bin/sh

# Description: delete a file with trash
# Requires: trash
# Author: Andrew Ho

if [ -n "$1" ]; then
    if [ -z "$( command -v trash )" ]; then
        echo "trash is not installed: brew install trash"
        read -r
        exit 1
    else
        trash "$1"
    fi
fi
