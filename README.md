# Dotfiles

This is a collection of my dot files and setups.

## Homebrew

``` shell
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

## Dotfiles

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
### install ruby dependencies

```shell
brew install openssl@3 readline libyaml gmp
```

## pyenv

```shell
git clone https://github.com/pyenv/pyenv.git ~/.pyenv
```
### install python dependencies

```shell
brew install openssl readline sqlite3 xz zlib tcl-tk@8
```

## Docker
I prefer the [OrbStack](http://orbstack.dev) over the vanila Docker Desktop.

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

```shell
brew install --cask emacs
```

### Doom

``` shell
git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.config/emacs
~/.config/emacs/bin/doom install
```

#### Doom dependencies

```shell
brew install coreutils markdown shellcheck fontconfig ripgrep 
```

## Stats

```shell
brew install --cask stats
```
