#!/usr/bin/env bash
# Set a text editor as the default application for common text and source
# formats.
#
# Associations are normally limited to the selected app's declared UTIs and
# filename extensions. PLAIN_TEXT_EXTENSIONS covers text formats an editor can
# open without declaring them. Ambiguous extensions (notably `ts`, which macOS
# may treat as a transport stream) are handled by UTI only.
#
# Usage: scripts/set-default-editor.sh [--app NAME|PATH] [--dry-run|--check]

set -euo pipefail

APP_ARG="${DEFAULT_EDITOR_APP:-TextEdit}"
DRY_RUN=0
CHECK_ONLY=0

run() {
  if [ "$DRY_RUN" -eq 1 ]; then
    printf '\033[1;36m[dry-run]\033[0m %s\n' "$*"
  else
    "$@"
  fi
}

die() { printf '\033[1;31m[x]\033[0m %s\n' "$*" >&2; exit 1; }

usage() {
  cat <<'EOF'
Usage: set-default-editor.sh [options]

  --app NAME|PATH  Application name, shorthand, or path (default: TextEdit)
  --dry-run        Print the associations without changing anything
  --check          Show the current default app for common extensions
  -h, --help       This help

Environment:
  DEFAULT_EDITOR_APP  Default application name, shorthand, or path
EOF
}

# Candidate types are filtered against the selected app's own Info.plist.
# This avoids assigning formats such as JSON or TOML to TextEdit, which cannot
# open them, while still letting richer editors claim the full list.
UTIS=(
  # Plain text and configuration
  public.plain-text
  public.json
  public.yaml
  public.toml
  com.microsoft.ini
  public.comma-separated-values-text
  public.tab-separated-values-text
  public.patch-file

  # Markup and documentation
  net.daringfireball.markdown
  com.textpattern.textile
  org.python.restructuredtext
  org.tug.tex
  org.tug.bibtex.bib
  public.xml

  # Shell and scripting
  public.shell-script
  public.bash-script
  public.zsh-script
  public.python-script
  public.ruby-script
  public.perl-script
  public.php-script
  org.lua.lua-source

  # Compiled languages
  public.c-source
  public.c-header
  public.c-plus-plus-source
  public.c-plus-plus-header
  public.objective-c-source
  public.objective-c-plus-plus-source
  com.microsoft.c-sharp
  public.swift-source
  com.sun.java-source
  org.kotlinlang.source
  org.golang.go-script
  org.rust-lang.rust-script
  org.scala-lang.scala-source
  org.haskell.haskell-script
  org.dlang.d-source
  dev.dart.dart-script
  public.fortran-source
  org.julia.julia-script

  # Web source (HTML and SVG stay with the browser)
  com.netscape.javascript-source
  public.css

  # Query languages
  org.iso.sql
)

CHECK_EXTENSIONS=(
  txt text md markdown json yaml yml toml ini conf cfg
  sh bash zsh py rb php pl lua el
  c h cc cpp cxx hpp hxx m mm
  swift java kt kts cs go rs
  js mjs cjs jsx
  css scss sass less xml sql csv tsv
  tex bib patch diff
)

# Extensions let apps that register documents by filename (like Zed) receive
# the same coverage as apps that declare explicit UTIs.
EXTENSIONS=(
  txt text
  md markdown
  json yaml yml toml ini conf
  sh bash zsh
  py rb php pl lua
  c h cc cpp cxx hpp hxx m mm
  swift java kt kts cs go rs
  js mjs cjs jsx ts tsx
  css xml sql csv tsv
  tex bib patch diff
)

# Text formats CotEditor can edit even when they are absent from its
# Info.plist. Keep this list narrow and add new formats here.
PLAIN_TEXT_EXTENSIONS=(
  el
)

while [ $# -gt 0 ]; do
  case "$1" in
    --app)
      [ $# -ge 2 ] || die "--app requires a name or path"
      APP_ARG="$2"
      shift
      ;;
    --app=*)      APP_ARG="${1#*=}" ;;
    -n|--dry-run) DRY_RUN=1 ;;
    --check)      CHECK_ONLY=1 ;;
    -h|--help)    usage; exit 0 ;;
    *)            die "unknown option: $1 (try --help)" ;;
  esac
  shift
done

[ "$(uname -s)" = "Darwin" ] || die "file associations are macOS-only"
command -v duti >/dev/null 2>&1 || die "duti is required (brew install duti)"

if [ "$CHECK_ONLY" -eq 1 ]; then
  printf '%-8s %s\n' "EXT" "DEFAULT APP"
  for ext in "${CHECK_EXTENSIONS[@]}"; do
    app="$(duti -x "$ext" 2>/dev/null | head -n 1 || true)"
    printf '%-8s %s\n' "$ext" "${app:-not associated}"
  done
  exit 0
