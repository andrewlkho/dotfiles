# Print out a fullscreen calendar
pretty_remind () {
    clear
    remind -c+$(( ((`tput lines` - 5) / 8) + 1 )) -g -m -b1 -w`tput cols` $* | head -n $(( `tput lines` - 2 ))
    echo
}

alias rem=$'pretty_remind ~/.remind/remind'
