#!/bin/bash
# Inspired by janus' bootstrap.bash

DOTFILE_DIR=$HOME/.dotfiles
OLD_DOTFILE_DIR=$HOME/.dotfiles.old

# copy from janus's bootstrap.sh
function die () {
    echo "${@}"
    exit 1
}

# Install Top Programming Fonts
curl -L https://github.com/hbin/top-programming-fonts/raw/master/install.sh | bash

# Install Janus for vim
curl -L https://github.com/carlhuda/janus/raw/master/bootstrap.sh | bash

# Install oh-my-zsh
curl -L https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh | bash

# Remove legacy $OLD_DOTFILE_DIR
if [[ -e $OLD_DOTFILE_DIR ]]; then
  rm -rf $OLD_DOTFILE_DIR || die "Could not remove $OLD_DOTFILE_DIR"
  echo "$OLD_DOTFILE_DIR has been removed!"
fi

# Rename $DOTFILE_DIR to $OLD_DOTFILE_DIR OR make a new $OLD_DOTFILE_DIR
if [[ -e $DOTFILE_DIR ]]; then
  mv $DOTFILE_DIR $OLD_DOTFILE_DIR || die "Could not move $DOTFILE_DIR to $OLD_DOTFILE_DIR"
  echo "$DOTFILE_DIR has been rename to $OLD_DOTFILE_DIR"
else
  mkdir $OLD_DOTFILE_DIR || die "Could not mkdir $OLD_DOTFILE_DIR"
fi

# Clone dotfiles to ~/.dotfiles
git clone https://github.com/hbin/dotfiles.git $DOTFILE_DIR \
  || die "Cound not clone the repository to $DOTFILE_DIR"

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
