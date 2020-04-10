unsetopt MENU_COMPLETE
setopt AUTO_MENU
setopt COMPLETE_ALIASES

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

autoload -Uz compinit
compinit -d "${XDG_CACHE_HOME}/zsh/zcompdump"
