# Repository Guidelines

## What this is

Personal dotfiles for macOS + Linux: shell, Git, Vim, Emacs Doom, Ghostty,
Karabiner, and assorted tool configs (371 tracked files). There is no build
step, package manifest, test suite, or CI — the files themselves are the
deliverable, symlinked into `$HOME` by `scripts/stow`.

Single user, single branch (`master`, remote `git@github.com:hbin/dotfiles.git`).

## Layout

| Path | What it is | Linked to |
|---|---|---|
| `alias`, `bashrc`, `bash_profile`, `gitconfig`, `gitignore_global`, `profile`, `pryrc`, `vimrc`, `zprofile`, `zshenv`, `zshrc` | flat shell/editor/tool configs | `~/.<name>` |
| `bin/` | helper executables (`git-rollback`) | `~/.local/bin/<name>` |
| `doom.d/` | Doom Emacs config and snippets | `~/.doom.d` |
| `karabiner.json` | Karabiner-Elements remaps (macOS only) | `~/.config/karabiner/karabiner.json` |
| `ghostty.conf` | Ghostty terminal config | `~/.config/ghostty/config` |
| `mihomo/` | Clash/mihomo proxy templates | repo-only |
| `scripts/` | `stow` (linker) and `install.sh` (bootstrap) | repo-only |
| `AGENTS.md`, `README.md` | agent and user docs | repo-only |

`README.md` holds the user-facing quick start and a path/purpose table; keep it
in sync when a tracked config is added, renamed, or removed.

## Linking (`scripts/stow`)

A hand-rolled stow replacement (no GNU stow, no `.stowrc`):

- **Destinations are overwritten, with no backup** — `ln -sfn`, and `~/.doom.d`
  is `rm -rf`'d first, which is also what stops `ln -n` from nesting the link
  inside a real directory.
- All side effects go through `run()`, so `--dry-run` is the safe preview.
  Never run `scripts/stow` as a side effect of an edit.
- Only the source is gated, never the destination: a missing source is skipped
  with a warning. Root configs, `bin/`, `doom.d/`, and `ghostty.conf` are linked
  when present; `karabiner.json` only on Darwin.

`bin/*` lands in `~/.local/bin` (already on `PATH`), which is why
`bin/git-rollback` becomes `git rollback` — git resolves `git-<subcommand>`
via `PATH`.

**Adding a tracked config:** put the file at the repo root, add its bare name to
the `FILES` array in `scripts/stow` (otherwise it is never linked), and add a
row to README's path table. Verify with `scripts/stow --dry-run`.

## Shells

- bash: `~/.bash_profile` → `~/.profile` → `~/.bashrc`. `bashrc` returns early
  for non-interactive shells, so PATH/tool activation stays above that guard and
  aliases/hooks below it.
- zsh: `~/.zshenv` (locale, every shell) → `~/.zshrc` (PATH, oh-my-zsh,
  then user config). `zprofile` was removed: its brew PATH block moved into
  `zshrc`, which every interactive zsh reads. Non-interactive zsh never reads
  `.zshrc`, so no guard is needed.
- PATH is built by prepending: `/usr/local/sbin`, Homebrew, `~/.local/bin`,
  Doom's bin, mise/cargo, `$GOPATH/bin` — later steps win. `zshrc`'s
  `typeset -U path` dedupes and must stay the last PATH operation.
- Tool activation is existence-gated, never `uname`-gated: test for the
  binary/path (`brew`, `mise`, `~/.cargo/env`, `$HOME/go`). `uname -s` belongs
  in `scripts/` only.
- Both shells are first-class: mirror environment changes in `bashrc` and
  `zshrc`/`zprofile`. Locale is deliberately duplicated in `profile` and
  `zshenv`; add a third copy nowhere.
- Shared aliases live in `alias` (sourced by both shells); bash-only aliases
  stay in `bashrc`; zsh gets `g*`, `brew`, and `bundler` from oh-my-zsh
  plugins.
- Machine-local overrides go in the untracked `~/.bashrc.local` /
  `~/.zshrc.local`, sourced last.

## Doom Emacs

`doom.d/init.el` (modules) → `packages.el` (`package!`; needs `doom sync`) →
`config.el` (per-package config; `M-x doom/reload` suffices). Snippets are
auto-discovered from `doom.d/snippets/<name>/` — 336 snippet files in 24
directories plus 9 `.yas-parents` inheritance files; there is no registry. Only
`doom.d/` is tracked; never edit the generated `~/.config/emacs` tree.

