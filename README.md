# Dotfiles

My personal dotfiles, shared between macOS and Linux. Shell (bash + zsh),
Git, Vim, Emacs Doom, Ghostty, Karabiner, and proxy config templates.

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
| `ghostty.conf` | Ghostty terminal config (symlinked to `~/.config/ghostty/config`) |
| `karabiner.json` | Karabiner-Elements key remaps (symlinked to `~/.config/karabiner/`; macOS only) |
| `mihomo/` | Clash/mihomo proxy config templates |
| `ctags`, `globalrc`, `pryrc` | Misc tool configs |
| `bin/` | Small helper commands, linked into `~/.local/bin` — see Commands below |
| `scripts/install.sh` | One-line bootstrap installer (environment + dotfiles) |
| `scripts/stow` | Symlinks the repo into `$HOME` (and `bin/` into `~/.local/bin`); replaces whatever is already at each destination |

## Commands

Helpers in `bin/` are linked into `~/.local/bin`, so they run as normal commands.

### `git rollback`

Git has no `rollback` subcommand; this adds one. It drops recent commits but
**keeps your changes**.

| Command | What happens |
|---|---|
| `git rollback` | drop the last commit, changes stay staged |
| `git rollback 3` | drop the last three |
| `git rollback --mixed` | drop it, changes stay unstaged |
| `git rollback --hard` | drop it **and discard** the changes |
| `git rollback --undo` | put the last rollback back |
| `git rollback -h` | full help |

Two things need `--force`: dropping commits that are already pushed, and
`--undo` on a branch other than the one you rolled back on.

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

### Ghostty

Works on macOS and Linux. The installer symlinks `ghostty.conf` to
`~/.config/ghostty/config` but does not install the app — do that yourself if
you use it:

```shell
brew install --cask ghostty
```

On Linux, install Ghostty from your package manager.

### Karabiner-Elements

macOS only. The installer symlinks `karabiner.json` to
`~/.config/karabiner/karabiner.json` but does not install the app — do that
yourself if you use it:

```shell
brew install --cask karabiner-elements
```

## Notes

- `~/.bashrc.local` and `~/.zshrc.local` are sourced if present — keep
  machine-specific secrets there; they are not part of this repo.
