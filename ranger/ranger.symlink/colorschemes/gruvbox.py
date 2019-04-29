# Assumes that macOS Terminal.app has the 16 ANSI colours set to gruvbox
# colours.  Gruvbox: https://github.com/morhetz/gruvbox

from __future__ import (absolute_import, division, print_function)
from ranger.gui.colorscheme import ColorScheme
from ranger.gui.color import (
    black, red, green, yellow, blue, magenta, cyan, white, default,
    normal, BRIGHT, default_colors,
    )

class Gruvbox(ColorScheme):
    progress_bar_color = blue

    def use(self, context):
        fg, bg, attr = default_colors

        if context.reset:
            return default_colors

        elif context.in_browser:
            if context.selected:
                bg = yellow
                fg = black
            if context.empty: # suppress the "empty" message
                bg = black
                fg = black
            if context.border:
                fg = white
            if context.directory:
                fg = blue
                if context.selected:
                    fg = black
            if context.main_column and context.marked:
                fg = red
        
        elif context.in_titlebar:
            if context.directory:
                fg = yellow
            if context.tab:
                if context.good:
                    fg = yellow
                else:
                    fg = white

        elif context.in_statusbar:
            fg = white

        return fg, bg, attr
