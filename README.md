# Dotfiles

This is a collection of my dot files and setups.

## Installation

```shell
git clone https://github.com/hbin/dotfiles.git ~/dotfiles
~/dotfiles/scripts/stow
```
## oh-my-zsh
```shell
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

### zsh autosuggestions
```shell
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
```

## rbenv
```shell
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/ruby-build
```

### install dependencies with Homebrew
```shell
brew install openssl@3 readline libyaml gmp
```

## pyenv
TODO

## Emacs
```shell
brew install emacs
```

## Stats
```shell
brew install stats
```

## Docker

### MySQL
```shell
docker run -e MYSQL_ALLOW_EMPTY_PASSWORD=true -d --restart always -p 3306:3306 mysql
```
#### MySQL client
```shell
brew install mysql-client
brew link -f mysql-client
```

## Emacs

### Doom
```
brew install coreutils markdown shellcheck fontconfig
```
