# Dotfiles

My personal dotfiles, shared between macOS and Linux. Shell (bash + zsh),
Git, Vim, Emacs Doom, Karabiner, and proxy config templates.

## Quick Start

One command sets everything up:

```shell
bash -c "$(curl -fsSL https://raw.githubusercontent.com/hbin/dotfiles/master/scripts/install.sh)"
```

Options: `--dry-run`, `--skip-brew`, `--skip-omz`, `--skip-mise`
(run `--help` for details). Open a new shell afterwards, or `exec $SHELL`.

### Doing it manually

If you would rather run each step yourself:

```shell
# 1. Homebrew (optional; works on macOS and Linux)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 2. Clone and link
git clone https://github.com/hbin/dotfiles.git ~/dotfiles
~/dotfiles/scripts/stow

# 3. oh-my-zsh + autosuggestions
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# 4. mise (runtime manager)
curl https://mise.run | sh
```

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
| `scripts/install.sh` | One-line bootstrap installer (environment + dotfiles) |
| `scripts/stow` | Symlinks the repo into `$HOME`; backs up any real file it replaces |

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

### Karabiner-Elements

macOS only. The installer copies `karabiner.json` into place but does not
install the app — do that yourself if you use it:

```shell
brew install --cask karabiner-elements
```

## Notes

- `~/.bashrc.local` and `~/.zshrc.local` are sourced if present — keep
  machine-specific secrets there; they are not part of this repo.
