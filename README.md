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
| `zshrc`, `zshenv` | Zsh setup. oh-my-zsh + same environment as bash; `zshenv` sets locale, `zshrc` holds PATH and interactive config |
| `alias` | Shared aliases, sourced by both shells |
| `gitconfig`, `gitignore_global` | Git config and global ignores (`.DS_Store`, editor droppings) |
| `vimrc` | Vim |
| `doom.d/` | Emacs Doom config |
| `ghostty.conf` | Ghostty terminal config (symlinked to `~/.config/ghostty/config`) |
| `karabiner.json` | Karabiner-Elements key remaps (symlinked to `~/.config/karabiner/`; macOS only) |
| `mihomo/` | Clash/mihomo proxy config templates |
| `.agents/skills/` | Project-scoped Codex skills; local `.env` files stay untracked |
| `pryrc` | Pry (Ruby REPL) config |
| `bin/` | Small helper commands, linked into `~/.local/bin` — see Commands below |
| `scripts/install.sh` | One-line bootstrap installer (environment + dotfiles) |
| `scripts/set-default-editor.sh` | macOS: makes a chosen app the default for common text and source formats |
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

### Default text editor

macOS only. `scripts/set-default-editor.sh` uses
[`duti`](https://github.com/jgee/duti) to make a chosen editor the default for
plain text, configuration, markup, and common source formats. TextEdit is the
default; pass another app name or an absolute `.app` path with `--app`:

```shell
brew install duti
scripts/set-default-editor.sh --dry-run
scripts/set-default-editor.sh --app CotEditor
scripts/set-default-editor.sh --app Zed
scripts/set-default-editor.sh --app "VS Code"
scripts/set-default-editor.sh --app "/Applications/CotEditor.app"
scripts/set-default-editor.sh                  # reset to TextEdit
scripts/set-default-editor.sh --check
```

Associations normally follow the document types the selected app declares in
its `Info.plist` (by UTI or filename extension), so TextEdit only receives its
native plain-text types. `.el` is an explicit plain-text exception, letting
CotEditor open Emacs Lisp files. Apps that only register `.ts` by extension are
skipped for that ambiguous type rather than claiming macOS's MPEG
transport-stream UTI.

HTML and SVG stay associated with the browser. Extensionless dotfiles such as
`~/.zshrc` have no filename extension for LaunchServices to match; open them
directly, for example `open -a CotEditor ~/.zshrc`.

## Notes

- `~/.bashrc.local` and `~/.zshrc.local` are sourced if present — keep
  machine-specific secrets there; they are not part of this repo.
- Git identity is not tracked either: `gitconfig` includes `~/.gitconfig.local`,
  which you create yourself —
  `git config --file ~/.gitconfig.local user.name "Your Name"` and
  `git config --file ~/.gitconfig.local user.email "you@example.com"`.
