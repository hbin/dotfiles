# Repository Guidelines

## Project Overview

Personal dotfiles for macOS + Linux (shell, Git, Vim, Emacs Doom, Ghostty,
Karabiner, mihomo/Clash proxy templates). Not a library or application: there is
no build step, no package manifest, no test suite, and no CI. The deliverable is
the set of files themselves, which `scripts/stow` symlinks into `$HOME`.

Single user, single branch (`master`, remote `git@github.com:hbin/dotfiles.git`).

## Architecture & Data Flow

**1. Linking model — destinations are the contract.** `scripts/stow` is a
hand-rolled stow replacement (no GNU stow binary, no `.stowrc`). Every
destination is created with `ln -sfn`: **whatever is already at the destination
is overwritten, with no backup**, and `~/.doom.d` is `rm -rf`'d first
(`scripts/stow:70-73`). `install.sh` clones the repo and then calls `stow`
(`scripts/install.sh:141`).

| Repo path | `$HOME` destination | Gate |
|---|---|---|
| `alias`, `bashrc`, `bash_profile`, `ctags`, `gitconfig`, `gitignore_global`, `globalrc`, `profile`, `pryrc`, `vimrc`, `zprofile`, `zshenv`, `zshrc` | `~/.<name>` (fixed list, `scripts/stow:36-39`) | file exists |
| `bin/*` | `~/.local/bin/<name>` | `bin/` exists |
| `doom.d/` | `~/.doom.d` (dir symlink) | `doom.d/` exists |
| `karabiner.json` | `~/.config/karabiner/karabiner.json` | `uname -s` = `Darwin` |
| `ghostty.conf` | `~/.config/ghostty/config` | file exists |

Not linked (repo-only): `README.md`, `scripts/`, `mihomo/`.

**2. Shell startup chains.** Because files are symlinked, editing a repo file
edits the live config.

- bash: `~/.bash_profile` → `~/.profile` → `~/.bashrc` (`bash_profile:3-6`, `profile:16-21`).
- zsh: `~/.zshenv` (locale, every shell) → `~/.zprofile` (PATH, login) → `~/.zshrc` (omz, the main file).
- `bashrc:36` `[ -z "$PS1" ] && return` — everything below it is **interactive-only**; PATH/tool activation above it also applies to non-interactive shells.
- PATH is built by prepending in execution order: `/usr/local/sbin` → Homebrew `shellenv` → `~/.local/bin` → Emacs doom bin → mise/cargo → `$GOPATH/bin`. `zshrc:70-71` (`typeset -U path; path=($path)`) dedupes and **must stay the last PATH operation**.
- Tool activation is existence-gated, not OS-gated: `[ -x /opt/homebrew/bin/brew ]` (`bashrc:7-9`, `zprofile:3-5`), `command -v mise` (`bashrc:20-22`, `zshrc:30-32`), `~/.cargo/env`, `GOPATH=$HOME/go`.
- Shared aliases live in `alias` (→ `~/.alias`), sourced by both shells (`bashrc:64-67`, `zshrc:59-62`). Bash-only aliases stay inline in `bashrc:74-86`; zsh gets `g*` from the omz `git` plugin instead.
- Local escape hatches: `~/.bashrc.local`, `~/.zshrc.local` (machine secrets, deliberately untracked).

**3. Doom Emacs.** `doom.d/init.el` (module tree) → `doom.d/packages.el`
(`package!` declarations, needs `doom sync`) → `doom.d/config.el` (per-package
config). Snippets are auto-discovered from `snippets/<mode-name>/`, no registry.
Only `doom.d/` is tracked; never edit the generated `~/.config/emacs` tree.

**4. mihomo.** `mihomo/template.{phone,router}.yaml` are **hand-edited
templates**; the top-level `proxies:` block is intentionally empty
(`template.phone.yaml:126`, `template.router.yaml:149`) and node credentials
live in the generated on-device config, outside the repo. Both templates wire
`mihomo/ruleset/brokers.yaml` (the one vendored ruleset) back to this repo via a
jsDelivr URL pinned to `@master`.

**5. `bin/` → git subcommands.** `bin/*` is linked into `~/.local/bin` (already
on PATH), which is how `bin/git-rollback` becomes `git rollback`.

## Key Directories

| Path | Purpose |
|---|---|
| `*.conf`, `bashrc`, `zshrc`, `alias`, `gitconfig`, … (repo root) | flat shell/editor/tool configs; each is symlinked to `~/.<name>` |
| `bin/` | helper executables linked to `~/.local/bin`; currently `git-rollback` (POSIX `sh`) |
| `doom.d/` | Doom Emacs: `init.el`, `config.el`, `packages.el` |
| `doom.d/snippets/` | 345 yasnippet files in 24 `<mode>-mode/` dirs (plus `.yas-parents` inheritance files) |
| `mihomo/` | Clash/mihomo templates for phone and router + vendored `ruleset/` |
| `scripts/` | `stow` (linker, the source of truth for what gets linked), `install.sh` (bootstrap) |

