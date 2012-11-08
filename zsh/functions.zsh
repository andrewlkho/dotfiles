# Each topic can have its own functions/ directory (including zsh/functions/)
for topic_functions in $ZSH/*/functions; fpath=($topic_functions $fpath)
autoload -U $ZSH/*/functions/*(:t)
