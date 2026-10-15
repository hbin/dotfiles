# Dotfiles

My personal dotfiles, shared between macOS and Linux. Shell (bash + zsh),
Git, Vim, Emacs Doom, Karabiner, and proxy config templates.

## Quick Start

On a fresh machine, run these in order.

### 1. Homebrew (optional)

Works on macOS and Linux.

```shell
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 2. Clone and link

```shell
git clone https://github.com/hbin/dotfiles.git ~/dotfiles
~/dotfiles/scripts/stow
```

The `stow` script symlinks everything into `$HOME` (it is plain
`ln -sf`, no GNU stow required).

### 3. oh-my-zsh + autosuggestions

```shell
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
```

### 4. mise (runtime manager)

```shell
curl https://mise.run | sh
```

New shells pick it up automatically (`mise activate` is called in both
`bashrc` and `zshrc`).

## What's Inside

| Path | Purpose |
|---|---|
| `bashrc`, `bash_profile`, `profile` | Bash setup. `bash_profile` → `profile` → `bashrc`; PATH (Homebrew, mise, cargo, Go), editor, aliases |
| `zshrc`, `zprofile`, `zshenv` | Zsh setup. oh-my-zsh + same environment as bash |
| `alias` | Shared aliases, sourced by both shells |
| `gitconfig`, `gitignore_global` | Git config and global ignores |
| `vimrc`, `vimrc.before`, `vimrc.after` | Vim |
| `doom.d/` | Emacs Doom config |
| `ideavimrc` | IdeaVim |
| `karabiner.json` | Karabiner-Elements key remaps (copied to `~/.config/karabiner/`) |
| `mihomo/` | Clash/mihomo proxy config templates |
| `ctags`, `globalrc`, `pryrc` | Misc tool configs |
| `scripts/stow` | The symlink installer |

## Optional

### Emacs Doom

macOS (emacs-plus is a Homebrew formula):

```shell
brew tap d12frosted/emacs-plus
brew install emacs-plus
brew install coreutils markdown shellcheck fontconfig ripgrep fd
git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.config/emacs
~/.config/emacs/bin/doom install
```

On Linux, install Emacs 29+ from your package manager instead.

### Docker

On macOS I prefer [OrbStack](https://orbstack.dev) over Docker Desktop.

## Notes

- `~/.bashrc.local` and `~/.zshrc.local` are sourced if present — keep
  machine-specific secrets there; they are not part of this repo.
