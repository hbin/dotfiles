#!/bin/bash
# Inspired by janus' bootstrap.bash
# TODO use rake
#      install font

DOTFILE_DIR=$HOME/.dotfiles
OLD_DOTFILE_DIR=$HOME/.dotfiles.old

# copy from janus's bootstrap.sh
function die () {
    echo "${@}"
    exit 1
}

# Install the janus for vim
curl -L https://github.com/carlhuda/janus/raw/master/bootstrap.sh | bash

# Install the oh-my-zsh
curl -L https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh | bash

# Make backup dotfiles dir
mkdir $OLD_DOTFILE_DIR || die "Could not mkdir $OLD_DOTFILE_DIR"

# Clone dotfiles to ~/.dotfiles
git clone https://github.com/hbin/dotfiles.git $HOME/.dotfiles \
  || die "Cound not clone the repository to ${HOME}/.dotfiles"

# TODO: use rake!
# Backup and make symbolink
cd $DOTFILE_DIR || die "Could not go into the $DOTFILE_DIR"
for i in ${pwd}*; do
    if [[ $i =~ ^_ ]]; then
        hdot=${HOME}/.${i:1}
        ndot=${DOTFILE_DIR}/_${i:1}
        odot=${OLD_DOTFILE_DIR}/_${i:1}

        if [[ (-e $hdot) || (-h $hdot) ]]; then
            mv $hdot $odot || die "Could not move $hdot to $odot"
            echo "backup $hdot"
        fi
        
        ln -fs $ndot $hdot || die "Could not symblink $ndot to $hdot"
        echo "symbolink $ndot"
    fi
done
