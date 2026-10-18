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

# zsh state that would otherwise litter $HOME lives in one directory. Both must
# be set before oh-my-zsh is sourced: it honours pre-set ZSH_COMPDUMP/HISTFILE.
ZSH_CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
command mkdir -p "$ZSH_CACHE"

# Completion dump; omz's own default is $HOME/.zcompdump-<host>-<version>.
# ${HOST%%.*} is the short hostname omz itself would use.
ZSH_COMPDUMP="$ZSH_CACHE/zcompdump-${HOST%%.*}-${ZSH_VERSION}"

# History file; omz's own default is $HOME/.zsh_history. Its HISTSIZE/SAVEHIST
# and history setopts are left untouched.
HISTFILE="$ZSH_CACHE/history"

if [ -r "$ZSH/oh-my-zsh.sh" ]; then
    source "$ZSH/oh-my-zsh.sh"
fi

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

# Keep the terminal's own TERM (e.g. Ghostty's xterm-ghostty) instead of
# downgrading it. Only fall back when TERM is missing, "dumb", or has no
# terminfo entry on this host (which happens on some SSH targets).
if [ -z "$TERM" ] || [ "$TERM" = dumb ] || ! infocmp "$TERM" >/dev/null 2>&1; then
    export TERM=xterm-256color
fi
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
