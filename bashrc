# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# Emacs doom {{{
if [ -d "$HOME/.emacs.d" ]; then
    export PATH="$HOME/.emacs.d/bin:$PATH"
fi
# }}}

# Mise
if [ -x "$(command -v mise)" ]; then
  eval "$(mise activate --shims zsh)"
fi

# Go
if [ -d "$HOME/go" ]; then
  export GOPATH=$HOME/go
  export PATH=$GOPATH/bin:$PATH
fi

export GO111MODULE=auto
# }}}

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

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# include .alias if it exists
if [ -f "$HOME/.alias" ]; then
    . "$HOME/.alias"
fi

# include .bashrc.local if it exists
if [ -f "$HOME/.bashrc.local" ]; then
    . "$HOME/.bashrc.local"
fi

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
export SSH_KEY_PATH="~/.ssh/id_rsa"

export TERM=xterm-256color
export ALTERNATE_EDITOR=""

# Press Ctrl+D forty-two times before it actually quits the shell
export IGNOREEOF=42

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
    export EDITOR='vim'
else
    if which mvim >/dev/null; then
        export EDITOR="mvim"
    else
        export EDITOR='vim'
    fi
fi
