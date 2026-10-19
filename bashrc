# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# Homebrew
export PATH=/usr/local/sbin:$PATH
if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

export PATH="$HOME/.local/bin:$PATH"

# Emacs doom {{{
if [ -d "$HOME/.config/emacs/bin" ]; then
    export PATH="$HOME/.config/emacs/bin:$PATH"
fi
# }}}

# Mise
if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate bash)"
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

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# Color Bash Prompt
# inspired by the oh-my-zsh's gentoo
PS1='\[\e[1;32m\]\u@\h\[\e[m\]\[\e[1;34m\] \w \$ \[\e[0m\]'

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see bash(1) for HISTSIZE and HISTFILESIZE in bash(1)
# Match oh-my-zsh's floor in spirit: 10x the old 1000/2000 so daily history
# survives (files stay in the 2-4MB range).
HISTSIZE=10000
HISTFILESIZE=20000

# enable color support of ls and also add handy aliases
if command -v gdircolors >/dev/null 2>&1; then
    test -r ~/.dircolors && eval "$(gdircolors -b ~/.dircolors)" || eval "$(gdircolors -b)"
fi
if ls --color=auto / >/dev/null 2>&1; then
    alias ls='ls --color=auto'
else
    alias ls='ls -G'
fi
alias grep='grep --color=auto'

# include .alias if it exists
if [ -f "$HOME/.alias" ]; then
    . "$HOME/.alias"
fi

# include .bashrc.local if it exists
if [ -f "$HOME/.bashrc.local" ]; then
    . "$HOME/.bashrc.local"
fi

# Collapse duplicate PATH entries (bash has no zsh `typeset -U path`);
# keeps the first occurrence and drops empty entries. Child shells re-run
# this file and would otherwise prepend a fresh copy of every entry.
PATH="$(printf '%s' "$PATH" | awk -v RS=: '!($0 in seen) && $0 != "" {seen[$0]; printf "%s%s", sep, $0; sep=":"}')"
export PATH

# Alias definitions.
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ga='git add'
alias gb='git branch'
alias gc='git commit'
alias gd='git diff'
alias gst='git status'
alias gco='git checkout'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# User configuration

# Keep the terminal's own TERM (e.g. Ghostty's xterm-ghostty) instead of
# downgrading it. Only fall back when TERM is missing, "dumb", or has no
# terminfo entry on this host (which happens on some SSH targets).
if [ -z "$TERM" ] || [ "$TERM" = dumb ] || ! infocmp "$TERM" >/dev/null 2>&1; then
    export TERM=xterm-256color
fi
export ALTERNATE_EDITOR=""

# Press Ctrl+D forty-two times before it actually quits the shell
export IGNOREEOF=42

# Preferred editor: nvim with vim fallback
if command -v nvim >/dev/null 2>&1; then
    export EDITOR='nvim'
else
    export EDITOR='vim'
fi
