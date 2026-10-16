#!/usr/bin/env bash
# Bootstrap installer for my dotfiles (macOS + Linux).
#
# One-liner:
#   bash -c "$(curl -fsSL https://raw.githubusercontent.com/hbin/dotfiles/master/scripts/install.sh)"
#
# Use `bash -c "$(curl ...)"` rather than `curl ... | bash`: the former keeps
# stdin attached to your terminal, so the sudo/prompt-driven installers below
# still work.
#
# Every step is idempotent — re-running is safe. Existing dotfiles are simply
# symlinked over; anything already at a destination path is overwritten.

set -euo pipefail

REPO_URL="${DOTFILES_REPO:-https://github.com/hbin/dotfiles.git}"
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
DRY_RUN=0
SKIP_BREW=0
SKIP_OMZ=0
SKIP_MISE=0

log()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[!]\033[0m %s\n' "$*"; }
die()  { printf '\033[1;31m[x]\033[0m %s\n' "$*" >&2; exit 1; }

run() {
  if [ "$DRY_RUN" -eq 1 ]; then
    printf '\033[1;36m[dry-run]\033[0m %s\n' "$*"
  else
    "$@"
  fi
}

usage() {
  cat <<'EOF'
Usage: install.sh [options]

  --dry-run        Print what would happen, change nothing
  --skip-brew      Do not install/verify Homebrew
  --skip-omz       Do not install oh-my-zsh
  --skip-mise      Do not install mise
  -h, --help       This help

Environment overrides:
  DOTFILES_REPO    Git URL to clone (default: GitHub)
  DOTFILES_DIR     Where to clone (default: ~/dotfiles)
EOF
}

# Installers are wrapped in functions so that --dry-run never even downloads
# them (a bare "$(curl ...)" argument would run during argument evaluation).
install_homebrew() {
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}
install_oh_my_zsh() {
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}
install_mise() {
  sh -c "$(curl -fsSL https://mise.run)"
}

while [ $# -gt 0 ]; do
  case "$1" in
    --dry-run)    DRY_RUN=1 ;;
    --skip-brew)  SKIP_BREW=1 ;;
    --skip-omz)   SKIP_OMZ=1 ;;
    --skip-mise)  SKIP_MISE=1 ;;
    -h|--help)    usage; exit 0 ;;
    *)            die "unknown option: $1 (try --help)" ;;
  esac
  shift
done

OS="$(uname -s)"
log "Platform: $OS"
[ "$OS" = "Darwin" ] || [ "$OS" = "Linux" ] || die "unsupported platform: $OS"

# ---------------------------------------------------------------- 1. preflight

log "Checking base tools (git, curl)"
if [ "$OS" = "Darwin" ] && ! xcode-select -p >/dev/null 2>&1; then
  warn "Xcode command line tools are missing (git needs them)."
  run xcode-select --install
  die "Re-run this script once the command line tools finish installing."
fi
for cmd in git curl; do
  command -v "$cmd" >/dev/null 2>&1 || die "$cmd is required but not installed"
done

# ---------------------------------------------------------------- 2. Homebrew

if [ "$SKIP_BREW" -eq 1 ]; then
  log "Skipping Homebrew (--skip-brew)"
elif command -v brew >/dev/null 2>&1 || [ -x /opt/homebrew/bin/brew ] || [ -x /usr/local/bin/brew ]; then
  log "Homebrew already installed, skipping"
else
  log "Installing Homebrew"
  run install_homebrew
fi

# ---------------------------------------------------------------- 3. oh-my-zsh

if [ "$SKIP_OMZ" -eq 1 ]; then
  log "Skipping oh-my-zsh (--skip-omz)"
elif [ -d "$HOME/.oh-my-zsh" ]; then
  log "oh-my-zsh already installed, skipping"
else
  log "Installing oh-my-zsh (keeping any existing ~/.zshrc)"
  # RUNZSH/CHSH: do not drop into a shell or change the login shell.
  # KEEP_ZSHRC: do not overwrite ~/.zshrc — ours is symlinked in later.
  run install_oh_my_zsh
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
if [ -d "$HOME/.oh-my-zsh" ] && [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
  log "Installing zsh-autosuggestions"
  run git clone --depth 1 \
    https://github.com/zsh-users/zsh-autosuggestions \
    "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

# ------------------------------------------------------- 4. dotfiles + symlinks

if [ -d "$DOTFILES_DIR/.git" ]; then
  log "Updating existing checkout at $DOTFILES_DIR"
  run git -C "$DOTFILES_DIR" pull --ff-only
else
  log "Cloning dotfiles into $DOTFILES_DIR"
  run git clone "$REPO_URL" "$DOTFILES_DIR"
fi

if [ "$DOTFILES_DIR" != "$HOME/dotfiles" ]; then
  log "Linking from $DOTFILES_DIR (not ~/dotfiles)"
fi

# scripts/stow is self-contained: it overwrites whatever is already at each
# destination path, so there is nothing to prepare here.
log "Linking dotfiles (scripts/stow)"
run env DOTFILES_DIR="$DOTFILES_DIR" bash "$DOTFILES_DIR/scripts/stow"

# ---------------------------------------------------------------- 5. mise

if [ "$SKIP_MISE" -eq 1 ]; then
  log "Skipping mise (--skip-mise)"
elif command -v mise >/dev/null 2>&1; then
  log "mise already installed, skipping"
else
  log "Installing mise"
  run install_mise
fi

# ---------------------------------------------------------------- done

log "Done."
cat <<EOF

Next steps:
  - Start a new shell (or run: exec \$SHELL) to load the new config.
  - Optional: run 'mise install' to install the runtimes listed in
    ~/.config/mise/config.toml.
  - macOS only: install Karabiner-Elements yourself if you use it
    (brew install --cask karabiner-elements). Its config is already
    symlinked to ~/.config/karabiner/karabiner.json.
EOF