## Development Commands

```shell
# Link repo configs into $HOME (overwrites destinations — dry-run first)
scripts/stow --dry-run
scripts/stow

# Bootstrap a machine (idempotent; --skip-brew/--skip-omz/--skip-mise)
bash scripts/install.sh --dry-run
bash -c "$(curl -fsSL https://raw.githubusercontent.com/hbin/dotfiles/master/scripts/install.sh)"

# Apply shell changes in the running shell
exec $SHELL          # or: source ~/.zshrc

# Git identity lives outside the repo (gitconfig includes this untracked file)
git config --file ~/.gitconfig.local user.name "Your Name"
git config --file ~/.gitconfig.local user.email "you@example.com"

# Syntax / validity checks (there is no test suite; use these)
bash -n scripts/stow scripts/install.sh
sh -n bin/git-rollback
zsh -n zshrc zshenv zprofile
python3 -m json.tool karabiner.json
ghostty +show-config && ghostty +list-keybinds      # validates ghostty.conf
python3 -c 'import yaml,sys;[yaml.safe_load(open(f)) for f in sys.argv[1:]]' \
  mihomo/template.phone.yaml mihomo/template.router.yaml mihomo/ruleset/brokers.yaml
shellcheck scripts/stow scripts/install.sh bin/git-rollback   # if installed

# Doom (after editing init.el/packages.el)
~/.config/emacs/bin/doom sync && ~/.config/emacs/bin/doom doctor

# Helper under test
git rollback --dry-run && git rollback --undo
```

## Code Conventions & Common Patterns

**Shell scripts (`scripts/*`).** `#!/usr/bin/env bash`, `set -euo pipefail`,
2-space indent, all side effects behind a dry-run wrapper:

```bash
run() {                       # scripts/stow:15-20, scripts/install.sh:27-33
  if [ "$DRY_RUN" -eq 1 ]; then printf '\033[1;36m[dry-run]\033[0m %s\n' "$*"
  else "$@"; fi
}
```

- Output via `printf` with flat ANSI escapes and prefixed helpers (`log`/`warn`/`die`, or `warn` + stderr `exit 2` for bad usage). No `trap`, no temp files.
- Quote everything (`"$var"`, `"$@"`); config file lists are bash arrays (`scripts/stow:36-39`) — **adding a root config file means adding it to that array**, otherwise it never gets linked.
- Remote installers are wrapped in functions so `--dry-run` cannot execute them (`scripts/install.sh:51-62`).
- Keep to bash 3.2 (macOS default): no associative arrays, `${var,,}`, `mapfile`.

**`bin/*` scripts.** `#!/bin/sh` + `set -eu`, 4-space indent, every helper
prefixed (`gr_` in `git-rollback`) to avoid shadowing system commands, color
auto-disabled when stderr is not a tty / `NO_COLOR` / `TERM=dumb`
(`bin/git-rollback:20-31`). Prefer plain `git` + coreutils; no third-party deps.

**Config files.** Sections separated by a blank line with a comment header, and
comments explain *why* (see `ghostty.conf:22-26`, `bashrc:57`). Preserve
existing grouping and ordering; never mass-reformat. Rebinding/unbinding keys is
done explicitly and the removed default is documented in the comment
(`ghostty.conf:65-66`, `doom.d/config.el:107-116`). mihomo templates use
English YAML keys with Chinese inline comments **and Chinese proxy-group names** —
keep both untranslated.

**Cross-platform.** Shell rc files branch on file/dir existence, not `uname`;
`uname -s` appears only in scripts (`scripts/install.sh:78`,
`scripts/stow:78`). Karabiner and `macos-*`/`mac-*` settings are macOS-only.

**Doom.** `use-package!` with `:defer`/`:commands`/`:requires` is the norm;
package variables must go inside `after!`/`:config` unless `doom-*`/`+*`-prefixed
or file/dir-valued (`doom.d/config.el:51-55`). `doom-*` settings must be set
early in `config.el`. No `map!`/leader keys — the `(evil +everywhere)` module is
disabled (`init.el:55`); bindings are plain `bind-key`/`global-unset-key`.

**Ordering invariants (do not "tidy" away).** `typeset -U path` last in
`zshrc`; `bashrc:36` interactive guard above all aliases/hooks; PATH prepend
order; `use-package! :requires` chains in `config.el`; rule order in
`mihomo/*.yaml` (`MATCH` last, Apple-CN before `geolocation-!cn`,
`template.phone.yaml:436`); `rules[]` order in `karabiner.json` (UI-driven).

