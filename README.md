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

## [Mise](https://mise.jdx.dev)

``` shell
curl https://mise.run | sh
```

<strike>
## rbenv(Deprecated)

```shell
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/ruby-build
```
</strike>

### install ruby dependencies

```shell
brew install openssl@3 readline libyaml gmp
```

<strike>
## pyenv(Deprecated)

```shell
git clone https://github.com/pyenv/pyenv.git ~/.pyenv
```
</strike>

### install python dependencies

```shell
brew install openssl readline sqlite3 xz zlib tcl-tk@8
```

## Docker
I prefer the [OrbStack](http://orbstack.dev) over the vanila Docker Desktop.

### MySQL

``` shell
docker run -e MYSQL_ALLOW_EMPTY_PASSWORD=true -d --restart always -p 3306:3306 mysql
```
#### MySQL client

``` shell
brew install mysql-client
brew link -f mysql-client
```

## Emacs

Install emacs-plus, recommended for Doom.

``` shell
brew tap d12frosted/emacs-plus
brew install emacs-plus
```

Make alias to the /Applications folder

``` shell
osascript -e 'tell application "Finder" to make alias file to posix file "/opt/homebrew/opt/emacs-plus/Emacs.app" at posix file "/Applications" with properties {name:"Emacs.app"}'
```

### Doom

Install Doom dependencies

``` shell
brew install coreutils markdown shellcheck fontconfig ripgrep fd
```

``` shell
git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.config/emacs
~/.config/emacs/bin/doom install
```

<strike>
## Stats(Deprecated)

``` shell
brew install --cask stats
```
</strike>