Conventions: `use-package!` with `:defer`/`:commands`/`:requires`; set `doom-*`
variables early in `config.el`; the `(evil +everywhere)` module is disabled, so
use plain `bind-key`/`global-unset-key` rather than `map!`. Do not reorder
`:requires` chains.

## Secrets and PII

The repo is public.

- Never commit API keys, tokens, passwords, database URLs, or private keys.
  Machine-local secrets belong in the untracked `~/.bashrc.local` /
  `~/.zshrc.local`.
- There is **no root `.gitignore` today**; ignore behavior comes from
  `core.excludesfile = ~/.gitignore_global` (see `gitconfig`). If a file type
  could hold a credential (`.env`, `*.pem`, …), create a root `.gitignore` with
  that pattern in the same change that introduces the file type, so it fails
  safe.
- No owner name/email is tracked: Git identity comes from an untracked
  `~/.gitconfig.local` included by `gitconfig`. Do not add an address back to
  `doom.d/config.el`, `vimrc`, or the snippets.
- Machine-specific values (Karabiner device ids, proxy/server values in
  `mihomo/` and tool configs) are intentional. Cite them by file — never copy
  the literals into docs, commits, or issues.

## Commands

```shell
scripts/stow --dry-run            # preview; then scripts/stow to apply
bash scripts/install.sh --dry-run # bootstrap; --skip-brew/--skip-omz/--skip-mise
                                  # env overrides: DOTFILES_REPO, DOTFILES_DIR
exec $SHELL                       # apply shell changes to the current shell
```

Syntax/validity checks (there is no test suite):

```shell
bash -n scripts/stow scripts/install.sh
sh -n bin/git-rollback
zsh -n zshrc zshenv zprofile && bash -n bashrc bash_profile profile alias
python3 -m json.tool karabiner.json
/Applications/Ghostty.app/Contents/MacOS/ghostty +show-config  # if not on PATH
~/.config/emacs/bin/doom sync && ~/.config/emacs/bin/doom doctor
```

Pair each change with one live check of that behavior: `stow --dry-run` shows
the new link, `git rollback --dry-run`/`--undo` exercises the helper,
`ghostty +show-config`/`+list-keybinds` validates the terminal config. Skip
checks whose tool is absent (`doom`, `shellcheck`) — do not install them.

## Conventions

- **Scripts:** bash scripts use `#!/usr/bin/env bash`, `set -euo pipefail`,
  2-space indent, and keep `run()` identical in `stow` and `install.sh`. Stay
  bash 3.2 compatible (no associative arrays, `mapfile`, `${var,,}`). `bin/*`
  is POSIX `sh` with `set -eu`, 4-space indent, and a command prefix (`gr_` in
  `git-rollback`) to avoid shadowing system commands.
- **Formatting:** manual and opt-in. `shfmt -i 2` for `scripts/*` and `shfmt
  -i 4` for `bin/*` is fine as its own commit (e.g. `scripts: apply shfmt`);
  never reformat files you are not otherwise changing.
- **Configs:** sections separated by a blank line with a comment header;
  comments explain *why*. Preserve existing grouping and ordering — never
  mass-reformat. Document any default keybinding that is removed or rebound.
- **Do not reorder:** PATH prepend order, `typeset -U path`, `:requires`
  chains, or the `rules[]` array in `karabiner.json` (Karabiner's UI owns it;
  treat its on-disk rewrite as authoritative).
- **Commits:** imperative subject, `area: summary` when scoped (e.g.
  `zshrc: move history into ~/.cache/zsh`); one concern per commit. Keep each
  commit simple and neat — related files only, no incidental reformatting,
  drive-by fixes, or unrelated files, so it is easy to review and revert.
  **Always show the staged diff (`git diff --cached`) and wait for approval
  before committing** — never commit unreviewed changes.

## Never

- Run `scripts/stow` or `scripts/install.sh` as a side effect of an edit — they
  mutate `$HOME` with no backup (including `rm -rf ~/.doom.d`). Use `--dry-run`.
- Commit secrets or personal data, or copy machine-specific literals into docs,
  commits, or issues.
- Edit the generated `~/.config/emacs` tree.
- Bundle new tooling (tests, CI, formatter/linter config) into an unrelated
  config change — it belongs in its own scoped change.
