#!/usr/bin/env bash
# Symlink dotfiles into place. Idempotent; backs up any existing real files.
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

link() {
  local src="$1" dest="$2"
  mkdir -p "$(dirname "$dest")"
  if [ -L "$dest" ]; then
    rm "$dest"                         # replace an existing symlink
  elif [ -e "$dest" ]; then
    echo "Backing up existing $dest -> $dest.bak"
    mv "$dest" "$dest.bak"
  fi
  ln -s "$src" "$dest"
  echo "Linked $dest -> $src"
}

# --- Ghostty ---------------------------------------------------------------
# macOS reads the app-support path; Linux/other uses the XDG path.
case "$(uname -s)" in
  Darwin) GHOSTTY_DEST="$HOME/Library/Application Support/com.mitchellh.ghostty/config" ;;
  *)      GHOSTTY_DEST="${XDG_CONFIG_HOME:-$HOME/.config}/ghostty/config" ;;
esac
link "$DOTFILES_DIR/ghostty/config" "$GHOSTTY_DEST"

echo "Done."
