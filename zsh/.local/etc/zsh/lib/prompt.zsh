# pure prompt: https://github.com/sindresorhus/pure

autoload -U promptinit; promptinit

zstyle :prompt:pure:git:arrow color default
zstyle :prompt:pure:git:branch color default
zstyle :prompt:pure:host color default
zstyle :prompt:pure:prompt:success color green
zstyle :prompt:pure:user color default
zstyle :prompt:pure:user:root color magenta
zstyle :prompt:pure:virtualenv color white

prompt pure
