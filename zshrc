# ~/.zshrc: executed by zsh for non-login shells.

# Path to your oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
# ZSH_THEME="robbyrussell"
ZSH_THEME="gentoo"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(brew git bundler zsh-autosuggestions)

# Completion dump. oh-my-zsh honours a pre-set ZSH_COMPDUMP; its own default is
# $HOME/.zcompdump-<host>-<version>, which litters $HOME. ${HOST%%.*} is the
# short hostname omz itself would use.
ZSH_COMPDUMP="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump-${HOST%%.*}-${ZSH_VERSION}"
command mkdir -p "${ZSH_COMPDUMP:h}"

source $ZSH/oh-my-zsh.sh

# User configuration
export PATH=$HOME/.local/bin:$PATH

# Emacs doom {{{
if [ -d "$HOME/.config/emacs/bin" ]; then
    export PATH="$HOME/.config/emacs/bin:$PATH"
fi
# }}}

# Mise
if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate zsh)"
fi

# Rust
if [ -f "$HOME/.cargo/env" ]; then
  . "$HOME/.cargo/env"
fi

# Go
if [ -d "$HOME/go" ]; then
  export GOPATH=$HOME/go
  export PATH=$GOPATH/bin:$PATH
fi

# Ctrl+D refused ("use 'exit' to exit"); 10 consecutive EOFs force exit
# (bash IGNOREEOF=42: exits on the 43rd; zsh ignores the IGNOREEOF variable)
setopt ignore_eof

[ -n "$TMUX" ] || export TERM=xterm-256color
export ALTERNATE_EDITOR=""

# Preferred editor: nvim with vim fallback
if command -v nvim >/dev/null 2>&1; then
    export EDITOR='nvim'
else
    export EDITOR='vim'
fi

# include .alias if it exists
if [ -f "$HOME/.alias" ]; then
    . "$HOME/.alias"
fi

# include .zshrc.local if it exists
if [ -f "$HOME/.zshrc.local" ]; then
    . "$HOME/.zshrc.local"
fi

# Collapse duplicate PATH entries added both here and by mise's activation
typeset -U path
path=($path)
