# @andrewlkho's dotfiles

This repository contains most of the dotfiles that I use on a regular basis.  It 
is divided up broadly by the UNIX tools they each belong to (zsh, vim _et 
cetera_).  The layout and concept behind this organisation is heavily borrowed 
from [Zach Holman](https://github.com/holman/dotfiles)'s work.  Hopefully others 
will find parts of this useful, or suggest ways in which my setup could be 
improved.


## Installation

Some of the vim configuration uses git submodules, so use `--recursive` to 
clone:

    % git clone --recursive git://github.com/andrewlkho/dotfiles.git

Then to install:

    % ./dotfiles install

This will symlink any file `foo.symlink` as `~/.foo`


## Passwords

Some dotfiles inevitably contain sensitive data.  The way I handle this is to 
create a template file called `foo.example` and replace any sensitive data with 
`__SOME TOKEN__`.  Then, when you run `./dotfiles install` it will ask you what 
to replace that token with (and generate a file called `foo`).

Don't forget that you may want to name files `bar.symlink.example` if they both 
contain sensitive data and need to be symlinked.