**PII and machine-specific values — never normalize, "fix", or commit newly.**
The repo is public, so no owner address is tracked anywhere: Git identity comes
from an untracked `~/.gitconfig.local` via `[include]` (`gitconfig:1-4`), and
`doom.d/config.el:9-10`, `vimrc:2`,
`doom.d/snippets/dockerfile-mode/Dockerfile:9` deliberately carry no email — do
not add one back. Also machine-specific: Karabiner `vendor_id` device
ids (`karabiner.json:17-19`), router LAN `192.168.31.0/24`
(`mihomo/template.router.yaml:11-12`), proxy credentials (must stay out of the
repo), hardcoded `/opt/homebrew` and `/usr/local` brew paths (`globalrc:56,61`).

**Commits.** Imperative subject, `area: summary` when it is scoped — e.g.
`ghostty: drop default Cmd+Shift+W close-window binding`, `mihomo: …, vimrc: …,
bin: …`. One concern per commit.

## Important Files

- `scripts/stow` — linker; owns the destination mapping and the `FILES` array.
- `scripts/install.sh` — bootstrap (preflight → brew → oh-my-zsh + autosuggestions → clone/pull + `stow` → mise); flags `--dry-run`, `--skip-brew`, `--skip-omz`, `--skip-mise`; env overrides `DOTFILES_REPO`, `DOTFILES_DIR`.
- `bin/git-rollback` — `git rollback` implementation (reset-based, pushed-commit guard, `--undo` via `.git/git-rollback-state`, state is per-repo not per-branch).
- `bashrc`, `profile`, `bash_profile`, `zshrc`, `zprofile`, `zshenv`, `alias` — shell entry points; edit the file that owns the concern.
- `gitconfig`, `gitignore_global` — `core.excludesfile`, `g` alias, and an `[include]` of untracked `~/.gitconfig.local` (the only place the user's name/email live — never commit them); no `includeIf` conditionals.
- `doom.d/{init,config,packages}.el` — Emacs entry points; `doom.d/snippets/**` is data, not code.
- `ghostty.conf`, `karabiner.json`, `vimrc`, `ctags`, `globalrc`, `pryrc` — tool configs (`ctags` = Universal/Exuberant ctags options; `globalrc` = GNU GLOBAL/gtags, unrelated to `~/.ctags`).
- `mihomo/template.{phone,router}.yaml` + `mihomo/ruleset/brokers.yaml`, `README.md`.

## Runtime/Tooling Preferences

- Both bash and zsh are first-class and must stay feature-equivalent; keep env setup mirrored in `bashrc` and `zshrc`/`zprofile` (locale is deliberately duplicated in `profile:11-13` and `zshenv:3-5` — add a third copy nowhere).
- No repo-level package manager, formatter, linter, or hook. Runtimes (Node, Python, Go, Ruby, etc.) come from **mise** at shell startup; helpers belong in `bin/`.
- `python3` is used only for ad-hoc validation; do not add Python/Node tooling to the repo for it.
- Karabiner-Elements rewrites `karabiner.json` itself (ordering/formatting), and mihomo clients persist runtime state (`store-selected: true`) — treat the on-disk file after an app-side edit as authoritative and re-sync instead of overwriting blindly.
- Never run `scripts/stow` or `scripts/install.sh` as a side effect of an edit: they mutate `$HOME` (including `rm -rf ~/.doom.d`) with no backup. Use `--dry-run`.

## Testing & QA

There are **no tests, no CI, no lint config, and no git hooks** in this repo
(`.github/`, `.editorconfig`, `.shellcheckrc`, `.pre-commit-config.yaml`,
`Makefile`, `tests/` — none exist; `.git/hooks/` holds only `*.sample`). Quality
gates are therefore syntactic plus one live check of the changed behavior:

| Change | Verify with |
|---|---|
| `scripts/stow`, `scripts/install.sh` | `bash -n` + `scripts/stow --dry-run`; confirm the new path appears in the printed link set |
| `bin/*` | `sh -n`, then run the helper for real (`git rollback --dry-run`, `git rollback --undo`) |
| shell rc files | `zsh -n` / `bash -n`, then `exec $SHELL` and confirm the exported value (`echo $PATH`, `alias …`) |
| `ghostty.conf` | `ghostty +show-config` (loads the file) and `ghostty +list-keybinds` (shows effective bindings) |
| `karabiner.json` | `python3 -m json.tool karabiner.json`; on macOS re-open the Karabiner UI and confirm the rule list matches |
| `mihomo/*.yaml` | `yaml.safe_load` all three files, then reload the profile on the device |
| `doom.d/init.el`, `packages.el` | `doom sync` (restart Emacs) then `doom doctor`; `config.el` alone only needs `M-x doom/reload` |

Expectations: add no test infrastructure for a config change; do not reformat
files or "fix" unrelated values; keep each change scoped to the config file that
owns the concern, and update `README.md`'s path/purpose table when adding or
renaming a tracked config.