fi

resolve_app() {
  local app="$1"
  case "$app" in
    "VS Code"|"VSCode"|vscode|code) app="Visual Studio Code" ;;
  esac

  case "$app" in
    /*)
      [ -d "$app" ] || die "application not found: $app"
      printf '%s\n' "$app"
      return
      ;;
    *.app)
      for dir in /Applications "$HOME/Applications"; do
        [ -d "$dir/$app" ] || continue
        printf '%s\n' "$dir/$app"
        return
      done
      [ -d "/System/Applications/$app" ] || die "application not found: $app"
      printf '%s\n' "/System/Applications/$app"
      return
      ;;
  esac

  for dir in /Applications "$HOME/Applications"; do
    [ -d "$dir/$app.app" ] || continue
    printf '%s\n' "$dir/$app.app"
    return
  done
  [ -d "/System/Applications/$app.app" ] && {
    printf '%s\n' "/System/Applications/$app.app"
    return
  }
  die "application not found: $app (try an absolute .app path)"
}

APP_PATH="$(resolve_app "$APP_ARG")"
INFO_PLIST="$APP_PATH/Contents/Info.plist"
[ -f "$INFO_PLIST" ] || die "not an application bundle: $APP_PATH"
BUNDLE_ID="$(plutil -extract CFBundleIdentifier raw -o - "$INFO_PLIST" 2>/dev/null)" ||
  die "cannot read bundle identifier: $INFO_PLIST"
[ -n "$BUNDLE_ID" ] || die "missing bundle identifier: $INFO_PLIST"
APP_NAME="${APP_PATH##*/}"
APP_NAME="${APP_NAME%.app}"

DOCUMENT_TYPES="$(plutil -extract CFBundleDocumentTypes json -o - "$INFO_PLIST")" ||
  die "cannot read document types: $INFO_PLIST"

SUPPORTED_UTIS=()
for uti in "${UTIS[@]}"; do
  if printf '%s\n' "$DOCUMENT_TYPES" | grep -Fq "\"$uti\""; then
    SUPPORTED_UTIS[${#SUPPORTED_UTIS[@]}]="$uti"
  fi
done

SUPPORTED_EXTENSIONS=()
for ext in "${EXTENSIONS[@]}"; do
  case "$ext" in
    txt|md|markdown|json|toml|py|cs|c|h|cpp|hpp|go|rs|js|jsx|tsx|css|xml|sql)
      ;;
    *) continue ;;
  esac
  if printf '%s\n' "$DOCUMENT_TYPES" | grep -Fq "\"$ext\""; then
    SUPPORTED_EXTENSIONS[${#SUPPORTED_EXTENSIONS[@]}]="$ext"
  fi
done

if printf '%s\n' "$DOCUMENT_TYPES" | grep -Fq '"public.plain-text"'; then
  for ext in "${PLAIN_TEXT_EXTENSIONS[@]}"; do
    SUPPORTED_EXTENSIONS[${#SUPPORTED_EXTENSIONS[@]}]="$ext"
  done
fi

[ "${#SUPPORTED_UTIS[@]}" -gt 0 ] || [ "${#SUPPORTED_EXTENSIONS[@]}" -gt 0 ] ||
  die "$APP_NAME does not declare any supported text document types"

failed=()
for uti in "${SUPPORTED_UTIS[@]}"; do
  if ! run duti -s "$BUNDLE_ID" "$uti" all; then
    failed[${#failed[@]}]="$uti"
  fi
done

for ext in "${SUPPORTED_EXTENSIONS[@]}"; do
  if ! run duti -s "$BUNDLE_ID" "$ext" all; then
    failed[${#failed[@]}]="$ext"
  fi
done

if [ "$DRY_RUN" -eq 1 ]; then
  printf '[dry-run] would set %d handlers to %s (%d UTIs, %d extensions)\n' \
    "$((${#SUPPORTED_UTIS[@]} + ${#SUPPORTED_EXTENSIONS[@]}))" \
    "$BUNDLE_ID" "${#SUPPORTED_UTIS[@]}" "${#SUPPORTED_EXTENSIONS[@]}"
  exit 0
fi

if [ "${#failed[@]}" -gt 0 ]; then
  printf '\033[1;33m[!]\033[0m %d associations were rejected:\n' "${#failed[@]}" >&2
  printf '  %s\n' "${failed[@]}" >&2
  exit 1
fi

printf 'Set %d text associations to %s.\n' \
  "$((${#SUPPORTED_UTIS[@]} + ${#SUPPORTED_EXTENSIONS[@]}))" "$APP_NAME"
printf 'Run %s --check to inspect common extensions.\n' "$0"
printf 'HTML, SVG, and extensionless dotfiles are unchanged.\n'
